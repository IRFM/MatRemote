function remote_profile = remote_PSFC_LOKI(varargin)
%
% This function regroups the remote profiles run on the LOKI cluster
% in the PSFC/MIT network
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'pbs';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'ypeysson';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% pbs pro
%
remote.pbs.ypeysson = default_remote_profile;
remote.pbs.ypeysson.host = 'loki';
remote.pbs.ypeysson.hostname = 'head';
remote.pbs.ypeysson.shell = 'bash';
remote.pbs.ypeysson.nproc = 12;
remote.pbs.ypeysson.cmd = 'qsub';
remote.pbs.ypeysson.remotedatapath = '/home/ypeysson/tmp/';
remote.pbs.ypeysson.get_jobid = {'','.head'};%str_before,str_after
remote.pbs.ypeysson.set_jobid = {'qstat ','.head','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.ypeysson.shclean = 1;
remote.pbs.ypeysson.matver.mat712 = '/usr/local/bin/matlab';
remote.pbs.ypeysson.matver.matdef = remote.pbs.ypeysson.matver.mat712;%default matlab on remote machine
remote.pbs.ypeysson.remoteuser = 'ypeysson';
%remote.pbs.ypeysson.bridge.url.host = 'cmodws85.psfc.mit.edu';%cmodws85 workstation PSFC/MIT
%remote.pbs.ypeysson.bridge.ftp.host = 'cmodws85.psfc.mit.edu';%cmodws85 workstation PSFC/MIT
remote.pbs.ypeysson.bridge.ssh.host = 'cmodws85.psfc.mit.edu';%cmodws85 workstation PSFC/MIT
%
% direct
%
% note : mode direct bridge disabled because nohup does not work
%
remote.direct.ypeysson = default_remote_profile;
remote.direct.ypeysson.host = 'loki';
remote.direct.ypeysson.hostname = 'head';
remote.direct.ypeysson.shell = 'bash';
remote.direct.ypeysson.nproc = 12;
remote.direct.ypeysson.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.ypeysson.remotedatapath = '/home/ypeysson/tmp/';
remote.direct.ypeysson.get_jobid = {};%str_before,str_after
remote.direct.ypeysson.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.ypeysson.matver.mat712 = '/usr/local/bin/matlab';
remote.direct.ypeysson.matver.matdef = remote.direct.ypeysson.matver.mat712;%default matlab on remote machine
remote.direct.ypeysson.remoteuser = 'ypeysson';
%remote.direct.ypeysson.bridge.url.host = 'cmodws85.psfc.mit.edu';%cmodws85 workstation PSFC/MIT
%remote.direct.ypeysson.bridge.ftp.host = 'cmodws85.psfc.mit.edu';%cmodws85 workstation PSFC/MIT
remote.direct.ypeysson.bridge.ssh.host = 'cmodws85.psfc.mit.edu';%cmodws85 workstation PSFC/MIT
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
