function remote_profile = remote_IPR_SCYLLA(varargin)
%
% This function regroups the remote profiles run on the IPR VIRTUALBOX (Gandhinagar, Gujarat, India)
%
%   INPUTS : 
%
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'torque';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'peysson';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% Note : direct mode disabled because login for pid check could occur on a different machine
%
% torque
%
remote.torque.peysson = default_remote_profile;
remote.torque.peysson.host = '103.49.147.27';%empty for local host (202.127.204.22)
remote.torque.peysson.hostname = 'scylla';%'login113';%login110(10.10.10.110) to login113(10.10.10.113)
remote.torque.peysson.nproc = 12;% default number of nodes for job on shenma
remote.torque.peysson.wait = 0;
remote.torque.peysson.shclean = 1;
remote.torque.peysson.cmd = 'qsub -q batch';%'qsub -q batch -o /scratch/PEYSSON';%for debug only (clear mat* files in /scratch/PEYSSON after turned on) 
remote.torque.peysson.remotedatapath = '/home/peysson/tmp/';
remote.torque.peysson.get_jobid = {'','.scylla'};%str_before,str_after
remote.torque.peysson.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.peysson.timeout = 60;
remote.torque.peysson.matver.mat805 = '/usr/local/bin/matlab';
remote.torque.peysson.matver.matdef = remote.torque.peysson.matver.mat805;%default matlab on remote machine
remote.torque.peysson.remoteuser = 'peysson';
remote.torque.peysson.rempause = 0.5;% pause between job checks (in minutes) (because of ssh access limitation)
%remote.torque.peysson.bridge.url.host = 'tolbachik.hd.free.fr:8081';%raspberry1 aix
%remote.torque.peysson.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%raspberry1 aix
remote.torque.peysson.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%raspberry1 aix
%
% direct
%
remote.direct.peysson = default_remote_profile;
remote.direct.peysson.host = '103.49.147.27';
remote.direct.peysson.hostname = 'scylla';
remote.direct.peysson.nproc = 20;
remote.direct.peysson.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.peysson.get_jobid = {};%str_before,str_after
remote.direct.peysson.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.peysson.timeout = 60;
remote.direct.peysson.remotedatapath = '/home/peysson/tmp/';
remote.direct.peysson.matver.mat805 = '/usr/local/bin/matlab';
remote.direct.peysson.matver.matdef = remote.direct.peysson.matver.mat805;%default matlab on remote machine
remote.direct.peysson.remoteuser = 'peysson';
%remote.direct.peysson.bridge.url.host = 'tolbachik.hd.free.fr:8081';%raspberry1 aix
%remote.direct.peysson.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%raspberry1 aix
remote.direct.peysson.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%raspberry1 aix
%
% HARSHITA RAJ
%
remote.torque.harshita= remote.torque.peysson;
remote.torque.harshita.remoteuser = 'harshita';
remote.torque.harshita.remotedatapath = '/home/harshita/tmp/';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
