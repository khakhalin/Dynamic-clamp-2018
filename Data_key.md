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
  * 0\. Control: proper control group (spent 3 hours on a gray background)
  * 1\. Crash: gradual reversals of the grid (see "Methods")
  * 2\. Flash: instantaneous reversals of the grid
  * 3\. Sound: sound clicks + gray background
  * 4\. Sync: visual flashes, paired with sound clicks
  * 5\. Async: visual flashes (provided without sound), and clicks provided exactly in-between two flashes
  * 6\. SlowC: Crashes, but delivered NOT once every second, as in groups 1-5, but once every 3 seconds. These cells were not included in the final analysis.
  * 7\. SlowF: Flashes, but delivered NOT once every second, as in gropu 2, but once every 3 seconds. These cells were not included in the final analysis.
  * 8\. Naive: cells that went through no conditioning; essentially, an incorrect control group. These cells were not included in the final analysis.
* stage - tadpole stage. 48 for stage 48; 49 for young stage 49; 50 for older, larger stage-49 tadpoles (they would still be classified as stage 49, according to Nieuwkoop and Faber, 1994)

Cell basic properties:
* ra - access resistance, mOhm
* rm - membrane resistance, GOhm
* cm - membrane capacicty, pF
* ihold	- current required to bring the cell to -60 mV, in pA
* rostral - how caudal the cell was, in arbitrary "screen units". In the script 'dynamic_other_vars.R' this value is then recalcualted to true "rostral", and measured in percent. The reason for this weird way of measurement is an unfortuante suboptimal choice that was made early, and then maintained during the whole data collection period.
* medial - how lateral the cell was, measured in relative units. Similarly, is adjusted (reveresed, and changed to percent) in the processing script.

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
* mono_m - mean monosynaptic current, pA
* mono_s - trial-to-trial standard deviation of monosynaptic current, pA
* poly_m - mean late, polysynaptic current, pA
* poly_s - standard deviation for late, polysynaptic current, pA
* lat_m	- mean latency, ms
* lat_s - trial-to-trial standard deviation of resonse latency, ms

Current step injections:
* stepspike - number of spikes in response to current step injections
* thslope - a slope of spike threshold increase with increasing current injections, in current clamp mode, mV/pA

### data_manualCounting.txt	

Results of manual counting of spikes via Matlab GUI interface **dynamic_dynamic_reader.m**. Can be used to verify consensus data at **data_outDataset.txt**.

### data_outDataset.txt	

Consensus total number of spikes generated in each sweep, for each cell, in the dynamic clamp protocol. Arranged in a simple 3-column manner: Cell_id, Sweep#, Number of spikes. 

### data_spikeShapes.txt

For each cell, quantifies average spiking, amplitude tuning, and temporal tuning of spikiness in the dynamic clamp experiments. Produced by **dynamic_spikes_plot.R**, based on the data from **data_outDataset**. These numbers were latere integrated into the **data_mainInput.txt** summary table.
