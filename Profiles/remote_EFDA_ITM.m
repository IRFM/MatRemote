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
default.scheduler = 'sge';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'yvesp';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% sun grid engine (sge)
%
remote.sge.yves = default_remote_profile;
remote.sge.yves.host = 'g01.efda-itm.eu';
remote.sge.yves.hostname = 'itm.rzg.mpg.de';
remote.sge.yves.mailuser = 'ypeysson@free.fr';
remote.sge.yves.nproc = 16;% limited to two jobs per PBS node to avoid cluster saturation
remote.sge.yves.wait = 0;% invalid option
remote.sge.yves.nodes = NaN;% invalid option
remote.sge.yves.ncpus = NaN;% invalid option
remote.sge.yves.memory = NaN;% invalid option
remote.sge.yves.walltime = NaN;% invalid option
remote.sge.yves.cmd = 'qsub';%
remote.sge.yves.sge = {'#!/bin/bash','#$ -l h_rt=168:00:00 -l h_vmem=1250M','#$ -cwd',['#$ -M ',remote.sge.yves.mailuser],'#$ -m e','#$ -notify','#$ -N test','# load the ITM software environment','#module load itmenv','# load specific modules','# select specific UAL','#source $ITMSCRIPTDIR/ITMv1.sh kepler test 4.10a'};
remote.sge.yves.remotedatapath = '/u/yvesp/tmp/';
remote.sge.yves.get_jobid = {'Your job ',' '};%str_before,str_after
remote.sge.yves.set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
remote.sge.yves.matver.mat800.root = '/afs/ipp/common/soft/matlab_2012b/bin/';
remote.sge.yves.matver.mat800.prefdir = '/pfs/home/yvesp/.matlab/R2012b';%warning /pfs/home/ must replace /u/
remote.sge.yves.matver.matdef = remote.sge.yves.matver.mat800;%default matlab on remote machine
remote.sge.yves.remoteuser = 'yvesp';
remote.sge.yves.bridge.url.host = 'tolbachik.hd.free.fr';
remote.sge.yves.bridge.url.path = '~yvespeysson/MatRemote';
remote.sge.yves.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.sge.yves.bridge.ftp.username = 'matremote';
remote.sge.yves.bridge.ftp.password = 'Rq59G4zzPSzZNC9LFMdTK';
remote.sge.yves.bridge_enforce = true;

% direct
%
remote.direct.yves = default_remote_profile;
remote.direct.yves.host = 'g01.efda-itm.eu';
remote.direct.yves.hostname = 'itm.rzg.mpg.de';
remote.direct.yves.nproc = 16;
remote.direct.yves.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &',''};% direct calculation (csh, bash)
remote.direct.yves.get_jobid = {'[1] ',{' ',''}};%str_before,str_after
remote.direct.yves.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.yves.matver.mat800.root = '/afs/ipp/common/soft/matlab_2012b/bin/';
remote.direct.yves.matver.mat800.prefdir = '/pfs/home/yvesp/.matlab/R2012b';
remote.direct.yves.matver.matdef = remote.direct.yves.matver.mat800;%default matlab on remote machine
remote.direct.yves.remoteuser = 'yvesp';
remote.direct.yves.bridge.url.host = 'tolbachik.hd.free.fr';
remote.direct.yves.bridge.url.path = '~yvespeysson/MatRemote';
remote.direct.yves.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.direct.yves.bridge.ftp.username = 'matremote';
remote.direct.yves.bridge.ftp.password = 'Rq59G4zzPSzZNC9LFMdTK';
remote.direct.yves.bridge_enforce = true;
%
% JOAN DECKER
%
remote.sge.joan = remote.sge.yves;
remote.direct.joan = remote.direct.yves;
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
