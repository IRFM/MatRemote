#!/bin/bash
#
# Filename: matlabbatch.sh
#
#
# run matlab in text mode 
"$remotebatch_matlabroot"matlab  -nojvm -nodesktop -nodisplay -nosplash -r "$*"

