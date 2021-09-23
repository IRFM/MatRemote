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
default.filename = mfilename;%remote_xxx_yyy.m file name
%
% YVES PEYSSON
%
remote.pbs.YP105119 = default_remote_profile;
remote.pbs.YP105119.host = 'andromede1.partenaires.cea.fr';
remote.pbs.YP105119.hostname = 'andromede';
remote.pbs.YP105119.shell = 'bash';%
remote.pbs.YP105119.nproc = 12;
remote.pbs.YP105119.cmd = 'qsub';
remote.pbs.YP105119.remotedatapath = '/home/YP105119/tmp';
remote.pbs.YP105119.get_jobid = {'','.andromede1'};%str_before,str_after
remote.pbs.YP105119.set_jobid = {'qstat ','.andromede1','finished'};%str_before,str_after,str_check
remote.pbs.YP105119.shclean = 1;
remote.pbs.YP105119.matver.mat710 = '/Applications/Matlab_2010A/bin/matlab';
remote.pbs.YP105119.matver.mat800 = '/Applications/Matlab_2012B/bin/matlab';
remote.pbs.YP105119.matver.mat801 = '/Applications/Matlab_2013A/bin/matlab';
remote.pbs.YP105119.matver.mat802 = '/Applications/Matlab_2013B/bin/matlab';
remote.pbs.YP105119.matver.mat805 = '/Applications/Matlab_2015A/bin/matlab';
remote.pbs.YP105119.matver.mat806 = '/Applications/Matlab_2015B/bin/matlab';
remote.pbs.YP105119.matver.mat903 = '/Applications/Matlab_2017B/bin/matlab';
remote.pbs.YP105119.matver.matdef = remote.pbs.YP105119.matver.mat903;%default matlab on remote machine
remote.pbs.YP105119.remoteuser = 'YP105119';
%remote.pbs.YP105119.bridge.url.host = 'https://tolbachik.hd.free.fr';%Shuttle aix
%remote.pbs.YP105119.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%Shuttle aix
remote.pbs.YP105119.bridge.ssh.host = 'spcsrv18.epfl.ch';%spcsrv18 EPFL, Switzerland
%remote.pbs.YP105119.bridge.ssh.host = 'hpc-login.iter.org';%ITER
%remote.pbs.YP105119.bridge.ssh.host = 'login.eufus.eu';%EUROfusion (sshpass necessary)
%remote.pbs.YP105119.bridge.ssh.password = getenv('EUROFUSION_ITM_PASSWD');%set password for the remote machine in startup.m or in session startup script
remote.pbs.YP105119.bridge.ssh.remotepassword = getenv('CEA_PARTENAIRES_PASSWD');%set password for the remote machine in startup.m or in session startup script
%
% direct
%
% note : mode direct bridge disabled because nohup does not work
%
remote.direct.YP105119 = default_remote_profile;
remote.direct.YP105119.host = 'andromede1.partenaires.cea.fr';
remote.direct.YP105119.hostname = 'andromede';
remote.direct.YP105119.shell = 'bash';
remote.direct.YP105119.nproc = 12;
% remote.direct.YP105119.cmd = {'csh','nohup ',' `</dev/null` >nohup.out &',''};% direct calculation (csh, bash)
remote.direct.YP105119.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.YP105119.get_jobid = {};%str_before,str_after
remote.direct.YP105119.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.YP105119.remotedatapath = '/home/YP105119/tmp';
remote.direct.YP105119.matver.mat710 = '/Applications/Matlab_2010A/bin/matlab';
remote.direct.YP105119.matver.mat800 = '/Applications/Matlab_2012B/bin/matlab';
remote.direct.YP105119.matver.mat801 = '/Applications/Matlab_2013A/bin/matlab';
remote.direct.YP105119.matver.mat802 = '/Applications/Matlab_2013B/bin/matlab';
remote.direct.YP105119.matver.mat805 = '/Applications/Matlab_2015A/bin/matlab';
remote.direct.YP105133.matver.mat806 = '/Applications/Matlab_2015B/bin/matlab';
remote.direct.YP105119.matver.mat903 = '/Applications/Matlab_2017B/bin/matlab';
remote.direct.YP105119.matver.matdef = remote.direct.YP105119.matver.mat903;%default matlab on remote machine
remote.direct.YP105119.remoteuser = 'YP105119';
%remote.direct.YP105119.bridge.url.host = 'https://tolbachik.hd.free.fr';%Shuttle aix
%remote.direct.YP105119.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%Shuttle aix
%remote.direct.YP105119.bridge.ssh.host = 'tolbachik.hd.free.fr:2223';%Shuttle aix
remote.direct.YP105119.bridge.ssh.host = 'spcsrv18.epfl.ch';%spcsrv18 EPFL, Switzerland
%remote.direct.YP105119.bridge.ssh.host = 'hpc-login.iter.org';%ITER
%remote.direct.YP105119.bridge.ssh.host = 'login.eufus.eu';%EUROfusion (sshpass necessary)
%remote.direct.YP105119.bridge.ssh.password = getenv('EUROFUSION_ITM_PASSWD');%set password for the remote machine in startup.m or in session startup script
remote.direct.YP105119.bridge.ssh.remotepassword = getenv('CEA_PARTENAIRES_PASSWD');%set password for the remote machine in startup.m or in session startup script
%
% Jean-François Artaud
% 
% pbs pro
%
remote.pbs.JA132999 = remote.pbs.YP105119;
remote.pbs.JA132999.remoteuser = 'JA132999';
remote.pbs.JA132999.shell = 'csh';
remote.pbs.JA132999.remotedatapath = '/home/JA132999/tmp/';
%
remote.direct.JA132999.cmd = {'csh','',' &',' &'};% direct calculation (csh, bash)
%
% Annika Ekedahl
%
% pbs pro
%
remote.pbs.AE165440 = remote.pbs.YP105119;
remote.pbs.AE165440.remoteuser = 'AE165440';
remote.pbs.AE165440.shell = 'csh';
remote.pbs.AE165440.remotedatapath = '/home/AE165440/tmp/';
%
remote.direct.AE165440.cmd = {'csh','',' &',' &'};% direct calculation (csh, bash)
%
% Clarisse Bourdelle
%
% pbs pro
%
remote.pbs.DM088721 = remote.pbs.YP105119;
remote.pbs.DM088721.remoteuser = 'DM088721';
remote.pbs.DM088721.shell = 'csh';
remote.pbs.DM088721.remotedatapath = '/home/DM088721/tmp/';
%
remote.direct.DM088721.cmd = {'csh','',' &',' &'};% direct calculation (csh, bash)
%
% Lena Delpech
%
% pbs pro
%
remote.pbs.LD142631 = remote.pbs.YP105119;
remote.pbs.LD142631.remoteuser = 'LD142631';
remote.pbs.LD142631.shell = 'csh';
remote.pbs.LD142631.remotedatapath = '/home/LD142631/tmp/';
%
remote.direct.LD142631.cmd = {'csh','',' &',' &'};% direct calculation (csh, bash)
%
% Marc Goniche
%
% pbs pro
%
remote.pbs.MG100063 = remote.pbs.YP105119;
remote.pbs.MG100063.remoteuser = 'MG100063';
remote.pbs.MG100063.shell = 'csh';
remote.pbs.MG100063.remotedatapath = '/home/MG100063/tmp/';
%
remote.direct.MG100063.cmd = {'csh','',' &',' &'};% direct calculation (csh, bash)
%
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
