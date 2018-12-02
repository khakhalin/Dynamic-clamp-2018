Dynamic clamp: Workflow
==================

This document describes all scripts used in the Busch Khakhalin 2018 project.

# Stimulation

### checker_flash_ding.html

Stimulation program, used for sensory conditioning. A working version [can be found here](http://faculty.bard.edu/~akhakhal/checker_flash_ding.html). The copy in this repo will not be updated, to stay true to the paper, but updated versions may be posted to the [home depisotory for JS-based experimental protocols](https://github.com/khakhalin/js-experiments).

# Analysis

## R

### dynamic_other_vars.R

Main analysis file that compares tuning properties of each cell, as measured via the dynamic clamp protocol, to all other properties of every cell. Exclusively relies on the summary table **data_mainInput.txt**.

### dynamic_spikes_plot.R

Analyses everyting about dynamic data. Loads **data_outDataset.txt** data file, processes it, outputs to **spike shapes.txt**.

Also contains a module to compare consensus number of spikes from **data_outDataset.txt** to the results of blinded manual counting in **data_manualCounting.txt**.


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

* dispf - a custom mix between disp() and fprintf() that arranges outputs as a table, easy to copy ----------- TODO -----------


