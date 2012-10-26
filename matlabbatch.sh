#!/bin/bash
#
# Filename: matlabbatch.sh
#
# Standard matlab batch start where the generic function remotematrun is called after setting the path to environment variable 'remotebatch_path'
#
"$remotebatch_matlabroot"matlab -nodesktop -nodisplay -nosplash -r "remotebatch_path = getenv('remotebatch_path');addpath(remotebatch_path);disp([' Path set to ',remotebatch_path]);remotematrun;exit"

