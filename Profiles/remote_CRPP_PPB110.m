function remote_profile = remote_CRPP_PPB110(varargin)
%
% This function regroups the remote profiles run on PPB110 cluster at the CRPP
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'slurm';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'joan';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% JOAN DECKER
%
% direct
%
remote.direct.joan = default_remote_profile;
remote.direct.joan.host = 'ppb110.epfl.ch';
remote.direct.joan.hostname = 'ws0';
remote.direct.joan.nproc = 4;
remote.direct.joan.cmd = 'bash';% direct calculation (csh, bash)
remote.direct.joan.get_jobid = {};%str_before,str_after
remote.direct.joan.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.joan.matver.mat801.root = '/usr/local/matlab-8.1/bin/';
remote.direct.joan.matver.mat801.prefdir = '/home/G09625/.matlab/R2013a';
remote.direct.joan.matver.matdef = remote.direct.joan.matver.mat801;%default matlab on remote machine
remote.direct.joan.remoteuser = 'joan.decker@cea.fr';
%
% slurm
%
remote.slurm.joan = default_remote_profile;
remote.slurm.joan.host = 'ppb110.epfl.ch';
remote.slurm.joan.hostname = 'ws0';
remote.slurm.joan.nproc = 36;
remote.slurm.joan.cmd = 'sbatch';% direct calculation (csh, bash)
remote.slurm.joan.get_jobid = {'Submitted batch job ',''};%str_before,str_after
remote.slurm.joan.set_jobid = {'squeue -j ','','prod'};%str_before,str_after,str_check
remote.slurm.joan.matver.mat801.root = '/usr/local/matlab-8.1/bin/';
remote.slurm.joan.matver.mat801.prefdir = '/home/G09625/.matlab/R2013a';
remote.slurm.joan.matver.matdef = remote.slurm.joan.matver.mat801;%default matlab on remote machine
remote.slurm.joan.remoteuser = 'joan.decker@cea.fr';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
