function remote_profile = remote_GA_LOHAN14(varargin)
%
% This function regroups the remote profiles run on the LOHAN14 cluster
% in the GA (General Atomics, USA) network
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
remote.pbs.ypeysson.get_jobid = {'','.loki'};%str_before,str_after
remote.pbs.ypeysson.set_jobid = {'qstat ','.loki','finished'};%str_before,str_after,str_check
remote.pbs.ypeysson.shclean = 1;
remote.pbs.ypeysson.matver.mat712 = '/usr/local/bin/matlab';
remote.pbs.ypeysson.matver.matdef = remote.pbs.ypeysson.matver.mat712;%default matlab on remote machine
remote.pbs.ypeysson.remoteuser = 'ypeysson';
%remote.pbs.ypeysson.bridge.url.host = 'tolbachik.hd.free.fr:8081';%raspberry1 aix
%remote.pbs.ypeysson.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%raspberry1 aix
remote.pbs.ypeysson.bridge.ssh.host = 'tolbachik.hd.free.fr -p 2222';%raspberry1 aix
%
% direct
%
% note : mode direct bridge disabled because nohup does not work
%
remote.direct.ypeysson = default_remote_profile;
remote.direct.ypeysson.host = 'loki';
remote.direct.ypeysson.hostname = 'andromede';
remote.direct.ypeysson.shell = 'bash';
remote.direct.ypeysson.nproc = 12;
remote.direct.ypeysson.cmd = {'csh','',' &',' &'};% direct calculation (csh, bash)
remote.direct.ypeysson.remotedatapath = '/home/ypeysson/tmp/';
remote.direct.ypeysson.get_jobid = {};%str_before,str_after
remote.direct.ypeysson.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.ypeysson.matver.mat712 = '/usr/local/bin/matlab';
remote.direct.ypeysson.matver.matdef = remote.direct.ypeysson.matver.mat712;%default matlab on remote machine
remote.direct.ypeysson.remoteuser = 'ypeysson';
remote.direct.ypeysson.bridge.url.host = 'tolbachik.hd.free.fr:8081';%raspberry1 aix
remote.direct.ypeysson.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%raspberry1 aix
remote.direct.ypeysson.bridge.ssh.host = 'tolbachik.hd.free.fr -p 2222';%raspberry1 aix
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
