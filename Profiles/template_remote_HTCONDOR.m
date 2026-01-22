function remote_profile = remote_MACHINENAME(varargin)
%
% This function regroups the remote profile for HTCONDOR scheduler. 
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'condor';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'REMOTEUSER';% default user profile if 'remoteuser' is not an existing user profile
%
default.filename = mfilename;%remote_xxx_yyy.m file name
%
% --------------------------------------------------
%
% condor
%
remote.condor.HOSTNAME = default_remote_profile;
remote.condor.HOSTNAME.host = {'INTERNALIPADDRESS','EXTERNALIPADDRESS:PORT'} or 'EXTERNALIPADDRESS:PORT';% no port needed if 22
remote.condor.HOSTNAME.hostname = 'HOSTNAME';%type hostname in a remote terminal
remote.condor.HOSTNAME.nproc = NN;%number of procs or cores
remote.condor.HOSTNAME.cmd = 'condor_submit';
remote.condor.HOSTNAME.get_jobid = {'** Proc ',':'};
remote.condor.HOSTNAME.set_jobid = {'condor_q ',' -nobatch'};
remote.condor.HOSTNAME.condor.CONDOR_CONFIG = '/etc/condor/condor_config';
remote.condor.HOSTNAME.condor.PATH = '$PATH';
remote.condor.HOSTNAME.remotedatapath = '/home/HOSTNAME/tmp/';
remote.condor.HOSTNAME.matver.matXXX = 'REMOTEMATLABFULLPATH/bin/matlab';%XXX is the matlab version (type version in matlab command window, and XXX are the first three digits)
remote.condor.HOSTNAME.matver.matdef = remote.condor.HOSTNAME.matver.matXXX;%default matlab on remote machine
remote.condor.HOSTNAME.remoteuser = 'HOSTNAME';
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