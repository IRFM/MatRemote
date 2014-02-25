function remote_profile = remote_CEA_ANDROMEDE(varargin)
%
% This function regroups the remote profiles run on the ANDROMEDE cluster
% in the CEA PARTENAIRES network
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
% pbs pro
%
remote.pbs.joan = default_remote_profile;
remote.pbs.joan.host = 'andromede1.partenaires.cea.fr';
remote.pbs.joan.hostname = 'andromede1';
remote.pbs.joan.nproc = 12;
remote.pbs.joan.cmd = 'qsub';
remote.pbs.joan.get_jobid = {'','.andromede1'};%str_before,str_after
remote.pbs.joan.set_jobid = {'qstat ','.andromede1','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.joan.shclean = 1;
remote.pbs.joan.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.pbs.joan.matver.mat710.prefdir = '/home/JD211098/.matlab/R2010a';
remote.pbs.joan.matver.mat800.root = '/Applications/Matlab_2012B/bin/';
remote.pbs.joan.matver.mat800.prefdir = '/home/JD211098/.matlab/R2012b';
remote.pbs.joan.matver.matdef = remote.pbs.joan.matver.mat800;%default matlab on remote machine
remote.pbs.joan.remoteuser = 'JD211098';
remote.pbs.joan.bridge.url.host = 'tolbachik.hd.free.fr';
remote.pbs.joan.bridge.url.path = '~yvespeysson/MatRemote';
remote.pbs.joan.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.pbs.joan.bridge.ftp.username = 'matremote';
remote.pbs.joan.bridge.ftp.password = 'Rq59G4zzPSzZNC9LFMdTK';
%
% direct
%
remote.direct.joan = default_remote_profile;
remote.direct.joan.host = 'andromede1.partenaires.cea.fr';
remote.direct.joan.hostname = 'andromede1';
remote.direct.joan.nproc = 12;
remote.direct.joan.cmd = {'csh',' &;'};% direct calculation (csh, bash)
remote.direct.joan.get_jobid = {'[1] ',{' ',''}};%str_before,str_after
remote.direct.joan.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.joan.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.direct.joan.matver.mat710.prefdir = '/home/JD211098/.matlab/R2010a';
remote.direct.joan.matver.mat800.root = '/Applications/Matlab_2012B/bin/';
remote.direct.joan.matver.mat800.prefdir = '/home/JD211098/.matlab/R2012b';
remote.direct.joan.matver.matdef = remote.direct.joan.matver.mat800;%default matlab on remote machine
remote.direct.joan.remoteuser = 'JD211098';
%
% YVES PEYSSON
%
remote.pbs.yves = default_remote_profile;
remote.pbs.yves.host = 'andromede1.partenaires.cea.fr';
remote.pbs.yves.hostname = 'andromede1';
remote.pbs.yves.nproc = 12;
remote.pbs.yves.cmd = 'qsub';
remote.pbs.yves.remotedatapath = '/home/YP105119/tmp/';
remote.pbs.yves.get_jobid = {'','.andromede1'};%str_before,str_after
remote.pbs.yves.set_jobid = {'qstat ','.andromede1','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.yves.shclean = 1;
remote.pbs.yves.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.pbs.yves.matver.mat710.prefdir = '/home/YP105119/.matlab/R2010a';
remote.pbs.yves.matver.mat800.root = '/Applications/Matlab_2012B/bin/';
remote.pbs.yves.matver.mat800.prefdir = '/home/YP105119/.matlab/R2012b';
remote.pbs.yves.matver.matdef = remote.pbs.yves.matver.mat800;%default matlab on remote machine
remote.pbs.yves.remoteuser = 'YP105119';
remote.pbs.yves.bridge.url.host = 'tolbachik.hd.free.fr';
remote.pbs.yves.bridge.url.path = '~yvespeysson/MatRemote';
remote.pbs.yves.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.pbs.yves.bridge.ftp.username = 'matremote';
remote.pbs.yves.bridge.ftp.password = 'Rq59G4zzPSzZNC9LFMdTK';
remote.pbs.yves.bridge_enforce = false;
%
% direct
%
remote.direct.yves = default_remote_profile;
remote.direct.yves.host = 'andromede1.partenaires.cea.fr';
remote.direct.yves.hostname = 'andromede1';
remote.direct.yves.nproc = 12;
remote.direct.yves.cmd = 'csh';% direct calculation (csh, bash)
remote.direct.yves.get_jobid = {'[1] ',{' ',''}};%str_before,str_after
remote.direct.yves.set_jobid = {'ps -p ',' -o comm=',''};%str_before,str_after,str_check
remote.direct.yves.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.direct.yves.matver.mat710.prefdir = '/home/YP105119/.matlab/R2010a';
remote.direct.yves.matver.mat800.root = '/Applications/Matlab_2012B/bin/';
remote.direct.yves.matver.mat800.prefdir = '/home/YP105119/.matlab/R2012b';
remote.direct.yves.matver.matdef = remote.direct.yves.matver.mat800;%default matlab on remote machine
remote.direct.yves.remoteuser = 'YP105119';
remote.direct.yves.bridge.url.host = 'tolbachik.hd.free.fr';
remote.direct.yves.bridge.url.path = '~yvespeysson/MatRemote';
remote.direct.yves.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.direct.yves.bridge.ftp.username = 'matremote';
remote.direct.yves.bridge.ftp.password = 'Rq59G4zzPSzZNC9LFMdTK';
remote.direct.yves.bridge_enforce = false;
%
% YVES BURAVAND
%
remote.pbs.yvesb = default_remote_profile;
remote.pbs.yvesb.host = 'andromede1.partenaires.cea.fr';
remote.pbs.yvesb.hostname = 'andromede1';
remote.pbs.yvesb.nproc = 12;
remote.pbs.yvesb.cmd = 'qsub';
remote.pbs.yvesb.get_jobid = {'','.andromede1'};%str_before,str_after
remote.pbs.yvesb.set_jobid = {'qstat ','.andromede1','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.yvesb.shclean = 1;
remote.pbs.yvesb.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.pbs.yvesb.matver.mat710.prefdir = '/home/YB109156/.matlab/R2010a';
remote.pbs.yvesb.matver.mat712.root = '/Applications/Matlab_2011A/bin/';
remote.pbs.yvesb.matver.mat712.prefdir = '/home/YB109156/.matlab/R2011a';
remote.pbs.yvesb.matver.matdef = remote.pbs.yvesb.matver.mat710;%default matlab on remote machine
remote.pbs.yvesb.remoteuser = 'YB109156';
%
% EMELIE NILSSON
%
% andromede (pbs pro)
%
remote.pbs.emelie = default_remote_profile;
remote.pbs.emelie.host = 'andromede1.partenaires.cea.fr';% empty for local host
remote.pbs.emelie.hostname = 'andromede1';
remote.pbs.emelie.nproc = 12;
remote.pbs.emelie.cmd = 'qsub';
remote.pbs.emelie.get_jobid = {'','.andromede1'};%str_before,str_after
remote.pbs.emelie.set_jobid = {'qstat ','.andromede1','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.emelie.shclean = 1;
remote.pbs.emelie.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.pbs.emelie.matver.mat710.prefdir = '/home/EN290612/.matlab/R2010a';
remote.pbs.emelie.matver.mat800.root = '/Applications/Matlab_2012B/bin/';
remote.pbs.emelie.matver.mat800.prefdir = '/home/EN290612/.matlab/R2012b';
remote.pbs.emelie.matver.matdef = remote.pbs.emelie.matver.mat800;%default matlab on remote machine
remote.pbs.emelie.remoteuser = 'EN290612';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
