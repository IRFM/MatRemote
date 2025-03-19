function remote_profile = remote_UYORK(varargin)
%
% UYORK server  pll543@research1
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'direct';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'pll543';% default user profile if 'remoteuser' is not an existing user profile (Yves Savoye-Peysson)
%
default.filename = mfilename;%remote_xxx_yyy.m file name
% --------------------------------------------------
%
% general parameters
%
host = 'research1';% IP address on EPFL network
hostname = 'research1';
matver.mat242 = '/usr/bin/matlab';
matver.mat242.enforce = true;
matver.mat242.cmd = '/usr/bin/matlab -c /etc/matlab.lic';
matver.matdef = matver.mat242.cmd;%default matlab on remote machine
%
% direct profile
%
direct = default_remote_profile;
direct.host = host;
direct.hostname = hostname;
direct.nproc = 16;
direct.cmd = {'bash','',' &'};% direct calculation (csh, bash)
direct.get_jobid = {};%str_before,str_after
direct.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
direct.remotedatapath = '/tmp/';
direct.matver = matver;
%
% scheduler
%{
%condor = default_remote_profile;
%condor.host = host;
%condor.hostname = hostname;
condor.nproc = 12;
condor.cmd = 'condor_submit';
condor.get_jobid = {'** Proc ',':'};
condor.set_jobid = {'condor_q ',' -nobatch'};
condor.condor.CONDOR_CONFIG = '/etc/condor/condor_config';
condor.condor.PATH = '$PATH';
condor.matver = matver;
%}
% YVES SAVOYE-PEYSSON
%
% direct
%
remote.direct.pll543 = direct;
remote.direct.pll543.remoteuser = 'pll543';
%
% condor
%{
remote.condor.decker = condor;
remote.condor.decker.remotedatapath = '/home/decker/condor/';
remote.condor.decker.remoteuser = 'decker';
%}
% --------------------------------------------------
%
% JONATHAN CARROTTE
%
% direct
%
remote.direct.rnf508 = direct;
remote.direct.rnf508.remoteuser = 'rnf508';
%
% condor
%{
remote.condor.peysson = condor;
remote.condor.peysson.remotedatapath = '/home/peysson/condor/';
remote.condor.peysson.remoteuser = 'peysson';
%}
% --------------------------------------------------
%
% TOM WILSON
%
% direct
%
remote.direct.tw1723 = direct;
remote.direct.tw1723.remoteuser = 'tw1723';
%
% condor
%{
remote.condor.eriksson = condor;
remote.condor.eriksson.remotedatapath = '/home/eriksson/condor/';
remote.condor.eriksson.remoteuser = 'eriksson';
%}
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
