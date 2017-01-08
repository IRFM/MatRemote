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
default.profile = 'YP105119';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
% %
% % JOAN DECKER
% %
% % pbs pro
% %
% remote.pbs.decker = default_remote_profile;
% remote.pbs.decker.host = 'andromede1.partenaires.cea.fr';
% remote.pbs.decker.hostname = 'andromede';
% remote.pbs.decker.shell = 'csh';
% remote.pbs.decker.nproc = 12;
% remote.pbs.decker.cmd = 'qsub';
% remote.pbs.decker.remotedatapath = '/home/JD211098/tmp/';
% remote.pbs.decker.get_jobid = {'','.andromede1'};%str_before,str_after
% remote.pbs.decker.set_jobid = {'qstat ','.andromede1','finished'};%str_before,str_after,str_check
% remote.pbs.decker.shclean = 1;
% remote.pbs.decker.matver.mat710 = '/Applications/Matlab_2010A/bin/matlab';
% remote.pbs.decker.matver.mat800 = '/Applications/Matlab_2012B/bin/matlab';
% remote.pbs.decker.matver.mat805 = '/Applications/Matlab_2015A/bin/matlab';
% remote.pbs.decker.matver.mat806 = '/Applications/Matlab_2015B/bin/matlab';
% remote.pbs.decker.matver.matdef = remote.pbs.decker.matver.mat806;%default matlab on remote machine
% remote.pbs.decker.remoteuser = 'JD211098';
% remote.pbs.decker.bridge.url.host = 'tolbachik.hd.free.fr:8081';%nuc aix
% remote.pbs.decker.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%nuc aix
% remote.pbs.decker.bridge.ssh.host = 'tolbachik.hd.free.fr -p 2222';%nuc aix
% %
% % direct
% %
% % note : mode direct bridge disabled because nohup does not work
% %
% remote.direct.decker = default_remote_profile;
% remote.direct.decker.host = 'andromede1.partenaires.cea.fr';
% remote.direct.decker.hostname = 'andromede';
% remote.direct.decker.shell = 'csh';
% remote.direct.decker.nproc = 12;
% %
% % remote.direct.decker.cmd = {'csh','',' &;'};% direct calculation (csh, bash)
% % remote.direct.decker.get_jobid = {'[1] ',{' ',''}};%str_before,str_after
% % remote.direct.decker.set_jobid = {'ps -p ',' -o comm=','csh'};%str_before,str_after,str_check
% %
% % remote.direct.decker.cmd = {'csh','nohup ',' `</dev/null` >nohup.out &',''};% direct calculation (csh, bash)
% remote.direct.decker.cmd = {'csh','',' &',' &'};% direct calculation (csh, bash)
% remote.direct.decker.remotedatapath = '/home/JD211098/tmp/';
% remote.direct.decker.get_jobid = {};%str_before,str_after
% remote.direct.decker.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
% remote.direct.decker.matver.mat710 = '/Applications/Matlab_2010A/bin/matlab';
% remote.direct.decker.matver.mat800 = '/Applications/Matlab_2012B/bin/matlab';
% remote.direct.decker.matver.mat805 = '/Applications/Matlab_2015A/bin/matlab';
% remote.direct.decker.matver.mat806 = '/Applications/Matlab_2015B/bin/matlab';
% remote.direct.decker.matver.matdef = remote.direct.decker.matver.mat806;%default matlab on remote machine
% remote.direct.decker.remoteuser = 'JD211098';
% remote.direct.decker.bridge.url.host = 'tolbachik.hd.free.fr:8081';%nuc aix
% remote.direct.decker.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%nuc aix
% remote.direct.decker.bridge.ssh.host = 'tolbachik.hd.free.fr -p 2222';%nuc aix
%
% YVES PEYSSON
%
remote.pbs.YP105119 = default_remote_profile;
remote.pbs.YP105119.host = 'andromede1.partenaires.cea.fr';
remote.pbs.YP105119.hostname = 'andromede';
remote.pbs.YP105119.shell = 'csh';
remote.pbs.YP105119.nproc = 12;
remote.pbs.YP105119.cmd = 'qsub';
remote.pbs.YP105119.remotedatapath = '/home/YP105119/tmp/';
remote.pbs.YP105119.get_jobid = {'','.andromede1'};%str_before,str_after
remote.pbs.YP105119.set_jobid = {'qstat ','.andromede1','finished'};%str_before,str_after,str_check
remote.pbs.YP105119.shclean = 1;
remote.pbs.YP105119.matver.mat710 = '/Applications/Matlab_2010A/bin/matlab';
remote.pbs.YP105119.matver.mat800 = '/Applications/Matlab_2012B/bin/matlab';
remote.pbs.YP105119.matver.mat805 = '/Applications/Matlab_2015A/bin/matlab';
remote.pbs.YP105119.matver.mat806 = '/Applications/Matlab_2015B/bin/matlab';
remote.pbs.YP105119.matver.matdef = remote.pbs.YP105119.matver.mat806;%default matlab on remote machine
remote.pbs.YP105119.remoteuser = 'YP105119';
%remote.pbs.YP105119.bridge.url.host = 'tolbachik.hd.free.fr:8081';%nuc aix
%remote.pbs.YP105119.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%nuc aix
remote.pbs.YP105119.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%nuc aix
%
% direct
%
% note : mode direct bridge disabled because nohup does not work
%
remote.direct.YP105119 = default_remote_profile;
remote.direct.YP105119.host = 'andromede1.partenaires.cea.fr';
remote.direct.YP105119.hostname = 'andromede';
remote.direct.YP105119.shell = 'csh';
remote.direct.YP105119.nproc = 12;
% remote.direct.YP105119.cmd = {'csh','nohup ',' `</dev/null` >nohup.out &',''};% direct calculation (csh, bash)
remote.direct.YP105119.cmd = {'csh','',' &',' &'};% direct calculation (csh, bash)
remote.direct.YP105119.get_jobid = {};%str_before,str_after
remote.direct.YP105119.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.YP105119.remotedatapath = '/home/YP105119/';
remote.direct.YP105119.matver.mat710 = '/Applications/Matlab_2010A/bin/matlab';
remote.direct.YP105119.matver.mat800 = '/Applications/Matlab_2012B/bin/matlab';
remote.direct.YP105119.matver.mat805 = '/Applications/Matlab_2015A/bin/matlab';
remote.direct.YP105119.matver.mat806 = '/Applications/Matlab_2015B/bin/matlab';
remote.direct.YP105119.matver.matdef = remote.direct.YP105119.matver.mat806;%default matlab on remote machine
remote.direct.YP105119.remoteuser = 'YP105119';
%remote.direct.YP105119.bridge.url.host = 'tolbachik.hd.free.fr:8081';%nuc aix
%remote.direct.YP105119.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%nuc aix
remote.direct.YP105119.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%nuc aix
%
% YVES BURAVAND
%
% pbs pro
%
remote.pbs.YB109156 = remote.pbs.YP105119;
remote.pbs.YB109156.remoteuser = 'YB109156';
%
% EMELIE NILSSON
%
% pbs pro
%
remote.pbs.EN290612 = remote.pbs.YP105119;
remote.pbs.EN290612.remoteuser = 'EN290612';
remote.pbs.EN290612.remotedatapath = '/home/EN290612/tmp/';
%
% JOSEF KAMLEITNER
%
% pbs pro
%
remote.pbs.kamleitn = remote.pbs.YP105119;
remote.pbs.kamleitn.remoteuser = 'jkamleitner';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
