function remote_profile = remote_MACHINENAME(varargin)
%
% This function regroups the remote profile for TORQUE/PBS scheduler.
% (change torque everywhere by pbs if psb is used)
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'torque';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'REMOTEUSER';% default user profile if 'remoteuser' is not an existing user profile
%
default.filename = mfilename;%remote_xxx_yyy.m file name
%
% --------------------------------------------------
remote.torque.HOSTNAME = default_remote_profile;
remote.torque.HOSTNAME.host = {'INTERNALIPADDRESS','EXTERNALIPADDRESS:PORT'} or 'EXTERNALIPADDRESS:PORT';% 
remote.torque.HOSTNAME.hostname = 'HOSTNAME';%type hostname in a remote terminal
remote.torque.HOSTNAME.nproc = NN;%number of procs or cores
remote.torque.HOSTNAME.wait = 0;
remote.torque.HOSTNAME.shclean = 1;
remote.torque.HOSTNAME.cmd = 'qsub -q batch';%'qsub -q batch -o /scratch/PEYSSON';%for debug only (clear mat* files in /scratch/PEYSSON after turned on) 
remote.torque.HOSTNAME.remotedatapath = 'CALCULATIONFOLDERFULLPATH';
remote.torque.HOSTNAME.get_jobid = {'','.JOBEXTENSION'};%str_before,str_after
remote.torque.HOSTNAME.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.HOSTNAME.timeout = 10;
remote.torque.HOSTNAME.matver.matXXX = 'REMOTEMATLABFULLPATH/bin/matlab';%XXX is the matlab version (type version in matlab command window, and XXX are the first three digits)
remote.torque.HOSTNAME.matver.matdef = remote.slurm.HOSTNAME.matver.matXXX;%default matlab on remote machine
remote.torque.HOSTNAME.rempause = 0.1;% pause between job checks (in minutes) (because of ssh access limitation)
%
% direct
%
remote.direct.HOSTNAME = default_remote_profile;
remote.direct.HOSTNAME.host = {'INTERNALIPADDRESS','EXTERNALIPADDRESS:PORT'} or 'EXTERNALIPADDRESS:PORT';% no port needed if 22 
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
% Add below other users for HOSTNAME2,HOSTNAME3,... or comment if only a single user
%
remote.torque.HOSTNAME2 = remote.torque.HOSTNAME;
remote.torque.HOSTNAME2.host =  {'INTERNALIPADDRESS','EXTERNALIPADDRESS:PORT'} or 'EXTERNALIPADDRESS:PORT';% 
remote.torque.HOSTNAME2.remoteuser = 'HOSTNAME';%type hostname in a remote terminal
remote.torque.HOSTNAME2.remotedatapath = 'CALCULATIONFOLDERFULLPATH';
remote.torque.HOSTNAME2.bridge.ssh.host = '';
remote.torque.HOSTNAME2.bridge.ssh.remotepassword = '';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%