function remote_profile = remote_ITER_HPC(varargin)
%
% This function regroups the remote profiles run on the ITER/HPC cluster
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'slurm';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'peyssoy';% default user profile if 'remoteuser' is not an existing user profile
%
default.filename = mfilename;%remote_xxx_yyy.m file name
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% slurm
%
remote.slurm.peyssoy = default_remote_profile;
remote.slurm.peyssoy.host = 'hpc-login.iter.org';
remote.slurm.peyssoy.hostname = 'hpc-login02.iter.org';
remote.slurm.peyssoy.nproc = 20;
%remote.slurm.ypeysson.walltime = '00:10';
%---------------------------------------------------
% To run a long serial job (or any serial job) the sched_mit_psfc_serial partition must be used. Calculations are restricted to one core. 
% For very long jobs which need parallel work in matlab the quality of service (qos) option : --qos=psfc_long must be used with the sched_mit_psfc partition (one week job, limited to three nodes, number of core must be specified)
% The quality of service (qos) option : --qos=psfc_24h allows 24 hour jobs, limited to 50 nodes.
%---------------------------------------------------
remote.slurm.peyssoy.cmd = 'sbatch ';% direct calculation (csh, bash) (for debugging, move to the remote folder and launch the slum command replacing sbatch by srun, the interactive mode)

remote.slurm.peyssoy.remotedatapath = '/home/ITER/peyssoy/tmp/';
remote.slurm.peyssoy.get_jobid = {'Submitted batch job ',''};%str_before,str_after
remote.slurm.peyssoy.set_jobid = {'squeue -j ','','prod'};%str_before,str_after,str_check
remote.slurm.peyssoy.matver.mat904 = '/work/imas/opt/EasyBuild/software/MATLAB/2018a/bin/matlab';
remote.slurm.peyssoy.matver.matdef = remote.slurm.peyssoy.matver.mat904;%default matlab on remote machine
remote.slurm.peyssoy.remoteuser = 'peyssoy';
%
% direct
%
remote.direct.peyssoy = default_remote_profile;
remote.direct.peyssoy.host = 'hpc-login.iter.org';
remote.direct.peyssoy.hostname = 'hpc-login.iter.org';
remote.direct.peyssoy.shell = 'bash';
remote.direct.peyssoy.nproc = 20;
remote.direct.peyssoy.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.peyssoy.remotedatapath = '/home/ITER/peyssoy/tmp/';
remote.direct.peyssoy.get_jobid = {};%str_before,str_after
remote.direct.peyssoy.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.peyssoy.matver.mat904 = '/work/imas/opt/EasyBuild/software/MATLAB/2018a/bin/matlab';
remote.direct.peyssoy.matver.matdef = remote.direct.peyssoy.matver.mat904;%default matlab on remote machine
remote.direct.peyssoy.remoteuser = 'peyssoy';
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
