function remote_profile = remote_ASIPP_SHENMA(varargin)
%
% This function regroups the remote profiles run on the ASIPP SHENMA cluster (Hefei, China)
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'torque';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'PEYSSON';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% Note : direct mode disabled because login for pid check could occur on a different machine
%
% torque
%
remote.torque.PEYSSON = default_remote_profile;
remote.torque.PEYSSON.host = 'shenma.ipp.ac.cn';%empty for local host (202.127.204.22)
remote.torque.PEYSSON.hostname = 'shenma107';%'login113';%login110(10.10.10.110) to login113(10.10.10.113)
remote.torque.PEYSSON.nproc = 20;% default number of nodes for job on shenma
remote.torque.PEYSSON.wait = 0;
remote.torque.PEYSSON.shclean = 1;
remote.torque.PEYSSON.cmd = 'qsub -q batch';%'qsub -q batch -o /scratch/PEYSSON';%for debug only (clear mat* files in /scratch/PEYSSON after turned on) 
remote.torque.PEYSSON.remotedatapath = '/scratch/PEYSSON/';
remote.torque.PEYSSON.get_jobid = {'','.service103'};%str_before,str_after
remote.torque.PEYSSON.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.PEYSSON.matver.mat714 = '/pkg/MATLAB/MATLAB/R2012a/bin/matlab';
remote.torque.PEYSSON.matver.mat801 = '/pkg/MATLAB/MATLAB/R2013a/bin/matlab';
remote.torque.PEYSSON.matver.mat804 = '/pkg/MATLAB/MATLAB/R2014b/bin/matlab';
remote.torque.PEYSSON.matver.matdef = remote.torque.PEYSSON.matver.mat804;%default matlab on remote machine
remote.torque.PEYSSON.remoteuser = 'PEYSSON';
remote.torque.PEYSSON.rempause = 0.5;% pause between job checks (in minutes) (because of ssh access limitation)
remote.torque.PEYSSON.bridge.url.host = 'tolbachik.hd.free.fr:8081';%raspberry1 aix
remote.torque.PEYSSON.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%raspberry1 aix
remote.torque.PEYSSON.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%raspberry1 aix
%
% direct
%
remote.direct.PEYSSON = default_remote_profile;
remote.direct.PEYSSON.host = 'shenma.ipp.ac.cn';
remote.direct.PEYSSON.hostname = 'shenma107';%'login113';%login110(10.10.10.110) to login113(10.10.10.113)
remote.direct.PEYSSON.nproc = 20;
remote.direct.PEYSSON.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &',''};% direct calculation (csh, bash)
remote.direct.PEYSSON.get_jobid = {};%str_before,str_after
remote.direct.PEYSSON.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.PEYSSON.remotedatapath = '/scratch/PEYSSON/';
remote.direct.PEYSSON.matver.mat714 = '/pkg/MATLAB/MATLAB/R2012a/bin/matlab';
remote.direct.PEYSSON.matver.mat801 = '/pkg/MATLAB/MATLAB/R2013a/bin/matlab';
remote.direct.PEYSSON.matver.mat804 = '/pkg/MATLAB/MATLAB/R2014b/bin/matlab';
remote.direct.PEYSSON.matver.matdef = remote.direct.PEYSSON.matver.mat804;%default matlab on remote machine
remote.direct.PEYSSON.remoteuser = 'PEYSSON';
remote.direct.PEYSSON.rempause = 0.5;% pause between job checks (in minutes) (because of ssh access limitation)
remote.direct.PEYSSON.bridge.url.host = 'tolbachik.hd.free.fr:8081';%raspberry1 aix
remote.direct.PEYSSON.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%raspberry1 aix
remote.direct.PEYSSON.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%raspberry1 aix

%
% BOJIANG DING (SHENMA)
%
remote.torque.bjding= remote.torque.PEYSSON;
remote.torque.bjding.remoteuser = 'bjding';
remote.torque.bjding.remotedatapath = '/scratch/bjding/';
%
% BOJIANG DING (LAPTOP)
%
remote.torque.bjdingLinux= remote.torque.PEYSSON;
remote.torque.bjdingLinux.remoteuser = 'bjding';
remote.torque.bjdingLinux.remotedatapath = '/scratch/bjding/';
%
% MIAOHUI LI  (SHENMA)
%
remote.torque.limiaohui = remote.torque.PEYSSON;
remote.torque.limiaohui.remoteuser = 'limiaohui';
remote.torque.limiaohui.remotedatapath = '/scratch/limiaohui/';
%
% YONGCHUN LI (SHENMA)
%
remote.torque.ycunli = remote.torque.PEYSSON;
remote.torque.ycunli.remoteuser = 'ycunli';
remote.torque.ycunli.remotedatapath = '/scratch/ycunli/';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
