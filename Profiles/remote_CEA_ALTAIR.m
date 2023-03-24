function remote_profile = remote_CEA_ALTAIR(varargin)
%
% This function regroups the remote profiles run on the ALTAIR cluster
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
remote.pbs.YP105119.host = 'altair.partenaires.cea.fr';
remote.pbs.YP105119.hostname = 'altair';
remote.pbs.YP105119.shell = 'bash';%
remote.pbs.YP105119.nproc = 40;
remote.pbs.YP105119.walltime = 24;% in hours
remote.pbs.YP105119.cmd = 'qsub';
remote.pbs.YP105119.remotedatapath = '/home/YP105119/tmp';
%remote.pbs.YP105119.get_jobid = {'','.altair'};%str_before,str_after
%remote.pbs.YP105119.set_jobid = {'qstat ','.altair','finished'};%str_before,str_after,str_check
remote.pbs.YP105119.get_jobid = {'','.altair'};%str_before,str_after
remote.pbs.YP105119.set_jobid = {'qstat ','.altair','finished'};%str_before,str_after,str_check
remote.pbs.YP105119.shclean = 1;
remote.pbs.YP105119.matver.mat802 = '/home/YP105119/mat802.sh';%create executable bash script named mat802.sh with module purge;module load tools_dc;module load matlab/2013b;matlab "$@"
remote.pbs.YP105119.matver.mat806 = '/home/YP105119/mat806.sh';%create executable bash script named mat806.sh with module purge;module load tools_dc/m2015b;module load matlab/2015b;matlab "$@"
remote.pbs.YP105119.matver.mat903 = '/home/YP105119/mat903.sh';%create executable bash script named mat903.sh with module purge;module load matlab/2017b;matlab "$@"
remote.pbs.YP105119.matver.mat907 = '/home/YP105119/mat907.sh';%create executable bash script named mat907.sh with module purge;module load tools_dc/m2019b;module load matlab/2019b;matlab "$@"
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
%
% direct
%
% note : mode direct bridge disabled because nohup does not work
%
remote.direct.YP105119 = default_remote_profile;
remote.direct.YP105119.host = 'altair.partenaires.cea.fr';
remote.direct.YP105119.hostname = 'altair';
remote.direct.YP105119.shell = 'bash';
remote.direct.YP105119.nproc = 40;
% remote.direct.YP105119.cmd = {'csh','nohup ',' `</dev/null` >nohup.out &',''};% direct calculation (csh, bash)
remote.direct.YP105119.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.YP105119.get_jobid = {};%str_before,str_after
remote.direct.YP105119.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.YP105119.remotedatapath = '/home/YP105119/tmp';
remote.direct.YP105119.matver.mat802 = '/home/YP105119/mat802.sh';%create executable bash script named mat802.sh with module purge;module load tools_dc;module load matlab/2013b;matlab "$@"
remote.direct.YP105119.matver.mat806 = '/home/YP105119/mat806.sh';%create executable bash script named mat806.sh with module purge;module load tools_dc/m2015b;module load matlab/2015b;matlab "$@"
remote.direct.YP105119.matver.mat903 = '/home/YP105119/mat903.sh';%create executable bash script named mat903.sh with module purge;module load matlab/2017b;matlab "$@"
remote.direct.YP105119.matver.mat907 = '/home/YP105119/mat907.sh';%create executable bash script named mat907.sh with module purge;module load tools_dc/m2019b;module load matlab/2019b;matlab "$@"
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
remote = add_cea_users(remote,'PARTENAIRES');
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
