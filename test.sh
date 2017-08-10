#!/bin/bash

DEPEND=true

qt=$(python3 -c "import PyQt5" 2>&1)

if [[ -z "$qt" ]]
then
   echo "Pass"
else
   echo "FAIL"
fi
