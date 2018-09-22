# Silas spiking data analyzer
# version Oct 30 2017
require(ggplot2)
require(dplyr)
require(reshape2)
library(lmerTest)
rm(list = ls())  # Clear workspace

# ----- Read and prepare spike data ----
d = read.table("C:/Users/Arseny/Documents/5_Dynamic clamp/out 20171025.txt",header=T)
d = subset(d,is.element(Group,c(0,1,2,3,4,5))) # Remove slow and naive
d = mutate(d,Group = recode_factor(Group,"0"="Control","2"="Flash","1"="Looming",
                "3"="Sound","4"="Sync","5"="Async","6"="Slowc","7"="Slowf","8"="Naive"))
d = mutate(d,ShapeName = recode_factor(Shape,"1"="100","2"="200","3"="500","4"="1000"))

# Only leave good new crashes and flashes; exclude the bad old ones
# (where "bad old" are all old cells that don't belong to Naive group)
d$Old = ifelse(d$Cell<=102,"Old","New") # TRUE if the cell is old
d$Old = factor(d$Old)
d = subset(d,Old=="New")
# d = subset(d,(is.element(Group,"Naive")) | (Old=="New"))


# ----- Some simple analysis  ----
# Count cell numbers:
summarize(group_by(d,Group,Old), count = length(unique(Cell)))
names(d)

ds = summarize(group_by(d,Cell,Amp,Shape),Spikes=mean(Spikes))

# Fit spike-curves, to quantify them with 3 parameters for each cell
d1 = d %>% group_by(Cell) %>% 
  do(fsa=lm(Spikes ~ (Amp-1),.),
     fss=lm(Spikes~Shape+I(Shape^2),.),
     ms=mean(.$Spikes)) %>% as_data_frame() %>%
  summarize(Cell=Cell,ms=ms,sa=coef(fsa)[2],ss=coef(fss)[3],ms2=coef(fsa)[1])
head(d1)
# Sence-check if mean term is different than simple mean
ggplot() + theme_bw() + geom_point(data=d1,aes(ms,ms2)) # Basically the same, doesn't matter

# Testbed for these strange lm formulas
t = c(1,2,3,4)-1
y = c(0,1,2,3); lm(y~t + I(t^2)) # 0 (linear)
y = c(0,1,1,1); lm(y~t + I(t^2)) # -0.25 (plato)
y = c(0,1,2,2); lm(y~t + I(t^2)) # -0.25 (also plato)
y = c(1,2,3,2); lm(y~t + I(t^2)) # -0.5 (decline)
y = c(1,2,2,1); lm(y~t + I(t^2)) # -0.5 (also decline)
y = c(1,2,2,3); lm(y~t + I(t^2)) # ~0 (antisigmoid)
y = c(1,1,3,3); lm(y~t + I(t^2)) # ~0 (sigmoid)
y = c(0,1,2,4); lm(y~t + I(t^2)) # 0.25 (accelerator)
y = c(1,1,3,2); lm(y~t + I(t^2)) # -0.25 (accelerator followed by a drop)
qplot(t,y,shape=I(1)) + theme_classic() + geom_line() + ylim(c(0,4))
mean(y)

## Checking whether fancy quadratic estimation makes sense.
## Conclusion: yes, it does capture the shape, and is better than a simpler measure
dss = summarize(group_by(ds,Cell,Shape),spikes=mean(Spikes))
dssc = dcast(dss,Cell ~ Shape, value.var="spikes")
dssc$bend = dssc[[5]]-dssc[[4]]
head(dssc)
summary(dssc)
dfull = merge(d1,dssc,by="Cell")
head(dfull)
ggplot() + theme_bw() + geom_point(data=dfull,aes(ss,bend))

# Output
write.csv(d1,"C:/Users/Arseny/Documents/5_Dynamic clamp/spike shapes.txt",row.names=F)

d2 = inner_join(ds,d1,by="Cell")
# Just plot everything
ggplot(mutate(d2,ssign=(ss<0))) + theme_bw() +
  geom_line(aes(Shape,Spikes,group=interaction(Cell,Amp))) + 
  facet_grid(ssign~Amp)
# Check whether different ss values look differently
ggplot(mutate(d2,ssgroup=floor(ss*5))) + theme_bw() +
  geom_line(aes(Shape,Spikes,group=interaction(Cell,Amp))) + 
  facet_grid(.~ssgroup)

### Summary at cell level (semi-raw)
# d_cell = ddply(d,c("Amp","Shape","Group","Cell"), function(x) {
#   data.frame(Spikes=mean(x$Spikes),
#              ci=sd(x$Spikes)/sqrt(length(x$Spikes))*qt(0.025,df=length(x$Spikes)-1))
# })
# ggplot(data=d_cell, aes(Shape,1+Spikes,color=Shape)) + theme_bw() + 
#   facet_grid(Amp~Group) + scale_y_log10() +
#   geom_point(alpha=0.2,size=3) +
#   theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank());

### Summary at treatment level (very aggregated)
# Summary plot with CI error bars (aka "main plot of the poster")
d_sum = summarize(group_by(d,Group,Amp,Shape),
            sn = ShapeName[1],
            m=mean(Spikes),
            n = n(),
            s = sd(Spikes),
            ci=sd(Spikes)/sqrt(n)*qt(0.025,df=n-1))
d_sum$Amp = factor(d_sum$Amp)
ggplot(data=d_sum, aes(sn,m,color=Amp,group=Amp)) + 
  theme_bw() + theme(text=element_text(size=8)) + 
  facet_grid(.~Group) +
  geom_line() + geom_errorbar(aes(ymin=m-ci,ymax=m+ci),width=0.1) +
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank()) +
  xlab('Conductance curve length, ms') + ylab('Number of spikes')

# Summary plot showing changes vs control (not very pretty, due to CI overlap)
require(dplyr)
d_diff = d_sum %>% group_by(Amp,Shape) %>% 
  mutate(diff = m[Group=="Control"]-m , 
         diffci = sqrt(ci^2 + ci[Group=="Control"]^2))
ggplot(data=subset(d_diff,Group!="Control"), aes(sn,diff,color=Amp,group=Amp)) + 
  theme_bw() + theme(text=element_text(size=8)) + 
  facet_grid(.~Group) +
  geom_line() + geom_errorbar(aes(ymin=diff-diffci,ymax=diff+diffci),width=0.1) +
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank()) +
  xlab('Conductance curve length, ms') + ylab('Spike suppression')

# Compare any set of groups to each other
# Uncomment any of the options below
#ds = subset(d,is.element(Group,c("Control","Flash","Looming")))
#ds = subset(d,is.element(Group,c("Flash","Sound","Sync","Async")))
# ds = subset(d,is.element(Group,c("Control","Flash")))
# ds = subset(d,is.element(Group,c("Control","Looming")))
# ds = subset(d,is.element(Group,c("Flash","Looming")))
#ds = subset(d,is.element(Group,c("Control","Async")))
# ds = subset(d,is.element(Group,c("Control","Sou#nd")))
#ds = subset(d,is.element(Group,c("Flash","Sound")))
ds = subset(d,is.element(Group,c("Flash","Sync")))
ds = subset(d,is.element(Group,c("Flash","Async")))
# ds = d # To compare all
dsflat <- ds %>% group_by(Group,Cell,Amp,Shape) %>% summarize(Spikes=mean(Spikes,na.rm=T))
summary(aov(data=dsflat,Spikes~Group + Group*Shape + Group*Amp + Cell)) # Repeated measures
# Sense-check:
# anova(lmer(data=ds,Spikes~Group*Shape + Group*Amp + (1+Shape+Amp|Cell),na.action=na.omit)) # Interactions
# Except that aov is sequential, while lmer is typeIII (marginal with interactions included)
# Summarize data:
ds %>% group_by(Group,Cell) %>% summarize(spikes=mean(Spikes),na.rm=T) %>%
  group_by(Group) %>% summarize(n=n(),m=mean(spikes),s=sd(spikes))

dsum = summarize(group_by(ds,Group,Shape,Amp),m=mean(Spikes,na.rm=T))
# Version that looks pretty
ggplot(data=ds, aes(Shape,Spikes,color=Group)) + theme_bw() + 
  facet_grid(Group~Amp) + 
  stat_summary(fun.y="mean",aes(group=Cell),geom="line",alpha=0.5) +
  geom_line(data=dsum,aes(Shape,m,group=Group),color="black") +
  geom_point(data=dsum,aes(Shape,m,group=Group),color="black") + ylim(0,4)
# Version for illustrator
ggplot(data=ds, aes(Shape,Spikes,color=Group)) + theme_bw() + 
  facet_grid(Group~Amp) + 
  stat_summary(fun.y="mean",aes(group=Cell),geom="line") +
  geom_line(data=dsum,aes(Shape,m,group=Group),color="black") +
  geom_point(data=dsum,aes(Shape,m,group=Group),color="black",shape=1) + ylim(0,4)
# Direct comparison
ggplot(data=ds, aes(Group,Spikes,color=Group)) + theme_bw() + 
  facet_grid(Shape~Amp) + 
  stat_summary(fun.y="mean",aes(group=Cell),geom="point",alpha=0.5) +
  geom_line(data=dsum,aes(Group,m,group=Shape),color="black") +
  geom_point(data=dsum,aes(Group,m),color="black") + ylim(0,4)

# Compare flashes - to crashes - to controls
ds = subset(d,is.element(Group,c("Control","Flash","Looming")))
ggplot(data=ds, aes(Shape,Spikes,color=Group,group=Group)) + theme_classic() + 
  facet_grid(Amp~.) +  stat_summary(fun.y="mean",geom="line")
m = aov(data=ds,Spikes~Shape*Amp + Shape*Group + Amp*Group)
summary(m)
TukeyHSD(m,which="Amp:Group")



# Unpublished technical sub-analysis: old vs new data groups for flashes and crashes
ds = subset(d,is.element(Group,c("Crash","Flash")))
ggplot(data=ds, aes(Shape,Spikes,color=Group,group=Group)) + theme_bw() + 
  facet_grid(Amp~Old) +  stat_summary(fun.y="mean",geom="line") # Summary curves
ggplot(data=subset(ds,Amp==2), aes(Shape,Spikes,color=Group,group=Group)) + theme_bw() + 
  facet_grid(Group~Old) +  geom_point(alpha=0.5,position = position_jitter(w = 0.3, h = 0.3)) # All points
summary(aov(data=subset(ds,Old==FALSE),Spikes~Shape*Amp + Shape*Group + Group)) # Analysis within new group only
summary(aov(data=subset(ds,Old==TRUE),Spikes~Shape*Amp + Shape*Group + Group))  # Analysis within old group only
summary(aov(data=ds,Spikes~Shape*Amp + Shape*Group + Group)) # Both groups combined
ddply(ds,c("Group","Old"), summarize, length(unique(Cell)))  # Number of cells in each subgroup

# Unpublished: Compare slow flashes to slow crashes
ds = subset(d,is.element(Group,c("Slow crash","Slow flash")))
summary(aov(data=ds,Spikes~Shape*Amp + Shape*Group + Amp*Group))
ggplot(data=ds, aes(Shape,Spikes,color=Group,group=Group)) + theme_bw() + 
  facet_grid(Amp~.) +  stat_summary(fun.y="mean",geom="line")
ddply(ds,c("Group"), summarize, length(unique(Cell)))

# Compare sound to control
ds = subset(d,is.element(Group,c("Control","Sound")))
summary(aov(data=ds,Spikes~Shape*Amp + Shape*Group + Amp*Group + Cell*Shape*Amp)) # Optimistic repeated
ggplot(data=ds, aes(Shape,Spikes,color=Group,group=Group)) + theme_bw() + 
  facet_grid(.~Amp) +  stat_summary(fun.y="mean",geom="line")

# Multisensory effects: flash vs sync vs async
ds = subset(d,is.element(Group,c("Flash","Sync","Async")))
ds$Shape = factor(ds$Shape)
ggplot(data=ds, aes(Shape,Spikes,color=Group,group=Group)) + theme_bw() + 
  facet_grid(.~Amp) +  stat_summary(fun.y="mean",geom="line")
model = aov(data=ds,Spikes~Shape*Amp + Shape*Group + Amp*Group + Cell*Shape*Amp) # Optimistic repeated
summary(model)
#TukeyHSD(model,which="Group")

# All points
#ggplot(data=ds, aes(Shape,Spikes,color=Group)) + theme_bw() + 
#  facet_grid(Amp~Group) +  geom_point(alpha=0.5,position = position_jitter(w = 0.3, h = 0.3)) # Each measurement as a point
ggplot(data=ds, aes(Shape,Spikes,color=Group,group=Cell)) + theme_bw() + 
  facet_grid(Amp~Group) +  stat_summary(fun.y="mean",geom="line",alpha = 0.3) # Each cell as a line

# Each cell as a line + average (fancy)
ggplot(data=ds, aes(Shape,Spikes,color=Group)) + theme_bw() + 
  facet_grid(Amp~Group) +  
  stat_summary(fun.y="mean",geom="line",alpha = 0.3,aes(group=Cell))  +  
  stat_summary(fun.y="mean",geom="line",aes(group=Group),size=1,color="black") + 
  scale_y_continuous(limits = c(0, 10))


# ------- Double-blinded verification of spike counts
# Loading raw AKh estimations of spikes for each sweep:
d2 = read.table("C:/Users/Arseny/Documents/5_Dynamic clamp/manualCounting - combined.txt",header=T)
# Decipher sweep number into what they actually were
d2$Shape = (d2$Sweep-1) %% 4 + 1
d2$Amp = floor((d2$Sweep-1)/4) + 1
d2$Rep = floor((d2$Sweep-1)/12) + 1
head(d2)

# Only look at cells that I could open, but that were also included into the final set
d3 = d
d3 = subset(d3,d3$Cell %in% unique(d2$Cell))
d2 = subset(d2,d2$Cell %in% unique(d3$Cell))

d3$Spikes = pmin(9,d3$Spikes) # Because in verification set nSpikes was capped at 9, cap it here too

d3 = subset(d3,!(d3$Cell %in% c(145,272))) # Exclude two incomplete cells:
d2 = subset(d2,!(d2$Cell %in% c(145,272))) # broken sweeps were processed differently

ggplot() + theme_bw() + geom_point(data=d3,aes(Cell+Amp/4,Spikes,color=Shape)) +
  geom_point(data=d2,aes(Cell+Amp/4,Spikes+10,color=Shape))

length(unique(d2$Cell))
length(unique(d3$Cell)) # Number of cells now matches
# d2 %>% group_by(Cell) %>% summarize(n=n()) %>% data.frame
# d3 %>% group_by(Cell) %>% summarize(n=n()) %>% data.frame
nrow(d2) # 9660
nrow(d3) # Now they match

d2 = rename(d2,Spikes2=Spikes) # AKh spike are now Spikes2
head(d2)
dc = merge(d2,d3,by=c("Cell","Shape","Amp","Rep"))
head(dc)
ggplot(data=dc,aes(Spikes,Spikes2)) + theme_bw() + geom_point(alpha=0.2)
# AKh is more conservative than SB
cor(dc$Spikes,dc$Spikes2) # r=0.95
sum(dc$Spikes!=dc$Spikes2)/nrow(d3) # 1.5% of disagreement
dc$diff = dc$Spikes2-dc$Spikes
dc %>% subset(diff!=0) %>% summarize(m=mean(diff),s=sd(diff)) # -1.2 diff on average
ggplot(data=dc,aes(Group,diff)) + theme_bw() + geom_jitter(alpha=0.5,width=0.2,height=0.3)

# Let's check sound in particular, as that's the group with largest differences
ds=subset(dc,Group %in% c("Control","Sound"))
dsflat <- ds %>% group_by(Group,Cell,Amp,Shape) %>% 
  summarize(Spikes=mean(Spikes,na.rm=T),Spikes2=mean(Spikes2,na.rm=T))
summary(aov(data=dsflat,Spikes~Group + Group*Shape + Group*Amp + Cell))
summary(aov(data=dsflat,Spikes2~Group + Group*Shape + Group*Amp + Cell))
# No qualitative difference, so it doesn't matter

summary(aov(data=dsflat,Spikes~Group + Group*Shape*Amp + Cell))
summary(aov(data=dsflat,Spikes2~Group + Group*Shape*Amp + Cell))
# Again, no qualitative difference (S*A is significant, bug G*S*A isn't)

# Zoomed-in view on individual values:
ggplot(data=subset(dsflat,Group %in% c("Control","Sound")),aes(Group,Spikes2,color=Group)) +
  theme_bw() +  geom_jitter(alpha=0.2,width=0.1,height=0.01) + 
  facet_grid(Amp~Shape) +
  stat_summary(fun.y="mean",color="black",geom="point")
