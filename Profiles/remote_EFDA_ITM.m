function remote_profile = remote_EFDA_ITM(clustername,profilename,localuser)
%
% This function regroups the remote profiles run on the european EFDA ITM cluster
%
default_cluster = 'sge';% default cluster profile if 'clustername' is not an existing cluster profile
default_profile = 'yvesp';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% YVES PEYSSON
%
remote.sge.yvesp = default_remote_profile;
remote.sge.yvesp.host = 'g01.efda-itm.eu';% empty for local host
remote.sge.yvesp.nproc = 20;
%remote.sge.yvesp.nodes = 10;% default number of nodes for job on shenma
remote.sge.yvesp.wait = 0;
remote.sge.yvesp.shclean = 1;
remote.sge.yvesp.cmd = 'qsub -q batch';
%remote.sge.yvesp.cmd = 'qsub -q batch -o /scratch/PEYSSON';%for debug only (clear mat* files in /scratch/PEYSSON after turned on) 
remote.sge.yvesp.remotedatapath = '/scratch/PEYSSON/';
remote.sge.yvesp.get_jobid = {'','.master'};%str_before,str_after
remote.sge.yvesp.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.sge.yvesp.matver.mat800.root = '/afs/ipp/common/soft/matlab_2012b/bin/';
remote.sge.yvesp.matver.mat800.prefdir = '/u/yvesp/.matlab/R2012b';
remote.sge.yvesp.matver.matdef = remote.sge.yvesp.matver.mat800;%default matlab on remote machine
remote.sge.yvesp.luke_root = '/u/yvesp/public/LUKE_ITM/trunk/LUKE/';
remote.sge.yvesp.users.remoteuser = 'PEYSSON';
%
% JOAN DECKER
%
%remote.sge.joan = remote.sge.yvesp;
%remote.sge.joan.luke_root = '/home/PEYSSON/JoanDecker/LUKE/';
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
