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
default.profile = 'bojiang';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% BOJIANG DING
%
remote.torque.bojiang = default_remote_profile;
remote.torque.bojiang.host = 'shenma.ipp.ac.cn';% empty for local host
remote.torque.bojiang.hostname = 'shenma';
remote.torque.bojiang.nproc = 20;% default number of nodes for job on shenma
remote.torque.bojiang.wait = 0;
remote.torque.bojiang.shclean = 1;
remote.torque.bojiang.cmd = 'qsub -q batch';%'qsub -q batch -o /scratch/PEYSSON';%for debug only (clear mat* files in /scratch/PEYSSON after turned on) 
remote.torque.bojiang.remotedatapath = '/scratch/bjding/';
remote.torque.bojiang.get_jobid = {'','.master'};%str_before,str_after
remote.torque.bojiang.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.bojiang.matver.mat800.root = '/pkg/MATLAB/R2012b/bin/';
remote.torque.bojiang.matver.mat800.prefdir = '/home/bjding/.matlab/R2012b';
remote.torque.bojiang.matver.matdef = remote.torque.bojiang.matver.mat800;%default matlab on remote machine
remote.torque.bojiang.remoteuser = 'bjding';
%
% YVES PEYSSON
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
remote.torque.yves.matver.mat800.root = '/pkg/MATLAB/R2012b/bin/';
remote.torque.yves.matver.mat800.prefdir = '/home/PEYSSON/.matlab/R2012b';
remote.torque.yves.matver.matdef = remote.torque.yves.matver.mat800;%default matlab on remote machine
remote.torque.yves.remoteuser = 'PEYSSON';
remote.torque.yves.bridge.url.host = 'tolbachik.hd.free.fr';
remote.torque.yves.bridge.url.path = '~yvespeysson/MatRemote';
remote.torque.yves.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.torque.yves.bridge.ftp.username = 'matremote';
remote.torque.yves.bridge.ftp.password = 'Rq59G4zzPSzZNC9LFMdTK';
%
% JOAN DECKER
%
remote.torque.joan = remote.torque.yves;
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
