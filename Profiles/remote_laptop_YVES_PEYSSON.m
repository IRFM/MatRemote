function remote_profile = remote_laptop_YVES_PEYSSON(clustername,profilename,localuser)
%
% This function regroups the remote profiles run on the MACPRO of Yves Peysson
%
default_cluster = 'condor';% default cluster profile if 'clustername' is not an existing cluster profile
default_profile = 'yves';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% macbookyves (condor)
%
%
% YVES PEYSSON
%
remote.condor.yves = default_remote_profile;
remote.condor.yves.host = '127.0.0.1';
remote.condor.yves.nproc = 6;
remote.condor.yves.cmd = 'condor_submit';
remote.condor.yves.get_jobid = {'** Proc ',':'};
remote.condor.yves.set_jobid = {'condor_q ',''};
remote.condor.yves.env.CONDOR_CONFIG = '/usr/local/condor/etc/condor_config';
remote.condor.yves.env.PATH = '/usr/local/condor/sbin:/usr/local/condor/bin:${PATH}';
remote.condor.yves.remotedatapath = '/Users/yves/condor/';
remote.condor.yves.matver.mat800.root = '/Applications/MATLAB_R2012b.app/bin/';
remote.condor.yves.matver.mat800.prefdir = '/Users/yves/.matlab/R2012b';
remote.condor.yves.matver.mat801.root = '/Applications/MATLAB_R2013a.app/bin/';
remote.condor.yves.matver.mat801.prefdir = '/Users/yves/.matlab/R2013a';
remote.condor.yves.matver.matdef = remote.condor.yves.matver.mat801;%default matlab on remote machine
remote.condor.yves.luke_root = '/Users/yves/Projets/LUKE/';
remote.condor.yves.users.remoteuser = 'yves';
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
    