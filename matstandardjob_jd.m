function job = matstandardjob_jd(remotematfnc)
%
% Standard preparation for remote matlab job
%
job.script = 'matlabbatch.sh';% script to be run by scheduler on remote cluster
%
job.savefcn = 'matstandardsave';% function saving the data locally 
job.loadfcn = 'matstandardload';% function reading the data locally
%
job.localdatapath = '';%'';%forder where local data is stored - leave empty for local data folder
%
job.env.remotebatch_matlabfun = 'remotematrun';% (required by matlabbatch.sh) matlab function to be called by batch script on remote cluster
job.env.remotepathfnc = '';% (optional, called by remotematrun) matlab function to set the path on the remote machine
%
if nargin > 0 && ~isempty(remotematfnc),
    job.env.remotematfnc = remotematfnc;
end
%
