function remote_profile = remote_PSFC_EOFE7(varargin)
%
% This function regroups the remote profiles run on the MIT/EOFE7 engaging cluster
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'slurm';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'ypeysson';% default user profile if 'remoteuser' is not an existing user profile
%
default.filename = mfilename;%remote_xxx_yyy.m file name
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% slurm
%
remote.slurm.ypeysson = default_remote_profile;
remote.slurm.ypeysson.host = 'eofe7.mit.edu';
remote.slurm.ypeysson.hostname = 'eofe7';
remote.slurm.ypeysson.nproc = 20;
%remote.slurm.ypeysson.walltime = '00:10';
%---------------------------------------------------
% To run a long serial job (or any serial job) the sched_mit_psfc_serial partition must be used. Calculations are restricted to one core. 
% For very long jobs which need parallel work in matlab the quality of service (qos) option : --qos=psfc_long must be used with the sched_mit_psfc partition (one week job, limited to three nodes, number of core must be specified)
% The quality of service (qos) option : --qos=psfc_24h allows 24 hour jobs, limited to 50 nodes.
%---------------------------------------------------
remote.slurm.ypeysson.cmd = 'sbatch --partition=sched_mit_psfc --qos=psfc_24h';% direct calculation (csh, bash) (for debugging, move to the remote folder and launch the slum command replacing sbatch by srun, the interactive mode)
remote.slurm.ypeysson.remotedatapath = '/home/ypeysson/tmp/';
remote.slurm.ypeysson.get_jobid = {'Submitted batch job ',''};%str_before,str_after
remote.slurm.ypeysson.set_jobid = {'squeue -j ','',''};%str_before,str_after,str_check
remote.slurm.ypeysson.matver.mat903 = '/cm/shared/mit/matlab/matlab-2017b/bin/matlab';
remote.slurm.ypeysson.matver.mat905 = '/cm/shared/mit/matlab/matlab-2018b/bin/matlab';
remote.slurm.ypeysson.matver.matdef = remote.slurm.ypeysson.matver.mat905;%default matlab on remote machine
remote.slurm.ypeysson.remoteuser = 'ypeysson';
%
% direct
%
remote.direct.ypeysson = default_remote_profile;
remote.direct.ypeysson.host = 'eofe7.mit.edu';
remote.direct.ypeysson.hostname = 'eofe7';
remote.direct.ypeysson.shell = 'bash';
remote.direct.ypeysson.nproc = 20;
remote.direct.ypeysson.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.ypeysson.remotedatapath = '/home/ypeysson/tmp/';
remote.direct.ypeysson.get_jobid = {};%str_before,str_after
remote.direct.ypeysson.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.ypeysson.matver.mat903 = '/cm/shared/mit/matlab/matlab-2017b/bin/matlab';
remote.direct.ypeysson.matver.mat905 = '/cm/shared/mit/matlab/matlab-2018b/bin/matlab';
remote.direct.ypeysson.matver.matdef = remote.direct.ypeysson.matver.mat905;%default matlab on remote machine
remote.direct.ypeysson.remoteuser = 'ypeysson';
%
% Tullio Barbui
%
% pbs pro
%
remote.slurm.tbarbui = remote.slurm.ypeysson;
remote.slurm.tbarbui.remoteuser = 'tbarbui';
remote.slurm.tbarbui.remotedatapath = '/home/tbarbui/tmp/';
%
% direct
%
remote.direct.tbarbui = remote.direct.ypeysson;
remote.direct.tbarbui.remoteuser = 'tbarbui';
remote.direct.tbarbui.remotedatapath = '/home/tbarbui/tmp/';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
