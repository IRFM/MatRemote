function remote_profile = remote_SPCPC483(varargin)
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
default.profile = 'joan';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% JOAN DECKER
%
% direct
%
remote.direct.joan = default_remote_profile;
remote.direct.joan.host = 'spcpc483.epfl.ch';% IP address on EPFL network
remote.direct.joan.hostname = 'spcpc483';
remote.direct.joan.nproc = 4;
remote.direct.joan.cmd = {'bash','',' &'};% direct calculation (csh, bash)
remote.direct.joan.get_jobid = {};%str_before,str_after
remote.direct.joan.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.joan.remotedatapath = '/tmp/';
remote.direct.joan.matver.mat803 = 'matlab-8.3.0';
remote.direct.joan.matver.mat804 = 'matlab-8.4.0';
remote.direct.joan.matver.mat900 = 'matlab-9.0.0';
remote.direct.joan.matver.mat901 = 'matlab-9.1.0';
remote.direct.joan.matver.matdef = remote.direct.joan.matver.mat901;%default matlab on remote machine
remote.direct.joan.remoteuser = 'decker';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
