function remote_profile = remote_MACHINENAME(varargin)
%
% This function regroups the remote profile for SLURM scheduler. 
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'slurm';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'REMOTEUSER';% default user profile if 'remoteuser' is not an existing user profile
%
default.filename = mfilename;%remote_xxx_yyy.m file name
%
% --------------------------------------------------
%
% slurm
%
remote.slurm.HOSTNAME = default_remote_profile;
remote.slurm.HOSTNAME.host = {'INTERNALIPADDRESS','EXTERNALIPADDRESS:PORT'} or 'EXTERNALIPADDRESS:PORT';% 
remote.slurm.HOSTNAME.hostname = 'HOSTNAME';%type hostname in a remote terminal
remote.slurm.HOSTNAME.nproc = NN;%number of procs or cores
%remote.slurm.HOSTNAME.walltime = '00:10';
remote.slurm.HOSTNAME.cmd = 'sbatch';% direct calculation (csh, bash) (for debugging, move to the remote folder and launch the slum command replacing sbatch by srun, the interactive mode)
remote.slurm.HOSTNAME.remotedatapath = '/home/HOSTNAME/tmp/';
remote.slurm.HOSTNAME.get_jobid = {'Submitted batch job ',''};%str_before,str_after
remote.slurm.HOSTNAME.set_jobid = {'squeue -j ','',''};%str_before,str_after,str_check
remote.slurm.HOSTNAME.matver.matXXX = 'REMOTEMATLABFULLPATH/bin/matlab';%XXX is the matlab version (type version in matlab command window, and XXX are the first three digits)
remote.slurm.HOSTNAME.matver.matdef = remote.slurm.HOSTNAME.matver.matXXX;%default matlab on remote machine
remote.slurm.HOSTNAME.remoteuser = 'HOSTNAME';
remote.slurm.HOSTNAME.services = {'opensnitch'};
%
% direct
%
remote.direct.HOSTNAME = default_remote_profile;
remote.direct.HOSTNAME.host = {'INTERNALIPADDRESS','EXTERNALIPADDRESS:PORT'} or 'EXTERNALIPADDRESS:PORT';% 
remote.direct.HOSTNAME.hostname = 'HOSTNAME';%type hostname in a remote terminal
remote.direct.HOSTNAME.nproc = NN;%number of procs or cores
remote.direct.HOSTNAME.cmd = {'bash','nohup ',' &'};% direct calculation (csh, bash)
remote.direct.HOSTNAME.get_jobid = {};%str_before,str_after
remote.direct.HOSTNAME.set_jobid = {'ps -p ','','MATLAB'};%str_before,str_after,str_check
remote.direct.HOSTNAME.remotedatapath = '/home/HOSTNAME/tmp/';
remote.direct.HOSTNAME.matver.matXXX= 'REMOTEMATLABFULLPATH/bin/matlab';%XXX is the matlab version (type version in matlab command window, and XXX are the first three digits)
remote.direct.HOSTNAME.matver.matdef = remote.direct.HOSTNAME.matver.matXXX;%default matlab on remote machine
remote.direct.HOSTNAME.remoteuser = 'HOSTNAME';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%