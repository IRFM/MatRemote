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
% --------------------------------------------------
%
% JOAN DECKER
%
% direct
%
remote.direct.decker = default_remote_profile;
%remote.direct.decker.host = '128.178.125.161';% IP address on EPFL network
remote.direct.decker.host = 'crpppc359.epfl.ch';% IP address on EPFL network
remote.direct.decker.hostname = 'chalmers-PC-joan';
remote.direct.decker.nproc = 2;
remote.direct.decker.cmd = {'bash','',' &'};% direct calculation (csh, bash)
remote.direct.decker.get_jobid = {};%str_before,str_after
remote.direct.decker.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.decker.matver.mat712 = '/opt/MATLAB/R2011A/bin/matlab';
remote.direct.decker.matver.mat801 = '/opt/MATLAB/R2013A/bin/matlab';
remote.direct.decker.matver.mat803 = '/opt/MATLAB/R2014A/bin/matlab';
remote.direct.decker.matver.matdef = remote.direct.decker.matver.mat803;%default matlab on remote machine
remote.direct.decker.remoteuser = 'joan';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
