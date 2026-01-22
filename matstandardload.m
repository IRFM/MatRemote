% 
% /////////////////////////////////////////
%
% Software name : MatRemote, part of LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function [soutput] = matstandardload(job)
%
% This function loads data from the file job.load_id at location job.localdatapath into the structure soutput
%
if exist([job.localdatapath,job.load_id],'file'),
    soutput = load([job.localdatapath,job.load_id]);
else
    soutput.err = ['The file ',[job.localdatapath,job.load_id],' does not exist'];
end