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
remote.torque.PEYSSON.host = {'10.10.10.112','shenma.ipp.ac.cn'};%put external IP last in a list of IP addresses (shenma.ipp.ac.cn not accessible when login shenma)
remote.torque.PEYSSON.hostname = 'login11';%login11* -> (10.10.10.11*) with * = {0,1,2,3} 
remote.torque.PEYSSON.nproc = 10;% default number of nodes for job on shenma
remote.torque.PEYSSON.wait = 0;
remote.torque.PEYSSON.shclean = 1;
remote.torque.PEYSSON.cmd = 'qsub -q batch';%'qsub -q batch -o /scratch/PEYSSON';%for debug only (clear mat* files in /scratch/PEYSSON after turned on) 
remote.torque.PEYSSON.remotedatapath = '/gpfs/scratch/PEYSSON/';
remote.torque.PEYSSON.get_jobid = {'','.service103'};%str_before,str_after
remote.torque.PEYSSON.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.PEYSSON.timeout = 10;
remote.torque.PEYSSON.matver.mat903 = '/home/users/PEYSSON/mat903.sh';%create executable bash script named mat903.sh with module purge;module load matlab/2017b;matlab "$@"
remote.torque.PEYSSON.matver.matdef = remote.torque.PEYSSON.matver.mat903;%default matlab on remote machine
remote.torque.PEYSSON.remoteuser = 'PEYSSON';
remote.torque.PEYSSON.rempause = 0.1;% pause between job checks (in minutes) (because of ssh access limitation)
remote.torque.PEYSSON.bridge.ssh.host = 'spcsrv18.epfl.ch';%spcsrv18 EPFL, Switzerland
remote.torque.PEYSSON.bridge.ssh.remotepassword = getenv('ASIPP_SHENMA_PASSWD');%set password for the remote machine in startup.m or in session startup script
%
% direct
%
remote.direct.PEYSSON = default_remote_profile;
remote.direct.PEYSSON.host = {'10.10.10.112','shenma.ipp.ac.cn'};%put external IP last in a list of IP addresses (shenma.ipp.ac.cn not accessible when login shenma)
remote.direct.PEYSSON.hostname = 'login11';%login11* -> (10.10.10.11*) with * = {0,1,2,3}
remote.direct.PEYSSON.nproc = 100;
%remote.direct.PEYSSON.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &',''};% direct calculation (csh, bash)
remote.direct.PEYSSON.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.PEYSSON.get_jobid = {};%sr_before,str_after
remote.direct.PEYSSON.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.PEYSSON.timeout = 10;
remote.direct.PEYSSON.remotedatapath = '/gpfs/scratch/PEYSSON/';
remote.direct.PEYSSON.matver.mat903 = '/home/users/PEYSSON/mat903.sh';%create executable bash script named mat903.sh with module purge;module load matlab/2017b;matlab "$@"
remote.direct.PEYSSON.matver.matdef = remote.direct.PEYSSON.matver.mat903;%default matlab on remote machine
remote.direct.PEYSSON.remoteuser = 'PEYSSON';
remote.direct.PEYSSON.rempause = 0.1;% pause between job checks (in minutes) (because of ssh access limitation)
remote.direct.PEYSSON.bridge.ssh.host = 'spcsrv18.epfl.ch';%spcsrv18 EPFL, Switzerland
remote.direct.PEYSSON.bridge.ssh.remotepassword = getenv('ASIPP_SHENMA_PASSWD');%set password for the remote machine in startup.m or in session startup script
%
% BOJIANG DING (SHENMA)
%
remote.torque.bjding = remote.torque.PEYSSON;
remote.torque.bjding.host = '10.10.10.112';
remote.torque.bjding.remoteuser = 'bjding';
remote.torque.bjding.remotedatapath = '/scratch/bjding/';
remote.torque.bjding.bridge.ssh.host = '';
remote.torque.bjding.bridge.ssh.remotepassword = '';
%
% MIAOHUI LI  (SHENMA)
%
remote.torque.limiaohui = remote.torque.PEYSSON;
remote.torque.limiaohui.host = '10.10.10.112';
remote.torque.limiaohui.remoteuser = 'limiaohui';
remote.torque.limiaohui.remotedatapath = '/scratch/limiaohui/';
remote.torque.limiaohui.bridge = [];
remote.torque.limiaohui.bridge.ssh.host = '';
remote.torque.limiaohui.bridge.ssh.remotepassword = '';
%
remote.direct.limiaohui = remote.direct.PEYSSON;
remote.direct.limiaohui.host = '10.10.10.112';
remote.direct.limiaohui.remoteuser = 'limiaohui';
remote.direct.limiaohui.remotedatapath = '/scratch/limiaohui/';
remote.direct.limiaohui.bridge = [];
remote.torque.limiaohui.bridge.ssh.host = '';
remote.torque.limiaohui.bridge.ssh.remotepassword = '';
%
% YONGCHUN LI (SHENMA)
%
remote.torque.ycunli = remote.torque.PEYSSON;
remote.torque.ycunli.host = '10.10.10.112';
remote.torque.ycunli.remoteuser = 'ycunli';
remote.torque.ycunli.remotedatapath = '/scratch/ycunli/';
remote.torque.ycunli.bridge.ssh.host = '';
remote.torque.ycunli.bridge.ssh.remotepassword = '';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%