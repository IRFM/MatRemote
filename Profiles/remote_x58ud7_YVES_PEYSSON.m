function remote_profile = remote_x58ud7_YVES_PEYSSON(varargin)
%
% This function regroups the remote profiles run on the X58-UD7 Linux server (Aix) of Yves Peysson
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'condor';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'ypeysson';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% direct
%
remote.direct.ypeysson = default_remote_profile;
remote.direct.ypeysson.host = 'home-aix.yvespeysson.fr';
remote.direct.ypeysson.hostname = 'ypeysson-X58A-UD7';
remote.direct.ypeysson.nproc = 6;
% remote.direct.ypeysson.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &'};% direct calculation (csh, bash)
remote.direct.ypeysson.cmd = {'bash','nohup ',' &'};% direct calculation (csh, bash)
remote.direct.ypeysson.get_jobid = {};%str_before,str_after
remote.direct.ypeysson.set_jobid = {'ps -p ','','MATLAB'};%str_before,str_after,str_check
remote.direct.ypeysson.remotedatapath = '/home/ypeysson/';
remote.direct.ypeysson.matver.mat902 = '/usr/local/MATLAB/R2017a/bin/matlab';
remote.direct.ypeysson.matver.mat903 = '/usr/local/MATLAB/R2017b/bin/matlab';
remote.direct.ypeysson.matver.mat904 = '/usr/local/MATLAB/R2018a/bin/matlab';
remote.direct.ypeysson.matver.matdef = remote.direct.ypeysson.matver.mat904;%default matlab on remote machine
remote.direct.ypeysson.remoteuser = 'ypeysson';
%
% condor
%
remote.condor.ypeysson = default_remote_profile;
remote.condor.ypeysson.host = 'home-aix.yvespeysson.fr';
remote.condor.ypeysson.hostname = 'ypeysson-X58A-UD7';
remote.condor.ypeysson.nproc = 6;
remote.condor.ypeysson.cmd = 'condor_submit';
remote.condor.ypeysson.get_jobid = {'** Proc ',':'};
remote.condor.ypeysson.set_jobid = {'condor_q ',''};
remote.condor.ypeysson.condor.CONDOR_CONFIG = '/etc/condor/condor_config';
remote.condor.ypeysson.condor.PATH = '$PATH';
remote.condor.ypeysson.remotedatapath = '/home/ypeysson/condor/';
remote.condor.ypeysson.matver.mat902 = '/usr/local/MATLAB/R2017a/bin/matlab';
remote.condor.ypeysson.matver.mat903 = '/usr/local/MATLAB/R2017b/bin/matlab';
remote.condor.ypeysson.matver.mat904 = '/usr/local/MATLAB/R2018a/bin/matlab';
remote.condor.ypeysson.matver.matdef = remote.condor.ypeysson.matver.mat904;%default matlab on remote machine
remote.condor.ypeysson.remoteuser = 'ypeysson';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%


    