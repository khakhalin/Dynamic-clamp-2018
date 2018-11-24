Dynamic clamp: Workflow Pipeline
==================

This document describes the workflow for the Busch Khakhalin 2018 project on dynamic clamp study of intrinsic plasticity.

# Programs

## Matlab

### dynamic_what_is_where.m

This file contains hard-coded file names for all cells and all protocols used in this study. Our CED digitizer was set up to name files in ISO standard (for example, 20151009 for 9th Oct, 2015), followed by an underscore, and file number within each day. During data acquisition, we recorded the number (id) of each file in a spreadsheet, for each of the protocols (iv, step, dynamic clamp, synaptic, and minis). Later we exported this spreadsheet as a text table, and then hard-coded it is a Matlab matrix, as this was easier than reading a TXT file from a drive. Each Matlab file that reads data from a drive calls this function at the very beginning, and thus gets access to the same verified list of files to load.

We then went through every cell, and verified that all references are correct. One row had a typo, and also 5 files were corrupted, which is all described in the `dynamic_what_is_where` file itself.

All data files were originally stored in folders with funky names (`Cell A`, `Cell B`, `Cell A` etc.). The problm with these folders is that they go in a strange sequence (`Cell B` does NOT come after `Cell A`), and the only way to match new cell ids (simple integer numbers) to old cell ids is to look at a table. 

### dynamic_alpha_curve_tester.m

Short simple script that builds an alpha curve: $y = \frac{t}{\tau}\cdot \text{exp}(1-\frac{t}{\tai})$, for calibration, and for the figures in the final paper.

### dynamic_dynamic_reader.m	

dynamic_iv_reader.m			

dynamic_minis_reader.m		

dynamic_steps_reader.m		

dynamic_synaptic_reader.m	

dynamic_temporal_reader.m	

## R

silas_othervars.R

silas_spikes_plot_2017.R



# Data files

data_mainInput.txt	

data_manualCounting.txt	

data_outDataset.txt	

data_spikeShapes.txt	
