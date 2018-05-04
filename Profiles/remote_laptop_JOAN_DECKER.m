function remote_profile = remote_laptop_JOAN_DECKER(varargin)
%
% This function regroups the remote profiles run on joan's laptop
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'direct';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'decker';% default user profile if 'remoteuser' is not an existing user profile
%
default.filename = mfilename;%remote_xxx_yyy.m file name
%
% --------------------------------------------------
%
% JOAN DECKER
%
% direct
%
remote.direct.decker = default_remote_profile;
remote.direct.decker.host = 'spcpc458.epfl.ch';% IP address on EPFL network
remote.direct.decker.hostname = 'spcpc458';
remote.direct.decker.nproc = 2;
remote.direct.decker.cmd = {'bash','',' &'};% direct calculation (csh, bash)
remote.direct.decker.get_jobid = {};%str_before,str_after
remote.direct.decker.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.decker.remotedatapath = '/tmp/';
remote.direct.decker.matver.mat900 = '/usr/local/MATLAB/R2016a/bin/matlab';
remote.direct.decker.matver.mat901 = '/usr/local/MATLAB/R2016b/bin/matlab';
remote.direct.decker.matver.matdef = remote.direct.decker.matver.mat901;%default matlab on remote machine
remote.direct.decker.remoteuser = 'joan';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
