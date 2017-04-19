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
pathmetis0 = which('metis4itm');%remove metis4itm in the Matlab search because it uses also m2html nut in a different way
if length(pathmetis0) > 0,
	imetis4itm = strfind(pathmetis0,'metis4itm');
    warning off
	rmpath(genpath([pathmetis0(1:imetis4itm(1)-1),'metis4itm']));
	warning on
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
redminepath = 'http://tolbachik.hd.free.fr:8080/redmine';%path to the redmine website 
%
if isempty(redminepath),disp('WARNING: the ''redminepath'' path is empty.');end
%
make_help(verbose,ref_folder(1).path,redminepath,texfilelist,excludedfoldernames,helptools);
%
cd(dirinit);
