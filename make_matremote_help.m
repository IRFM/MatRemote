function make_matremote_help(verbose)
%MatRemote - Installation script for automatic generation of the on-line documentation 
%
%Installation script for automatic generation of the on-line documentation using MatHelp library
%
% INPUT:
%
%	- verbose: display the output of the documentation build-up (on/off). Empty is off.
%
% OUTPUT: none
%
%By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr) 
%
if nargin == 0,
    verbose = 'off';
end
%
excludedfoldernames = {};%list of excluded folders. Update if necessary 
%
disp('************************* EXCLUDED FOLDER NAMES **************************')
for ie = 1:length(excludedfoldernames),
    disp([' - ',excludedfoldernames{ie}])
end
disp('**************************************************************************')
%
dirinit = pwd;
%
helptools = '';%specific display tools (like TeX, GraphViz or ImageMagick which are considered by default)
%
% List of pdf text files that can be viewed from the web browser. 
%
% Format: 
%       texfilelist(i).file = path to the file without extension;
%       texfilelist(i).title = name of the link in the webpage;
%
texfilelist = '';
%
ref_folder = what('MatRemote');
outputpath = getenv('output_path');%where the help website is created
if isempty(outputpath),disp('WARNING: the output path has not been found. Set the environment variable ''output_path'' for a specific path. Otherwise, the help website is created locally.');
    outputpath = [pwd,'/Help'];
end
%
make_help(verbose,ref_folder(1).path,outputpath,texfilelist,excludedfoldernames,helptools);
%
cd(dirinit);
