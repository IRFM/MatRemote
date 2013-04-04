function remote_profile = remote_CEA_SATURNE(clustername,profilename,localuser)
%
% This function regroups the remote profiles run on the SATURNE cluster
%
default_cluster = 'sun';% default cluster profile if 'clustername' is not an existing cluster profile
default_profile = 'joan';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% saturne (sun batch system)
%
%
% JOAN DECKER
%
remote.sun.joan = default_remote_profile;
remote.sun.joan.host = 'saturne1.partenaires.cea.fr';% empty for local host
remote.sun.joan.nproc = 12;% limited to two jobs per PBS node to avoid cluster saturation
remote.sun.joan.wait = 0;% invalid option
remote.sun.joan.nodes = NaN;% invalid option
remote.sun.joan.ncpus = NaN;% invalid option
remote.sun.joan.memory = NaN;% invalid option
remote.sun.joan.walltime = NaN;% invalid option
remote.sun.joan.cmd = 'qsub -q batch.q';% 
remote.sun.joan.get_jobid = {'Your job ',' '};%str_before,str_after
remote.sun.joan.set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
remote.sun.joan.matver.mat705.root = '/usr/local/matlab7/bin/';
remote.sun.joan.matver.mat705.prefdir = '/home/JD211098/.matlab/R2007b';
remote.sun.joan.matver.matdef = remote.sun.joan.matver.mat705;%default matlab on remote machine
remote.sun.joan.luke_root = '/home/JD211098/LUKE/';
remote.sun.joan.users.remoteuser = 'JD211098';
%
% YVES PEYSSON
%
remote.sun.yves = default_remote_profile;
remote.sun.yves.host = 'saturne1.partenaires.cea.fr';
remote.sun.yves.nproc = 12;% limited to two jobs per PBS node to avoid cluster saturation
remote.sun.yves.wait = 0;% invalid option
remote.sun.yves.nodes = NaN;% invalid option
remote.sun.yves.ncpus = NaN;% invalid option
remote.sun.yves.memory = NaN;% invalid option
remote.sun.yves.walltime = NaN;% invalid option
remote.sun.yves.cmd = 'qsub -q batch.q';% 
remote.sun.yves.get_jobid = {'Your job ',' '};%str_before,str_after
remote.sun.yves.set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
remote.sun.yves.matver.mat705.root = '/usr/local/matlab7/bin/';
remote.sun.yves.matver.mat705.prefdir = '/home/YP105119/.matlab/R2007b';
remote.sun.yves.matver.matdef = remote.sun.yves.matver.mat705;%default matlab on remote machine
remote.sun.yves.luke_root = '/home/YP105119/LUKE/';
remote.sun.yves.users.remoteuser = 'YP105119';
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
