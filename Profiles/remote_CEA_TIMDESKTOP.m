function remote_profile = remote_CEA_TIMDESKTOP(clustername,profilename,localuser)
%
% This function regroups the remote profiles run timothee's computer
%
default_cluster = 'torque';% default cluster profile if 'clustername' is not an existing cluster profile
default_profile = 'joan';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% JOAN DECKER
%
% cadts-0412 (torque)
%
remote.torque.joan = default_remote_profile;
remote.torque.joan.host = 'cadts-0412.intra.cea.fr';% empty for local host
remote.torque.joan.nproc = 12;
remote.torque.joan.wait = 0;
remote.torque.joan.cmd = 'qsub';
remote.torque.joan.get_jobid = {'','.cadts-0412'};%str_before,str_after
remote.torque.joan.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.joan.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.torque.joan.matver.mat710.prefdir = '/home/sccp/gsem/decker/.matlab/R2010a';
remote.torque.joan.matver.mat712.root = '/Applications/Matlab_2011A/bin/';
remote.torque.joan.matver.mat712.prefdir = '/home/sccp/gsem/decker/.matlab/R2011a';
remote.torque.joan.matver.matdef = remote.torque.joan.matver.mat710;%default matlab on remote machine
remote.torque.joan.luke_root = '/home/sccp/gsem/decker/LUKE_1_10/';
remote.torque.joan.users.remoteuser = 'joan';
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
