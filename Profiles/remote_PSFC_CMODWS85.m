function remote_profile = remote_PSFC_CMODWS85(varargin)
%
% This function regroups the remote profiles run on the workstation
% CMODWS85 in the PSFC/MIT network
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'direct';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'ypeysson';% default user profile if 'remoteuser' is not an existing user profile
%
default.filename = mfilename;%remote_xxx_yyy.m file name
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% direct
%
% note : mode direct bridge disabled because nohup does not work
%
remote.direct.ypeysson = default_remote_profile;
remote.direct.ypeysson.host = 'cmodws85.psfc.mit.edu';
remote.direct.ypeysson.hostname = 'cmodws85';
remote.direct.ypeysson.shell = 'bash';
remote.direct.ypeysson.nproc = 12;
remote.direct.ypeysson.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.ypeysson.remotedatapath = '/home/ypeysson/tmp/';
remote.direct.ypeysson.get_jobid = {};%str_before,str_after
remote.direct.ypeysson.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.ypeysson.matver.mat806 = '/usr/local/bin/matlab';
remote.direct.ypeysson.matver.matdef = remote.direct.ypeysson.matver.mat806;%default matlab on remote machine
remote.direct.ypeysson.remoteuser = 'ypeysson';
%remote.direct.ypeysson.bridge.url.host = 'cmodws85.psfc.mit.edu';%cmodws85 workstation PSFC/MIT
%remote.direct.ypeysson.bridge.ftp.host = 'cmodws85.psfc.mit.edu';%cmodws85 workstation PSFC/MIT
remote.direct.ypeysson.bridge.ssh.host = 'cmodws85.psfc.mit.edu';%cmodws85 workstation PSFC/MIT
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
