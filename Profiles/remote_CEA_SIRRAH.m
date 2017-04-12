function remote_profile = remote_CEA_SIRRAH(varargin)
%
% This function regroups the remote profiles run on the SIRRAH cluster
% in the CEA INTRA network
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'pbs';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'YP105119';% default user profile if 'remoteuser' is not an existing user profile
%
% YVES PEYSSON
%
remote.pbs.YP105119 = default_remote_profile;
remote.pbs.YP105119.host = 'sirrah.intra.cea.fr';
remote.pbs.YP105119.hostname = 'sirrah';
remote.pbs.YP105119.shell = 'csh';
remote.pbs.YP105119.nproc = 12;
remote.pbs.YP105119.cmd = 'qsub';
remote.pbs.YP105119.remotedatapath = '/tmp/';
remote.pbs.YP105119.get_jobid = {'','.sirrah'};%str_before,str_after
remote.pbs.YP105119.set_jobid = {'qstat ','.andromede1','finished'};%str_before,str_after,str_check
remote.pbs.YP105119.shclean = 1;
remote.pbs.YP105119.matver.mat805 = '/Applications/Matlab_2015A/bin/matlab';
remote.pbs.YP105119.matver.matdef = remote.pbs.YP105119.matver.mat805;%default matlab on remote machine
remote.pbs.YP105119.remoteuser = 'YP105119';
%
% direct
%
remote.direct.YP105119 = default_remote_profile;
remote.direct.YP105119.host = 'sirrah.intra.cea.fr';
remote.direct.YP105119.hostname = 'sirrah';
remote.direct.YP105119.shell = 'csh';
remote.direct.YP105119.nproc = 12;
% remote.direct.YP105119.cmd = {'csh','nohup ',' `</dev/null` >nohup.out &',''};% direct calculation (csh, bash)
remote.direct.YP105119.cmd = {'csh','',' &',' &'};% direct calculation (csh, bash)
remote.direct.YP105119.get_jobid = {};%str_before,str_after
remote.direct.YP105119.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.YP105119.remotedatapath = '/Home/YP105119/';
remote.direct.YP105119.matver.mat805 = '/Applications/Matlab_2015A/bin/matlab';
remote.direct.YP105119.matver.matdef = remote.direct.YP105119.matver.mat805;%default matlab on remote machine
remote.direct.YP105119.remoteuser = 'YP105119';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
