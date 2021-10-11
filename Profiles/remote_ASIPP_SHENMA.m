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
default.filename = mfilename;%remote_xxx_yyy.m file name
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% Note : direct mode disabled because login for pid check could occur on a different machine
%
% torque
%
remote.torque.PEYSSON = default_remote_profile;%202.127.204.22
remote.torque.PEYSSON.host = {'10.10.10.110','shenma.ipp.ac.cn'};%put external IP last in a list of IP addresses (shenma.ipp.ac.cn not accessible when login shenma)
remote.torque.PEYSSON.hostname = 'login11';%login11* -> (10.10.10.11*) with * = {0,1,2,3} 
remote.torque.PEYSSON.nproc = 20;% default number of nodes for job on shenma
remote.torque.PEYSSON.wait = 0;
remote.torque.PEYSSON.shclean = 1;
remote.torque.PEYSSON.cmd = 'qsub -q batch';%'qsub -q batch -o /scratch/PEYSSON';%for debug only (clear mat* files in /scratch/PEYSSON after turned on) 
remote.torque.PEYSSON.remotedatapath = '/scratch/PEYSSON/';
remote.torque.PEYSSON.get_jobid = {'','.service103'};%str_before,str_after
remote.torque.PEYSSON.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.PEYSSON.timeout = 60;
remote.torque.PEYSSON.matver.mat902 = '/gpfs_home/pkg/MATLAB/MATLAB/R2017a/bin/matlab';
remote.torque.PEYSSON.matver.mat903 = '/gpfs-home/pkg/matlab/R2017b/bin/matlab';
remote.torque.PEYSSON.matver.matdef = remote.torque.PEYSSON.matver.mat902;%default matlab on remote machine
remote.torque.PEYSSON.remoteuser = 'PEYSSON';
remote.torque.PEYSSON.rempause = 0.1;% pause between job checks (in minutes) (because of ssh access limitation)
%
% direct
%
remote.direct.PEYSSON = default_remote_profile;
remote.direct.PEYSSON.host = {'10.10.10.110','shenma.ipp.ac.cn'};%put external IP last in a list of IP addresses (shenma.ipp.ac.cn not accessible when login shenma)
remote.direct.PEYSSON.hostname = 'login11';%login11* -> (10.10.10.11*) with * = {0,1,2,3}
remote.direct.PEYSSON.nproc = 20;
%remote.direct.PEYSSON.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &',''};% direct calculation (csh, bash)
remote.direct.PEYSSON.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.PEYSSON.get_jobid = {};%sr_before,str_after
remote.direct.PEYSSON.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.PEYSSON.timeout = 60;
remote.direct.PEYSSON.remotedatapath = '/scratch/PEYSSON/';
remote.direct.PEYSSON.matver.mat902 = '/gpfs-home/pkg/MATLAB/MATLAB/R2017a/bin/matlab';
remote.direct.PEYSSON.matver.mat902 = '/gpfs-home/pkg/matlab/R2017b/bin/matlab';
remote.direct.PEYSSON.matver.matdef = remote.direct.PEYSSON.matver.mat902;%default matlab on remote machine
remote.direct.PEYSSON.remoteuser = 'PEYSSON';
remote.direct.PEYSSON.rempause = 0.1;% pause between job checks (in minutes) (because of ssh access limitation)
%remote.direct.PEYSSON.bridge.url.host = 'https://tolbachik.hd.free.fr';%nuc aix
%remote.direct.PEYSSON.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%nuc aix
%remote.direct.PEYSSON.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%nuc aix
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
remote.torque.limiaohui.bridge = [];
%
remote.direct.limiaohui = remote.direct.PEYSSON;
remote.direct.limiaohui.remoteuser = 'limiaohui';
remote.direct.limiaohui.remotedatapath = '/scratch/limiaohui/';
remote.direct.limiaohui.bridge = [];
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
