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
default.profile = 'joan';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% JOAN DECKER
%
% direct
%
remote.direct.joan = default_remote_profile;
remote.direct.joan.host = '128.178.125.161';% IP address on EPFL network
remote.direct.joan.hostname = 'chalmers-PC-joan';
remote.direct.joan.nproc = 2;
remote.direct.joan.cmd = {'bash','',' &'};% direct calculation (csh, bash)
remote.direct.joan.get_jobid = {};%str_before,str_after
remote.direct.joan.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.joan.matver.mat712 = '/opt/MATLAB/R2011A/bin/matlab';
remote.direct.joan.matver.mat801 = '/opt/MATLAB/R2013A/bin/matlab';
remote.direct.joan.matver.mat803 = '/opt/MATLAB/R2014A/bin/matlab';
remote.direct.joan.matver.matdef = remote.direct.joan.matver.mat803;%default matlab on remote machine
remote.direct.joan.remoteuser = 'joan';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
