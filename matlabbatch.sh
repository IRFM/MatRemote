#!/bin/bash
#
# Filename: matlabbatch.sh
#
#
# run matlab in text mode 
#
# Note : the matlab command can be specified either through the environment variable $args (xgrid)
#        or through an argument to the command matlabbatch (condor)
#
"$remotebatch_matlabroot"matlab  -nojvm -nodesktop -nodisplay -nosplash -r "$args $*"

