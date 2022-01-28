

function remote_profile = remote_CEA_CEPHEE(varargin)
%
% This function regroups the remote profiles run on the CEPHEE cluster
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
remote.pbs.YP105119.host = {'cephee','cephee.partenaires.cea.fr'};
remote.pbs.YP105119.hostname = 'cephee';
remote.pbs.YP105119.shell = 'bash';%
remote.pbs.YP105119.nproc = 12;
remote.pbs.YP105119.cmd = 'qsub';
remote.pbs.YP105119.remotedatapath = '/home/YP105119/tmp';
%remote.pbs.YP105119.get_jobid = {'','.altair'};%str_before,str_after
%remote.pbs.YP105119.set_jobid = {'qstat ','.altair','finished'};%str_before,str_after,str_check
remote.pbs.YP105119.get_jobid = {'','.altair'};%str_before,str_after
remote.pbs.YP105119.set_jobid = {'qstat ','.altair','finished'};%str_before,str_after,str_check
remote.pbs.YP105119.shclean = 1;
remote.pbs.YP105119.matver.mat802 = '/home/YP105119/mat802.sh';%create executable bash script named mat802.sh with module purge;module load matlab/2013b;matlab "$@"
remote.pbs.YP105119.matver.mat806 = '/home/YP105119/mat806.sh';%create executable bash script named mat806.sh with module purge;module load matlab/2015b;matlab "$@"
remote.pbs.YP105119.matver.mat903 = '/home/YP105119/mat903.sh';%create executable bash script named mat903.sh with module purge;module load matlab/2017b;matlab "$@"
remote.pbs.YP105119.matver.mat907 = '/home/YP105119/mat907.sh';%create executable bash script named mat907.sh with module purge;module load matlab/2019b;matlab "$@"
remote.pbs.YP105119.matver.mat909 = '/home/YP105119/mat909.sh';%create executable bash script named mat909.sh with module purge;module load matlab/2020b;matlab "$@"
remote.pbs.YP105119.matver.matdef = remote.pbs.YP105119.matver.mat903;%default matlab on remote machine
remote.pbs.YP105119.remoteuser = 'YP105119';
%remote.pbs.YP105119.bridge.url.host = 'https://tolbachik.hd.free.fr';%Shuttle aix
%remote.pbs.YP105119.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%Shuttle aix
remote.pbs.YP105119.bridge.ssh.host = 'spcsrv18.epfl.ch';%spcsrv18 EPFL, Switzerland
remote.pbs.YP105119.bridge.ssh.remotepassword = getenv('CEA_PARTENAIRES_PASSWD');%set password for the remote machine in startup.m or in session startup script
%remote.pbs.YP105119.bridge.ssh.host = 'hpc-login.iter.org';%ITER
%remote.pbs.YP105119.bridge.ssh.host = 'login.eufus.eu';%EUROfusion (sshpass necessary)
%remote.pbs.YP105119.bridge.ssh.password = getenv('EUROFUSION_ITM_PASSWD');%set password for the remote machine in startup.m or in session startup script
%remote.pbs.YP105119.bridge.ssh.remotepassword = getenv('CEA_PARTENAIRES_PASSWD');%set password for the remote machine in startup.m or in session startup script
%
% direct
%
% note : mode direct bridge disabled because nohup does not work
%
remote.direct.YP105119 = default_remote_profile;
remote.direct.YP105119.host = {'cephee','cephee.partenaires.cea.fr'};
remote.direct.YP105119.hostname = 'cephee';
remote.direct.YP105119.shell = 'bash';
remote.direct.YP105119.nproc = 12;
% remote.direct.YP105119.cmd = {'csh','nohup ',' `</dev/null` >nohup.out &',''};% direct calculation (csh, bash)
remote.direct.YP105119.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.YP105119.get_jobid = {};%str_before,str_after
remote.direct.YP105119.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.YP105119.remotedatapath = '/home/YP105119/tmp';
remote.direct.YP105119.matver.mat802 = '/home/YP105119/mat802.sh';%create executable bash script named mat802.sh with module purge;module load matlab/2013b;matlab "$@"
remote.direct.YP105119.matver.mat806 = '/home/YP105119/mat806.sh';%create executable bash script named mat806.sh with module purge;module load matlab/2015b;matlab "$@"
remote.direct.YP105119.matver.mat903 = '/home/YP105119/mat903.sh';%create executable bash script named mat903.sh with module purge;module load matlab/2017b;matlab "$@"
remote.direct.YP105119.matver.mat907 = '/home/YP105119/mat907.sh';%create executable bash script named mat907.sh with module purge;module load matlab/2019b;matlab "$@"
remote.direct.YP105119.matver.mat909 = '/home/YP105119/mat909.sh';%create executable bash script named mat909.sh with module purge;module load matlab/2020b;matlab "$@"
remote.direct.YP105119.matver.matdef = remote.direct.YP105119.matver.mat903;%default matlab on remote machine
remote.direct.YP105119.remoteuser = 'YP105119';
%remote.direct.YP105119.bridge.url.host = 'https://tolbachik.hd.free.fr';%Shuttle aix
%remote.direct.YP105119.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%Shuttle aix
remote.direct.YP105119.bridge.ssh.host = 'spcsrv18.epfl.ch';%spcsrv18 EPFL, Switzerland
remote.direct.YP105119.bridge.ssh.remotepassword = getenv('CEA_PARTENAIRES_PASSWD');%set password for the remote machine in startup.m or in session startup script
%remote.direct.YP105119.bridge.ssh.host = 'hpc-login.iter.org';%ITER
%remote.direct.YP105119.bridge.ssh.host = 'login.eufus.eu';%EUROfusion (sshpass necessary)
%remote.direct.YP105119.bridge.ssh.password = getenv('EUROFUSION_ITM_PASSWD');%set password for the remote machine in startup.m or in session startup script
%
% ------------------------------ OTHER USERS  -----------------------------
%
% Jean-François Artaud
% 
% pbs pro
%
remote.pbs.JA132999 = remote.pbs.YP105119;
remote.pbs.JA132999.remoteuser = 'JA132999';
remote.pbs.JA132999.remotedatapath = '/home/JA132999/tmp/';
remote.pbs.JA132999.bridge.ssh.host = '';
remote.pbs.JA132999.bridge.ssh.remotepassword = '';%set password for the remote machine in startup.m or in session startup script
%
remote.direct.JA132999 = remote.direct.YP105119;
remote.direct.JA132999.remoteuser = 'JA132999';
remote.direct.JA132999.remotedatapath = '/home/JA132999/tmp/';
remote.direct.JA132999.bridge.ssh.host = '';
remote.direct.JA132999.bridge.ssh.remotepassword = '';%set password for the remote machine in startup.m or in session startup script
%
% Clarisse Bourdelle
%
% pbs pro
%
remote.pbs.DM088721 = remote.pbs.YP105119;
remote.pbs.DM088721.remoteuser = 'DM088721';
remote.pbs.DM088721.remotedatapath = '/home/DM088721/tmp/';
remote.pbs.DM088721.bridge.ssh.host = '';
remote.pbs.DM088721.bridge.ssh.remotepassword = '';%set password for the remote machine in startup.m or in session startup script
%
remote.direct.DM088721 = remote.direct.YP105119;
remote.direct.DM088721.remoteuser = 'DM088721';
remote.direct.DM088721.remotedatapath = '/home/DM088721/tmp/';
remote.direct.DM088721.bridge.ssh.host = '';
remote.direct.DM088721.bridge.ssh.remotepassword = '';%set password for the remote machine in startup.m or in session startup script
%
% Marc Goniche
%
% pbs pro
%
remote.pbs.MG100063 = remote.pbs.YP105119;
remote.pbs.MG100063.remoteuser = 'MG100063';
remote.pbs.MG100063.remotedatapath = '/home/MG100063/tmp/';
remote.pbs.MG100063.bridge.ssh.host = '';
remote.pbs.MG100063.bridge.ssh.remotepassword = '';%set password for the remote machine in startup.m or in session startup script
%
remote.direct.MG100063 = remote.direct.YP105119;
remote.direct.MG100063.remoteuser = 'MG100063';
remote.direct.MG100063.remotedatapath = '/home/MG100063/tmp/';
remote.direct.MG100063.bridge.ssh.host = '';
remote.direct.MG100063.bridge.ssh.remotepassword = '';%set password for the remote machine in startup.m or in session startup script
%
% Valeria Ostuni
%
% pbs pro
%
remote.pbs.VO259454 = remote.pbs.YP105119;
remote.pbs.VO259454.remoteuser = 'VO259454';
remote.pbs.VO259454.remotedatapath = '/home/VO259454/tmp/';
remote.pbs.VO259454.bridge.ssh.host = '';
remote.pbs.VO259454.bridge.ssh.remotepassword = '';%set password for the remote machine in startup.m or in session startup script
%
remote.direct.VO259454 = remote.direct.YP105119;
remote.direct.VO259454.remoteuser = 'VO259454';
remote.direct.VO259454.remotedatapath = '/home/VO259454/tmp/';
remote.direct.VO259454.bridge.ssh.host = '';
remote.direct.VO259454.bridge.ssh.remotepassword = '';%set password for the remote machine in startup.m or in session startup script
%
% Jorge Morales
%
% pbs pro
%
remote.pbs.JM240179 = remote.pbs.YP105119;
remote.pbs.JM240179.remoteuser = 'JM240179';
remote.pbs.JM240179.remotedatapath = '/home/JM240179/tmp/';
remote.pbs.JM240179.bridge.ssh.host = '';
remote.pbs.JM240179.bridge.ssh.remotepassword = '';%set password for the remote machine in startup.m or in session startup script
%
remote.direct.JM240179 = remote.direct.YP105119;
remote.direct.JM240179.remoteuser = 'JM240179';
remote.direct.JM240179.remotedatapath = '/home/JM240179/tmp/';
remote.direct.JM240179.bridge.ssh.host = '';
remote.direct.JM240179.bridge.ssh.remotepassword = '';%set password for the remote machine in startup.m or in session startup script
%
% Tullio Barbui
%
% pbs pro
%
remote.pbs.TB263881 = remote.pbs.YP105119;
remote.pbs.TB263881.remoteuser = 'TB263881';
remote.pbs.TB263881.remotedatapath = '/home/TB263881/tmp/';
remote.pbs.TB263881.bridge.ssh.host = '';
remote.pbs.TB263881.bridge.ssh.remotepassword = '';
%
remote.direct.TB263881 = remote.direct.YP105119;
remote.direct.TB263881.remoteuser = 'TB263881';
remote.direct.TB263881.remotedatapath = '/home/TB263881/tmp/';
remote.direct.TB263881.bridge.ssh.host = '';
remote.direct.TB263881.bridge.ssh.remotepassword = '';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%

