function remote_profile = remote_CEA_PLEIONE(varargin)
%
% This function regroups the remote profiles run on the CEA PBS PRO SYSTEM, including PLEIONE, MEROPE, NASHIRA and the NUNKI cluster
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
% JOAN DECKER
%
% nunki (pbs pro)
%
remote.pbs.joan = default_remote_profile;
remote.pbs.joan.host = 'pleione.intra.cea.fr';% empty for local host
remote.pbs.joan.hostname = 'pleione';
remote.pbs.joan.nproc = 48;
remote.pbs.joan.cmd = 'qsub';
remote.pbs.joan.get_jobid = {'','.pleione'};%str_before,str_after
remote.pbs.joan.set_jobid = {'qstat ','.pleione','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.joan.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.pbs.joan.matver.mat710.prefdir = '/home/sccp/gsem/decker/.matlab/R2010a';
remote.pbs.joan.matver.mat712.root = '/Applications/Matlab_2011A/bin/';
remote.pbs.joan.matver.mat712.prefdir = '/home/sccp/gsem/decker/.matlab/R2011a';
remote.pbs.joan.matver.mat800.root = '/Applications/Matlab_2012B/bin/';
remote.pbs.joan.matver.mat800.prefdir = '/home/sccp/gsem/decker/.matlab/R2012b';
remote.pbs.joan.matver.matdef = remote.pbs.joan.matver.mat800;%default matlab on remote machine
remote.pbs.joan.remoteuser = 'JD211098';
%
% YVES PEYSSON
%
remote.pbs.yves = default_remote_profile;
remote.pbs.yves.host = 'pleione.intra.cea.fr';
remote.pbs.yves.hostname = 'pleione';
remote.pbs.yves.nproc = 48;
remote.pbs.yves.cmd = 'qsub';
remote.pbs.yves.get_jobid = {'','.pleione'};%str_before,str_after
remote.pbs.yves.set_jobid = {'qstat ','.pleione','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.yves.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.pbs.yves.matver.mat710.prefdir = '/home/sccp/gsem/peysson/.matlab/R2010a';
remote.pbs.yves.matver.mat712.root = '/Applications/Matlab_2011A/bin/';
remote.pbs.yves.matver.mat712.prefdir = '/home/sccp/gsem/peysson/.matlab/R2011a';
remote.pbs.yves.matver.matdef = remote.pbs.yves.matver.mat710;%default matlab on remote machine
remote.pbs.yves.remoteuser = 'YP105119';
%
% YVES BURAVAND
%
remote.pbs.yvesb = default_remote_profile;
remote.pbs.yvesb.host = 'pleione.intra.cea.fr';
remote.pbs.yvesb.hostname = 'pleione';
remote.pbs.yvesb.nproc = 48;
remote.pbs.yvesb.cmd = 'qsub';
remote.pbs.yvesb.get_jobid = {'','.pleione'};%str_before,str_after
remote.pbs.yvesb.set_jobid = {'qstat ','.pleione','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.yvesb.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.pbs.yvesb.matver.mat710.prefdir = '/home/sccp/gsem/peysson/.matlab/R2010a';
remote.pbs.yvesb.matver.mat712.root = '/Applications/Matlab_2011A/bin/';
remote.pbs.yvesb.matver.mat712.prefdir = '/home/sccp/gsem/peysson/.matlab/R2011a';
remote.pbs.yvesb.matver.matdef = remote.pbs.yvesb.matver.mat710;%default matlab on remote machine
remote.pbs.yvesb.remoteuser = 'YB109156';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%

