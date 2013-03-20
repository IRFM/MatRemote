function remote_profile = remote_macpro_YVES_PEYSSON(clustername,profilename,localuser)
%
% This function regroups the remote profiles run on the MACPRO of Yves Peysson
%
default_cluster = 'condor';% default cluster profile if 'clustername' is not an existing cluster profile
default_user = 'yves';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% macproyves (condor)
%
%
% YVES PEYSSON
%
remote.condor.yves = default_remote_profile;
remote.condor.yves.host = 'tolbachik.hd.free.fr';
remote.condor.yves.nproc = 6;
remote.condor.yves.cmd = 'condor_submit';
remote.condor.yves.get_jobid = {'** Proc ',':'};
remote.condor.yves.set_jobid = {'condor_q ',''};
remote.condor.yves.env.CONDOR_CONFIG = '/usr/local/condor/etc/condor_config';
remote.condor.yves.env.PATH = '/usr/local/condor/sbin:/usr/local/condor/bin:${PATH}';
remote.condor.yves.remotedatapath = '/Users/yvespeysson/condor/';
remote.condor.yves.matver.mat714.root = '/Applications/MATLAB_R2012a.app/bin/';
remote.condor.yves.matver.mat714.prefdir = '/Users/yvespeysson/.matlab/R2012a';
remote.condor.yves.matver.mat800.root = '/Applications/MATLAB_R2012b.app/bin/';
remote.condor.yves.matver.mat800.prefdir = '/Users/yvespeysson/.matlab/R2012b';
remote.condor.yves.matver.mat801.root = '/Applications/MATLAB_R2013a.app/bin/';
remote.condor.yves.matver.mat801.prefdir = '/Users/yvespeysson/.matlab/R2013a';
remote.condor.yves.matver.matdef = remote.condor.yves.matver.mat800;%default matlab on remote machine
remote.condor.yves.luke_root = '/Users/yvespeysson/Projets/LUKE/';
remote.condor.yves.remoteuser = 'yvespeysson';
%
% JOAN DECKER
%
remote.condor.joan = default_remote_profile;
remote.condor.joan.host = 'tolbachik.hd.free.fr';
remote.condor.joan.nproc = 6;
remote.condor.joan.cmd = 'condor_submit';
remote.condor.joan.get_jobid = {'** Proc ',':'};
remote.condor.joan.set_jobid = {'condor_q ',''};
remote.condor.joan.env.CONDOR_CONFIG = '/usr/local/condor/etc/condor_config';
remote.condor.joan.env.PATH = '/usr/local/condor/sbin:/usr/local/condor/bin:${PATH}';
remote.condor.joan.remotedatapath = '/Users/yvespeysson/condor/';
remote.condor.joan.matver.mat714.root = '/Applications/MATLAB_R2012a.app/bin/';
remote.condor.joan.matver.mat714.prefdir = '/Users/yvespeysson/.matlab/R2012a';
remote.condor.joan.matver.mat800.root = '/Applications/MATLAB_R2012b.app/bin/';
remote.condor.joan.matver.mat800.prefdir = '/Users/yvespeysson/.matlab/R2012b';
remote.condor.joan.matver.matdef = remote.condor.joan.matver.mat800;%default matlab on remote machine
remote.condor.joan.luke_root = '/Users/yvespeysson/joandecker/Work/LUKE_1_10/';
remote.condor.joan.remoteuser = 'yvespeysson';%'joandecker';
%
% --------------------------------------------------
%
% macproyves (xgrid)
%
%
% YVES PEYSSON
%
remote.xgrid.yves = default_remote_profile;
remote.xgrid.yves.host = 'tolbachik.hd.free.fr';
remote.xgrid.yves.nproc = 6;
remote.xgrid.yves.cmd = {'xgrid -h ',' -p ',' -job batch '};
remote.xgrid.yves.get_jobid = {'jobIdentifier = ',';'};
remote.xgrid.yves.set_jobid = {'xgrid -h ',' -job attributes -id ','jobStatus = Running','jobStatus = Pending','jobStatus = Finished',' -job results -id ',' -se ',' -so ',' -out ',' -job delete -id '};%
remote.xgrid.yves.remotedatapath = '/Users/yvespeysson/xgrid/';
remote.xgrid.yves.matver.mat800.root = '/Applications/MATLAB_R2012b.app/bin/';
remote.xgrid.yves.matver.mat800.prefdir = '/Users/yvespeysson/.matlab/R2012b';
remote.xgrid.yves.matver.mat801.root = '/Applications/MATLAB_R2013a.app/bin/';
remote.xgrid.yves.matver.mat801.prefdir = '/Users/yvespeysson/.matlab/R2013a';
remote.xgrid.yves.matver.matdef = remote.xgrid.yves.matver.mat800;%default matlab on remote machine
remote.xgrid.yves.luke_root = '/Users/yvespeysson/LUKE/';
remote.xgrid.yves.password = {'ghm93'};
remote.xgrid.yves.remoteuser = 'yvespeysson';%'joandecker';
%
% JOAN DECKER
%
remote.xgrid.joan = default_remote_profile;
remote.xgrid.joan.host = 'tolbachik.hd.free.fr';
remote.xgrid.joan.nproc = 6;
remote.xgrid.joan.cmd = {'xgrid -h ',' -p ',' -job batch '};
remote.xgrid.joan.get_jobid = {'jobIdentifier = ',';'};
remote.xgrid.joan.set_jobid = {'xgrid -h ',' -job attributes -id ','jobStatus = Running','jobStatus = Pending','jobStatus = Finished',' -job results -id ',' -se ',' -so ',' -out ',' -job delete -id '};%
remote.xgrid.joan.remotedatapath = '/Users/yvespeysson/xgrid/';
remote.xgrid.joan.matver.mat714.root = '/Applications/MATLAB_R2012a.app/bin/';
remote.xgrid.joan.matver.mat714.prefdir = '/Users/yvespeysson/.matlab/R2012a';
remote.xgrid.joan.matver.mat800.root = '/Applications/MATLAB_R2012b.app/bin/';
remote.xgrid.joan.matver.mat800.prefdir = '/Users/yvespeysson/.matlab/R2012b';
remote.xgrid.joan.matver.matdef = remote.xgrid.joan.matver.mat800;%default matlab on remote machine
remote.xgrid.joan.luke_root = '/Users/yvespeysson/joandecker/Work/LUKE_1_10/';
remote.xgrid.joan.password = {'ghm93'};
remote.xgrid.joan.remoteuser = 'yvespeysson';%'joandecker';
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
    profilename = default_user;
end
%
remote_profile = remote.(clustername).(profilename);
%
if nargin >= 3,
    remote_profile.(localuser) = remote_profile.remoteuser;
end
%
    