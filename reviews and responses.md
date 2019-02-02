Reviews and Authors' Responses for (Busch Khakhalin 2018)
======================

This is a collection of reviews and feedbacks, both official and unofficial, for different working copies of this paper. Reviews are split into paragraphs, and Author's responses and comments are shown after each paragraph. Reviews, and responses to these revivews, are given in reverese chronological order.

# Reviews from J Neurosci, 2018 Nov 01 (rejection letter)

These reviews were received on Nov 1st 2018 from J Neurosci, as this paper was rejected by the editor. We decided to include these reviews to our next submission, and to this repository, and provide our responses to each of the critiques.

## Reviewer #1

> The study is full of clever ideas and technical expertise, but it is too phenomenological and descriptive at this point, lacking a systematic step by step dissection of the underlying mechanisms. The hypothesis is fascinating but it isn't really tested directly.

> This paper takes advantage of the Xenopus laevis tadpole optic tectum as a model system for examining how prolonged (4h) exposure to specific forms of conditioning sensory input to a neuron alter its intrinsic excitability and tuning for firing action potentials. Using the dynamic clamp method the authors show that cells exposed to intensive (presumably brief) visual (but not other sensory) stimulation shift their preferred input to favor shorter-lasting synaptic inputs, which the authors describe as "adaptive" plasticity that allows the cell to fire in response to the stimuli which it recently experienced. They also discovered a so-called homeostatic plasticity within conditioning groups such that those cells that have brief rapid responses to optic chiasm stimulation tended to prefer long slow inputs whereas cells with slower repsonses seemed to be tuned to brief inputs. None of these properties correlated with position in the tectum and therefore with presumptive cellular maturation.

> Although the central question and ideas that make up this paper are very interesting and potentially constitute a very new way of thinking about plasticity of intrinsic excitability, the paper is almost entirely descriptive and phenomenological, with a number of holistic inferences that, although thought provoking, are not necessary covered withing the scope of the experiments presented. For example, the idea that adaptive vs. homeostatic mechanisms are at play infers too much of a desired outcome for the system without any real justification for such an attribution, especially without having characterized the actual network responses to the conditioning stimuli used. Maybe the plasticity doesn't serve the purpose of making the cells more sensitive or regulating dynamic range. Perhaps it does something useful but unanticipated for the network as it functions in the entire animal. We don't know and shouldn't presume. Also there were numerous points where the data presented here disagree with previous publications by the senior author and although some handwaving explanations were provided, no actual experimental evidence for these differences was presented.

> A reasonable attempt was made explain the conditioning changes observed at a more mechanistic level, but at least for the dynamic clamp experiments the authors were unable to account for their observations based on traditional mechanisms for regulation of intrinsic excitability. Overall the paper is fascinating and introduces a potentially interesting new way of thinking about plasticity, but doesn't quite provide enough of a mechanistic underpinning nor of a functional context for the model. It comes across as a slightly contrived set of systematic observations. The paper has a few minor technical issues, but suffers mainly from failing to systematically test any hypothesis in a satisfying and reductionist way. The paper would likely be better suited either for a more specialized cellular neurophysiology journal or, if the narrative can be tightened up to clearly convey its novelty, for a short format high-impact report.

&nbsp;

We are grateful for the kind words, and agree with the assessment that our paper is largely phenomenological. Unfortunatelly, in a small teaching-oriented college, we simply cannot run most experiments needed to probe the mechanisms of intrinsic temporal tuning. We cannot perform in-vivo experiments with sensory stimulation; and cannot measure or change gene expression in isolated tectal cells. Even a detailed electrophysiological study of isolated ionic currents would have taken extra 2-3 years, so we decided to publish this phenomenological report, in a hope that the very phenomenon we describe is interesting enough to be followed up by other labs, potentially in different models.

In this, updated version of the paper, we try to be more explicit about possible next steps that may be taken to study the mechanisms behind the exciting phenomenon we discovered.

### Specific points:

> 1.	Page 2, Line 29 the word "thorough" is not appropriate here. If the search had been thorough, an answer would have been found. Instead "extensive" may be more appropriate.

Corrected.

> 2.	Page 2-3, The dynamic clamp is not very commonly used. It would be useful to provide more detail about how it differs from simple step injections of current and why this might matter.

Thank you for reminding us about that! We now added a one-sentence description of dynamic clamp into the last paragraph of the intro section:

"Unlike for more common voltage and current clamp techniques, in dynamic clamp, the electric current injected into the cell is dynamically adjusted, based on a predefined formula that depends on cell membrane potential and time."

> 3.	Page 3 line 18, "when tadpoles were exposed to" -> "in tadpoles that had been exposed to"

Corrected.

> 4.	The statistical tests applied throughout the paper are unclear and need more explanation. The number of degrees of freedom (e.g, 667) seems far too high, suggesting that multiple recordings from the same cell under different conditions are being treated as independent N. However recordings from the same cell under different temporal or amplitude conditions are far from independent measurements. It seems that a two-way or even three-way ANOVA might be the best approach for examining the variables of conditioning stimulus and response property. 

The number of degrees of freedom in question comes from a full linear model, and does not mean that we treated different conditions as independent. Typically, to compare the numer of spikes in two conditions we used a 3-way ANCOVA (injection amplitude and duration as ordinal variables; group id as a nominal variable) with interactions, and repeated measures (where cell id included as a nominal variable). For example, for a comparison of "Control" group to "Sound" group we used the following R code (see `dynamic_spikes_plot.R` for the full code):

```R
ds = subset(d,is.element(Group,c("Control","Sound")))
summary(aov(data=ds,Spikes~Shape*Amp + Shape*Group + Amp*Group + Cell*Shape*Amp))
```

In addition to a full description of our analysis approach, as given in the "Methods", we now included a second, shoter description of it in the "Results" section, to make the paper more readable. We also improved the description in the "Methods" section; and added several extra referrals to the "Methods" section from the "Results" section, to remind the reader that extra information is available there. In particular, in the sentence that reports the first F-value for this study, we now added the following commentary:

"F(1,677)=30.4, p=5e-8, n cells=28, 29. Here and below, when F-values are reported, we use 4-way fixed effects analysis of variance with selected interactions, and cell id included as repeated measures factor, see "Methods" for a detailed description."

> 5.	Page 5 line 19 "This suggests that unlike the change in overall intrinsic excitability, the average temporal retuning was "adaptive" rather than "homeostatic", as neurons exposed to shorter stimuli (flashes) became more equipped to process shorter activation patterns." While it is appealing to give a name to this form of plasticity, the looming stimulus, which can be thought of as slower than the flash nonetheless caused a similar type of shift in response preference in the neurons, which runs counter the notion that there exists a meaningful dichotomy of adaptive vs. homeostatic change here.

We think that there exists a certain dichotomy here, but we agree that our description of it was not clear enough. We now replaced it with the following, longer exposition:

"... This suggests that the change in overall intrinsic excitability, and the change in temporal tuning, follow two different kinds of logic. The overall excitability is homeostatic, as neurons became less excitable in response to stronger stimulation. The temporal retuning however can be better described as “adaptive”, as neurons exposed to shorter stimuli (flashes) became relatively *more* responsive to shorter stimuli, and less responsive to longer stimuli, which is opposite of what one would expect for a homeostatic retuning. We chose to call this type of plasticity "adaptive", as presumably it means that after exposure to faster stimuli, neurons become more equipped to process faster patterns of activation."

> 6.	Figure 2B Amplitude is misspelled.

Fixed.

> 7.	The narrative logic on page 9 lines 11-22 is confusing. How does homeostatic plasticity, if it truly is at play here, "increase their ability to respond to unusual patterns of synaptic activation." If anything wouldn't homeostasis decrease dynamic range by pushing all cells toward a central set point?

We agree that the word "homeostatic" was confusing in this context. We now simplified the sentence:

"This means that individual neurons tended to tune their intrinsic properties away from the typical statistics of their inputs, decreasing their responses to common input patters, and enhancing responses to unusual patterns of synaptic activation."

> 8.	Page 12 the section on position within the tectum feels like it was just tacked onto the end of the paper. This should be integrated earlier in the paper perhaps to go with figure 1A.

We placed the decription of this effect at the very end of the paper, as we prefer to downplay it a bit, as it was described previously (Khakhalin 2012; Hamodi 2012; Ciarleglio 2015), and we don't want to distract the reader from our other findings. At the same time, we find it important to mention that we observed a strong correlation with position: first, because it provides an independent replication of previously observed patterns, and second, as the dependency of cellular properties on position necessitated an adjustment for position during analysis (see "Methods"), which needed to be justified. The implication for the principle of parameter degeneracy in development (Prinz 2004) is also interesting, and we wanted to point at it, even though within this paper we don't have enough material to fully explore this theme.


## Reviewer #2

> There is indeed some merit in the goals of the study (to see if adaptation changes with experience in addition to conductance/response gains), but it has so many technical problems at present that it would need to be radically different (perhaps with experiments and analysis re-done) to perhaps be of interest to the broad readership of J Neuroscience.

> The manuscript by Khakhalin and Busch describes the impact of experience on the intrinsic response properties of tectal neurons in the developing tadpole. The authors describe a surprising phenomenon: not only is the response gain of the conductance response altered by experience (in a homeostatic manner, if we imagine that the experience produces increased activity, which isn't shown), but the adaptation of the response is also impacted. The authors then go on to make some arguments, in my opinion unconvincing, that properties of the duration of the polysynaptic response to an optic chiasm shock are related to these intrinsic properties.

> The paper is, in my opinion, hard to read because the authors are often not clear about what they mean, refer to previous parts of the paper assuming the reader has a perfect memory or is willing to turn back and forth across pages, and use non-traditional terminology. In addition, the statistically analysis appears to be pooling many data points from non-independent cells, rendering many of the conclusions invalid. Further, the experiments intended to measure intrinsic properties (in Figures 1 and 2) appear to have been performed without synaptic blockers, so the the adaptation that they measure could be in the circuit (inhibitory recruitment) instead of in the intrinsic properties.

> There is indeed some merit in the goals of the study (to see if adaptation changes with experience in addition to conductance/response gains), but it has so many technical problems at present that it would need to be radically different (perhaps with experiments and analysis re-done) to perhaps be of interest to the broad readership of J Neuroscience.

&nbsp;

On excessive cross-references between different parts of the paper: thank you for pointing it out! We now tried to link different parts of the paper more tightly together, by gently reminding the reader about previously made statements every time we make a reference.

On statistical analysis: we do not pool data points from non-independent cells, but used a repeated measures analysis, verified by mixed model analysis (see Methods, as well as corrections described above, in our responses to Reviewer 1).

On synaptic blockers: it is true that we measured intrinsic properties without synaptic blockers, but this is considered a standard practice in this preparation, as most earlier studies measured IV curves without synaptic blockers (Azenman .. Cline 2002; Aizenman .. Cline 2003; James .. Aizenman 2015; Ciarleglio Khakhalin .. Aizenman 2015). What makes this practice possible is a relatively weak recruitment of polysynaptic activity after activation of a single tectal cell (Bell .. Aizenman 2011).

### Specific points:

> Introduction:

> Page 3, line 23: Sentences that begin "First" and "Second" need subjects

We now added "we asked" to both sentences, which makes "we" a subject.

> Page 3, line 34: "spikiness" -> not a precise word. "Changes in f-I curve", perhaps? Or "Average firing rate"?

We think that this word well reflects the nature of the property we are describing (the property of being easily excitable, and able to generate spikes), and we also think that we define it rather precisely within thiss paper. We prefer it to other alternatives, as they are rather too general ("intrinsic excitability") or too bulky ("ability to produce spikes in response to stimulation"). 

Of the two options offered by the reviewer, the first one ("Changes in f-I curve") is both too long, and does not reflect the nature of our measure, as with it we are trying to assess average ability to produce spikes, not a change of any sort. The second one sounds good and standard, but is actually somewhat misleading, as the term "Avereage firing rate" is defined rather precisely as the average rate at which a neuron fires in the network; usually either in the context of in-vivo recordings, or in-vitro spontaneous activity. Accordingly, a true "Average firing rate" for our neurons would depend both on their intrinsic properties (perhaps the measure we call "spikness here"), *and* the strength of their synaptic inputs, as well as their position within the network. In short, while "Average firing rate" is an important property, in this study we did not address it, nor had an opportunity to observe a proxy for it.

> Page 3: "traces left by multi sensory stimuli in the tectum of freely behaving tadpoles" -> unclear what is meant by the this sentence until later; suggest re-word

Reworded: "for the first time we were able to look at tectal network retuning in response to multisensory stimuli in freely behaving tadpoles."

> Results

> Page 4, line 6 "the stimuli we used were weaker" What is meant, the stimuli in the previous studies were weaker, or the stimuli in the present study? Maybe say the previous stimuli were very high contrast and did not reflect contrasts used in behavioral studies. Here, we presented a checkerboard"...

Changed to "the stimuli we used in the present study were weaker".

> Page 4 line 19 "spiky" again, imprecise

We like the word "spiky", as it captures the phenomelogical effect without making assuptions about underlying mechanisms. It is also intuitive and short, which aids understanding.

> Page 4, lines 21-24. I'm really confused about the degrees of freedom. Are you all loading in all observations from all cells? If so, the assumption of the statistical test that these are independent observations is violated. Many of these values were measured in the same cells with different current levels, so they are clearly not independent measurements. The analysis should essentially contain one observation per cell. (One "gain" value or number of spikes to some stimulus, etc..) Or could do a multi-variate ANOVA...

We did in fact run a linear model with repeated measures that may be vaguely described as multi-variate ANOVA; see responses above.

> Page 4: Lines 27, 28: This sentence is missing conjunctions "in order to map their amplitude transfer function" ?

Reworded: "We then mapped the amplitude tuning of neurons (also known as amplitude transfer function, or gain), by looking at how an increase in transmembrane conductance translated into increased spike output."

> Page 4: Lines 27, 28: What exactly is meant by the amplitude transfer function or amplitude tuning? Is there an equation?

At this point we describe tuning as an empirical curve (something that can be plotted in a figure, and compared from cell to cell), but do not yet use any equations. Later in the text we parameterize these curves, and provide all related equations.

> Page 4, lines 27 - 33: what figure panels are being described here? 

We added a reference to (Fig 1D,E).

> Page 6, lines 10-20. The authors point out that the amount of response adaptation in the conductance vs. number of spike curves varies as a function of the stimulus that the animal was exposed to. While it is true that this information can be gleaned by examining Figure 1E, the authors would be well served to make a second index, such as an adaptation index, in a panel F. This would really drive home the points the authors would like the reader to take away from the Figure. (I missed it the first time through, I just saw the reduced gain in Fig. 1E, not the adaptation.)

We introduce adaptation index (parametrized quantification of temporal tuning) later in the text.

> Page 6, lines 10-20. Need to cite Figure 1E

Done.

> Page 6, line 22: "homologous to superior colliculus"

Fixed.

> Page 7, line 3: after multi sensory stimulation, "tectal neurons were more excitable than after visual stimulation alone). Many issues. The average number of spikes is reported.. Is this across all conductance curve conditions or just one of them? 

The averages were calculated across all testing conditions; we added this info to the sentence: "after four hours of multisensory stimulation, tectal neurons were more excitable than after visual stimulation alone (0.6$\pm$0.4 spikes, F(1,689)=11.2, p=8e-4; and 0.7$\pm$0.6 spikes, F(1,665)=41.7, p=2e-10, for sync and async respectively, across all testing conditions)."

> Next, in Fig 1E, "sync" and "flash" and "looming" all look pretty similar to each other. 

We think that it rather reasonable that effects of going through some stimulation, compared to control, are stonger, than differences between different types of stimulation. We explore this question in detail further in the text.

> What are the degrees of freedom? Again, they seem very high like each condition might be being treated as independent.

See other comments above. Generally, unless a mixed model is used, the second value for degrees of freedom, defining F-distributions, is close to the total number of measurements recorded in a study, even if a multivariate analysis of variance is used, and even for nested non-independent designs, such as blocking or repeated measures analysis. For our study in particular, the only way to bring the second value for degrees of freedom down, making it closer to the number of cells, rather than to the number of measurements, would be to use a mixed model. We used a mixed model in our senstivity / verification test, and observed that it provided qualitatively similar results, as described in the method. We however reported a fixed model everywhere else, as it is more straightforward, and, in our opinion, more consistent.

> More stats: Are these multiple comparisons across conditions done in an unbiased manner, like with a Bonferroni correction or an ANOVA? It seems not.

1) As described above, we used a family of similar generalized linear models, followed by F-test for the analysis of variance, to compare across conditions. This type of analysis may be loosely referred to as ANOVA, although most textbooks would not recommend referring our models as an "ANOVA", as it included two ordinal variables, and a factor to account for repeated measures.

2) It is true that in our analysis we compared several pairs of conditions: Flash to Control, Looming to Control, Flash to Looming, Sound to Control, Flash to Sync, and Flash to Async. However, all of these comparisons were easily interpretable, as they form a logical progression of stimuli. These planned comparisons consistuted a small share of all possible post-hoc comparisons between groups that one could have run on this data (6 out of 30 possible pairs). Typically, for planned comparisons, researchers do not use an adjustment for multiple comparisons.

3) Finally, in this paper we report exact numbers all p-values, instead of indicating whether they were above or below any arbitrary threshold. This gives the reader the freedom to interpret our data against any significance threshold of their choice. As expected, some p-values were larger, and some were smaller, but we are confident that our overall conclusions are reasonable, expecially if comparing different pieces of evidence across the entire study.

Together, this makes us reasonably confident that a Bonferroni correction would be unnecessarily punitive for this type of analysis.

> Page 8, lines 2-12. "Average firing rate" is a more common term than "spikiness". 

Please see our comments above. The term "average firing rate" is typically used to refer to actual average firing rates, either long-term or instaneous, in situations when relatively realistic neural activity is possible, such as in-vivo recordings, or during spontaneous activity. We however looked at a rather artificial excitability index, and we would prefer to stress that by naming this index, and defining it within the study.

> How about "gain" for amplitude tuning? I see that the authors are using the parameter a to indicate the non-linearity in the tuning curve. For "temporal tuning", why not use "adaptation index" or something like that, that could be plotted in Figure 1F? The "temporal tuning" is a measure of non-linearity, but it is not very intuitive. (It is not "incorrect" as the authors have it now, but I think it would be hard for the interdisciplinary readership of J Neuroscience to get on board easily.)

We would really prefer to retain terms "amplitude tuning" and "temporal tuning", as they better represent the main message of our paper, as we are trying to think of these values not in terms of abstract properties each neuron has, but as parameters that can tune a neuron to a certain type of synaptic inputs, in terms of their temporal properties, and their amplitude. We however now included words "gain" and "adaptation index" in paragraphs that introduce values of amplitude and temporal tuning, respectively.

> Figure 2: Units needed for Y axis on A, B (units of a are spikes per conductance squared and units of amplitude tuning are spikes/conductance)

Both tuning parameters are dimensionless, as both conductance and amplitude were treated as rank-transformed, ordinal values (see methods).

> Page 8, about line 9: It is false that the numerical values are not interpretable, they are in an equation and have units.

We now replaced "not interpretable" with "not easily interpretable". We wanted our readers to know that a comparison of these values can be interpreted very easily, while exact numbers (say, 0.82) do not carry that much narrative weight.

> Page 8, line 16-19: Cohen's D tells the discriminability rather than whether there is a difference between two quantities. A test like the Hoteling-2 test can provide significance measures for whether the means of the data in 2C are significant.

We initially reported Cohen's d values as a measure of effect sizes, not as a quantification of significance. Now we also ran Hotelling t-squared tests on 2D sets of points, representing amplitude and temporal tuning values for different cells, across different groups.

> Page 8, lines 26-35: Rather than only saying that groups that were significantly different in average values were also significantly different in variability, name the groups again. (Otherwise the reader has to jump all around.)

> Figure 2B and Figure 3A, 3D don't show any post-hoc comparisons among the groups. Which groups differ? I see it in the text but it is hard to take it home.

We added asterisks to mark significance in figures.

> Figure 3E and G: how can we reconcile these accounts? In each of the groups (3G), there is at best a very weak relationship between temporal tuning and synaptic duration. Somehow, if you take the means of all of these groups, you can fit a line through them (Figure 3E). Why is that the right thing to do? Aren't the field of individual points (partially-transparent background) and the data plotted in 3G the relative quantities?

We now added a paragraph describing this situation in detail, and reference a textbook name for this type of situation, when between-group and within-group analyses yield seemily opposite results (Simpson's paradox).

> Figure 3C shows that monosynaptic amplitude and synaptic duration are correlated, as one would expect from the definition of synaptic duration (center of mass). Basically, as the monosynaptic amplitude gets bigger, the center of mass will shift earlier and earlier. So what independent information is really being conveyed in the synaptic duration? The correlation in 3C is so strong, I don't see that it is truly an independent quantity that teaches us something beyond the monosynaptic input strength. The monosynaptic input strength is much more defined, why not use that for examining correlation with temporal tuning (or adaptation index), average firing rate, and gain. The "synaptic duration" isn't really a measure of synaptic duration, which makes Page 10, lines 3-23 really hard to interpret.

When comparing temporal properties of synaptic inputs to that of intrinsic tuning, it is important to make the two measures as similar (matching) as possible, as methodologically it is supposed to increase the power of our comparisons. In practice, if for intrinsic properties we quantify non-linearity of responses to currents of different duration, then we need to estimate current duration for our synaptic inputs. In other words, while synaptic current duration is largerly just a different way to quantify the relative impact of polysynaptic activity, it is a necessary step for a good analysis. We now reworded two sentences at the beginning of paragraph in question, to hopefully make this point more clear:

"To better match and compare temporal properties of synaptic inputs to those of intrinsic tuning, we calculated average "synaptic current duration" for each cell as a temporal "center of mass" of currents within the first 700 ms after optic chiasm stimulation (see "Methods"). Neurons with different contribution of early and late synaptic responses naturally had different synaptic current duration: cells with strong monosynaptic inputs had shorter currents, while polysynaptic activity made synaptic currents longer (Figure 3C; p=2e-16, r=$-$0.78, n=168)."

> Figure 3G, page 10 lines 24-40. Creation of "super groups" is totally bogus. This part should be dropped. I see no strong significant relationship between temporal tuning and synaptic duration, and am not convinced synaptic duration is a meaningful quantity.

We now removed this paragraph. In response to this comment, we initially attempted a different analysis of the interaction between synaptic and intrinsic properties across groups, but while some reasonable types of comparisons were significant, this analysis lacks power, and relies too much on post-hoc reasoning, so we decided to follow the advice and just remove this paragraph entirely. While we still believe that stronger stimulation (in terms of its effect on average intrinsic properties) generally caused stronger disruption of the synaptic-intrinsic correlation, this statement is hard to fully justify with our current data.

> I am very confused by Figure 4. Is it supposed to tell us that average firing rate is correlated with sodium channel conductances? Why is this experiment being done? What do we learn about the brain? I mean this genuinely, I feel I do not understand what the authors are trying to say that is novel. Of course we would expect such a relationship. Why not show the 8 parameter model fit of the current tuning curves?

In the previous version of this paper we tried to show correlations of 2 types of spiking (those recorded in current and dynamic clamp modes) with Na conductance, to illustrate that one of the correlations is much stronger than the other. We agree however that showing the 8 parameter model fit is much better way of illustrating this point. We now show two scatterplots, for both dynamic and current clamp data, in which values predicted by the 8-parameter model are compared to actual measurements. It is clear to see that one of the models (that for current clamp data) works much better than the other one (for the dynamic clamp data).

> Page 11, "the mechanisms behind temporal intrinsic plasticity". I'm confused. This section and Figure 4 seems to focus on average firing rate / spikiness rather than the temporal tuning parameter. So why the heading?

Different fields have different criteria for what level of explanation is low enough to count as "mechanistic". Had we reliably predicted cell phenotypes (spiking) from their low-level electrophysiological properties, especially across treatment groups, we would have comfortably called it a mechanistic explanation. We show that for one type of measurements (current clamp), we have a tolerable level of mechanistic understanding of differences in observed cell excitability, while for more nuanced dynamic clamp experiments this mechanistic understanding is clearly lacking.


> Discussion: 

> Page 13, lines 18 - 24: the authors refer to the questions they asked in the introduction, without re-describing them. The reader cannot possibly remember and is forced to page back and forth. The writing must be so much better.

We reworded the beginning of the discussion, to make sure that we re-state any questions before providing the answers.

> "intrinsic plasticity does not simply adjust neuronal spikiness, but can regulate selectivity for inputs of different dynamics". How are the input dynamics different? I only see that monosynaptic magnitude is different across the conditions. The duration parameter does not reflect duration, just a weighted average of where the most input arrives, and is not related to the whole duration of synaptic input in a manner independent of the initial volley of input.)

The "synaptic duration" value is higher for those synaptic inputs that last longer (have a long polysyaptic tail after the original bout of monosynaptic currents), and is smaller for those inputs that are short (mostly limited to monosynaptic currents). Therefore, we believe that duration value does capture and reflect the duration. We chose the "weighted average" approach (the center of mass), as strictly speaking, in the presence of spontaneous activity there is no point when the synaptic resonse is truly over, and one has to go for a different way to quantify it.

While preparing this paper, we actually also tried a different way to estimate synaptic durations: we attempted to fit all synaptic currents with the same curve that we used for simulated conductances in our dynamic clamp experiments ( g*(t/tau)*exp(1-t/tau) ). While this idea seemed good in theory, in practice the synaptic curves were too variable in terms of their shape, decay, latency, and the amount of noise, making most curve fits were really bad, which made us go for a simpler, and a more parsimonuous measure.

> "we show that synaptic and intrinsic temporal properties of neurons are homeostatically co-tuned" what does this mean?

We now made the Discussion section a bit longer, and so used longer, simpler statements, when describing the co-ordination of synaptic and intrinsic properties. For example, the sentece in question was replaced with this sentence: "In answer to our second question, about whether intrinsic and synaptic properties of tectal cells are in any way coordinated, here we show that intrinsic and synaptic temporal properties are co-tuned in the tectum, and moreover, that this co-tuning can be modified by sensory experience."


# Reviews from eLife, 2018 Aug 17 (rejection letter)

> ...While both BRE members found much to like about the manuscript, they found it dense going. But they both felt this paper belongs in a more specialized journal. A comment from one of them: 

> The authors pose two questions in the introduction: 1. Is intrinsic plasticity limited to changes in excitability? 2. Whether intrinsic plasticity is a response to synaptic activation? There are data in other systems that make these questions "straw men". We know from the STG that intrinsic plasticity is not limited to change in spikiness alone and that there are several other parameters such as bursts, rebounds, spike widths etc which can and do get altered in the short and long term. There are also plenty of examples where one ion channel expression is co-regulated with another type of ion channel, or by slow action of growth factors, hormones and other neuromodulators. These are examples of intrinsic plasticity not governed by fast synaptic transmission alone.

This is of course true, but while many types of intricate effects of intrinsic plasticity are described in small networks, and especially in oscillatory networks, such as the STG, it is less common to consider these non-trivial effects in large feed-forward excitatory networks, such as networks in the cortex, or superior colliculus. It is natural for researchers to limit the complexity of their conceptual and computational models, and it is probably fair to say that as the number of neurons involved in a model increases, researchers often shift their attention from intrinsic mechanisms to connectomic approaches, approximating neural networks as a collection of nodes, linked with synapses of different strengths (e.g: Cline 2008; Kirby 2013). Even realistic biophysical models that represent neurons as multi compartment systems with active dendritic currents often don't assume that these active currents may be modulated in response to activation (Moldwin 2018). When machine learning approaches are used as a model for brain development, intrinsic excitability is reflected in these models, as a change in activation function of each artificial neuron (Marblestone 2016). This type of modeling implicitly assumes, however, that outside of obviously oscillatory networks (spinal cord, thalamus, etc.), intrisic excitability in biological networks is largely confined to overall changes in neuronal "responsiveness".

Here we show that even for large-scale feed-forward networks that do not seem to rely on oscillations, changes in intrinsic excitability go well beyond variations in "spikness". We think that it is an interesting observation, that may have far-reaching effects on network computations, and network development. We also predict that similar effects of temporal tuning may be observed in other systems, such as mammalian cortex.

In the new version of this manuscript, we added a few sentences to the introduction, trying to make our message more clear, and also more nuanced.

&nbsp;

References:

Cline, H., & Haas, K. (2008). The regulation of dendritic arbor development and plasticity by glutamatergic synaptic input: a review of the synaptotrophic hypothesis. The Journal of physiology, 586(6), 1509-1517.

Kirkby, L. A., Sack, G. S., Firl, A., & Feller, M. B. (2013). A role for correlated spontaneous activity in the assembly of neural circuits. Neuron, 80(5), 1129-1144.

Marblestone, A. H., Wayne, G., & Kording, K. P. (2016). Toward an integration of deep learning and neuroscience. Frontiers in computational neuroscience, 10, 94.

Moldwin, T., & Segev, I. (2018). Perceptron learning and classification in a modeled cortical pyramidal cell. bioRxiv, 464826

> That aside, the authors make a big deal out of 'temporal tuning' but to me from fig 1 this looks like non-preference towards syn duration more than preference for any temporal window, as argued by the authors (compare fig 1E panels). 

We think that a preference or non-preference for a certain synaptic duration can be described as a change in temporal selectivity. In the optic tectum, this temporal tuning is not as obvious as it would have been for an oscillatory network, as tectal neurons don't seem to express typical ionic currents associated with oscillatory networks (such as the h-current). Still, one can argue that it only makes our discovery more interesting: we show that neurons can change their temporal properties, even though they don't seem to be equipped with currents most researchers associate with temporal selectivity.

> There are other methodological issues as well: Did they randomize the order of injections? 

No, the order of injections was always the same; it is now decribed in the "Methods".

> Is a syn current that is more than 250 ms long 'monosynaptic' ?

We did not quite understand the question, but generally, for this model, monosynaptic component peaks at about 5-20 ms, and is over by 50-100 ms, as described in the "Methods" section.
