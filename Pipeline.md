Dynamic clamp: Workflow Pipeline
==================

This document describes the workflow for the Busch Khakhalin 2018 project on dynamic clamp study of intrinsic plasticity.

# Stimulation programs

TODO

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
  0. Control: proper control group (spent 3 hours on a gray background)
  1. Crash: gradual reversals of the grid (see "Methods")
  2. Flash: instantaneous reversals of the grid
  3. Sound: sound clicks + gray background
  4. Sync: visual flashes, paired with sound clicks
  5. Async: visual flashes (provided without sound), and clicks provided exactly in-between two flashes
  6. SlowC: Crashes, but delivered less frequently TODO
  7. SlowF: Flashes, but delivered less frequently TODO
  8. Naive: cells that went through no conditioning; essentially, an incorrect control group; not included in final analysis
* stage - tadpole stage. 48 for stage 48; 49 for young stage 49; 50 for older, larger stage 49 (even though they would still be classified as stage 50, according to Nieuwkoop and Faber, 1994)
Cell basic properties:
* ra - access resistance
* rm - membrane resistance
* cm - membrane capacicty
* ihold	- current required to bring the cell to TODO
* rostral - how rostral the cell was, relative to the end of the tectum, TODO **Units?**
* medial - how medial the cell was, relative to the midline, TODO
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
* mono_m - mean monosynaptic current, pA **TODO - Is it true?**
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

# Programs

## R

### silas_othervars.R

### silas_spikes_plot_2017.R


## Matlab

### dynamic_what_is_where.m

This file contains hard-coded file names for all cells and all protocols used in this study. Our CED digitizer was set up to name files in ISO standard (for example, 20151009 for 9th Oct, 2015), followed by an underscore, and file number within each day. During data acquisition, we recorded the number (id) of each file in a spreadsheet, for each of the protocols (iv, step, dynamic clamp, synaptic, and minis). Later we exported this spreadsheet as a text table, and then hard-coded it is a Matlab matrix, as this was easier than reading a TXT file from a drive. Each Matlab file that reads data from a drive calls this function at the very beginning, and thus gets access to the same verified list of files to load.

We then went through every cell, and verified that all references are correct. One row had a typo, and also 5 files were corrupted, which is all described in the `dynamic_what_is_where` file itself.

All data files were originally stored in folders with funky names (`Cell A`, `Cell B`, `Cell A` etc.). The problm with these folders is that they go in a strange sequence (`Cell B` does NOT come after `Cell A`), and the only way to match new cell ids (simple integer numbers) to old cell ids is to look at a table. 

### dynamic_alpha_curve_tester.m

Short simple script that builds an alpha curve: y = t/tau * exp(1-(t/tau)), for calibration, and to generate figures for the final paper.

### dynamic_dynamic_reader.m

Interactive function, with a characteristig Matlab GUI, that allows the user to read all raw dynamic protocol data, one file after another, and for each one enter the number of spikes in each sweep. When the job is done, it writes this data down in a file 'manualCounting.txt'. It's better to analyze the data in chunks, save the files, then concatenate them.

### dynamic_iv_reader.m

Reads and automatically processes raw IV protocol data (in .cfs format). Measures average and peak currents for some pre-defined windows, and outputs them in the console, from where they can be copied further. All constants are defined at the beginning of this program.

### dynamic_minis_reader.m

A stub of a function that could have analyzed the minis data. This function was not finished, and the minis data was never analyzed.

### dynamic_steps_reader.m

Reads raw current step data (.cfs); attempts to automatically count the spikes using the inflection point methodology from (Ciargleglio Khakhalin ... Aizenman 2015).

### dynamic_synaptic_reader.m

Reads raw synaptic data; fits it with a mix of exponents, measures all synaptic properties used in this paper, outputs the full table in the console, to be copied. Can make very useful debugging figures, to illustrate the quality of fit for each cell.

### dynamic_temporal_reader.m	

A technical tool to transform spiking data from Excel that we originally used to track the number of spikes, into a TXT table. Was only run once. Essentially, this produced our first estimation of the number of spikes generated in each dynamic clamp experiment. Then another user would use **dynamic_dynamic_reader.m** to requantify this same data once again, and then we came up with a consensus estimation.

### Dependencies:

Some common functions used by more than one utility here:

* dispf - a custom mix between disp() and fprintf() that arranges outputs as a table, easy to copy


