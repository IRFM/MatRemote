function remote_profile = remote_CEA_GEMMA(varargin)
%
% This function regroups the remote profiles run on the GEMMA cluster in the CEA INTRA network
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
remote.pbs.YP105119.host = 'gemma.intra.cea.fr';
remote.pbs.YP105119.hostname = 'gemma';
remote.pbs.YP105119.shell = 'bash';
remote.pbs.YP105119.nproc = 12;
remote.pbs.YP105119.walltime = 2;% in hours
remote.pbs.YP105119.cmd = 'qsub';
remote.pbs.YP105119.remotedatapath = '/Home/YP105119/tmp';
remote.pbs.YP105119.get_jobid = {'','.pleione'};%str_before,str_after
remote.pbs.YP105119.set_jobid = {'qstat ','.pleione','finished'};%str_before,str_after,str_check
remote.pbs.YP105119.shclean = 1;
remote.pbs.YP105119.matver.mat802 = '/Home/YP105119/mat802.sh';%create executable bash script named mat802.sh with module purge;module load matlab/2013b;matlab "$@"
remote.pbs.YP105119.matver.mat806 = '/Home/YP105119/mat806.sh';%create executable bash script named mat806.sh with module purge;module load matlab/2015b;matlab "$@"
remote.pbs.YP105119.matver.mat903 = '/Home/YP105119/mat903.sh';%create executable bash script named mat903.sh with module purge;module load matlab/2017b;matlab "$@"
remote.pbs.YP105119.matver.mat907 = '/Home/YP105119/mat907.sh';%create executable bash script named mat907.sh with module purge;module load matlab/2019b;matlab "$@"
remote.pbs.YP105119.matver.mat909 = '/Home/YP105119/mat909.sh';%create executable bash script named mat909.sh with module purge;module load matlab/2020b;matlab "$@"
remote.pbs.YP105119.matver.matdef = remote.pbs.YP105119.matver.mat903;%default matlab on remote machine
remote.pbs.YP105119.remoteuser = 'YP105119';
%
% direct
%
remote.direct.YP105119 = default_remote_profile;
remote.direct.YP105119.host = 'gemma.intra.cea.fr';
remote.direct.YP105119.hostname = 'gemma';
remote.direct.YP105119.shell = 'bash';
remote.direct.YP105119.nproc = 12;
remote.direct.YP105119.walltime = '';% in hours
% remote.direct.YP105119.cmd = {'csh','nohup ',' `</dev/null` >nohup.out &',''};% direct calculation (csh, bash)
remote.direct.YP105119.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.YP105119.get_jobid = {};%str_before,str_after
remote.direct.YP105119.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.YP105119.remotedatapath = '/Home/YP105119/tmp';
remote.direct.YP105119.matver.mat802 = '/Home/YP105119/mat802.sh';%create executable bash script named mat802.sh with module purge;module load matlab/2013b;matlab "$@"
remote.direct.YP105119.matver.mat806 = '/Home/YP105119/mat806.sh';%create executable bash script named mat806.sh with module purge;module load matlab/2015b;matlab "$@"
remote.direct.YP105119.matver.mat903 = '/Home/YP105119/mat903.sh';%create executable bash script named mat903.sh with module purge;module load matlab/2017b;matlab "$@"
remote.direct.YP105119.matver.mat907 = '/Home/YP105119/mat907.sh';%create executable bash script named mat907.sh with module purge;module load matlab/2019b;matlab "$@"
remote.direct.YP105119.matver.mat909 = '/Home/YP105119/mat909.sh';%create executable bash script named mat909.sh with module purge;module load matlab/2020b;matlab "$@"
remote.direct.YP105119.matver.matdef = remote.direct.YP105119.matver.mat903;%default matlab on remote machine
remote.direct.YP105119.remoteuser = 'YP105119';
%
% ------------------------------ OTHER USERS  -----------------------------
%
% Jean-François Artaud
% 
% pbs pro
%
remote.pbs.JA132999 = remote.pbs.YP105119;
remote.pbs.JA132999.remoteuser = 'JA132999';
remote.pbs.JA132999.remotedatapath = '/Home/JA132999/tmp/';
%
remote.direct.JA132999 = remote.direct.YP105119;
remote.direct.JA132999.remoteuser = 'JA132999';
remote.direct.JA132999.remotedatapath = '/Home/JA132999/tmp/';
%
% Clarisse Bourdelle
%
% pbs pro
%
remote.pbs.DM088721 = remote.pbs.YP105119;
remote.pbs.DM088721.remoteuser = 'DM088721';
remote.pbs.DM088721.remotedatapath = '/Home/DM088721/tmp/';
%
remote.direct.DM088721 = remote.direct.YP105119;
remote.direct.DM088721.remoteuser = 'DM088721';
remote.direct.DM088721.remotedatapath = '/Home/DM088721/tmp/';
%
% Marc Goniche
%
% pbs pro
%
remote.pbs.MG100063 = remote.pbs.YP105119;
remote.pbs.MG100063.remoteuser = 'MG100063';
remote.pbs.MG100063.remotedatapath = '/Home/MG100063/tmp/';
%
remote.direct.MG100063 = remote.direct.YP105119;
remote.direct.MG100063.remoteuser = 'MG100063';
remote.direct.MG100063.remotedatapath = '/Home/MG100063/tmp/';
%
% Valeria Ostuni
%
% pbs pro
%
remote.pbs.VO259454 = remote.pbs.YP105119;
remote.pbs.VO259454.remoteuser = 'VO259454';
remote.pbs.VO259454.remotedatapath = '/Home/VO259454/tmp/';
%
remote.direct.VO259454 = remote.direct.YP105119;
remote.direct.VO259454.remoteuser = 'VO259454';
remote.direct.VO259454.remotedatapath = '/Home/VO259454/tmp/';
%
% Jorge Morales
%
% pbs pro
%
remote.pbs.JM240179 = remote.pbs.YP105119;
remote.pbs.JM240179.remoteuser = 'JM240179';
remote.pbs.JM240179.remotedatapath = '/Home/JM240179/tmp/';
%
remote.direct.JM240179 = remote.direct.YP105119;
remote.direct.JM240179.remoteuser = 'JM240179';
remote.direct.JM240179.remotedatapath = '/Home/JM240179/tmp/';
%
% Tullio Barbui
%
% pbs pro
%
remote.pbs.TB263881 = remote.pbs.YP105119;
remote.pbs.TB263881.remoteuser = 'TB263881';
remote.pbs.TB263881.remotedatapath = '/Home/TB263881/tmp/';
%
remote.direct.TB263881 = remote.direct.YP105119;
remote.direct.TB263881.remoteuser = 'TB263881';
remote.direct.TB263881.remotedatapath = '/Home/TB263881/tmp/';
%
% Radwan Kheroua
%
% pbs pro
%
remote.pbs.RK270585 = remote.pbs.YP105119;
remote.pbs.RK270585.remoteuser = 'TB263881';
remote.pbs.RK270585.remotedatapath = '/Home/RK270585/tmp/';
%
remote.direct.RK270585 = remote.direct.YP105119;
remote.direct.RK270585.remoteuser = 'RK270585';
remote.direct.RK270585.remotedatapath = '/Home/RK270585/tmp/';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%

