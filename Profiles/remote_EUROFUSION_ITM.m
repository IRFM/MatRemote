function remote_profile = remote_EUROFUSION_ITM(varargin)
%
% This function regroups the remote profiles run on EUROFUSION cluster at CINECA (Italy)
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'slurm';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'g2yvesp';% default user profile if 'remoteuser' is not an existing user profile
%
default.filename = mfilename;%remote_xxx_yyy.m file name
%
% YVES PEYSSON
%
% direct (does not work for matlab)
%
remote.direct.g2yvesp = default_remote_profile;
remote.direct.g2yvesp.host = 'login.eufus.eu';
remote.direct.g2yvesp.hostname = '@s';
remote.direct.g2yvesp.nproc = 10;
remote.direct.g2yvesp.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.g2yvesp.get_jobid = {};%str_before,str_after
remote.direct.g2yvesp.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
%remote.direct.g2yvesp.remotedatapath = '/afs/eufus.eu/user/g/g2yvesp/tmp/';
remote.direct.g2yvesp.remotedatapath = '/pfs/work/g2yvesp/tmp/';
remote.direct.g2yvesp.matver.mat902 = '/gw/swvend/matlab/r2017a/bin/matlab';
remote.direct.g2yvesp.matver.mat905 = '/gw/swvend/matlab/r2018b/bin/matlab';
remote.direct.g2yvesp.matver.mat908 = '/gw/swvend/matlab/r2020a/bin/matlab';
remote.direct.g2yvesp.matver.matdef = remote.direct.g2yvesp.matver.mat905;%default matlab on remote machine
remote.direct.g2yvesp.remoteuser = 'g2yvesp';
remote.direct.g2yvesp.password = getenv('EUROFUSION_ITM_PASSWD');%set password in startup.m or in session startup script
%
% slurm
%
remote.slurm.g2yvesp = default_remote_profile;
remote.slurm.g2yvesp.host = 'login.eufus.eu';
remote.slurm.g2yvesp.hostname = '@s';
remote.slurm.g2yvesp.nproc = 10;
remote.slurm.g2yvesp.cmd = 'sbatch --partition=gw';% direct calculation (csh, bash) (for debugging, move to the remote folder and launch the slum command replacing sbatch by srun, the interactive mode)
%remote.slurm.g2yvesp.remotedatapath = '/afs/eufus.eu/user/g/g2yvesp/tmp/';
remote.slurm.g2yvesp.remotedatapath = '/pfs/work/g2yvesp/tmp/';
remote.slurm.g2yvesp.get_jobid = {'Submitted batch job ',''};%str_before,str_after
remote.slurm.g2yvesp.set_jobid = {'squeue -j ','',''};%str_before,str_after,str_check
remote.slurm.g2yvesp.matver.mat902 = '/gw/swvend/matlab/r2017a/bin/matlab';
remote.slurm.g2yvesp.matver.mat905 = '/gw/swvend/matlab/r2018b/bin/matlab';
remote.slurm.g2yvesp.matver.mat908 = '/gw/swvend/matlab/r2020a/bin/matlab';
remote.slurm.g2yvesp.matver.matdef = remote.slurm.g2yvesp.matver.mat905;%default matlab on remote machine
remote.slurm.g2yvesp.remoteuser = 'g2yvesp';
remote.slurm.g2yvesp.password = getenv('EUROFUSION_ITM_PASSWD');%set password in startup.m or in session startup script
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
