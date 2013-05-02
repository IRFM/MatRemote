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
remote.torque.joan.shclean = 1;
remote.torque.joan.cmd = 'qsub';
remote.torque.joan.get_jobid = {'','.cadts-0412'};%str_before,str_after
remote.torque.joan.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.joan.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.torque.joan.matver.mat710.prefdir = '/home/sccp/gsem/decker/.matlab/R2010a';
remote.torque.joan.matver.mat712.root = '/Applications/Matlab_2011A/bin/';
remote.torque.joan.matver.mat712.prefdir = '/home/sccp/gsem/decker/.matlab/R2011a';
remote.torque.joan.matver.mat800.root = '/Applications/Matlab_2012B/bin/';
remote.torque.joan.matver.mat800.prefdir = '/home/sccp/gsem/decker/.matlab/R2012b';
remote.torque.joan.matver.matdef = remote.torque.joan.matver.mat800;%default matlab on remote machine
remote.torque.joan.luke_root = '/home/sccp/gsem/decker/LUKE_1_10/';
remote.torque.joan.users.remoteuser = 'joan';
%
% YVES PEYSSON
%
% cadts-0412 (torque)
%
remote.torque.yves = default_remote_profile;
remote.torque.yves.host = 'cadts-0412.intra.cea.fr';% empty for local host
remote.torque.yves.nproc = 12;
remote.torque.yves.wait = 0;
remote.torque.yves.shclean = 1;
remote.torque.yves.cmd = 'qsub';
remote.torque.yves.get_jobid = {'','.cadts-0412'};%str_before,str_after
remote.torque.yves.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.yves.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.torque.yves.matver.mat710.prefdir = '/home/sccp/gsem/peysson/.matlab/R2010a';
remote.torque.yves.matver.mat712.root = '/Applications/Matlab_2011A/bin/';
remote.torque.yves.matver.mat712.prefdir = '/home/sccp/gsem/peysson/.matlab/R2011a';
remote.torque.yves.matver.matdef = remote.torque.yves.matver.mat710;%default matlab on remote machine
remote.torque.yves.luke_root = '/home/sccp/gsem/peysson/LUKE/';
remote.torque.yves.users.remoteuser = 'YP105119';
%
% YVES BURAVAND
%
% cadts-0412 (torque)
%
remote.torque.yvesb = default_remote_profile;
remote.torque.yvesb.host = 'cadts-0412.intra.cea.fr';% empty for local host
remote.torque.yvesb.nproc = 12;
remote.torque.yvesb.wait = 0;
remote.torque.yvesb.shclean = 1;
remote.torque.yvesb.cmd = 'qsub';
remote.torque.yvesb.get_jobid = {'','.cadts-0412'};%str_before,str_after
remote.torque.yvesb.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.yvesb.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.torque.yvesb.matver.mat710.prefdir = '/home/sccp/gsem/peysson/.matlab/R2010a';
remote.torque.yvesb.matver.mat712.root = '/Applications/Matlab_2011A/bin/';
remote.torque.yvesb.matver.mat712.prefdir = '/home/sccp/gsem/peysson/.matlab/R2011a';
remote.torque.yvesb.matver.matdef = remote.torque.yvesb.matver.mat710;%default matlab on remote machine
remote.torque.yvesb.luke_root = '/home/sccp/gsem/peysson/LUKE/';
remote.torque.yvesb.users.remoteuser = 'YB109156';
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
