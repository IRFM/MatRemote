#!/bin/bash
#
# Filename: matlabbatch.sh
#
# Standard matlab batch start where the function $remotebatch_matlabfun (ex : remotematrun) is called
# The matlab version is controled using the variable $remotebatch_matlabroot
#
"$remotebatch_matlabroot"matlab -nodesktop -nodisplay -nosplash -r "remotebatchdir = getenv('remotebatchdir');addpath(remotebatchdir);remotebatch_matlabfun = getenv('remotebatch_matlabfun');feval(remotebatch_matlabfun);exit"
