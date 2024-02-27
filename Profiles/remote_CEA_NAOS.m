function remote_profile = remote_CEA_NAOS(varargin)
%
% This function regroups the remote profiles run on the NAOS cluster
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
default.filename = mfilename;%remote_xxx_yyy.m file name
%
% YVES PEYSSON
%
remote.pbs.YP105119 = default_remote_profile;
remote.pbs.YP105119.host = 'naos.intra.cea.fr';
remote.pbs.YP105119.hostname = 'naos';
remote.pbs.YP105119.shell = 'bash';
remote.pbs.YP105119.nproc = 12;
remote.pbs.YP105119.walltime = 24;% in hours
remote.pbs.YP105119.cmd = 'qsub';
remote.pbs.YP105119.remotedatapath = '/Home/YP105119/tmp';
remote.pbs.YP105119.get_jobid = {'','.pleione'};%str_before,str_after
remote.pbs.YP105119.set_jobid = {'qstat ','.pleione','finished'};%str_before,str_after,str_check
remote.pbs.YP105119.shclean = 1;
remote.pbs.YP105119.matver.mat802 = '/Home/YP105119/mat802.sh';%create executable bash script named mat802.sh with module purge;module load tools_dc;module load matlab/2013b;matlab "$@"
remote.pbs.YP105119.matver.mat806 = '/Home/YP105119/mat806.sh';%create executable bash script named mat806.sh with module purge;module load tools_dc/m2015b;module load matlab/2015b;matlab "$@"
remote.pbs.YP105119.matver.mat903 = '/Home/YP105119/mat903.sh';%create executable bash script named mat903.sh with module purge;module load matlab/2017b;matlab "$@"
remote.pbs.YP105119.matver.mat907 = '/Home/YP105119/mat907.sh';%create executable bash script named mat907.sh with module purge;module load tools_dc/m2019b;module load matlab/2019b;matlab "$@"
remote.pbs.YP105119.matver.mat909 = '/Home/YP105119/mat909.sh';%create executable bash script named mat909.sh with module purge;module load matlab/2020b;matlab "$@"
remote.pbs.YP105119.matver.mat911 = '/home/YP105119/mat911.sh';%create executable bash script named mat911.sh with module purge;module load matlab/2021b;matlab "$@"
remote.pbs.YP105119.matver.mat913 = '/home/YP105119/mat913.sh';%create executable bash script named mat913.sh with module purge;module load matlab/2022b;matlab "$@"
remote.pbs.YP105119.matver.matdef = remote.pbs.YP105119.matver.mat903;%default matlab on remote machine
remote.pbs.YP105119.remoteuser = 'YP105119';
%
% direct
%
remote.direct.YP105119 = default_remote_profile;
remote.direct.YP105119.host = 'naos.intra.cea.fr';
remote.direct.YP105119.hostname = 'naos';
remote.direct.YP105119.shell = 'bash';
remote.direct.YP105119.nproc = 12;
remote.direct.YP105119.walltime = '';% in hours
% remote.direct.YP105119.cmd = {'csh','nohup ',' `</dev/null` >nohup.out &',''};% direct calculation (csh, bash)
remote.direct.YP105119.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.YP105119.get_jobid = {};%str_before,str_after
remote.direct.YP105119.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.YP105119.remotedatapath = '/Home/YP105119/tmp';
remote.direct.YP105119.matver.mat802 = '/Home/YP105119/mat802.sh';%create executable bash script named mat802.sh with module purge;module load tools_dc;module load matlab/2013b;matlab "$@"
remote.direct.YP105119.matver.mat806 = '/Home/YP105119/mat806.sh';%create executable bash script named mat806.sh with module purge;module load tools_dc/m2015b;module load matlab/2015b;matlab "$@"
remote.direct.YP105119.matver.mat903 = '/Home/YP105119/mat903.sh';%create executable bash script named mat903.sh with module purge;module load matlab/2017b;matlab "$@"
remote.direct.YP105119.matver.mat907 = '/Home/YP105119/mat907.sh';%create executable bash script named mat907.sh with module purge;module load tools_dc/m2019b;module load matlab/2019b;matlab "$@"
remote.direct.YP105119.matver.mat909 = '/Home/YP105119/mat909.sh';%create executable bash script named mat909.sh with module purge;module load matlab/2020b;matlab "$@"
remote.direct.YP105119.matver.mat911 = '/home/YP105119/mat911.sh';%create executable bash script named mat909.sh with module purge;module load matlab/2021b;matlab "$@"
remote.direct.YP105119.matver.mat913 = '/home/YP105119/mat913.sh';%create executable bash script named mat909.sh with module purge;module load matlab/2022b;matlab "$@"
remote.direct.YP105119.matver.matdef = remote.direct.YP105119.matver.mat903;%default matlab on remote machine
remote.direct.YP105119.remoteuser = 'YP105119';
%
% ------------------------------ OTHER USERS  -----------------------------
%
remote = add_cea_users(remote,'INTRA');
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
