function remote_profile = remote_EFDA_ITM(varargin)
%
% This function regroups the remote profiles run on the european EFDA ITM cluster
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'sun';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'yvesp';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% sun grid engine (sge)
%
remote.sge.yvesp = default_remote_profile;
remote.sge.yvesp.host = 'g04.efda-itm.eu';
remote.sge.yvesp.hostname = 'itm.rzg.mpg.de';
remote.sge.yvesp.nproc = 16;% limited to two jobs per PBS node to avoid cluster saturation
remote.sge.yvesp.wait = 0;% invalid option
remote.sge.yvesp.nodes = NaN;% invalid option
remote.sge.yvesp.ncpus = NaN;% invalid option
remote.sge.yvesp.memory = NaN;% invalid option
remote.sge.yvesp.walltime = NaN;% invalid option
remote.sge.yvesp.cmd = 'qsub ';% 
remote.sge.yvesp.remotedatapath = '/tmp/';
remote.sge.yvesp.get_jobid = {'Your job ',' '};%str_before,str_after
remote.sge.yvesp.set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
remote.sge.yvesp.matver.mat800.root = '/afs/ipp/common/soft/matlab_2012b/bin/';
remote.sge.yvesp.matver.mat800.prefdir = '/pfs/home/yvesp/.matlab/R2012b';%warning /pfs/home/ must replace /u/
remote.sge.yvesp.matver.matdef = remote.sge.yvesp.matver.mat800;%default matlab on remote machine
remote.sge.yvesp.remoteuser = 'yvesp';
remote.sge.yvesp.bridge.url.host = 'tolbachik.hd.free.fr';
remote.sge.yvesp.bridge.url.path = '~yvespeysson/MatRemote';
remote.sge.yvesp.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.sge.yvesp.bridge.ftp.username = 'matremote';
remote.sge.yvesp.bridge.ftp.password = 'Rq59G4zzPSzZNC9LFMdTK';
remote.sge.yvesp.bridge_enforce = true;
%
%
% direct
%
remote.direct.yvesp = default_remote_profile;
remote.direct.yvesp.host = 'g04.efda-itm.eu';
remote.direct.yvesp.hostname = 'itm.rzg.mpg.de';
remote.direct.yvesp.nproc = 16;
remote.direct.yvesp.cmd = 'csh';% direct calculation (csh, bash)
remote.direct.yvesp.get_jobid = {'[1] ',{' ',''}};%str_before,str_after
remote.direct.yvesp.set_jobid = {'ps -p ',' -o comm=',''};%str_before,str_after,str_check
remote.direct.yvesp.matver.mat800.root = '/afs/ipp/common/soft/matlab_2012b/bin/';
remote.direct.yvesp.matver.mat800.prefdir = '/pfs/home/yvesp/.matlab/R2012b';
remote.direct.yvesp.matver.matdef = remote.direct.yvesp.matver.mat800;%default matlab on remote machine
remote.direct.yvesp.remoteuser = 'yvesp';
remote.direct.yvesp.bridge.url.host = 'tolbachik.hd.free.fr';
remote.direct.yvesp.bridge.url.path = '~yvespeysson/MatRemote';
remote.direct.yvesp.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.direct.yvesp.bridge.ftp.username = 'matremote';
remote.direct.yvesp.bridge.ftp.password = 'Rq59G4zzPSzZNC9LFMdTK';
remote.direct.yvesp.bridge_enforce = true;
%
% JOAN DECKER
%
remote.sge.joan = remote.sge.yvesp;
remote.direct.joan = remote.direct.yvesp;
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
