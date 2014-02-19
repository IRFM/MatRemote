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
remote.bash.joan = default_remote_profile;
remote.bash.joan.host = 'crpppc82.epfl.ch';
remote.bash.joan.hostname = 'crpppc82';
remote.bash.joan.nproc = 8;
remote.bash.joan.cmd = 'bash';% direct calculation (csh, bash)
remote.bash.joan.get_jobid = {'[1] ',{' ',''}};%str_before,str_after
remote.bash.joan.set_jobid = {'ps -p ',' -o comm=',''};%str_before,str_after,str_check
remote.bash.joan.matver.mat800.root = '/usr/local/MATLAB/R2012b/bin/';
remote.bash.joan.matver.mat800.prefdir = '/home/decker/.matlab/R2010a';
remote.bash.joan.matver.mat801.root = '/usr/local/MATLAB/R2013a/bin/';
remote.bash.joan.matver.mat801.prefdir = '/home/decker/.matlab/R2013a';
remote.bash.joan.matver.matdef = remote.bash.joan.matver.mat801;%default matlab on remote machine
remote.bash.joan.remoteuser = 'decker';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
