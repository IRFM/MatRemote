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
default.profile = 'decker';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% JOAN DECKER
%
% direct
%
remote.direct.decker = default_remote_profile;
remote.direct.decker.host = 'ppb110.epfl.ch';
remote.direct.decker.hostname = 'ws0.epfl.ch';
remote.direct.decker.nproc = 4;
remote.direct.decker.cmd ={'bash','',' &'};% direct calculation (csh, bash)
remote.direct.decker.get_jobid = {};%str_before,str_after
remote.direct.decker.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.decker.matver.mat801.root = '/usr/local/matlab-8.1/bin/';
remote.direct.decker.matver.mat801.prefdir = '/home/G09625/.matlab/R2013a';
remote.direct.decker.matver.matdef = remote.direct.decker.matver.mat801;%default matlab on remote machine
remote.direct.decker.remoteuser = 'joan.decker@cea.fr';
%
% slurm
%
remote.slurm.decker = default_remote_profile;
remote.slurm.decker.host = 'ppb110.epfl.ch';
remote.slurm.decker.hostname = 'ws0.epfl.ch';
remote.slurm.decker.nproc = 36;
remote.slurm.decker.cmd = 'sbatch';% direct calculation (csh, bash)
remote.slurm.decker.get_jobid = {'Submitted batch job ',''};%str_before,str_after
remote.slurm.decker.set_jobid = {'squeue -j ','','prod'};%str_before,str_after,str_check
remote.slurm.decker.matver.mat801.root = '/usr/local/matlab-8.1/bin/';
remote.slurm.decker.matver.mat801.prefdir = '/home/G09625/.matlab/R2013a';
remote.slurm.decker.matver.matdef = remote.slurm.decker.matver.mat801;%default matlab on remote machine
remote.slurm.decker.remoteuser = 'joan.decker@cea.fr';
%
% JOSEF KAMLEITNER
%
% direct
%
remote.direct.kamleitn = remote.direct.decker;
remote.direct.kamleitn.matver.mat801.prefdir = '/home/kamleitn/.matlab/R2013a';
remote.direct.kamleitn.matver.matdef = remote.direct.kamleitn.matver.mat801;%default matlab on remote machine
remote.direct.kamleitn.remoteuser = 'kamleitn';
%
% slurm
%
remote.slurm.kamleitn = remote.slurm.decker;
remote.slurm.kamleitn.matver.mat801.prefdir = '/home/kamleitn/.matlab/R2013a';
remote.slurm.kamleitn.matver.matdef = remote.slurm.kamleitn.matver.mat801;%default matlab on remote machine
remote.slurm.kamleitn.remoteuser = 'kamleitn';
%
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
