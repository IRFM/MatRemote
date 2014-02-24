function remote_profile = remote_CRPP_PC82(varargin)
%
% This function regroups the remote profiles run on PC82 at the CRPP
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'bash';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'joan';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% JOAN DECKER
%
% direct
%
remote.direct.joan = default_remote_profile;
remote.direct.joan.host = 'crpppc82.epfl.ch';
remote.direct.joan.hostname = 'crpppc82';
remote.direct.joan.nproc = 8;
remote.direct.joan.cmd = 'bash';% direct calculation (csh, bash)
remote.direct.joan.get_jobid = {};%str_before,str_after
remote.direct.joan.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.joan.matver.mat800.root = '/usr/local/MATLAB/R2012b/bin/';
remote.direct.joan.matver.mat800.prefdir = '/home/decker/.matlab/R2012b';
remote.direct.joan.matver.mat801.root = '/usr/local/MATLAB/R2013a/bin/';
remote.direct.joan.matver.mat801.prefdir = '/home/decker/.matlab/R2013a';
remote.direct.joan.matver.matdef = remote.direct.joan.matver.mat801;%default matlab on remote machine
remote.direct.joan.remoteuser = 'decker';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
