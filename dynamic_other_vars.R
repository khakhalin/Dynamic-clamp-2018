# Dynamic study of intrinsic plasticity:
# Analysis of everything that isn't raw spike data.
# Version Dec 09 2018

# install.packages("lme4") # This one is required for lmerTest to work
# install.packages("lmerTest")
# install.packages("effsize")
#install.packages("viridis")

require(dplyr)
require(ggplot2)
require(effsize)
require(ggbeeswarm) # Suddenly stopped working after an update around Dec 2018; may be a version conflict
require(reshape2) # needed for some old code
require(MASS) # Model selection. Note that it annoying masks "select" from dplyr
require(lmerTest) # Random effects model, requires lme4 as a dependency
require(viridis) # Pretty colors

rm(list = ls())  # Clear workspace

# ----- Read the data ----
# (The address below needs to point at the main data file. 
# Sadly, R doesn't support relative referencing)
#d = read.table("Dynamic-clamp-2018-git/Data/data_mainInput.txt",header=T)
d = read.table("5_Dynamic clamp/Git - Dynamic/Data/data_mainInput.txt",header=T)

d = mutate(d,group = reorder(group, groupid))
# d_full = d                # Save a copy just in case

names(d)
# Remove groups that weren't used in the paper
d = subset(d,group %in% c('Control','Crash','Flash','Sound','Sync','Async'))
d = mutate(d, group = recode_factor(group,'Control'='Control','Flash'='Flash','Crash'='Looming',
                                    'Sound'='Sound','Sync'='Sync','Async'='Async'))

# --- Cell positions ---
# Now let's fix cell coordinates (as they were originally measured a bit weirdly)
# Estimations from the tectal photo and drawing:
# Lower lip of the tectum has the "rostral" value of about 325 
# (which means that original numbers should have been actually called "caudal", not "rostral",
# as larger numbers corresponded to more caudal positioning)
# Rostral end of tectum has "rostral" of about 0. We'll have to flip it.
# Tectum side edge has "medial" of about 375 (which means that, again, it shold have been called "medial")
# Tectum midline has "medial" of about -25. So we flip it, but also shift it.

d$rostral = 1 - d$rostral/325        # Move to true "rostral", and from screen units to %
d$medial = 1 - (d$medial + 25)/375   # Move to true "medial"

# Now qplot(medial,rostral) will look like left tectum
# "medial" is indeed how medial everything is
# and "rostral" is indeed how rostral it is

# Check mean values and sds:
mean(d$rostral,na.rm=T)
sd(d$rostral,na.rm=T)
min(d$rostral,na.rm=T)
max(d$rostral,na.rm=T)
mean(d$medial,na.rm=T)
sd(d$medial,na.rm=T)
min(d$medial,na.rm=T)
max(d$medial,na.rm=T)

d$rm = d$rm/10  # The original data file used weird units. Now it's in GOhm

# Tuck down two extreme outlier cells
ggplot(data=d) + theme_bw() + geom_point(aes(samp,sbend))
domit = d
domit = mutate(domit, sbend = ifelse(sbend<0.5,sbend,0.5)) # From 1 to 0.5
domit = mutate(domit, samp = ifelse(samp<2.2,samp,2.2)) # From 3 and 4 to 2.2
ggplot(data=domit) + theme_bw() + geom_point(aes(samp,sbend))

# ------- Simple correlations
ggplot(data=d) + theme_bw() + geom_point(aes(smean,nai))
cor.test(d$smean,d$nai, use="complete.obs")
cor.test(d$smean,d$ksi, use="complete.obs")
cor.test(d$smean,d$kti, use="complete.obs")

# -------------- Position analysis
# Compare recording positions across groups.
# Flashes were more caudal; crashes, sound and async more medial
ggplot(data=d,aes(group,rostral,color=group)) + theme_bw() + geom_beeswarm()
ggplot(data=d,aes(group,medial,color=group)) + theme_bw() + geom_beeswarm()
t = data.frame(x=d$medial,y=d$rostral)
ggplot() + theme_bw() + geom_point(data=t,aes(x,y),color="gray") +
  geom_point(data=d,aes(medial,rostral,color=group)) + facet_wrap(~group) +
  xlab("Medial") + ylab("Rostral") # Positions of all cells, split intro groups
ggplot() + theme_classic() + geom_point(data=d,aes(medial,rostral,color=group),shape=1)

# --- Position effects on spiking
ggplot() + theme_bw() + theme(text=element_text(size=8)) + 
  geom_point(data=d,aes(medial,smean,color=group))
summary(aov(data=d,smean~group+rostral+medial)) # neither
summary(aov(data=d,samp~group+rostral+medial)) # neither
summary(aov(data=d,sbend~group+rostral+medial)) # neither

# --- Position effect ons IV variables
summary(aov(data=d,cm~group+rostral+medial)) # medial
summary(aov(data=d,rm~group+rostral+medial)) # medial
summary(aov(data=d,nai~group+rostral+medial)) # rostral
summary(aov(data=d,nav~group+rostral+medial)) # medial
summary(aov(data=d,kti~group+rostral+medial)) # no
summary(aov(data=d,ktv~group+rostral+medial)) # no
summary(aov(data=d,ksi~group+rostral+medial)) # medial
summary(aov(data=d,ksv~group+rostral+medial)) # no
# Drop of values across the entire tectum: 
f = lm(data=d,cm ~ group+medial+rostral); coef(f)['medial']*(0.53-0.25) # -2.4 pA
f = lm(data=d,rm ~ group+medial+rostral); coef(f)['medial']*(0.53-0.25) # 250 kOhm
f = lm(data=d,nav ~ group+medial+rostral); coef(f)['medial']*(0.53-0.25) # -12 mV
f = lm(data=d,ksi ~ group+medial+rostral); coef(f)['medial']*(0.53-0.25) # -276 pA
f = lm(data=d,nai ~ group+medial+rostral); coef(f)['rostral']*(0.69-0.36) # 156 pA

# Based on (Hamodi Pratt), they observed ~150 pA change in nai, and ~200 pA in ki (?),
# while comparing 0-30% and 60-80% of the OT. If ~ 55% of width gave them these differences,
# with our ~30% of range we can expect ~70-100 pA diff for nai and ki.

ggplot(data=d) + theme_bw() + geom_point(aes(medial,nav)) # We also see it, but it's not striking

# Different stories for 2 types of spiking
summary(aov(data=d,stepspike~group+rostral+medial)) # medial
summary(aov(data=d,smean~group+rostral+medial)) # none

ggplot(data=d,aes(medial,cm,color=group)) + theme_bw() + 
  theme(text=element_text(size=8)) + 
  geom_point() + geom_smooth(method=lm,se=F) # Not convincing


dtemp = na.omit(d) # Calculate group-adjusted r-values
fit = lm(data=dtemp,cm~group); dtemp$proxy1 = resid(fit) + mean(fitted(fit)); cor(dtemp$proxy1,dtemp$medial)
fit = lm(data=dtemp,rm~group); dtemp$proxy1 = resid(fit) + mean(fitted(fit)); cor(dtemp$proxy1,dtemp$medial)
fit = lm(data=dtemp,nai~group); dtemp$proxy1 = resid(fit) + mean(fitted(fit)); cor(dtemp$proxy1,dtemp$rostral)
fit = lm(data=dtemp,nav~group); dtemp$proxy1 = resid(fit) + mean(fitted(fit)); cor(dtemp$proxy1,dtemp$medial)
fit = lm(data=dtemp,ksi~group); dtemp$proxy1 = resid(fit) + mean(fitted(fit)); cor(dtemp$proxy1,dtemp$medial)

# --- Position effects on synaptic
# On raw data:
summary(aov(data=d,mono_m~group+medial+rostral)) # medial
summary(aov(data=d,mono_s~group+medial+rostral)) # none
summary(aov(data=d,poly_m~group+medial+rostral)) # rostral
summary(aov(data=d,poly_s~group+medial+rostral)) # none
summary(aov(data=d,lat_m~group+medial+rostral)) # medial
# Drop amplitudes:
f = lm(data=d,mono_m~group+medial+rostral); coef(f)['medial']*(0.53-0.25) # 25 pA
f = lm(data=d,poly_m~group+medial+rostral); coef(f)['rostral']*(0.69-0.36) # -10 pA
f = lm(data=d,lat_m~group+medial+rostral); coef(f)['medial']*(0.53-0.25) # 70 ms
# What about transformed data?
summary(aov(data=d,log(1-mono_m)~group+medial+rostral)) # medial
summary(aov(data=d,log(mono_s)~group+medial+rostral)) # medial
summary(aov(data=d,log(1-poly_m)~group+medial+rostral)) # none
summary(aov(data=d,log(poly_s)~group+medial+rostral)) # none

ggplot(data=d,aes(medial,log(1-mono_m),color=group)) + geom_point(alpha=0.5) + theme_bw() +
  geom_smooth(method=lm,se=F)

summary(aov(data=d,lat_m~rostral+medial)) # medial
summary(aov(data=d,lat_s~rostral+medial)) # almost, medial
ggplot(data=d,aes(group,lat_m)) + geom_point() # Looks quite normal
ggplot(data=d,aes(group,sqrt(lat_s))) + geom_point() # OK as is, but better with sqrt

dtemp = na.omit(d) # Calculate group-adjusted r-values
fit = lm(data=dtemp,log(1-mono_m)~group); dtemp$proxy1 = resid(fit) + mean(fitted(fit)); cor(dtemp$proxy1,dtemp$medial)
fit = lm(data=dtemp,log(mono_s)~group); dtemp$proxy1 = resid(fit) + mean(fitted(fit)); cor(dtemp$proxy1,dtemp$rostral)
fit = lm(data=dtemp,lat_m~group); dtemp$proxy1 = resid(fit) + mean(fitted(fit)); cor(dtemp$proxy1,dtemp$medial)


## -- How much does the position correction change things?
d$choice1 = d$samp; valName1 = 'Amplitude tuning' # Two variables of choice
d$choice2 = d$sbend; valName2 = 'Temporal tuning'
#d$choice1 = d$nai; valName1 = 'I Na' # Two variables of choice
#d$choice2 = d$nav; valName2 = 'V Na'
#d$choice1 = d$mono_m; valName1 = 'mono' # Two variables of choice
#d$choice2 = d$lat_m; valName2 = 'lat'
dclean = na.omit(d)
model1 = aov(data=dclean,choice1~rostral+medial)
dclean$proxy1 = resid(model1) + mean(fitted(model1)) # Residuals + general mean
# ggplot(data=dclean) + geom_point(aes(choice1,proxy1))
model2 = aov(data=dclean,choice2~rostral+medial)
dclean$proxy2 = resid(model2) + mean(fitted(model2))
d_sum = summarize(group_by(dclean,group),
                  m1=mean(proxy1,na.rm=T),m2=mean(proxy2,na.rm=T))
t = data.frame(x=dclean$proxy1,y=dclean$proxy2)
tmove = data.frame(x=d$choice1,y=d$choice2,id=d$id,group=d$group)
tmove = rbind(tmove,data.frame(x=dclean$proxy1,y=dclean$proxy2,id=dclean$id,group=dclean$group))
ggplot() + theme_bw() + theme(text=element_text(size=8)) + 
  geom_point(data=t,aes(x,y),color="gray") +
  geom_point(data=dclean,aes(proxy1,proxy2,color=group)) +
  geom_point(data=d_sum,aes(m1,m2),fill="black",shape=15) +
  geom_line(data=tmove,aes(x,y,color=group,group=id)) +
  facet_wrap(~group) + xlab(valName1) + ylab(valName2)


# ------- ------- Adjust variables on position once and for all
# -- This segment NEEDS to be run before all analyses further down
# -- start of adjuster block

# dadj = na.omit(d) # copy values, improper
dadj = d # copy values, proper

model = aov(data=dadj,smean~rostral+medial,na.action=na.exclude);    dadj$smean = resid(model) + mean(fitted(model),na.rm=T)
model = aov(data=dadj,samp~rostral+medial,na.action=na.exclude);     dadj$samp = resid(model) + mean(fitted(model),na.rm=T)
model = aov(data=dadj,sqrt(dadj$sbend+min(dadj$sbend,na.rm=T) + 1)~rostral+medial,na.action=na.exclude) # Normalization transformation
dadj$sbend = (resid(model)+mean(fitted(model),na.rm=T))^2-min(dadj$sbend,na.rm=T)-1 # Inverse transformation

# ggplot(data=d,aes(log(1-poly_m),fill=group)) + geom_density(alpha=0.2) + theme_bw() # visual test
# ggplot(data=d,aes(log(1+mono_s),fill=group)) + geom_density(alpha=0.2) + theme_bw() # visual test
model = aov(data=dadj,log(1-mono_m)~rostral+medial,na.action=na.exclude);
dadj$mono_m = resid(model) + mean(fitted(model),na.rm=T); dadj$mono_m = 1-exp(dadj$mono_m)
model = aov(data=dadj,log(1+mono_s)~rostral+medial,na.action=na.exclude);     
dadj$mono_s = resid(model) + mean(fitted(model),na.rm=T); dadj$mono_s = exp(dadj$mono_s)-1
model = aov(data=dadj,log(2-poly_m)~rostral+medial,na.action=na.exclude);     
dadj$poly_m = resid(model) + mean(fitted(model),na.rm=T); dadj$poly_m = 2-exp(dadj$poly_m)
model = aov(data=dadj,log(1+poly_s)~rostral+medial,na.action=na.exclude);     
dadj$poly_s = resid(model) + mean(fitted(model),na.rm=T); dadj$poly_s = exp(dadj$poly_s)-1

model = aov(data=dadj,log(1+stepspike)~rostral+medial,na.action=na.exclude);
dadj$stepspike = resid(model) + mean(fitted(model),na.rm=T); dadj$stepspike = exp(dadj$stepspike)-1

model = aov(data=dadj,lat_m~rostral+medial,na.action=na.exclude);     dadj$lat_m = resid(model) + mean(fitted(model),na.rm=T)
model = aov(data=dadj,lat_s~rostral+medial,na.action=na.exclude);     dadj$lat_s = resid(model) + mean(fitted(model),na.rm=T)
# -- end of adjuster block


# ------- ------- ANOVAs on spiking phenotypes
# ------- Analysis of smean
model = aov(data=d,smean~rostral+medial+group); summary(model) # Yes: p=0.01
TukeyHSD(model,which="group") # CF
anova(lmer(data=d,smean~rostral+medial+group+(1|animal),na.action=na.omit)) # Verification (yes, 0.047)
bartlett.test(data=d,smean~group) # Variances are different
ggplot(data=d,aes(group,smean)) + geom_point(alpha=0.3,position=position_jitter(w=0.2,h=0)) + theme_bw()

# Which vars are significantly different?
var.test(data=subset(d,group %in% c("Control","Flash")), smean~group, alternative = "two.sided") # 2e-6
var.test(data=subset(d,group %in% c("Control","Looming")), smean~group, alternative = "two.sided") # 7e-5
var.test(data=subset(d,group %in% c("Flash","Sound")), smean~group, alternative = "two.sided") # 1e-4
var.test(data=subset(d,group %in% c("Sound","Sync")), smean~group, alternative = "two.sided") #1e-3, Y more variable
var.test(data=subset(d,group %in% c("Flash","Async")), smean~group, alternative = "two.sided") # 0.01, A more variable
# Not different: CS (0.07), FY (0.9), SA (0.5)

t.test(data=subset(d,group %in% c("Control","Flash")),smean~group) # 0.01
t.test(data=subset(d,group %in% c("Control","Looming")),smean~group) # 0.1
t.test(data=subset(d,group %in% c("Control","Sound")),smean~group) # 0.5
t.test(data=subset(d,group %in% c("Sync","Flash")),smean~group) # 0.2
t.test(data=subset(d,group %in% c("Async","Flash")),smean~group) # 0.02
t.test(data=subset(d,group %in% c("Control","Sync")),smean~group) # 0.06
t.test(data=subset(d,group %in% c("Control","Async")),smean~group) # 0.4

# ------- Analysis of sbend
model = aov(data=d,sbend~rostral+medial+group); summary(model) # Yes
TukeyHSD(model,which="group") # FC, YC
bartlett.test(data=dadj,sbend~group) # Variances are different, p=7e-12 non-adj, 8e-12 adj
ggplot(data=d,aes(group,sbend)) + geom_boxplot() + theme_bw()

# Meaningful var comparisons:
var.test(data=subset(d,group %in% c("Control","Flash")), sbend~group, alternative = "two.sided") # 5e-11
var.test(data=subset(d,group %in% c("Control","Looming")), sbend~group, alternative = "two.sided") # 1e-7
var.test(data=subset(d,group %in% c("Control","Sound")), sbend~group, alternative = "two.sided") # 0.4
var.test(data=subset(d,group %in% c("Flash","Sync")), sbend~group, alternative = "two.sided") #0.7
var.test(data=subset(d,group %in% c("Flash","Async")), sbend~group, alternative = "two.sided") # 0.01, with A more variable

# First p-val is for non-position-adjusted; 2nd for adjusted values
t.test(data=subset(dadj,group %in% c("Control","Flash")),sbend~group) # 0.007, 0.008
t.test(data=subset(dadj,group %in% c("Control","Looming")),sbend~group) # 0.03, 0.03
t.test(data=subset(dadj,group %in% c("Control","Sound")),sbend~group) # 0.25, 0.26
t.test(data=subset(d,group %in% c("Sync","Flash")),sbend~group) # 0.7
t.test(data=subset(dadj,group %in% c("Async","Flash")),sbend~group) # 0.4, 0.5

# Note that for cohen d below signs are shown in the CFLSYA sequence, not in the sequence
# shown in the subset formula. (The formula sequence affects nothing, it's a set operation)
# First d is for non-position-adjusted; 2nd for adjusted values
cohen.d(data=subset(dadj,group %in% c("Control","Flash")),sbend~group) # 0.78 non-adj, 0.76 adj
cohen.d(data=subset(dadj,group %in% c("Control","Looming")),sbend~group) # 0.47, 0.46
cohen.d(data=subset(dadj,group %in% c("Flash","Looming")),sbend~group) # 0.26, 0.22
cohen.d(data=subset(dadj,group %in% c("Control","Sound")),sbend~group) # 0.27, 0.27
cohen.d(data=subset(dadj,group %in% c("Flash","Sync")),sbend~group) # 0.08, 0.01
cohen.d(data=subset(dadj,group %in% c("Flash","Async")),sbend~group) # 0.30, 0.26

# ------- Analysis for samp
model = aov(data=d,samp~rostral+medial+group); summary(model)  # Yes
TukeyHSD(model,which="group") # CF, CS
t.test(data=subset(dadj,group %in% c("Control","Sound")),samp~group) # 0.3
t.test(data=subset(dadj,group %in% c("Control","Looming")),samp~group) # 0.04
t.test(data=subset(dadj,group %in% c("Control","Async")),samp~group) # 0.07
bartlett.test(data=dadj,samp~group) # Variances are different, p=6e-10 non-adj, 2e-9 adj
ggplot(data=d,aes(group,samp)) + theme_bw() + 
  geom_point(alpha=0.5,position=position_jitter(width=0.1)) # With two outliers
ggplot(data=d,aes(group,pmin(samp,2.2))) + theme_bw() + 
  geom_point(alpha=0.5,position=position_jitter(width=0.1)) # With outliers tucked in
ggplot(data=d,aes(group,samp)) + theme_bw() + 
  geom_beeswarm(cex=1,shape=1,size=1,aes(color=group)) +
  stat_summary(fun.y="mean",color="black",geom="point")

var.test(data=subset(d,group %in% c("Control","Flash")), samp~group, alternative = "two.sided") # 2e-9
var.test(data=subset(d,group %in% c("Control","Looming")), samp~group, alternative = "two.sided") # 7e-9
var.test(data=subset(d,group %in% c("Control","Sound")), samp~group, alternative = "two.sided") # 0.06
var.test(data=subset(d,group %in% c("Flash","Sync")), samp~group, alternative = "two.sided") #0.9
var.test(data=subset(d,group %in% c("Flash","Async")), samp~group, alternative = "two.sided") # 0.6

t.test(data=subset(dadj,group %in% c("Control","Flash")),samp~group) # 0.002, 0.002
t.test(data=subset(dadj,group %in% c("Control","Looming")),samp~group) # 0.02, 0.02
t.test(data=subset(dadj,group %in% c("Control","Sound")),samp~group) # 0.2, 0.2
t.test(data=subset(dadj,group %in% c("Sync","Flash")),samp~group) # 0.4, 0.4
t.test(data=subset(dadj,group %in% c("Async","Flash")),samp~group) # 0.03, 0.03

# For each row, first non-position-ajusted, then position-adjusted value
cohen.d(data=subset(dadj,group %in% c("Control","Flash")),samp~group) # 0.89, 0.90
cohen.d(data=subset(dadj,group %in% c("Control","Looming")),samp~group) # 0.49, 0.50
cohen.d(data=subset(dadj,group %in% c("Flash","Looming")),samp~group) # 0.45, 0.44
cohen.d(data=subset(dadj,group %in% c("Control","Sound")),samp~group) # 0.28, 0.29
cohen.d(data=subset(dadj,group %in% c("Flash","Sync")),samp~group) # 0.24, 0.24
cohen.d(data=subset(dadj,group %in% c("Flash","Async")),samp~group) # 0.65, 0.64

# -------------- Big flexible visualizations
# Full analysis plot of each one variable
# Set the variable & its name in two rows below
d$best = d$smean # Put any value from names() here
valName = 'smean' # How to label y-axis below
transformNeeded = F # Transformation; set to T for sbend
dclean = na.omit(d)
if(transformNeeded) {
  dclean$temp = sqrt(dclean$best+min(dclean$best) + 1) # Transformation to keep it normal and positive
}else{
  dclean$temp = dclean$best
}
model1 = aov(data=dclean,temp~rostral+medial)
if(transformNeeded) {
  dclean$proxy = (resid(model1)+mean(fitted(model1)))^2-min(dclean$best)-1 # Inverse transformation
}else{
  dclean$proxy = resid(model1) + mean(fitted(model1))
}
ggplot(data=dclean) + theme_bw() + geom_point(aes(rostral,best),color="lightgray") +
  geom_point(aes(rostral,proxy),color="blue")
d_sum = summarize(group_by(dclean,group),
             m=mean(proxy,na.rm=T),
             n=n(),
             ci=sd(proxy,na.rm=T)/sqrt(n)*qt(0.025,df=n-1))
ggplot(data=d_sum, aes(group,m)) + 
  theme_bw() + theme(text=element_text(size=8)) + 
  geom_beeswarm(data=dclean,aes(group,proxy,color=group),cex=1,alpha=0.5,shape=16,size=2) +
  geom_point(shape=1) +
  geom_errorbar(aes(ymin=m-ci,ymax=m+ci),width=0.1) +
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank()) +
  xlab('Group') + ylab(valName)

### Now same, but 2D
# Universal approach that doesn't use dadj
d$choice1 = d$smean; valName1 = 'smean'
d$choice2 = d$sbend; valName2 = 'sbend'
dclean = na.omit(d)
if(valName1=="sbend"){dclean$choice1 = pmin(dclean$choice1,0.5)}
if(valName2=="sbend"){dclean$choice2 = pmin(dclean$choice2,0.5)}
if(valName2=="samp"){dclean$choice2 = pmin(dclean$choice2,2.5)}
model1 = aov(data=dclean,choice1~rostral+medial)
dclean$proxy1 = resid(model1) + mean(fitted(model1))
model2 = aov(data=dclean,choice2~rostral+medial)
dclean$proxy2 = resid(model2) + mean(fitted(model2))
d_sum = summarize(group_by(dclean,group),
                  n=n(), 
                  m1=mean(proxy1,na.rm=T),
                  ci1=sd(proxy1,na.rm=T)/sqrt(n)*qt(0.025,df=n-1),
                  m2=mean(proxy2,na.rm=T),
                  ci2=sd(proxy2,na.rm=T)/sqrt(n)*qt(0.025,df=n-1))
t = data.frame(x=dclean$proxy1,y=dclean$proxy2)
ggplot() + theme_bw() + theme(text=element_text(size=8)) + 
  geom_point(data=t,aes(x,y),color="lightgray") +
  geom_point(data=dclean,aes(proxy1,proxy2,color=group)) +
  geom_point(data=d_sum,aes(m1,m2),fill="black",shape=15) +
  facet_wrap(~group) + xlab(valName1) + ylab(valName2) + 
  stat_ellipse(data=dclean,aes(proxy1,proxy2,fill=group),alpha=0.2,geom="polygon")

# Specific approach that uses dadj; Illustrator-optimized
t = data.frame(x=dadj$smean,y=dadj$sbend)
ds = summarize(group_by(dadj,group),
               n=n(), 
               m1=mean(smean,na.rm=T),
               ci1=sd(smean,na.rm=T)/sqrt(n)*qt(0.025,df=n-1),
               m2=mean(sbend,na.rm=T),
               ci2=sd(sbend,na.rm=T)/sqrt(n)*qt(0.025,df=n-1))

ggplot() + theme_bw() + theme(text=element_text(size=8)) + 
  stat_ellipse(data=dadj,aes(smean,sbend,fill=group),geom="polygon") +
  geom_point(data=t,aes(x,y),color="lightgray",shape=1) +
  geom_point(data=dadj,aes(smean,sbend,color=group),shape=1) +
  geom_point(data=ds,aes(m1,m2),fill="black",shape=1) +
  facet_wrap(~group)
  

# 2D CI-based plot of same data
ggplot() + theme_bw() + theme(text=element_text(size=8)) + 
  geom_point(data=ds,aes(m1,m2,color=group)) +
  geom_errorbar(data=ds,aes(x=m1,ymin=m2-ci2,ymax=m2+ci2,color=group),width=0.02) +
  geom_errorbarh(data=ds,aes(x=m1,xmin=m1-ci1,xmax=m1+ci1,y=m2,color=group),height=0.02)

# 2D t-test (Hoteling t-squared test) for these crosses
#install.packages("Hotelling")
require(Hotelling)
dclean = na.omit(dadj)
names(dclean)
d_prepared = dclean %>% 
  dplyr::select(group,samp,sbend)
summary(d_prepared)

fit = hotelling.test(.~group, data=d_prepared, pair=c("Control","Flash"), perm=T); fit # 0.0002
fit = hotelling.test(.~group, data=d_prepared, pair=c("Control","Looming"), perm=T); fit # 0.01
fit = hotelling.test(.~group, data=d_prepared, pair=c("Flash","Looming"), perm=T); fit # 0.1
fit = hotelling.test(.~group, data=d_prepared, pair=c("Control","Sound"), perm=T); fit # 0.2
fit = hotelling.test(.~group, data=d_prepared, pair=c("Flash","Sync"), perm=T); fit # 0.2
fit = hotelling.test(.~group, data=d_prepared, pair=c("Flash","Async"), perm=T); fit # 0.04


# --- IV analysis
# ra rm cm ihold nav nai ktv kti ksv ksi smean samp sbend
# explanatory: group, stage, rostral, medial
summary(aov(data=d,rm~rostral+medial+group)) # no
summary(aov(data=d,cm~rostral+medial+group)) # no
summary(aov(data=d,nai~rostral+medial+group)) # no
summary(aov(data=d,nav~rostral+medial+group)) # yes, p=0.003
summary(aov(data=d,kti~rostral+medial+group)) # no
summary(aov(data=d,ktv~rostral+medial+group)) # no
summary(aov(data=d,ksi~rostral+medial+group)) # no
summary(aov(data=d,ktv~rostral+medial+group)) # no
ggplot(data=d,aes(group,nai)) + geom_beeswarm() + theme_bw() # note: not adjusted


# ---------------- Explaining spiking phenotype via IV variables
### ---- Smean analysis
drop1(aov(data=na.omit(d),smean~rostral+medial+nai+kti+ksi+cm+rm),test="F") # nai and rm
drop1(aov(data=na.omit(d),smean~rostral+medial+kti+ksi+cm+rm),test="F") # If no nai, then rm, cm
cor.test(d$nai,d$cm,use="complete.obs") # Because they correlate strongly (positively)
ggplot(data=d,aes(cm,nai,color=group)) + theme_bw() + geom_point()
drop1(aov(data=na.omit(d),smean~rostral+medial+kti+ksi+rm),test="F") # and nobody else
cor.test(d$smean,d$ksv,use="complete.obs") # Not this one. And really, nobody else
fit = aov(data=na.omit(d),smean~rostral+medial+nai+kti+ksi+nav+ktv+ksv+cm+rm)
stepAIC(fit, direction="both") # nai+rm 
summary(aov(data=na.omit(d),smean~rostral+medial+nai+rm))
# This analysis doesn't quite work as rostral and medial shouldn't be optional; 
# these are confounding factors that needs to be factored out before analysis
# Correct analysis:
dclean = na.omit(d)
fit1 = aov(data=dclean,smean~rostral+medial)
dclean$proxy = resid(fit1) + mean(fitted(fit1))
fit = aov(data=dclean,proxy~rostral+medial+nai+kti+ksi+nav+ktv+ksv+cm+rm)
stepAIC(fit, direction="both") # nai+rm
summary(fit)
summary(aov(formula = smean ~ rostral+medial+nai+nav, data = na.omit(d))) # Except nav is not. nai is the only one
cor.test(d$smean,d$nav,use="complete.obs") # Not
summary(aov(formula = smean ~ rostral+medial+group+nai, data = na.omit(d))) # Remains sig after group
summary(aov(data=dadj,
            smean~rm+cm+nai+nav+kti+ktv+ksi+ksv+group),test="F") # In fact group remains after everything
summary(aov(data=na.omit(d),smean~rostral+medial+group),test="F") # effect of group alone

ggplot(data=dadj,aes(nai,rm,color=log(smean))) + geom_point() + theme_bw() +
  scale_color_viridis() # Does not look like non-linear regression would help
summary(aov(data=dadj,smean~nai+rm)) # 10% of SS explained
summary(aov(data=dadj,log(smean)~nai+rm)) # 8% explained. No help here.


### ---- Sbend analysis
# it's important to use dadj instead of d, as sbend is tricky to position-compensate
# because of non-normality, but we've done it properly above.
drop1(aov(data=dadj,sbend~nai+kti+ksi+cm+rm+nav+ktv+ksv),test="F") # nav wins
cor.test(dadj$rm,dadj$nav,use="complete.obs") # rm and nav anticorrelate tho
fit = aov(data=dadj,sbend~nai+kti+ksi+nav+ktv+ksv+cm+rm)
stepAIC(fit, direction="both") # kti + rm + nav
summary(aov(data=dadj,sbend~kti+nav+rm)) # Variance explained: 2% (p=0.09), 6%, 3%
summary(aov(data=dadj,sbend~nav+rm)) # Variance explained: 7%, 2%
summary(aov(data=dadj,sbend~group+rm+nav),test="F") # nav and rm Remain after group
summary(aov(data=dadj,sbend~rm+nav+group),test="F") # Group remains after them
summary(aov(data=dadj,
    sbend~rm+cm+nai+nav+kti+ktv+ksi+ksv+group),test="F") # In fact group remains after everything
summary(aov(data=dadj,sbend~group),test="F") # effect of group alone

### ---- Samp analysis
drop1(aov(data=na.omit(d),samp~rostral+medial+nai+kti+ksi+cm+rm+nav+ktv+ksv),test="F") # nai
fit = aov(data=na.omit(d),samp~rostral+medial+nai+kti+ksi+nav+ktv+ksv+cm+rm)
stepAIC(fit, direction="both") # nai + nav + ktv
# Correct analysis:
dclean = na.omit(d)
fit1 = aov(data=dclean,samp~rostral+medial)
dclean$proxy = resid(fit1) + mean(fitted(fit1))
fit = aov(data=dclean,proxy~rostral+medial+nai+kti+ksi+nav+ktv+ksv+cm+rm)
stepAIC(fit, direction="both") # nai+nav+ktv
summary(aov(data=na.omit(d),samp~rostral+medial+nai+nav+ktv))
summary(fit)
summary(aov(data=na.omit(d),samp~rostral+medial+nai+nav+ktv),test="F") # ktv is not
summary(aov(data=dadj,samp~nai+nav)) # 6%, 2%
summary(aov(data=na.omit(d),samp~rostral+medial+group+nai+nav),test="F") # only nav remains after group
summary(aov(data=na.omit(d),samp~rostral+medial+nai+nav+group),test="F") # group remains after both
summary(aov(data=na.omit(d),
            samp~rostral+medial+rm+cm+nai+nav+kti+ktv+ksi+ksv+group)) # and after full
summary(aov(data=na.omit(d),samp~rostral+medial+group),test="F") # effect of group alone


# Potential pics for the figure
# a reminder: smean(nai,rm); sbend(rm,nav); samp(nai,nav)
ggplot(data=dadj,aes(nai,smean)) + theme_bw() + geom_point(shape=1) + geom_smooth(method=lm,se=F)
ggplot(data=dadj,aes(nav,sbend)) + theme_bw() + geom_point(shape=1) + geom_smooth(method=lm,se=F)
ggplot(data=dadj,aes(nai,samp)) + theme_bw() + geom_point(shape=1) + geom_smooth(method=lm,se=F)

# Similar plots for step current injections (see below for details)
ggplot(data=dadj,aes(stepspike,smean)) + theme_bw() + geom_point(shape=1) + geom_smooth(method=lm,se=F)
ggplot(data=dadj,aes(nai,stepspike)) + theme_bw() + geom_point(shape=1) + geom_smooth(method=lm,se=F)
ggplot(data=d,aes(nai,stepspike)) + theme_bw() + geom_jitter(shape=1,width=0,height=0.2) + geom_smooth(method=lm,se=F)

ggplot(data=dadj,aes(nai,nav,color=log(1+stepspike))) + geom_point() + theme_bw() +
  scale_color_viridis()
ggplot(data=dadj,aes(nai,nav,color=log(1+smean))) + geom_point() + theme_bw() +
  scale_color_viridis()

# -------- Step current injections
# Now how much variance can be explained for step injection number of spikes?
dclean = na.omit(d) # not adjusted for position, to measure position effect
nrow(dclean) # 135
fit1 = aov(data=dclean,stepspike~rostral+medial)
dclean$proxy = resid(fit1) + mean(fitted(fit1))
fit = aov(data=dclean,proxy~rostral+medial+nai+kti+ksi+nav+ktv+ksv+cm+rm)
stepAIC(fit, direction="both") # nai+rm
s = summary(fit)
s
ss = s[[1]]$`Sum Sq` # Sum of squares
1-sum(ss[1:length(ss)-1])/sum(ss) # 61% explained
cor.test(data=dadj,~stepspike+nai) # r=0.42, p=2e-8 - here and below, adjusted for position
cor.test(data=dadj,~stepspike+ksi) # 0.39, 2e-7
cor.test(data=dadj,~stepspike+nav) # 0.24, 0.002
cor.test(data=dadj,~stepspike+ksv) # -0.14, 0.06

# Did current-step spiking change between groups?
summary(aov(data=dadj,stepspike~group)) # p=0.6
summary(aov(data=dadj,smean~group)) # Contrast this with dynamic: p=0.02
ggplot(data=d,aes(group,stepspike)) + geom_beeswarm() + theme_bw()
ggplot(data=d,aes(group,smean)) + geom_beeswarm() + theme_bw()
cor.test(data=d,~stepspike+smean) # r=0.46, 1e-9
ggplot(data=d,aes(stepspike,smean)) + geom_point(alpha=0.3) + theme_bw() + 
  geom_smooth(method=lm)

# Comparison of step-injections to dynamic injections
cor.test(dadj$smean,dadj$stepspike, use="complete.obs") # Of course, p=2e-9, but r=0.5 only, r2=0.22
summary(aov(data=d,smean~stepspike+sbend+samp))
(14+12+25)/(14+12+25+13) # 0.80 variance explained
ggplot(data=d,aes(smean,stepspike,color=group)) + theme_bw() + 
  geom_jitter(width=0,height=0.2,alpha=0.5)
summary(aov(data=d,stepspike~group)) # No change. p=0.6
ggplot(data=d,aes(group,stepspike)) + geom_jitter(width=0.2,height=0.2,alpha=0.5)

cor.test(data=dadj,~stepspike+samp) # 0.45, 5e-9

# Contrasting two estimations
summary(aov(data=d,stepspike~rostral+medial+group+nai+kti+ksi+nav+ktv+ksv+cm+rm))
summary(aov(data=d,smean~rostral+medial+group+nai+kti+ksi+nav+ktv+ksv+cm+rm))

# A bunch of beeswarms for nav, nai etc.
dm = melt(dplyr::select(filter(d,group %in% c('Control','Crash','Flash','Sound')),
                 id,group,nav,nai,ktv,kti,ksv,ksi),id=c("id","group"))
ggplot(data=dm,aes(group,value,color=group)) + theme_bw() +
  geom_beeswarm(cex=1,alpha=0.3,shape=16,size=2)  +
  stat_summary(fun.y="mean",color="black",geom="point")+
  facet_wrap(~variable,ncol=2,scales="free")


### --- Compare models to actual data
# First dynamic clamp
dcomp = na.omit(dadj) # We use data that is compensated for position
fit1 = aov(data=dcomp,smean~nai+kti+ksi+nav+ktv+ksv+cm+rm)
dcomp$smean_model = predict(fit1,newdata=dcomp)
ggplot(data=dcomp,aes(smean,smean_model)) + theme_bw() + 
  geom_point(shape=21) +
  geom_smooth(method="lm",se=F,size=0.5) +
  xlab('Observed Spikiness, Dyn.C.') +
  ylab('Predicted spikiness')

# Now current injections
fit2 = aov(data=dcomp,stepspike~nai+kti+ksi+nav+ktv+ksv+cm+rm)
dcomp$stepspike_model = predict(fit2,newdata=dcomp)
ggplot(data=dcomp,aes(stepspike,stepspike_model)) + theme_bw() + 
  geom_point(shape=21) +
  geom_smooth(method="lm",se=F,size=0.5) +
  xlab('Observed N spikes in CC') +
  ylab('Predicted N spikes')



### --------------------- Synaptic stuff ---------------------
# mono_m, mono_s, poly_m, poly_s, lat_m, lat_s (means and variances)

# Changes with group?
# First on data without transformation:
summary(aov(data=d,mono_m~medial+rostral+group)) # No, p=0.3
summary(aov(data=d,mono_s~medial+rostral+group)) # No, p=0.6
summary(aov(data=d,poly_m~medial+rostral+group)) # No, p=0.8
summary(aov(data=d,poly_s~medial+rostral+group)) # Yes, 0.005
TukeyHSD(aov(data=d,poly_s~group)) # C>S, C>Y
# Note however that means are really non-normal
ggplot(data=d,aes(group,-mono_m)) + geom_beeswarm(color="blue",alpha=0.2) + theme_bw() + 
  stat_summary(fun.y=mean,geom="point")
ggplot(data=dadj,aes(group,-mono_m)) + geom_beeswarm(color="blue",alpha=0.2) + theme_bw() + 
  stat_summary(fun.y=mean,geom="point")
# For Illustrator:
ggplot(data=dadj,aes(group,-mono_m)) + theme_bw() + 
  geom_beeswarm(color="blue", cex=2, shape=1) +
  stat_summary(fun.y=mean,geom="point") + scale_y_log10(breaks=c(1,3,10,30,100))
# Looking for a good transformation:
ggplot(data=d,aes(group,log(1-mono_m))) + geom_beeswarm(color="blue",alpha=0.2) + theme_bw() + 
  stat_summary(fun.y=mean,geom="point")
ggplot(data=d) + geom_density(aes(log(1-mono_m)))
ggplot(data=d) + geom_density(aes(log(1+poly_s)))
# Same plot after compensation (the order of groups differs from that in the paper):
ggplot(data=dadj,aes(group,log(1-mono_m))) + theme_bw() + 
  #geom_beeswarm(color="blue",alpha=0.2) + 
  geom_point(alpha=0.2, position=position_jitter(w=0.1,h=0)) +
  stat_summary(fun.y=mean,geom="point") +
  NULL

# ANCOVAs on transformed:
# (relies on previouisly compensated dadj dataframe)
summary(aov(data=d,log(1-mono_m)~medial+rostral+group)) # yes, 0.009
TukeyHSD(aov(data=d,log(1-mono_m)~medial+rostral+group),which="group") # CA, CY
t.test(data=subset(dadj,group %in% c("Control","Flash")),log(1-mono_m)~group) # p=0.03
t.test(data=subset(dadj,group %in% c("Control","Sync")), log(1-mono_m)~group) # 0.003
t.test(data=subset(dadj,group %in% c("Control","Async")),log(1-mono_m)~group) # 0.004
t.test(data=subset(dadj,group %in% c("Control","Looming")),log(1-mono_m)~group) # 0.5
t.test(data=subset(dadj,group %in% c("Control","Sound")),log(1-mono_m)~group) # 0.4
cohen.d(data=subset(dadj,group %in% c("Control","Flash")),log(1-mono_m)~group) # 0.59 F>C
cohen.d(data=subset(dadj,group %in% c("Control","Sync")), log(1-mono_m)~group) # 0.92 Y>C
cohen.d(data=subset(dadj,group %in% c("Control","Async")),log(1-mono_m)~group) # 0.73 A>C
cohen.d(data=subset(dadj,group %in% c("Control","Sound")),log(1-poly_s)~group) # 0.64, S>C
summary(aov(data=d,sqrt(1+mono_s)~medial+rostral+group)) # no, p=0.4
summary(aov(data=d,log(1-poly_m)~medial+rostral+group)) # no 0.1
summary(aov(data=d,log(1+poly_s)~medial+rostral+group)) # yes, p=0.008
TukeyHSD(aov(data=d,log(1+poly_s)~medial+rostral+group),which="group") # CS - not too convincing


ggplot(data=d,aes(group,log(1+poly_s))) + geom_beeswarm(color="blue",alpha=0.2) + theme_bw() + 
  stat_summary(fun.y=mean,geom="point")

summary(aov(data=dadj,lat_m~group)) # yes, p=2e-5
TukeyHSD(aov(data=dadj,lat_m~group)) # CF, CY, CA, (LY, SY)
t.test(data=subset(dadj,group %in% c("Control","Sound")),lat_m~group) # 0.3
t.test(data=subset(dadj,group %in% c("Control","Looming")),lat_m~group) # 0.07
ggplot(data=dadj,aes(group,lat_m)) + 
  #geom_beeswarm(color="blue",cex=1.5,shape=1) + 
  geom_point(alpha=0.3,position=position_jitter(w=0.2,h=0)) +
  theme_bw() + stat_summary(fun.y=mean,geom="point") +
  NULL
dadj %>% group_by(group) %>% summarize(m=mean(lat_m,na.rm=T), s=sd(lat_m,na.rm=T))

# How do various synaptic properties interact?
summary(aov(data=dadj,lat_m~log(1-mono_m))) # huge, 2e-16
cor.test(dadj$lat_m,log(1-dadj$mono_m)) # 2e-16, -0.78
cor.test(dadj$lat_m,log(1-dadj$poly_m)) # 2e-9, -0.44
ggplot(data=dadj,aes(pmax(0.5,-mono_m),lat_m)) + theme_bw() + 
  geom_point(aes(color=group),shape=1) + 
  scale_x_log10(breaks=c(1,3,10,30,100)) +
  geom_smooth(method=lm,se=F)
ggplot(data=dadj,aes(log(1-poly_m),lat_m)) + theme_bw() + geom_point(aes(color=group),alpha=0.5) + 
  geom_smooth(method=lm,se=F) + facet_wrap(~group)
summary(aov(data=dadj,poly_m~mono_m)) # Also obviously 2e-16


# ----- Do synaptic inputs and intrinsic tuning interact?
# Temporal analysis - first
ggplot(data=dadj,aes(lat_m,sbend)) + theme_bw() + geom_point(aes(color=group)) + 
  geom_smooth(method="lm",se=F) # All lumped together
ggplot(data=dadj,aes(lat_m,sbend)) + theme_bw() + geom_point(aes(color=group)) + 
  geom_smooth(method="lm",se=F) + facet_wrap(~group) # All groups separately
ds = dadj %>% group_by(group) %>% 
  do(lat_mm=mean(.$lat_m,na.rm=T), 
     sbendm=mean(.$sbend,na.rm=T),
     f=lm(sbend~lat_m,.)) %>% as_data_frame() %>%
  summarize(lat_mm=lat_mm, sbendm=sbendm, ls=coef(f)[2], group=group)
ggplot(data=dadj,aes(lat_m,sbend,color=group)) + theme_bw() + geom_point(shape=1) + 
  geom_smooth(method=lm,se=F) +
  geom_point(data=ds,aes(lat_mm,sbendm),color="black") # Because of missing values, no exact match
ggplot(data=dadj,aes(lat_m,sbend)) + theme_bw() + geom_point(aes(color=group),shape=1) + 
  geom_point(data=ds,aes(lat_mm,sbendm)) +
  geom_text(data=ds,aes(lat_mm,sbendm,label=substr(group,1,1))) +
  geom_smooth(data=ds,aes(lat_mm,sbendm),method=lm,se=F,color="red") # Between groups - for the paper
dres = merge(dadj,ds,by="group") # Let's look at full within-groups residuals
dres$lat_m = dres$lat_m-dres$lat_mm
dres$sbend = dres$sbend-dres$sbendm
ggplot(data=dres,aes(lat_m,sbend,color=group)) + geom_point(shape=1) + 
  theme_bw() +  geom_smooth(method=lm,se=F) # Many lines
ggplot(data=dres,aes(lat_m,sbend)) + geom_point(aes(color=group),shape=1) + 
  theme_bw() +  geom_smooth(method=lm,se=F) # One line, with two outliers up there
ggplot(data=dres,aes(lat_m,pmin(0.47,sbend))) + geom_point(aes(color=group),shape=1) + 
  theme_bw() +  geom_smooth(method=lm,se=F) # One line - for the paper, with outliers tucked in
cor.test(dadj$lat_m,dadj$sbend) # Total: No: p=0.4, r=-0.07
cor.test(ds$lat_mm,ds$sbendm) # Between: Yes: 0.02, r=0.89
cor.test(dres$lat_m,dres$sbend) # Within: Yes: 0.02, r=-0.19 # Simpson's paradox
summary(aov(data=dadj,sbend~lat_m)) # p=0.4
summary(aov(data=dadj,sbend~group+lat_m)) # between p=0.01, within p=0.02
summary(aov(data=dadj,sbend~group*lat_m)) # between p=0.01, within 0.02, but not interaction p=0.1
lm(data=dadj,sbend~group+lat_m) # k=-0.0005 1/ms, or -0.5 s^-1
# Per-group correlations:
cor.test(data=subset(dadj),~lat_m+sbend)                  # p=0.4, df=150, r=-0.07
cor.test(data=subset(dadj,group=="Control"),~lat_m+sbend) # 0.8, 18,  -0.07
cor.test(data=subset(dadj,group=="Flash"),~lat_m+sbend)   # 0.2, 26,   0.27
cor.test(data=subset(dadj,group=="Looming"),~lat_m+sbend) # 0.08, 23, -0.36
cor.test(data=subset(dadj,group=="Sound"),~lat_m+sbend)   # 0.04, 24, -0.42
cor.test(data=subset(dadj,group=="Sync"),~lat_m+sbend)    # 0.96, 26, -0.01
cor.test(data=subset(dadj,group=="Async"),~lat_m+sbend)   # 0.97, 23,  0.01
# Comparison of per-group slopes (not significant)
ggplot(data=ds,aes(lat_mm,ls)) + theme_bw() + geom_point()
cor.test(data=ds,~lat_mm+ls) # p=0.2

# Combine all flashed groups (flash, sync, async), and compare to all "unflashed"
# (This analysis was included in the first version of the paper, but is now removed,
# as it is a bit of a strech to combine groups into "supergroups" based on some vague idea of
# strength, especially as we are no blinded to the result)
t <- dres
t %>% group_by(group) %>% summarize(lat_mm=mean(lat_m,na.rm=T)) # Debugging test (yes, it works)
t$flashed <- is.element(t$group,c('Flash','Sync','Async'))
ggplot(data=t,aes(lat_m,sbend)) + theme_bw() +
  geom_point(aes(color=group),shape=1) +
  geom_smooth(method=lm,se=F) +
  facet_grid(.~flashed)
summary(aov(data=t,sbend~flashed*lat_m)) # Interaction (difference in slopes) p=0.02
cor.test(data=subset(t,flashed==1),~lat_m+sbend)   # p=0.5,  df=79,  r=0.08
cor.test(data=subset(t,flashed==0),~lat_m+sbend)   #   0.01,    69,   -0.29

# Does slope interact with group?
summary(aov(data=dadj,sbend~group + lat_m))


# - Now amplitude analysis
summary(aov(data=dadj,samp~mono_m)) # Yes; 0.03
summary(aov(data=dadj,samp~log(1-mono_m))) # no, p=0.1. Suggests effect of extreme values
ggplot(data=dadj,aes(-mono_m,samp)) + theme_bw() + geom_point(aes(color=group)) + 
  geom_smooth(method="lm",se=F)
ggplot(data=dadj,aes(log(1-mono_m),samp)) + theme_bw() + geom_point(aes(color=group)) + 
  geom_smooth(method="lm",se=F)

dtemp = na.omit(dadj); nrow(dtemp)
summary(aov(data=dtemp,samp~mono_m)) # yes, p=0.01
dtemp = subset(dtemp,(-mono_m<65)&(samp<2)); nrow(dtemp) # Remove 4 outliers
summary(aov(data=dtemp,samp~mono_m)) # no, p=0.09. So it was all due to outliers

summary(aov(data=dadj,samp~mono_m)) # Total: Yes (even if outliers); 0.03
summary(aov(data=dadj,samp~group+mono_m)) # within: 0.005
ds = dadj %>% group_by(group) %>% 
  summarize(mono_mm=mean(mono_m,na.rm=T), sampm=mean(samp,na.rm=T))
dres = merge(dadj,ds,by="group") # Let's look at full within-groups residuals
dres$mono_m = dres$mono_m-dres$mono_mm
dres$samp = dres$samp-dres$sampm
cor.test(dadj$mono_m,dadj$samp) # Total: barely 0.03, -0.17
cor.test(ds$mono_mm,ds$sampm) # Between: no: p=0.2, 0.66
cor.test(dres$lat_m,dres$sbend) # Within: no: 0.6, 0.04 

ggplot(data=dadj,aes(-mono_m,samp)) + theme_bw() + geom_point(aes(color=group),alpha=0.1) + 
  geom_point(data=ds,aes(-mono_mm,sampm))

summary(aov(data=dadj,samp~poly_m)) # Total: no, p=0.0502
summary(aov(data=dadj,samp~log(1-poly_m))) # yes, sorta 0.04
ggplot(data=dadj,aes(log(1-poly_m),samp)) + theme_bw() + geom_point(aes(color=group),alpha=0.1) + 
  geom_smooth(method=lm,se=F)


# Temporal-amplitude crossovers
summary(aov(data=dadj,samp~group+lat_m)) # no
summary(aov(data=dadj,sbend~group+poly_m)) # no
summary(aov(data=dadj,sbend~group+mono_m)) # yes 0.03
summary(aov(data=dadj,sbend~group+log(1-mono_m))) # yes 0.006
ggplot(data=dadj,aes(log(1-mono_m),sbend)) + theme_bw() + geom_point(aes(color=group),alpha=0.5) + 
  geom_smooth(method=lm,se=F) + facet_wrap(~group)


# Means and dispersions
ggplot(data=d,aes(-poly_m,poly_s)) + theme_bw() + geom_point(aes(color=group)) +
  facet_wrap(~group)
cor.test(-d$poly_m,d$poly_s) # p=2e-16, r=0.7
ggplot(data=d,aes(group,-poly_m)) + theme_bw() + geom_point() # No change in mean
summary(aov(data=d,poly_s~group)) # 0.02
summary(aov(data=d,poly_s~rostral+medial+group)) # 0.005
summary(aov(data=subset(d,poly_s<10),poly_s~rostral+medial+group)) # 0.09, after only 4 cells cut off

ggplot(data=d,aes(group,lat_m)) + theme_bw() + geom_point() # lat m are somewhat different
ggplot(data=d,aes(lat_m,lat_s)) + theme_bw() + geom_point(aes(color=group)) +
  facet_wrap(~group) # No obvious shape, and not much diff in spread



