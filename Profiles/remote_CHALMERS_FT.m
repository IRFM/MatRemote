function remote_profile = remote_CHALMERS_FT(varargin)
%
% This function regroups the remote profiles run Chalmers ft computer
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
% default.scheduler = 'torque';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.scheduler = 'direct';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'decker';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% JOAN DECKER
%
% torque
%
% remote.torque.decker = default_remote_profile;
% remote.torque.decker.host = 'ft.nephy.chalmers.se';% empty for local host
% remote.torque.decker.hostname = 'ft.nephy.chalmers.se';
% remote.torque.decker.nproc = 4;
% remote.torque.decker.wait = 0;
% remote.torque.decker.cmd = 'qsub';
% remote.torque.decker.get_jobid = {'','.ft'};%str_before,str_after
% remote.torque.decker.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
% remote.torque.decker.matver.mat714 = '/usr/local/MATLAB/R2012a/bin/matlab';
% remote.torque.decker.matver.matdef = remote.torque.decker.matver.mat714;%default matlab on remote machine
% remote.torque.decker.remoteuser = 'decker';
%
% local
%
remote.direct.decker = default_remote_profile;
remote.direct.decker.host = 'ft.nephy.chalmers.se';% empty for local host
remote.direct.decker.hostname = 'ft.nephy.chalmers.se';
remote.direct.decker.nproc = 4;
remote.direct.decker.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.decker.get_jobid = {};%str_before,str_after
remote.direct.decker.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.decker.matver.mat714 = '/usr/local/MATLAB/R2012a/bin/matlab';
remote.direct.decker.matver.matdef = remote.direct.decker.matver.mat714;%default matlab on remote machine
remote.direct.decker.remoteuser = 'decker';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
