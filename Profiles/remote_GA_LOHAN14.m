function remote_profile = remote_GA_LOHAN14(varargin)
%
% This function regroups the remote profiles run on the LOHAN14 cluster
% in the GA (General Atomics, USA) network
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'direct';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'peyssony';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% pbs pro
%
%remote.pbs.peyssony = default_remote_profile;
%remote.pbs.peyssony.host = 'lohan14.gat.com';%'localhost -p 4023';%set first a permanent ssh tunnel locally on your computer before connection
%remote.pbs.peyssony.hostname = 'lohan14.gat.com';
%remote.pbs.peyssony.shell = 'tcsh';
%remote.pbs.peyssony.nproc = 12;
%remote.pbs.peyssony.cmd = 'qsub';
%remote.pbs.peyssony.remotedatapath = '/u/peyssony/tmp/';
%remote.pbs.peyssony.get_jobid = {'','.loki'};%str_before,str_after
%remote.pbs.peyssony.set_jobid = {'qstat ','.loki','finished'};%str_before,str_after,str_check
%remote.pbs.peyssony.shclean = 1;
%remote.pbs.peyssony.matver.mat804 = '/usr/local/bin/matlab';
%remote.pbs.peyssony.matver.mat806 = '/usr/local/bin/matlab15b';
%remote.pbs.peyssony.matver.matdef = remote.pbs.peyssony.matver.mat804;%default matlab on remote machine
%remote.pbs.peyssony.remoteuser = 'peyssony';
%%remote.pbs.peyssony.bridge.url.host = 'cybele.gat.com';%cybele workstation GA/DIII-D
%%remote.pbs.peyssony.bridge.ftp.host = 'cybele.gat.com';%cybele workstation GA/DIII-D
%remote.pbs.peyssony.bridge.ssh.host = 'cybele.gat.com -p 2039';%cybele workstation GA/DIII-D
%
% direct
%
% note : mode direct bridge disabled because nohup does not work
%
remote.direct.peyssony = default_remote_profile;
remote.direct.peyssony.host = 'lohan14.gat.com';%'localhost -p 4023';%set first a permanent ssh tunnel locally on your computer before connection
remote.direct.peyssony.hostname = 'lohan14.gat.com';
remote.direct.peyssony.shell = 'tcsh';
remote.direct.peyssony.nproc = 12;
remote.direct.peyssony.cmd = {'csh','',' &',' &'};% direct calculation (csh, bash)
remote.direct.peyssony.remotedatapath = '/u/peyssony/tmp/';
remote.direct.peyssony.get_jobid = {};%str_before,str_after
remote.direct.peyssony.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.peyssony.matver.mat804 = '/usr/local/bin/matlab';
remote.direct.peyssony.matver.mat806 = '/usr/local/bin/matlab15b';
remote.direct.peyssony.matver.matdef = remote.direct.peyssony.matver.mat804;%default matlab on remote machine
remote.direct.peyssony.remoteuser = 'peyssony';
%remote.direct.peyssony.bridge.url.host = 'cybele.gat.com';%cybele workstation GA/DIII-D
%remote.direct.peyssony.bridge.ftp.host = 'cybele.gat.com';%cybele workstation GA/DIII-D
remote.direct.peyssony.bridge.ssh.host = 'cybele.gat.com:2039';%cybele workstation GA/DIII-D
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
