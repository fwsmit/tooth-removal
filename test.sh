#!/bin/bash

python python/analysis/test.py

retval=$?
if [ $retval -ne 0 ]
then
        exit $retval
fi

cd src/
godot --no-window -s scripts/tests/test.gd

retval=$?
if [ $retval -ne 0 ]
then
        exit $retval
fi
