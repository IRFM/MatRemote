function remote_profile = remote_SPCSRV18(varargin)
%
% SPCSRV18 LUKE server
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
host = 'spcsrv18.epfl.ch';% IP address on EPFL network
hostname = 'spcsrv18';
matver.mat901 = '/usr/local/MATLAB/R2016b/bin/matlab';
matver.mat905 = '/usr/local/MATLAB/R2018b/bin/matlab -c /etc/matlab.lic';
matver.matdef = matver.mat901;%default matlab on remote machine
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
% condor
%
condor = default_remote_profile;
condor.host = host;
condor.hostname = hostname;
condor.nproc = 12;
condor.cmd = 'condor_submit';
condor.get_jobid = {'** Proc ',':'};
condor.set_jobid = {'condor_q ',' -nobatch'};
condor.condor.CONDOR_CONFIG = '/etc/condor/condor_config';
condor.condor.PATH = '$PATH';
condor.matver = matver;
%
% JOAN DECKER
%
% direct
%
remote.direct.decker = direct;
remote.direct.decker.remoteuser = 'decker';
%
% condor
%
remote.condor.decker = condor;
remote.condor.decker.remotedatapath = '/home/decker/condor/';
remote.condor.decker.remoteuser = 'decker';
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% direct
%
remote.direct.peysson = direct;
remote.direct.peysson.remoteuser = 'peysson';
%
% condor
%
remote.condor.peysson = condor;
remote.condor.peysson.remotedatapath = '/home/peysson/condor/';
remote.condor.peysson.remoteuser = 'peysson';
%
% --------------------------------------------------
%
% Krzysztof Krol
%
% direct
%
remote.direct.kkrol = direct;
remote.direct.kkrol.remoteuser = 'kkrol';
%
% condor
%
remote.condor.kkrol = condor;
remote.condor.kkrol.remotedatapath = '/home/kkrol/condor/';
remote.condor.kkrol.remoteuser = 'kkrol';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
