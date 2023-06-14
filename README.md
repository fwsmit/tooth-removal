# tooth-removal
Tooth removal trainer made for the Amsterdam UMC

## Setup
- Install Godot Engine version 4.0 or higher from https://godotengine.org/ 
- Download this git repository
- Open the project.godot file in godot

## Running
You can run the project by clicking the run button inside Godot.


## Data analysis
Extractions are recorded to a file called `extraction_data_DATE.json`, for
example `extraction_data_2023-05-26T09;52;23.json`. It is stored in the
following directory:

`user://`

This is a special path defined by godot. The location of this path on your
system can be found [here](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html)

This data can be analyzed and plotted using the python program located in `python/analysis/dataAnalysis.py`.
The options are explained below:

```
usage: dataAnalysis.py [-h] [--update_index] [--fix_data] [--graph_frequencies] [--graph_force_torque] [--complete_analysis] [--generate_ft_plots] [--dir DIR] [--per_teeth] [--tooth TOOTH] [--jaw JAW] [--grouped]
[--person_type PERSON_TYPE]
[filename]

Show graphs of sensor data

positional arguments:
filename              Path to data file. This file must be in JSON format

options:
-h, --help            show this help message and exit
--update_index        Update index of all data files
--fix_data
--graph_frequencies   Graph the fourier transform of the absolute force and torque
--graph_force_torque  Graph the force and torque in all direction
--complete_analysis   Perform a complete analysis of the data. It can be presented in a number of different ways
--generate_ft_plots   Generate force-torque plots for all extractions in user://Analysis_data (or directory specified with --dir)
--dir DIR             Specify directory to use for complete analysis or generating ft plots
--per_teeth           Show complete analysis per tooth
--tooth TOOTH         Show complete analysis for a single tooth
--jaw JAW             Specify which jaw to show the complete analysis for (upper or lower). Use in combination with --grouped or --tooth
--grouped             Show complete analysis per tooth group
    --person_type PERSON_TYPE
Filter extractions by person type (Student, Kaakchirurg in opleiding, Tandarts, Kaakchirurg or Demo)
```
