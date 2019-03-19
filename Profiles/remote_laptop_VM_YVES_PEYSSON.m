function remote_profile = remote_laptop_VM_YVES_PEYSSON(varargin)
%
% This function regroups the remote profiles run on the Virtual Machine (Parallels) Ubuntu Linux server on Yves Peysson's laptop
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'condor';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'parallels';% default user profile if 'remoteuser' is not an existing user profile
%
default.filename = mfilename;%remote_xxx_yyy.m file name
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% direct
%
remote.direct.parallels = default_remote_profile;
remote.direct.parallels.host = '10.211.55.4';
remote.direct.parallels.hostname = 'parallels-Parallels-Virtual-Platform';
remote.direct.parallels.nproc = 2;
% remote.direct.parallels.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &'};% direct calculation (csh, bash)
remote.direct.parallels.cmd = {'bash','nohup ',' &'};% direct calculation (csh, bash)
remote.direct.parallels.get_jobid = {};%str_before,str_after
remote.direct.parallels.set_jobid = {'ps -p ','','MATLAB'};%str_before,str_after,str_check
remote.direct.parallels.remotedatapath = '/home/parallels/';
remote.direct.parallels.matver.mat905 = '/usr/local/MATLAB/R2018b/bin/matlab';
remote.direct.parallels.matver.matdef = remote.direct.parallels.matver.mat905;%default matlab on remote machine
remote.direct.parallels.remoteuser = 'parallels';
%
% condor
%
remote.condor.parallels = default_remote_profile;
remote.condor.parallels.host = '10.211.55.4';
remote.condor.parallels.hostname = 'parallels-Parallels-Virtual-Platform';
remote.condor.parallels.nproc = 6;
remote.condor.parallels.cmd = 'condor_submit';
remote.condor.parallels.get_jobid = {'** Proc ',':'};
remote.condor.parallels.set_jobid = {'condor_q ',' -nobatch'};
remote.condor.parallels.condor.CONDOR_CONFIG = '/etc/condor/condor_config';
remote.condor.parallels.condor.PATH = '$PATH';
remote.condor.parallels.remotedatapath = '/home/parallels/condor/';
remote.condor.parallels.matver.mat905 = '/usr/local/MATLAB/R2018b/bin/matlab';
remote.condor.parallels.matver.matdef = remote.condor.parallels.matver.mat905;%default matlab on remote machine
remote.condor.parallels.remoteuser = 'parallels';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%


    