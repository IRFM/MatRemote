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
remote.torque.PEYSSON.host = 'shenma.ipp.ac.cn';% empty for local host
remote.torque.PEYSSON.hostname = 'shenma';
remote.torque.PEYSSON.nproc = 20;% default number of nodes for job on shenma
remote.torque.PEYSSON.wait = 0;
remote.torque.PEYSSON.shclean = 1;
remote.torque.PEYSSON.cmd = 'qsub -q batch';%'qsub -q batch -o /scratch/PEYSSON';%for debug only (clear mat* files in /scratch/PEYSSON after turned on) 
remote.torque.PEYSSON.remotedatapath = '/scratch/PEYSSON/';
remote.torque.PEYSSON.get_jobid = {'','.master'};%str_before,str_after
remote.torque.PEYSSON.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.PEYSSON.matver.mat800 = '/pkg/MATLAB/R2012b/bin/matlab';
remote.torque.PEYSSON.matver.matdef = remote.torque.PEYSSON.matver.mat800;%default matlab on remote machine
remote.torque.PEYSSON.remoteuser = 'PEYSSON';
remote.torque.PEYSSON.bridge.url.host = 'tolbachik.hd.free.fr';
remote.torque.PEYSSON.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.torque.PEYSSON.bridge.ssh.host = 'tolbachik.hd.free.fr';
%
% direct
%
remote.direct.PEYSSON = default_remote_profile;
remote.direct.PEYSSON.host = 'shenma.ipp.ac.cn';
remote.direct.PEYSSON.hostname = 'shenma';
remote.direct.PEYSSON.nproc = 20;
remote.direct.PEYSSON.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &',''};% direct calculation (csh, bash)
remote.direct.PEYSSON.get_jobid = {};%str_before,str_after
remote.direct.PEYSSON.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.PEYSSON.matver.mat800 = '/pkg/MATLAB/R2012b/bin/matlab';
remote.direct.PEYSSON.matver.mat801 = '/pkg/MATLAB/R2013a/bin/matlab';
remote.direct.PEYSSON.matver.matdef = remote.direct.PEYSSON.matver.mat800;%default matlab on remote machine
remote.direct.PEYSSON.remoteuser = 'PEYSSON';
remote.direct.PEYSSON.bridge.url.host = 'tolbachik.hd.free.fr';
remote.direct.PEYSSON.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.direct.PEYSSON.bridge.ssh.host = 'tolbachik.hd.free.fr';
%
% JOAN DECKER
%
remote.torque.joan = remote.torque.PEYSSON;
remote.direct.joan = remote.direct.PEYSSON;
%
% BOJIANG DING
%
remote.torque.bjding= remote.torque.PEYSSON;
remote.torque.bjding.remoteuser = 'bjding';
remote.torque.bjding.remotedatapath = '/scratch/bjding/';
%
% MIAOHUI LI
%
remote.torque.limiaohui = remote.torque.PEYSSON;
remote.torque.limiaohui.remoteuser = 'limiaohui';
remote.torque.limiaohui.remotedatapath = '/scratch/limiaohui/';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
