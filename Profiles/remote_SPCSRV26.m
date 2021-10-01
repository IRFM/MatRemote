function remote_profile = remote_SPCSRV26(varargin)
%
% SPCSRV26 LUKE server
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
% --------------------------------------------------
%
% general parameters
%
host = 'spcsrv26.epfl.ch';% IP address on EPFL network
hostname = 'spcsrv26';
matver.mat910 = '/usr/local/MATLAB/R2021a/bin/matlab';
matver.matdef = matver.mat910;%default matlab on remote machine
%
% direct profile
%
direct = default_remote_profile;
direct.host = host;
direct.hostname = hostname;
direct.nproc = 4;
direct.cmd = {'bash','',' &'};% direct calculation (csh, bash)
direct.get_jobid = {};%str_before,str_after
direct.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
direct.remotedatapath = '/tmp/';
direct.matver = matver;
%
% JOAN DECKER
%
% direct
%
remote.direct.decker = direct;
remote.direct.decker.remoteuser = 'decker';
remote.direct.decker.bridge.proxy.host = 'spcsrv18.epfl.ch';%spcsrv18 EPFL, Switzerland
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% direct
%
remote.direct.peysson = direct;
remote.direct.peysson.remoteuser = 'peysson';
remote.direct.peysson.bridge.proxy.host = 'spcsrv18.epfl.ch';%spcsrv18 EPFL, Switzerland
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
