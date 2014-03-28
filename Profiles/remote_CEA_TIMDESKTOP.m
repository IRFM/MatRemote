function remote_profile = remote_CEA_TIMDESKTOP(varargin)
%
% This function regroups the remote profiles run timothee's computer
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'torque';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'joan';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% JOAN DECKER
%
% cadts-0412 (torque)
%
remote.torque.joan = default_remote_profile;
remote.torque.joan.host = 'cadts-0412.intra.cea.fr';% empty for local host
remote.torque.joan.hostname = 'cadts-0412';
remote.torque.joan.nproc = 12;
remote.torque.joan.wait = 0;
remote.torque.joan.shclean = 1;
remote.torque.joan.cmd = 'qsub';
remote.torque.joan.get_jobid = {'','.cadts-0412'};%str_before,str_after
remote.torque.joan.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.joan.matver.mat710 = '/Applications/Matlab_2010A/bin/matlab';
remote.torque.joan.matver.mat712 = '/Applications/Matlab_2011A/bin/matlab';
remote.torque.joan.matver.mat800 = '/Applications/Matlab_2012B/bin/matlab';
remote.torque.joan.matver.matdef = remote.torque.joan.matver.mat800;%default matlab on remote machine
remote.torque.joan.remoteuser = 'joan';
%
% YVES PEYSSON
%
% cadts-0412 (torque)
%
remote.torque.yves = default_remote_profile;
remote.torque.yves.host = 'cadts-0412.intra.cea.fr';% empty for local host
remote.torque.yves.hostname = 'cadts-0412';
remote.torque.yves.nproc = 12;
remote.torque.yves.wait = 0;
remote.torque.yves.shclean = 1;
remote.torque.yves.cmd = 'qsub';
remote.torque.yves.get_jobid = {'','.cadts-0412'};%str_before,str_after
remote.torque.yves.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.yves.matver.mat710 = '/Applications/Matlab_2010A/bin/matlab';
remote.torque.yves.matver.mat712 = '/Applications/Matlab_2011A/bin/matlab';
remote.torque.yves.matver.matdef = remote.torque.yves.matver.mat710;%default matlab on remote machine
remote.torque.yves.remoteuser = 'YP105119';
%
% YVES BURAVAND
%
% cadts-0412 (torque)
%
remote.torque.yvesb = default_remote_profile;
remote.torque.yvesb.host = 'cadts-0412.intra.cea.fr';% empty for local host
remote.torque.yvesb.hostname = 'cadts-0412';
remote.torque.yvesb.nproc = 12;
remote.torque.yvesb.wait = 0;
remote.torque.yvesb.shclean = 1;
remote.torque.yvesb.cmd = 'qsub';
remote.torque.yvesb.get_jobid = {'','.cadts-0412'};%str_before,str_after
remote.torque.yvesb.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.yvesb.matver.mat710 = '/Applications/Matlab_2010A/bin/matlab';
remote.torque.yvesb.matver.mat712 = '/Applications/Matlab_2011A/bin/matlab';
remote.torque.yvesb.matver.matdef = remote.torque.yvesb.matver.mat710;%default matlab on remote machine
remote.torque.yvesb.remoteuser = 'YB109156';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
