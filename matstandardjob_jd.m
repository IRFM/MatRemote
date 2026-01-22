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
function job = matstandardjob_jd(remotematfnc)
%
% Standard preparation for remote luke job. Only with use of remotematrun
%
% INPUTS :
%       - remotematfnc : function to be called remotely. ex : runmat
%       
% OUTPUTS :
%       - job : default structure for job with remotematrun
%
job.script = 'matlabbatch.sh';% script to be run by scheduler on remote cluster
%
job.savefcn = 'matstandardsave';% function saving the data locally 
job.loadfcn = 'matstandardload';% function reading the data locally
%
job.localdatapath = '';%'';%forder where local data is stored - leave empty for local data folder
%
job.ppn = 2;
%
job.env.remotebatch_matlabfun = 'remotematrun';% (required by matlabbatch.sh) matlab function to be called by batch script on remote cluster
%
if nargin > 0 && ~isempty(remotematfnc),
    job.env.remotematfnc = remotematfnc;
end
%