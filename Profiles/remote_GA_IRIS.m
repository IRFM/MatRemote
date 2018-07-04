function remote_profile = remote_GA_IRIS(varargin)
%
% This function regroups the remote profiles run on the General Atomic Iris cluster
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'slurm';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'peyssony';% default user profile if 'remoteuser' is not an existing user profile
%
default.filename = mfilename;%remote_xxx_yyy.m file name
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% slurm
%
remote.slurm.peyssony = default_remote_profile;
remote.slurm.peyssony.host = 'iris.gat.com';
remote.slurm.peyssony.hostname = 'iris';
remote.slurm.peyssony.nproc = 20;
%remote.slurm.peyssony.walltime = '00:10';
remote.slurm.peyssony.cmd = 'sbatch ';% direct calculation (csh, bash) (for debugging, move to the remote folder and launch the slum command replacing sbatch by srun, the interactive mode)
remote.slurm.peyssony.remotedatapath = '/cscratch/peyssony/';
remote.slurm.peyssony.get_jobid = {'Submitted batch job ',''};%str_before,str_after
remote.slurm.peyssony.set_jobid = {'squeue -j ','',''};%str_before,str_after,str_check
remote.slurm.peyssony.matver.mat901 = '/fusion/usc/opt/MATLAB/R2016b/bin/matlab';
remote.slurm.peyssony.matver.mat903 = '/fusion/usc/opt/MATLAB/R2017b/bin/matlab';
remote.slurm.peyssony.matver.matdef = remote.slurm.peyssony.matver.mat903;%default matlab on remote machine
remote.slurm.peyssony.remoteuser = 'peyssony';
remote.slurm.peyssony.bridge.ssh.host = 'cybele.gat.com:2039';%cybele workstation GA/DIII-D
%
% direct
%
remote.direct.peyssony = default_remote_profile;
remote.direct.peyssony.host = 'iris.gat.com';
remote.direct.peyssony.hostname = 'iris';
remote.direct.peyssony.shell = 'bash';
remote.direct.peyssony.nproc = 20;
remote.direct.peyssony.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.peyssony.remotedatapath = '/cscratch/peyssony/';
remote.direct.peyssony.get_jobid = {};%str_before,str_after
remote.direct.peyssony.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.peyssony.matver.mat901 = '/fusion/usc/opt/MATLAB/R2016b/bin/matlab';
remote.direct.peyssony.matver.mat903 = '/fusion/usc/opt/MATLAB/R2017b/bin/matlab';
remote.direct.peyssony.matver.matdef = remote.direct.peyssony.matver.mat903;%default matlab on remote machine
remote.direct.peyssony.remoteuser = 'peyssony';
remote.direct.peyssony.bridge.ssh.host = 'cybele.gat.com:2039';%cybele workstation GA/DIII-D
%
% MICHAEL BROOKMAN (IRIS)
%
remote.slurm.brookmanmw = remote.slurm.peyssony;
remote.slurm.brookmanmw.remoteuser = 'brookmanmw';
remote.slurm.brookmanmw.remotedatapath = '/cscratch/brookmanmw/';
remote.slurm.brookmanmw.bridge = [];%direct link only as Michael is always at GA
%
remote.direct.brookmanmw = remote.direct.peyssony;
remote.direct.brookmanmw.remoteuser = 'brookmanmw';
remote.direct.brookmanmw.remotedatapath = '/cscratch/brookmanmw/';
remote.direct.brookmanmw.bridge = [];%direct link only as Michael is always at GA
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
