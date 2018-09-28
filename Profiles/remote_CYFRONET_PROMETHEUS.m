function remote_profile = remote_CYFRONET_PROMETHEUS(varargin)
%
% This function regroups the remote profiles run on the Cyfronet Prometheus cluster in Poland
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'slurm';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'plgypeysson';% default user profile if 'remoteuser' is not an existing user profile
%
default.filename = mfilename;%remote_xxx_yyy.m file name
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% slurm
%
remote.slurm.plgypeysson = default_remote_profile;
remote.slurm.plgypeysson.host = 'pro.cyfronet.pl';
remote.slurm.plgypeysson.hostname = 'cyfronet';
remote.slurm.plgypeysson.nproc = 24;
%remote.slurm.plgypeysson.walltime = '00:10';
%---------------------------------------------------
remote.slurm.plgypeysson.cmd = 'sbatch';% direct calculation (csh, bash) (for debugging, move to the remote folder and launch the slum command replacing sbatch by srun, the interactive mode)
remote.slurm.plgypeysson.remotedatapath = '/net/scratch/people/plgypeysson/';
remote.slurm.plgypeysson.get_jobid = {'Submitted batch job ',''};%str_before,str_after
remote.slurm.plgypeysson.set_jobid = {'squeue -j ','','prod'};%str_before,str_after,str_check
remote.slurm.plgypeysson.matver.mat904 = '/net/software/local/matlab/R2018a/bin/matlab';
remote.slurm.plgypeysson.matver.mat905 = '/net/software/local/matlab/R2018b/bin/matlab';
remote.slurm.plgypeysson.matver.matdef = remote.slurm.plgypeysson.matver.mat904;%default matlab on remote machine
remote.slurm.plgypeysson.remoteuser = 'plgypeysson';
%
% direct
%
remote.direct.plgypeysson = default_remote_profile;
remote.direct.plgypeysson.host = 'pro.cyfronet.pl';
remote.direct.plgypeysson.hostname = 'cyfronet';
remote.direct.plgypeysson.shell = 'bash';
remote.direct.plgypeysson.nproc = 24;
remote.direct.plgypeysson.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.plgypeysson.remotedatapath = '/net/scratch/people/plgypeysson';%echo $SCRATCH
remote.direct.plgypeysson.get_jobid = {};%str_before,str_after
remote.direct.plgypeysson.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.plgypeysson.matver.mat904 = '/net/software/local/matlab/R2018a/bin/matlab';
remote.direct.plgypeysson.matver.mat905 = '/net/software/local/matlab/R2018b/bin/matlab';
remote.direct.plgypeysson.matver.matdef = remote.direct.plgypeysson.matver.mat904;%default matlab on remote machine
remote.direct.plgypeysson.remoteuser = 'plgypeysson';
%
% KRZYSZTOF KROL (PROMETHEUS)
%
remote.slurm.plgzgoryk = remote.slurm.plgypeysson;
remote.slurm.plgzgoryk.remoteuser = 'plgzgoryk';
remote.slurm.plgzgoryk.remotedatapath = '/net/scratch/people/plgzgoryk/';
remote.slurm.plgzgoryk.bridge = [];
%
remote.direct.plgzgoryk = remote.direct.plgypeysson;
remote.direct.plgzgoryk.remoteuser = 'plgzgoryk';
remote.direct.plgzgoryk.remotedatapath = '/net/scratch/people/plgzgoryk/';
remote.direct.plgzgoryk.bridge = [];
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
