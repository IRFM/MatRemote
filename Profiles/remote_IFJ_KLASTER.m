function remote_profile = remote_IFJ_KLASTER(varargin)
%
% This function regroups the remote profiles run on the IFJ KLASTER cluster (Krakow, Poland)
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
default.profile = 'yves';% default user profile if 'remoteuser' is not an existing user profile
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
remote.torque.yves = default_remote_profile;
remote.torque.yves.host = 'klaster.ifj.edu.pl';% empty for local host (192.168.5.2)
remote.torque.yves.hostname = 'node01';
remote.torque.yves.nproc = 20;% default number of nodes for job on shenma
remote.torque.yves.wait = 0;
remote.torque.yves.shclean = 1;
remote.torque.yves.cmd = 'qsub';%
remote.torque.yves.queue.name = {'debug','express','small','medium','long','verylong'};%Queue mode
remote.torque.yves.queue.maxtask = {8,64,32,16,8,8};%maximum number of tasks per user
remote.torque.yves.queue.maxtime = {'00:15','05:00','10:00','24:00','168:00','360:00'};%Maximum calculation time per task (hh:mm) (seconds are set to 00)
remote.torque.yves.queue.qdef = 4;%default queue mode number (see queue.name)
remote.torque.yves.remotedatapath = '/home/yves/tmp/';
remote.torque.yves.get_jobid = {'','.mgmt.chess'};%str_before,str_after
remote.torque.yves.set_jobid = {'qstat ','',' ',' C '};%str_before,str_after,str_check
remote.torque.yves.timeout = 60;
remote.torque.yves.matver.mat802 = '/opt/MATLAB/R2013b/bin/matlab';
remote.torque.yves.matver.matdef = remote.torque.yves.matver.mat802;%default matlab on remote machine
remote.torque.yves.remoteuser = 'Yves';
%remote.torque.yves.bridge.url.host = 'https://tolbachik.hd.free.fr';%nuc aix
%remote.torque.yves.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%nuc aix
%remote.torque.yves.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%nuc aix
%
% direct
%
remote.direct.yves = default_remote_profile;
remote.direct.yves.host = 'klaster.ifj.edu.pl';
remote.direct.yves.hostname = 'node01';
remote.direct.yves.nproc = 20;
remote.direct.yves.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.yves.get_jobid = {};%str_before,str_after
remote.direct.yves.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.yves.timeout = 60;
remote.direct.yves.remotedatapath = '/home/yves/';
remote.direct.yves.matver.mat802 = '/opt/MATLAB/R2013b/bin/matlab';
remote.direct.yves.matver.matdef = remote.direct.yves.matver.mat802;%default matlab on remote machine
remote.direct.yves.remoteuser = 'Yves';
%remote.direct.yves.bridge.url.host = 'https://tolbachik.hd.free.fr';%nuc aix
%remote.direct.yves.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%nuc aix
%remote.direct.yves.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%nuc aix
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
