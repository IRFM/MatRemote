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
% --------------------------------------------------
%
% YVES PEYSSON
%
% Note : direct mode disabled because login for pid check could occur on a different machine
%
% torque
%
remote.torque.Yves = default_remote_profile;
remote.torque.Yves.host = 'cluster02.swip.ac.cn';% empty for local host
remote.torque.Yves.hostname = 'mgmt.chess';
remote.torque.Yves.nproc = 20;% default number of nodes for job on shenma
remote.torque.Yves.wait = 0;
remote.torque.Yves.shclean = 1;
remote.torque.Yves.cmd = 'qsub';%
remote.torque.Yves.remotedatapath = '/home/Yves/tmp/';
remote.torque.Yves.get_jobid = {'','.mgmt.chess'};%str_before,str_after
remote.torque.Yves.set_jobid = {'qstat ','',' C '};%str_before,str_after,str_check
remote.torque.Yves.matver.mat714 = '/opt/MATLAB/R2012a/bin/matlab';
remote.torque.Yves.matver.mat801 = '/opt/MATLAB/R2013a/bin/matlab';
remote.torque.Yves.matver.matdef = remote.torque.Yves.matver.mat714;%default matlab on remote machine
remote.torque.Yves.remoteuser = 'Yves';
remote.torque.Yves.bridge.url.host = 'tolbachik.hd.free.fr';
remote.torque.Yves.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.torque.Yves.bridge.ssh.host = 'tolbachik.hd.free.fr';
%
% direct
%
remote.direct.Yves = default_remote_profile;
remote.direct.Yves.host = 'cluster02.swip.ac.cn';
remote.direct.Yves.hostname = 'mgmt.chess';
remote.direct.Yves.nproc = 20;
remote.direct.Yves.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &',''};% direct calculation (csh, bash)
remote.direct.Yves.get_jobid = {};%str_before,str_after
remote.direct.Yves.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.Yves.matver.mat714 = '/opt/MATLAB/R2012a/bin/matlab';
remote.direct.Yves.matver.mat801 = '/opt/MATLAB/R2013a/bin/matlab';
remote.direct.Yves.matver.matdef = remote.direct.Yves.matver.mat714;%default matlab on remote machine
remote.direct.Yves.remoteuser = 'Yves';
remote.direct.Yves.bridge.url.host = 'tolbachik.hd.free.fr';
remote.direct.Yves.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.direct.Yves.bridge.ssh.host = 'tolbachik.hd.free.fr';
%
% JOAN DECKER
%
remote.torque.joan = remote.torque.Yves;
remote.direct.joan = remote.direct.Yves;
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
