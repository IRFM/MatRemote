function remote_profile = remote_EFDA_ITM(clustername,profilename,localuser)
%
% This function regroups the remote profiles run on the european EFDA ITM cluster
%
default_cluster = 'sun';% default cluster profile if 'clustername' is not an existing cluster profile
default_profile = 'yvesp';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% YVES PEYSSON
%
remote.sun.yvesp = default_remote_profile;
remote.sun.yvesp.host = 'g01.efda-itm.eu';
remote.sun.yvesp.nproc = 16;% limited to two jobs per PBS node to avoid cluster saturation
remote.sun.yvesp.wait = 0;% invalid option
remote.sun.yvesp.nodes = NaN;% invalid option
remote.sun.yvesp.ncpus = NaN;% invalid option
remote.sun.yvesp.memory = NaN;% invalid option
remote.sun.yvesp.walltime = NaN;% invalid option
remote.sun.yvesp.cmd = 'qsub -q batch.q';% 
remote.sge.yvesp.remotedatapath = '/tmp/';
remote.sun.yvesp.get_jobid = {'Your job ',' '};%str_before,str_after
remote.sun.yvesp.set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
remote.sun.yvesp.matver.mat800.root = '/afs/ipp/common/soft/matlab_2012b/bin/';
remote.sun.yvesp.matver.mat800.prefdir = '/u/yvesp/.matlab/R2012b';
remote.sun.yvesp.matver.matdef = remote.sun.yvesp.matver.mat800;%default matlab on remote machine
remote.sun.yvesp.cvs.CVSROOT = ':pserver:YP105119:Peys#4Yv@altair.partenaires.cea.fr:/usr/local/cvs/gcgc';%CVS root for LUKE
remote.sun.yvesp.cvs.cmd = 'update -d';%CVS command
remote.sun.yvesp.luke_root = '/u/yvesp/public/LUKE_ITM/trunk/LUKE/';
remote.sun.yvesp.users.remoteuser = 'yvesp';
%
% JOAN DECKER
%
remote.sun.joan = remote.sun.yvesp;
remote.sun.joan.luke_root = '/u/yvesp/joandecker/LUKE/';
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
