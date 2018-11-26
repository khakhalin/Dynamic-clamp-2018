Dynamic clamp: Data Key
==================

A description of data files in this repository.

# Data files

### data_mainInput.txt	

Final summary table, containing the full set of measurements for every cell.

A key for the columns:

Experiment design:
* id - cell id
* old - whether the cell belongs to a set that was not included in the analysis, for being conditioned incorrectly. All cells with `old==1` were excluded. All cells with `old==0` were included in the analysis.
* oldid	 - first version of cell id, later abandoned
* animal - animal id: first a date in ISO format (YYYYMMDD), then underscore, then the # of an animal used that day
* groupid - id of a group. See next column `group` for an explanation
* group	- treatment group. This includes:
  0) Control: proper control group (spent 3 hours on a gray background)
  1) Crash: gradual reversals of the grid (see "Methods")
  2) Flash: instantaneous reversals of the grid
  3) Sound: sound clicks + gray background
  4) Sync: visual flashes, paired with sound clicks
  5) Async: visual flashes (provided without sound), and clicks provided exactly in-between two flashes
  6) SlowC: Crashes, but delivered less frequently TODO -----------
  7) SlowF: Flashes, but delivered less frequently TODO -----------
  8) Naive: cells that went through no conditioning; essentially, an incorrect control group; not included in final analysis
* stage - tadpole stage. 48 for stage 48; 49 for young stage 49; 50 for older, larger stage 49 (even though they would still be classified as stage 50, according to Nieuwkoop and Faber, 1994)

Cell basic properties:
* ra - access resistance
* rm - membrane resistance
* cm - membrane capacicty
* ihold	- current required to bring the cell to TODO -----------
* rostral - how rostral the cell was, relative to the end of the tectum, TODO ----------- **Units?**
* medial - how medial the cell was, relative to the midline, TODO -----------

IV block:
* nav - activation potential for Na currents, mV
* nai - amplitude of Na channels current, pA
* ktv - activation potential for transient K currents, mV
* kti - amplitude of transient K currents, pA
* ksv - activation potential for stable K currents, mV
* ksi - amplitude of stable K currents, pA

Dynamic block:
* smean	- mean number of spikes in dynamic clamp experiments
* samp - amplitude tuning: regression coefficient linking current amplitude to the number of spikes, in dynamic clamp experiments
* sbend	- temporal tuning: quadratic regression coefficient linking input duration to the number of spikes, in dynamic clamp experiments

Synaptic block:
* mono_m - mean monosynaptic current, pA **TODO ----------- Is it true?**
* mono_s - trial-to-trial standard deviation of monosynaptic current, pA
* poly_m - mean late, polysynaptic current, pA
* poly_s - standard deviation for late, polysynaptic current, pA
* lat_m	- mean latency, ms
* lat_s - trial-to-trial standard deviation of resonse latency, ms

Current step injections:
* stepspike - number of spikes in response to current step injections

### data_manualCounting.txt	

Consensus total number of spikes generated in each sweep, for each cell, in the dynamic clamp protocol. Arranged in a simple 3-column manner: Cell_id, Sweep#, Number of spikes. Produced manually by the **dynamic_dynamic_reader.m** (below).

### data_outDataset.txt	

### data_spikeShapes.txt