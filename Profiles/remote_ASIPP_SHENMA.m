function remote_profile = remote_ASIPP_SHENMA(clustername,profilename,localuser)
%
% This function regroups the remote profiles run on the ASIPP SHENMA cluster (Hefei, China)
%
default_cluster = 'torque';% default cluster profile if 'clustername' is not an existing cluster profile
default_profile = 'bojiang';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% cephee (pbs)
%
%
% BOJIANG DING
%
remote.torque.bojiang = default_remote_profile;
remote.torque.bojiang.host = 'shenma.ipp.ac.cn';% empty for local host
remote.torque.bojiang.nproc = 20;
%remote.torque.bojiang.nodes = 10;% default number of nodes for job on shenma
remote.torque.bojiang.wait = 0;
remote.torque.bojiang.shclean = 1;
remote.torque.bojiang.cmd = 'qsub -q batch';
%remote.torque.bojiang.cmd = 'qsub -q batch -o /scratch/bjding';%for debug only (clear mat* files in /scratch/bjding after turned on)
remote.torque.bojiang.remotedatapath = '/scratch/bjding/';
remote.torque.bojiang.get_jobid = {'','.master'};%str_before,str_after
remote.torque.bojiang.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.bojiang.matver.mat800.root = '/pkg/MATLAB/R2012b/bin/';
remote.torque.bojiang.matver.mat800.prefdir = '/home/bjding/.matlab/R2012b';
remote.torque.bojiang.matver.matdef = remote.torque.bojiang.matver.mat800;%default matlab on remote machine
remote.torque.bojiang.luke_root = '/home/bjding/LUKE/';
remote.torque.bojiang.users.remoteuser = 'bjding';
%
% YVES PEYSSON
%
remote.torque.yves = default_remote_profile;
remote.torque.yves.host = 'shenma.ipp.ac.cn';% empty for local host
remote.torque.yves.nproc = 20;
%remote.torque.yves.nodes = 10;% default number of nodes for job on shenma
remote.torque.yves.wait = 0;
remote.torque.yves.shclean = 1;
remote.torque.yves.cmd = 'qsub -q batch';
%remote.torque.yves.cmd = 'qsub -q batch -o /scratch/PEYSSON';%for debug only (clear mat* files in /scratch/PEYSSON after turned on) 
remote.torque.yves.remotedatapath = '/scratch/PEYSSON/';
remote.torque.yves.get_jobid = {'','.master'};%str_before,str_after
remote.torque.yves.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.yves.matver.mat800.root = '/pkg/MATLAB/R2012b/bin/';
remote.torque.yves.matver.mat800.prefdir = '/home/PEYSSON/.matlab/R2012b';
remote.torque.yves.matver.matdef = remote.torque.yves.matver.mat800;%default matlab on remote machine
remote.torque.yves.luke_root = '/home/PEYSSON/LUKE/';
remote.torque.yves.users.remoteuser = 'PEYSSON';
%
% JOAN DECKER
%
remote.torque.joan = remote.torque.yves;
remote.torque.joan.luke_root = '/home/PEYSSON/JoanDecker/LUKE/';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
if nargin < 1 || ~isfield(remote,clustername),
    clustername = default_cluster;
end
%
if nargin < 2 || ~isfield(remote.(clustername),profilename),
    profilename = default_profile;
end
%
remote_profile = remote.(clustername).(profilename);
%
if nargin >= 3,
    remote_profile.users.(localuser) = remote_profile.users.remoteuser;
end
%
