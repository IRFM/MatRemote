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
default.profile = 'yves';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% Note : direct mode disabled because login for pid check could occur on a different machine
%
% torque
%
remote.torque.yves = default_remote_profile;
remote.torque.yves.host = 'shenma.ipp.ac.cn';% empty for local host
remote.torque.yves.hostname = 'shenma';
remote.torque.yves.nproc = 20;% default number of nodes for job on shenma
remote.torque.yves.wait = 0;
remote.torque.yves.shclean = 1;
remote.torque.yves.cmd = 'qsub -q batch';%'qsub -q batch -o /scratch/PEYSSON';%for debug only (clear mat* files in /scratch/PEYSSON after turned on) 
remote.torque.yves.remotedatapath = '/scratch/PEYSSON/';
remote.torque.yves.get_jobid = {'','.master'};%str_before,str_after
remote.torque.yves.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.yves.matver.mat800 = '/pkg/MATLAB/R2012b/bin/';
remote.torque.yves.matver.matdef = remote.torque.yves.matver.mat800;%default matlab on remote machine
remote.torque.yves.remoteuser = 'PEYSSON';
remote.torque.yves.bridge.url.host = 'tolbachik.hd.free.fr';
remote.torque.yves.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.torque.yves.bridge.ssh.host = 'tolbachik.hd.free.fr';
%
% direct
%
remote.direct.yves = default_remote_profile;
remote.direct.yves.host = 'shenma.ipp.ac.cn';
remote.direct.yves.hostname = 'shenma';
remote.direct.yves.nproc = 20;
remote.direct.yves.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &',''};% direct calculation (csh, bash)
remote.direct.yves.get_jobid = {};%str_before,str_after
remote.direct.yves.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.yves.matver.mat800 = '/pkg/MATLAB/R2012b/bin/';
remote.direct.yves.matver.mat801 = '/pkg/MATLAB/R2013a/bin/';
remote.direct.yves.matver.matdef = remote.direct.yves.matver.mat800;%default matlab on remote machine
remote.direct.yves.remoteuser = 'PEYSSON';
remote.direct.yves.bridge.url.host = 'tolbachik.hd.free.fr';
remote.direct.yves.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.direct.yves.bridge.ssh.host = 'tolbachik.hd.free.fr';
%
% JOAN DECKER
%
remote.torque.joan = remote.torque.yves;
%
% BOJIANG DING
%
remote.torque.bojiang = remote.torque.yves;
remote.torque.bojiang.remoteuser = 'bjding';
%
% MIAOHUI LI
%
remote.torque.miaohui = remote.torque.yves;
remote.torque.miaohui.remoteuser = 'limiaohui';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
