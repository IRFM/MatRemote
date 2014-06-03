function make_matremote_help(verbose)
%MatRemote - Installation script for automatic generation of the on-line documentation 
%
%Installation script for automatic generation of the on-line documentation using MatHelp library
%
% INPUT:
%
%	- verbose: display the output of the documentation build-up is not empty
%
% OUTPUT: none
%
%By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr) 
%
if nargin == 0,
    verbose = 'off';
end
%
excludedfoldernames = {};%update if necessary
%
disp('************************* EXCLUDED FOLDER NAMES **************************')
for ie = 1:length(excludedfoldernames),
    disp([' - ',excludedfoldernames{ie}])
end
disp('**************************************************************************')
%
dirinit = pwd;
%
helptools = '';
%
texfilelist = '';
%
ref_folder = what('MatRemote');
redminepath = 'http://tolbachik.hd.free.fr:8080/redmine/';
%
make_help(verbose,ref_folder.path,redminepath,texfilelist,excludedfoldernames,helptools);
%
cd(dirinit);
