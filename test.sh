#!/bin/bash

python python/analysis/test.py

retval=$?
if [ $retval -ne 0 ]
then
        exit $retval
fi
