function remote_profile = remote_IPP_ABACUS(varargin)
%
% This function regroups the remote profiles run on ABACUS cluster at the IPP Prague
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'pbs';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'decker';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% JOAN DECKER
%
% direct
%
remote.direct.decker = default_remote_profile;
remote.direct.decker.host = 'abacus.tok.ipp.cas.cz';
remote.direct.decker.hostname = 'abacus';
remote.direct.decker.nproc = 12;
remote.direct.decker.cmd ={'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.decker.get_jobid = {};%str_before,str_after
remote.direct.decker.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.decker.matver.mat801 = '/sw/matlab/r2013a/bin/matlab';
remote.direct.decker.matver.matdef = remote.direct.decker.matver.mat801;%default matlab on remote machine
remote.direct.decker.remoteuser = 'decker';
%
% pbs
%
remote.pbs.decker = default_remote_profile;
remote.pbs.decker.host = 'abacus.tok.ipp.cas.cz';
remote.pbs.decker.hostname = 'abacus';
remote.pbs.decker.nproc = 36;
remote.pbs.decker.cmd = 'qsub ';% direct calculation (csh, bash)
remote.pbs.decker.shclean = 1;
remote.pbs.decker.get_jobid = {'','.abacus'};%str_before,str_after
remote.pbs.decker.set_jobid = {'qstat ','.abacus','Unknown Job Id',' C '};%str_before,str_after,str_check
remote.pbs.decker.matver.mat801 = '/sw/matlab/r2013a/bin/matlab';
remote.pbs.decker.matver.matdef = remote.pbs.decker.matver.mat801;%default matlab on remote machine
remote.pbs.decker.remoteuser = 'decker';
%
% YVES PEYSSON
%
% direct
%
remote.direct.peysson = default_remote_profile;
remote.direct.peysson.host = 'abacus.tok.ipp.cas.cz';
remote.direct.peysson.hostname = 'abacus';
remote.direct.peysson.nproc = 12;
remote.direct.peysson.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &',''};% direct calculation (csh, bash)
remote.direct.peysson.get_jobid = {};%str_before,str_after
remote.direct.peysson.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.peysson.matver.mat801 = '/sw/matlab/r2013a/bin/matlab';
remote.direct.peysson.matver.matdef = remote.direct.peysson.matver.mat801;%default matlab on remote machine
remote.direct.peysson.remoteuser = 'peysson';
remote.direct.peysson.bridge.url.host = 'tolbachik.hd.free.fr';
remote.direct.peysson.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.direct.peysson.bridge.ssh.host = 'tolbachik.hd.free.fr';
%
% pbs
%
remote.pbs.peysson = default_remote_profile;
remote.pbs.peysson.host = 'abacus.tok.ipp.cas.cz';
remote.pbs.peysson.hostname = 'abacus';
remote.pbs.peysson.nproc = 36;
remote.pbs.peysson.cmd = 'qsub ';% direct calculation (csh, bash)
remote.pbs.peysson.shclean = 1;
remote.pbs.peysson.get_jobid = {'','.abacus'};%str_before,str_after
remote.pbs.peysson.set_jobid = {'qstat ','.abacus','Unknown Job Id',' C '};%str_before,str_after,str_check
remote.pbs.peysson.matver.mat801 = '/sw/matlab/r2013a/bin/matlab';
remote.pbs.peysson.matver.matdef = remote.pbs.peysson.matver.mat801;%default matlab on remote machine
remote.pbs.peysson.remoteuser = 'peysson';
remote.pbs.peysson.bridge.url.host = 'tolbachik.hd.free.fr';
remote.pbs.peysson.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.pbs.peysson.bridge.ssh.host = 'tolbachik.hd.free.fr';
%
% JAKUB URBAN
%
% pbs
%
remote.pbs.urban = remote.pbs.peysson;
remote.pbs.urban.remoteuser = 'urban';
%
% RICHARD PAPROK
%
% pbs
%
remote.pbs.paprok = remote.pbs.peysson;
remote.pbs.paprok.remoteuser = 'paprok';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
