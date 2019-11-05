function remote_profile = remote_CYFRONET_PROMETHEUS(varargin)
%
% This function regroups the remote profiles run on the Cyfronet Prometheus cluster in Poland
% "srun -p plgrid -A poloniumwest -n 1 --pty /bin/bash -l"
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
remote.slurm.plgypeysson.hostname = 'prometheus';
remote.slurm.plgypeysson.nproc = 24;
%remote.slurm.plgypeysson.walltime = '00:10';
%---------------------------------------------------
remote.slurm.plgypeysson.cmd = 'sbatch';% direct calculation (csh, bash) (for debugging, move to the remote folder and launch the slum command replacing sbatch by srun, the interactive mode)
remote.slurm.plgypeysson.remotedatapath = '/net/scratch/people/plgypeysson/';
remote.slurm.plgypeysson.get_jobid = {'Submitted batch job ',''};%str_before,str_after
remote.slurm.plgypeysson.set_jobid = {'squeue -j ','',''};%str_before,str_after,str_check
remote.slurm.plgypeysson.matver.mat904 = '/net/software/local/matlab/R2018a/bin/matlab';
remote.slurm.plgypeysson.matver.mat905 = '/net/software/local/matlab/R2018b/bin/matlab';
remote.slurm.plgypeysson.matver.matdef = remote.slurm.plgypeysson.matver.mat905;%default matlab on remote machine1
remote.slurm.plgypeysson.remoteuser = 'plgypeysson';
%
% test script in interactive way withing slurm 
% Type first in a terminal 
% srun -p plgrid -A poloniumwest -n 1 --pty /bin/bash -l'"
% the execute the script
%
%
% KRZYSZTOF KROL (PROMETHEUS)
%
remote.slurm.plgzgoryk = remote.slurm.plgypeysson;
remote.slurm.plgzgoryk.remoteuser = 'plgzgoryk';
remote.slurm.plgzgoryk.remotedatapath = '/net/scratch/people/plgzgoryk/';
remote.slurm.plgzgoryk.bridge = [];
%
% DOMINIK DWORAK (PROMETHEUS)
%
remote.slurm.plgddworak = remote.slurm.plgypeysson;
remote.slurm.plgddworak.remoteuser = 'plgddworak';
remote.slurm.plgddworak.remotedatapath = '/net/scratch/people/plgddworak/';
remote.slurm.plgddworak.bridge = [];
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
