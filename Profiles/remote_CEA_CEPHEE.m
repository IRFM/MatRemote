function remote_profile = remote_CEA_CEPHEE(clustername,profilename,localuser)
%
% This function regroups the remote profiles run on the CEPHEE cluster
%
default_cluster = 'pbs';% default cluster profile if 'clustername' is not an existing cluster profile
default_profile = 'joan';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% cephee (pbs)
%
%
% JOAN DECKER
%
remote.pbs.joan = default_remote_profile;
remote.pbs.joan.host = 'cephee15.intra.cea.fr';% empty for local host
remote.pbs.joan.nproc = 28;% limited to two jobs per PBS node to avoid cluster saturation
remote.pbs.joan.nodes = 1;% default number of nodes for job on cephee
remote.pbs.joan.ppn = 2;% default number of cores for job on cephee
remote.pbs.joan.cmd = 'qsub -l inter=false';% -l walltime=1:59:00 -l nodes=1:ppn=1
remote.pbs.joan.get_jobid = {'','.cephee'};%str_before,str_after
remote.pbs.joan.set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.joan.matver.mat705.root = '/applications/matlab_2007b/bin/';
remote.pbs.joan.matver.mat705.prefdir = '/home/sccp/gsem/decker/.matlab/R2007b';
remote.pbs.joan.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.pbs.joan.matver.mat710.prefdir = '/home/sccp/gsem/decker/.matlab/R2010a';
remote.pbs.joan.matver.mat712.root = '/Applications/Matlab_2011A/bin/';
remote.pbs.joan.matver.mat712.prefdir = '/home/sccp/gsem/decker/.matlab/R2011a';
remote.pbs.joan.matver.matdef = remote.pbs.joan.matver.mat710;%default matlab on remote machine
remote.pbs.joan.luke_root = '/home/sccp/gsem/decker/LUKE_1_10/';
remote.pbs.joan.users.remoteuser = 'JD211098';
%
% YVES PEYSSON
%
remote.pbs.yves = default_remote_profile;
remote.pbs.yves.host = 'cephee15.intra.cea.fr';
remote.pbs.yves.nproc = 28;% limited to two jobs per PBS node to avoid cluster saturation
remote.pbs.yves.nodes = 1;% default number of nodes for job on cephee
remote.pbs.yves.ppn = 2;% default number of cores for job on cephee
remote.pbs.yves.cmd = 'qsub -l inter=false';% -l walltime=1:59:00 -l nodes=1:ppn=1
remote.pbs.yves.get_jobid = {'','.cephee'};%str_before,str_after
remote.pbs.yves.set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.yves.matver.mat705.root = '/applications/matlab_2007b/bin/';
remote.pbs.yves.matver.mat705.prefdir = '/home/sccp/gsem/peysson/.matlab/R2007b';
remote.pbs.yves.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.pbs.yves.matver.mat710.prefdir = '/home/sccp/gsem/peysson/.matlab/R2010a';
remote.pbs.yves.matver.mat712.root = '/Applications/Matlab_2011A/bin/';
remote.pbs.yves.matver.mat712.prefdir = '/home/sccp/gsem/peysson/.matlab/R2011a';
remote.pbs.yves.matver.matdef = remote.pbs.yves.matver.mat710;%default matlab on remote machine
remote.pbs.yves.luke_root = '/home/sccp/gsem/peysson/LUKE/';
remote.pbs.yves.users.remoteuser = 'YP105119';
%
% YVES BURAVAND
%
remote.pbs.yvesb = default_remote_profile;
remote.pbs.yvesb.host = 'cephee15.intra.cea.fr';
remote.pbs.yvesb.nproc = 28;% limited to two jobs per PBS node to avoid cluster saturation
remote.pbs.yvesb.nodes = 1;% default number of nodes for job on cephee
remote.pbs.yvesb.ppn = 2;% default number of cores for job on cephee
remote.pbs.yvesb.cmd = 'qsub -l inter=false';% -l walltime=1:59:00 -l nodes=1:ppn=1
remote.pbs.yvesb.get_jobid = {'','.cephee'};%str_before,str_after
remote.pbs.yvesb.set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.yvesb.matver.mat705.root = '/applications/matlab_2007b/bin/';
remote.pbs.yvesb.matver.mat705.prefdir = '/home/sccp/gsem/peysson/.matlab/R2007b';
remote.pbs.yvesb.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.pbs.yvesb.matver.mat710.prefdir = '/home/sccp/gsem/peysson/.matlab/R2010a';
remote.pbs.yvesb.matver.mat712.root = '/Applications/Matlab_2011A/bin/';
remote.pbs.yvesb.matver.mat712.prefdir = '/home/sccp/gsem/peysson/.matlab/R2011a';
remote.pbs.yvesb.matver.matdef = remote.pbs.yvesb.matver.mat710;%default matlab on remote machine
remote.pbs.yvesb.luke_root = '/home/sccp/gsem/peysson/LUKE/';
remote.pbs.yvesb.users.remoteuser = 'YB109156';
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
