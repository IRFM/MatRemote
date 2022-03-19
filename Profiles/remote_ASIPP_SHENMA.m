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
remote.torque.PEYSSON.remotedatapath = '/tmp/';
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
remote.direct.PEYSSON.host = {'10.10.10.112','shenma.ipp.ac.cn'};%{'10.10.10.112','shenma.ipp.ac.cn'};%put external IP last in a list of IP addresses (shenma.ipp.ac.cn not accessible when login shenma)
remote.direct.PEYSSON.hostname = 'login11';%login11* -> (10.10.10.11*) with * = {0,1,2,3}
remote.direct.PEYSSON.nproc = 10;
%remote.direct.PEYSSON.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &',''};% direct calculation (csh, bash)
remote.direct.PEYSSON.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.PEYSSON.get_jobid = {};%sr_before,str_after
remote.direct.PEYSSON.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.PEYSSON.timeout = 10;
remote.direct.PEYSSON.remotedatapath = '/tmp/';
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
remote.torque.bjding.bridge.ssh.host = '';
remote.torque.bjding.bridge.ssh.remotepassword = '';
%
remote.direct.bjding = remote.direct.PEYSSON;
remote.direct.bjding.host = '10.10.10.112';
remote.direct.bjding.remoteuser = 'bjding';
remote.direct.bjding.bridge.ssh.host = '';
remote.direct.bjding.bridge.ssh.remotepassword = '';
%
% MIAOHUI LI  (SHENMA)
%
remote.torque.limiaohui = remote.torque.PEYSSON;
remote.torque.limiaohui.host = '10.10.10.112';
remote.torque.limiaohui.remoteuser = 'limiaohui';
remote.torque.limiaohui.bridge.ssh.host = '';
remote.torque.limiaohui.bridge.ssh.remotepassword = '';
%
remote.direct.limiaohui = remote.direct.PEYSSON;
remote.direct.limiaohui.host = '10.10.10.112';
remote.direct.limiaohui.remoteuser = 'limiaohui';
remote.direct.limiaohui.bridge.ssh.host = '';
remote.direct.limiaohui.bridge.ssh.remotepassword = '';
%
% YONGCHUN LI (SHENMA)
%
remote.torque.ycunli = remote.torque.PEYSSON;
remote.torque.ycunli.host = '10.10.10.112';
remote.torque.ycunli.remoteuser = 'ycunli';
remote.torque.ycunli.bridge.ssh.host = '';
remote.torque.ycunli.bridge.ssh.remotepassword = '';
%
remote.direct.ycunli = remote.direct.PEYSSON;
remote.direct.ycunli.host = '10.10.10.112';
remote.direct.ycunli.remoteuser = 'ycunli';
remote.direct.ycunli.bridge.ssh.host = '';
remote.direct.ycunli.bridge.ssh.remotepassword = '';
%
% CHENBIN WU (SHENMA)
%
remote.torque.chbwu = remote.torque.PEYSSON;
remote.torque.chbwu.host = '10.10.10.112';
remote.torque.chbwu.remoteuser = 'ycunli';
remote.torque.chbwu.bridge.ssh.host = '';
remote.torque.chbwu.bridge.ssh.remotepassword = '';
%
remote.direct.chbwu = remote.direct.PEYSSON;
remote.direct.chbwu.host = '10.10.10.112';
remote.direct.chbwu.remoteuser = 'chbwu';
remote.direct.chbwu.bridge.ssh.host = '';
remote.direct.chbwu.bridge.ssh.remotepassword = '';
%
% ghyan (SHENMA)
%
remote.torque.ghyan = remote.torque.PEYSSON;
remote.torque.ghyan.host = '10.10.10.112';
remote.torque.ghyan.remoteuser = 'ghyan';
remote.torque.ghyan.bridge.ssh.host = '';
remote.torque.ghyan.bridge.ssh.remotepassword = '';
%
remote.torque.ghyan = remote.torque.PEYSSON;
remote.torque.ghyan.host = '10.10.10.112';
remote.torque.ghyan.remoteuser = 'ghyan';
remote.torque.ghyan.bridge.ssh.host = '';
remote.torque.ghyan.bridge.ssh.remotepassword = '';
%
% YONGLIANG LI (SHENMA)
%
remote.torque.ylli = remote.torque.PEYSSON;
remote.torque.ylli.host = '10.10.10.112';
remote.torque.ylli.remoteuser = 'ylli';
remote.torque.ylli.bridge.ssh.host = '';
remote.torque.ylli.bridge.ssh.remotepassword = '';
%
remote.direct.ylli = remote.direct.PEYSSON;
remote.direct.ylli.host = '10.10.10.112';
remote.direct.ylli.remoteuser = 'ylli';
remote.direct.ylli.bridge.ssh.host = '';
remote.direct.ylli.bridge.ssh.remotepassword = '';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%