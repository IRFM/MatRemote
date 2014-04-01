function remote_profile = remote_CRPP_LAC4(varargin)
%
% This function regroups the remote profiles run on LAC4 at the CRPP
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
remote.direct.decker.host = 'lac4.epfl.ch';
remote.direct.decker.hostname = 'crpppc296';
remote.direct.decker.nproc = 12;
remote.direct.decker.cmd = {'bash','',' &'};% direct calculation (csh, bash)
remote.direct.decker.get_jobid = {};%str_before,str_after
remote.direct.decker.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.decker.matver.mat710 = '/usr/local/matlab710/bin/matlab';
remote.direct.decker.matver.matdef = remote.direct.decker.matver.mat710;%default matlab on remote machine
remote.direct.decker.remoteuser = 'decker';
remote.direct.decker.bridge.ssh.host = 'lac911.epfl.ch';
%
%
% --------------------------------------------------
%
% JOSEF KAMLEITNER
%
% direct
%
remote.direct.kamleitn = remote.direct.decker;
remote.direct.kamleitn.remoteuser = 'kamleitn';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
