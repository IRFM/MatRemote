function remote_profile = remote_IPP_SOROBAN(varargin)
%
% This function regroups the remote profiles run on SOROBAN cluster at the IPP Prague
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'pbs';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'peysson';% default user profile if 'remoteuser' is not an existing user profile
%
default.filename = mfilename;%remote_xxx_yyy.m file name
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% direct
%
remote.direct.peysson = default_remote_profile;
remote.direct.peysson.host = 'soroban.tok.ipp.cas.cz';
remote.direct.peysson.hostname = 'soroban';
remote.direct.peysson.nproc = 12;
remote.direct.peysson.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.peysson.get_jobid = {};%str_before,str_after
remote.direct.peysson.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.peysson.remotedatapath = '/compass/home/peysson/tmp/';
remote.direct.peysson.matver.mat902 = '/sw/matlab/r2017a/bin/matlab';
remote.direct.peysson.matver.mat906 = '/sw/matlab/r2019a/bin/matlab';
remote.direct.peysson.matver.matdef = remote.direct.peysson.matver.mat906;%default matlab on remote machine
remote.direct.peysson.remoteuser = 'peysson';
%
% pbs
%
remote.pbs.peysson = default_remote_profile;
remote.pbs.peysson.host = 'soroban.tok.ipp.cas.cz';
remote.pbs.peysson.hostname = 'soroban';
remote.pbs.peysson.nproc = 36;
remote.pbs.peysson.cmd = 'qsub ';% remote calculation with the pbs scheduler
remote.pbs.peysson.shclean = 1;
remote.pbs.peysson.get_jobid = {'','.soroban-sched'};%str_before,str_after
remote.pbs.peysson.set_jobid = {'qstat ','.soroban-sched','Job has finished',' C '};%str_before,str_after,str_check
remote.pbs.peysson.remotedatapath = '/compass/home/peysson/tmp/';
remote.pbs.peysson.matver.mat902 = '/sw/matlab/r2017a/bin/matlab';
remote.pbs.peysson.matver.mat906 = '/sw/matlab/r2019a/bin/matlab';
remote.pbs.peysson.matver.matdef = remote.pbs.peysson.matver.mat906;%default matlab on remote machine
remote.pbs.peysson.remoteuser = 'peysson';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
