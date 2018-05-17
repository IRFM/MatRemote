function remote_profile = remote_SWIP_CLUSTER02(varargin)
%
% This function regroups the remote profiles run on the SWIP CLUSTER02 cluster (Chendgu, China)
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
default.profile = 'Yves';% default user profile if 'remoteuser' is not an existing user profile
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
remote.torque.Yves = default_remote_profile;
remote.torque.Yves.host = 'cluster02.swip.ac.cn';% empty for local host (192.168.5.2)
remote.torque.Yves.hostname = 'mgmt.chess';
remote.torque.Yves.nproc = 20;% default number of nodes for job on shenma
remote.torque.Yves.wait = 0;
remote.torque.Yves.shclean = 1;
remote.torque.Yves.cmd = 'qsub';%
remote.torque.Yves.queue.name = {'debug','express','small','medium','long','verylong'};%Queue mode
remote.torque.Yves.queue.maxtask = {8,64,32,16,8,8};%maximum number of tasks per user
remote.torque.Yves.queue.maxtime = {'00:15','05:00','10:00','24:00','168:00','360:00'};%Maximum calculation time per task (hh:mm) (seconds are set to 00)
remote.torque.Yves.queue.qdef = 5;%default queue mode number (see queue.name)
remote.torque.Yves.remotedatapath = '/home/Yves/tmp/';
remote.torque.Yves.get_jobid = {'','.mgmt.chess'};%str_before,str_after
remote.torque.Yves.set_jobid = {'qstat ','',' ',' C '};%str_before,str_after,str_check
remote.torque.Yves.timeout = 240;%s
remote.torque.Yves.matver.mat714 = '/opt/MATLAB/R2012a/bin/matlab';
remote.torque.Yves.matver.mat801 = '/opt/MATLAB/R2013a/bin/matlab';
remote.torque.Yves.matver.mat802 = '/opt/MATLAB/R2013b/bin/matlab';
remote.torque.Yves.matver.matdef = remote.torque.Yves.matver.mat801;%default matlab on remote machinen

remote.torque.Yves.remoteuser = 'Yves';
remote.torque.Yves.bridge.url.host = 'https://tolbachik.hd.free.fr';%nuc aix
remote.torque.Yves.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%nuc aix
remote.torque.Yves.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%nuc aix
%
% direct
%
remote.direct.Yves = default_remote_profile;
remote.direct.Yves.host = 'cluster02.swip.ac.cn';
remote.direct.Yves.hostname = 'mgmt.chess';
remote.direct.Yves.nproc = 20;
remote.direct.Yves.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.Yves.get_jobid = {};%str_before,str_after
remote.direct.Yves.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.Yves.timeout = 240;%s
remote.direct.Yves.remotedatapath = '/home/Yves/tmp/';
remote.direct.Yves.matver.mat714 = '/opt/MATLAB/R2012a/bin/matlab';
remote.direct.Yves.matver.mat801 = '/opt/MATLAB/R2013a/bin/matlab';
remote.direct.Yves.matver.mat802 = '/opt/MATLAB/R2013b/bin/matlab';
remote.direct.Yves.matver.matdef = remote.direct.Yves.matver.mat801;%default matlab on remote machine
remote.direct.Yves.remoteuser = 'Yves';
remote.direct.Yves.bridge.url.host = 'https://tolbachik.hd.free.fr';%nuc aix
remote.direct.Yves.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%nuc aix
remote.direct.Yves.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%nuc aix
%
% SHAODONG SONG
%
remote.torque.songshd= remote.torque.Yves;
remote.torque.songshd.remoteuser = 'songshd';
remote.torque.songshd.remotedatapath = '/home/songshd/tmp/';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
