function remote_profile = remote_CRPP_BELLATRIX(varargin)
%
% This function regroups the remote profiles run on BELLATRIX cluster at the CRPP
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'slurm';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'kamleitn';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% JOSEF KAMLEITNER
%
% direct
%
remote.direct.kamleitn = default_remote_profile;
remote.direct.kamleitn.host = 'bellatrix.epfl.ch';
remote.direct.kamleitn.hostname = 'bellatrix.cluster';
remote.direct.kamleitn.nproc = 8;
remote.direct.kamleitn.cmd ={'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.kamleitn.remotedatapath = '/scratch/kamleitn/';
remote.direct.kamleitn.get_jobid = {};%str_before,str_after
remote.direct.kamleitn.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.kamleitn.matver.mat800 = '/opt/software/MATLAB/R2012b/bin/matlab';
remote.direct.kamleitn.matver.matdef = remote.direct.kamleitn.matver.mat800;%default matlab on remote machine
remote.direct.kamleitn.remoteuser = 'kamleitn';
remote.direct.kamleitn.bridge.ssh.host = 'lac911.epfl.ch';
%
% pbs (does not work any more since Aug 2014)
%
% remote.pbs.kamleitn = default_remote_profile;
% remote.pbs.kamleitn.host = 'bellatrix.epfl.ch';
% remote.pbs.kamleitn.hostname = 'bellatrix.cluster';
% remote.pbs.kamleitn.nproc = 6784;
% remote.pbs.kamleitn.cmd = 'qsub ';% direct calculation (csh, bash)
% remote.pbs.kamleitn.nodes = NaN;% number of nodes (set to NaN to use select);
% remote.pbs.kamleitn.memory = NaN;% memory not compatible with select;
% remote.pbs.kamleitn.remotedatapath = '/scratch/kamleitn/';
% remote.pbs.kamleitn.shclean = 1;
% remote.pbs.kamleitn.get_jobid = {'','.bellatrix'};%str_before,str_after
% remote.pbs.kamleitn.set_jobid = {'qstat ','.bellatrix','Job has finished'};%str_before,str_after,str_check
% remote.pbs.kamleitn.matver.mat800 = remote.direct.kamleitn.matver.mat800;
% remote.pbs.kamleitn.matver.matdef = remote.pbs.kamleitn.matver.mat800;%default matlab on remote machine
% remote.pbs.kamleitn.remoteuser = 'kamleitn';
% remote.pbs.kamleitn.bridge.ssh.host = 'lac911.epfl.ch';
%
% slurm
%
remote.slurm.kamleitn = default_remote_profile;
remote.slurm.kamleitn.host = 'bellatrix.epfl.ch';
remote.slurm.kamleitn.hostname = 'bellatrix.cluster';
remote.slurm.kamleitn.nproc = 6784;
remote.slurm.kamleitn.cmd = 'sbatch ';% direct calculation (csh, bash)
remote.slurm.kamleitn.remotedatapath = '/scratch/kamleitn/';
remote.slurm.kamleitn.get_jobid = {'Submitted batch job ',''};%str_before,str_after
remote.slurm.kamleitn.set_jobid = {'squeue -j ','',''};%str_before,str_after,str_check
remote.slurm.kamleitn.matver.mat800 = remote.direct.kamleitn.matver.mat800;
remote.slurm.kamleitn.matver.matdef = remote.slurm.kamleitn.matver.mat800;%default matlab on remote machine
remote.slurm.kamleitn.remoteuser = 'kamleitn';
remote.slurm.kamleitn.bridge.ssh.host = 'lac911.epfl.ch';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
