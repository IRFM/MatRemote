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
default.profile = 'joan';% default user profile if 'remoteuser' is not an existing user profile
%
default.filename = mfilename;%remote_xxx_yyy.m file name
% --------------------------------------------------
%
% JOAN DECKER
%
% direct
%
remote.direct.decker = default_remote_profile;
remote.direct.decker.host = 'spcsrv18.epfl.ch';% IP address on EPFL network
remote.direct.decker.hostname = 'spcsrv18';
remote.direct.decker.nproc = 4;
remote.direct.decker.cmd = {'bash','',' &'};% direct calculation (csh, bash)
remote.direct.decker.get_jobid = {};%str_before,str_after
remote.direct.decker.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.decker.remotedatapath = '/tmp/';
remote.direct.decker.matver.mat901 = '/usr/local/MATLAB/R2016b/bin/matlab';
remote.direct.decker.matver.mat905 = '/usr/local/MATLAB/R2018b/bin/matlab';
remote.direct.decker.matver.matdef = remote.direct.decker.matver.mat901;%default matlab on remote machine
remote.direct.decker.remoteuser = 'decker';
%
% condor
%
remote.condor.decker = default_remote_profile;
remote.condor.decker.host = 'spcsrv18.epfl.ch';
remote.condor.decker.hostname = 'spcsrv18';
remote.condor.decker.nproc = 12;
remote.condor.decker.cmd = 'condor_submit';
remote.condor.decker.get_jobid = {'** Proc ',':'};
remote.condor.decker.set_jobid = {'condor_q ',' -nobatch'};
remote.condor.decker.condor.CONDOR_CONFIG = '/etc/condor/condor_config';
remote.condor.decker.condor.PATH = '$PATH';
remote.condor.decker.remotedatapath = '/home/decker/condor/';
remote.condor.decker.matver.mat901 = '/usr/local/MATLAB/R2016b/bin/matlab';
remote.condor.decker.matver.mat905 = '/usr/local/MATLAB/R2018b/bin/matlab';
remote.condor.decker.matver.matdef = remote.condor.decker.matver.mat901;%default matlab on remote machine
remote.condor.decker.remoteuser = 'decker';
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% direct
%
remote.direct.peysson = default_remote_profile;
remote.direct.peysson.host = 'spcsrv18.epfl.ch';% IP address on EPFL network
remote.direct.peysson.hostname = 'spcsrv18';
remote.direct.peysson.nproc = 12;
remote.direct.peysson.cmd = {'bash','',' &'};% direct calculation (csh, bash)
remote.direct.peysson.get_jobid = {};%str_before,str_after
remote.direct.peysson.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.peysson.remotedatapath = '/tmp/';
remote.direct.peysson.matver.mat901 = '/usr/local/MATLAB/R2016b/bin/matlab';
remote.direct.peysson.matver.mat905 = '/usr/local/MATLAB/R2018b/bin/matlab';
remote.direct.peysson.matver.matdef = remote.direct.peysson.matver.mat901;%default matlab on remote machine
remote.direct.peysson.remoteuser = 'peysson';
%
% condor
%
remote.condor.peysson = default_remote_profile;
remote.condor.peysson.host = 'spcsrv18.epfl.ch';
remote.condor.peysson.hostname = 'spcsrv18';
remote.condor.peysson.nproc = 12;
remote.condor.peysson.cmd = 'condor_submit';
remote.condor.peysson.get_jobid = {'** Proc ',':'};
remote.condor.peysson.set_jobid = {'condor_q ',' -nobatch'};
remote.condor.peysson.condor.CONDOR_CONFIG = '/etc/condor/condor_config';
remote.condor.peysson.condor.PATH = '$PATH';
remote.condor.peysson.remotedatapath = '/home/peysson/condor/';
remote.condor.peysson.matver.mat901 = '/usr/local/MATLAB/R2016b/bin/matlab';
remote.condor.peysson.matver.mat905 = '/usr/local/MATLAB/R2018b/bin/matlab';
remote.condor.peysson.matver.matdef = remote.condor.peysson.matver.mat901;%default matlab on remote machine
remote.condor.peysson.remoteuser = 'peysson';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
