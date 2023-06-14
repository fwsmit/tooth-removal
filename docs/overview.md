# Overview

This project contains three parts:
- A godot project that implements the user interface
- Python code for analysing the recorded extraction data
- Python code for emulating a sensor. This is useful for testing when you have no sensor

Instructions for running this code can be found in the README. Further
explanations of the code can be found below.

## Godot

All the godot code can be found under `src/`. In this directory the most
important parts are the `scenes` and the `scripts` directories.

All screens in the user interface have been implemented in their own scene.
These can all be found in the `scenes` directory.

Each scene contains UI components and scripts to implement the UI. The scripts
can be found in the `scripts` directory. Each script is put in the directory
that corresponds to the name of the scene where they are used. Scripts that are
used in multiple scenes are put in the `common` directory. Lastly there is the
`tests` directory, used for testing scripts.

A few of the most importantt scripts for the godot interface and their respective functionality 
will be described below, namely 'client.gd', 'data_user.gd', 'post_extraction_continue.gd' & 'Global.gd'

then there are two more helper scripts, which lie outside of thee scope of the regular interface.
namely 'processOldData.gd' & 'tooth_location_visual.gd'

### 'client.gd'
The client script is created by data_user. It communicates with the sensor and
emits data signals with the measured forces and torques. These are already
translated from the sensor axes to the godot axes.

### 'data_user.gd'
This script takes the raw sensor data and processes it to be used in other scripts

### 'post_extraction_continue.gd'
this script is used mostly for the data storage 
When an extraction is recorded, the sensor data is saved to a file called
`extraction_data_DATE.json`, for example
`extraction_data_2023-05-26T09;52;23.json`. It is stored in the following
directory:

`user://`

This is a special path defined by godot. The location of this path on your
system can be found [here](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html)

### 'Global.gd'
Here all types of variables and data is stored which can be used globally throughout the code

### 'processOldData.gd'
When old data needs to be reprocessed, because somthing went wrong with the initial processing, e.g. location vectors were not properly measured. This code can be used to reprocess the data with the updated code.

### 'tooth_location_visual.gd'
This script is used to visually verify the tooth locations and tooth frames. WHen this script is run the tooth locations and the respective tooth frames are displayed in 3D tab for in the editor page.

## Python analysis

The analysis code is run from `dataAnalysis.py`. You can use a number of
arguments to specify which kind of analysis and plotting to do. These are all
explained in the README.

The data used for analysis is taken from different places in the `user://`
directory, but by default it's `Analysis_data`.

## Python sensor

The program `fakesensor.py` contains code to emulate a force torque sensor. It
can be easily modified to output different values, depending on your needs.

The program `sensorReader.py` is a program provided by the sensor manufacturer.
It connects to the sensor and outputs all the sensor data.
