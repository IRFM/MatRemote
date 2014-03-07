function remote_profile = remote_CEA_CEPHEE(varargin)
%
% This function regroups the remote profiles run on the CEPHEE cluster
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'pbs';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'joan';% default user profile if 'remoteuser' is not an existing user profile
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
remote.pbs.joan.hostname = 'cephee';
remote.pbs.joan.nproc = 28;% limited to two jobs per PBS node to avoid cluster saturation
remote.pbs.joan.nodes = 1;% default number of nodes for job on cephee
remote.pbs.joan.ppn = 2;% default number of cores for job on cephee
remote.pbs.joan.cmd = 'qsub -l inter=false';% -l walltime=1:59:00 -l nodes=1:ppn=1
remote.pbs.joan.get_jobid = {'','.cephee'};%str_before,str_after
remote.pbs.joan.set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.joan.matver.mat705 = '/applications/matlab_2007b/bin/';
remote.pbs.joan.matver.mat710 = '/Applications/Matlab_2010A/bin/';
remote.pbs.joan.matver.mat712 = '/Applications/Matlab_2011A/bin/';
remote.pbs.joan.matver.mat800 = '/Applications/Matlab_2012B/bin/';
remote.pbs.joan.matver.matdef = remote.pbs.joan.matver.mat800;%default matlab on remote machine
remote.pbs.joan.remoteuser = 'JD211098';
%
% direct
%
remote.direct.joan = default_remote_profile;
remote.direct.joan.host = 'cephee15.intra.cea.fr';% empty for local host
remote.direct.joan.hostname = 'cephee';
remote.direct.joan.nproc = 8;% cores per node
remote.direct.joan.nodes = 1;% default number of nodes for job on cephee
remote.direct.joan.ppn = 2;% default number of cores for job on cephee
remote.direct.joan.cmd = {'csh','',' &',' &'};% direct calculation (csh, bash)
remote.direct.joan.get_jobid = {};%str_before,str_after
remote.direct.joan.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.joan.matver.mat705 = '/applications/matlab_2007b/bin/';
remote.direct.joan.matver.mat710 = '/Applications/Matlab_2010A/bin/';
remote.direct.joan.matver.mat712 = '/Applications/Matlab_2011A/bin/';
remote.direct.joan.matver.mat800 = '/Applications/Matlab_2012B/bin/';
remote.direct.joan.matver.matdef = remote.direct.joan.matver.mat800;%default matlab on remote machine
remote.direct.joan.remoteuser = 'JD211098';
%
% YVES PEYSSON
%
remote.pbs.yves = default_remote_profile;
remote.pbs.yves.host = 'cephee15.intra.cea.fr';
remote.pbs.yves.hostname = 'cephee';
remote.pbs.yves.nproc = 28;% limited to two jobs per PBS node to avoid cluster saturation
remote.pbs.yves.nodes = 1;% default number of nodes for job on cephee
remote.pbs.yves.ppn = 2;% default number of cores for job on cephee
remote.pbs.yves.cmd = 'qsub -l inter=false';% -l walltime=1:59:00 -l nodes=1:ppn=1
remote.pbs.yves.get_jobid = {'','.cephee'};%str_before,str_after
remote.pbs.yves.set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.yves.remotedatapath = '/home/sccp/gsem/peysson/tmp/';
remote.pbs.yves.matver.mat705 = '/applications/matlab_2007b/bin/';
remote.pbs.yves.matver.mat710 = '/Applications/Matlab_2010A/bin/';
remote.pbs.yves.matver.mat712 = '/Applications/Matlab_2011A/bin/';
remote.pbs.yves.matver.mat800 = '/Applications/Matlab_2012B/bin/';
remote.pbs.yves.matver.matdef = remote.pbs.yves.matver.mat800;%default matlab on remote machine
remote.pbs.yves.remoteuser = 'YP105119';
%
% YVES BURAVAND
%
remote.pbs.yvesb = default_remote_profile;
remote.pbs.yvesb.host = 'cephee15.intra.cea.fr';
remote.pbs.yvesb.hostname = 'cephee';
remote.pbs.yvesb.nproc = 28;% limited to two jobs per PBS node to avoid cluster saturation
remote.pbs.yvesb.nodes = 1;% default number of nodes for job on cephee
remote.pbs.yvesb.ppn = 2;% default number of cores for job on cephee
remote.pbs.yvesb.cmd = 'qsub -l inter=false';% -l walltime=1:59:00 -l nodes=1:ppn=1
remote.pbs.yvesb.get_jobid = {'','.cephee'};%str_before,str_after
remote.pbs.yvesb.set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.yvesb.matver.mat705 = '/applications/matlab_2007b/bin/';
remote.pbs.yvesb.matver.mat710 = '/Applications/Matlab_2010A/bin/';
remote.pbs.yvesb.matver.mat712 = '/Applications/Matlab_2011A/bin/';
remote.pbs.yvesb.matver.mat800 = '/Applications/Matlab_2012B/bin/';
remote.pbs.yvesb.matver.matdef = remote.pbs.yvesb.matver.mat800;%default matlab on remote machine
remote.pbs.yvesb.remoteuser = 'YB109156';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
