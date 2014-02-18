function job = matstandardjob_jd(remotematfnc,remotepathfnc,remotepath)
%
% Standard preparation for remote luke job. Only with use of remotematrun
%
% INPUTS :
%       - remotematfnc : function to be called remotely. ex : runmat
%       - remotepathfnc : function to set up the path on the remote machine. ex : setpath_luke_jd
%       - remotepath : path on the remote machine where 'remotepathfnc' is to be found. 
%           If 'remotepath' is empty and funcopy >= 0, the function 'remotepathfnc' is copied from guest machine
%       
% OUTPUTS :
%       - job : default structure for job with remotematrun
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
if nargin < 3,
    remotepath = '';
end
if nargin > 1 && ~isempty(remotepathfnc),
    job.env.remotepathfnc = [remotepath,remotepathfnc];% (optional, called by remotematrun) matlab function to set the path on the remote machine
end
%