function remote_profile = remote_CEA_PLEIONE(clustername,profilename,localuser)
%
% This function regroups the remote profiles run on the CEA PBS PRO SYSTEM, including PLEIONE, MEROPE, NASHIRA and the NUNKI cluster
%
default_cluster = 'pbs';% default cluster profile if 'clustername' is not an existing cluster profile
default_profile = 'joan';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% JOAN DECKER
%
% nunki (pbs pro)
%
remote.pbs.joan = default_remote_profile;
remote.pbs.joan.host = 'pleione.intra.cea.fr';% empty for local host
remote.pbs.joan.nproc = 48;
remote.pbs.joan.cmd = 'qsub';
remote.pbs.joan.get_jobid = {'','.pleione'};%str_before,str_after
remote.pbs.joan.set_jobid = {'qstat ','.pleione','Unknown Job Id'};%str_before,str_after,str_check
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
remote.pbs.yves.host = 'pleione.intra.cea.fr';
%
% to complete
%

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
