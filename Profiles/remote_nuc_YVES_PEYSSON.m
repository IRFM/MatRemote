function remote_profile = remote_nuc_YVES_PEYSSON(varargin)
%
% This function regroups the remote profiles run on the NUC (Aix) of Yves Peysson
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'condor';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'yvespeysson';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% direct
%
remote.direct.yvespeysson = default_remote_profile;
remote.direct.yvespeysson.host = 'tolbachik.hd.free.fr';
remote.direct.yvespeysson.hostname = 'nucyves';
remote.direct.yvespeysson.nproc = 6;
% remote.direct.yvespeysson.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &'};% direct calculation (csh, bash)
remote.direct.yvespeysson.cmd = {'bash','nohup ',' &'};% direct calculation (csh, bash)
remote.direct.yvespeysson.get_jobid = {};%str_before,str_after
remote.direct.yvespeysson.set_jobid = {'ps -p ','','MATLAB'};%str_before,str_after,str_check
remote.direct.yvespeysson.remotedatapath = '/Users/yvespeysson/';
remote.direct.yvespeysson.matver.mat901 = '/usr/local/MATLAB/R2016b/bin/matlab';
remote.direct.yvespeysson.matver.matdef = remote.direct.yvespeysson.matver.mat901;%default matlab on remote machine
remote.direct.yvespeysson.remoteuser = 'yvespeysson';
remote.direct.yvespeysson.bridge.url.host = 'tolbachik.hd.free.fr:8081';%nuc aix
remote.direct.yvespeysson.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%nuc aix
remote.direct.yvespeysson.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%nuc aix
%
% condor
%
remote.condor.yvespeysson = default_remote_profile;
remote.condor.yvespeysson.host = 'tolbachik.hd.free.fr';
remote.condor.yvespeysson.hostname = 'nucyves';
remote.condor.yvespeysson.nproc = 6;
remote.condor.yvespeysson.cmd = 'condor_submit';
remote.condor.yvespeysson.get_jobid = {'** Proc ',':'};
remote.condor.yvespeysson.set_jobid = {'condor_q ',''};
remote.condor.yvespeysson.condor.CONDOR_CONFIG = '/etc/condor/condor_config';
remote.condor.yvespeysson.condor.PATH = '/usr/sbin/';
remote.condor.yvespeysson.remotedatapath = '/Users/yvespeysson/condor/';
remote.condor.yvespeysson.matver.mat901 = '/Applications/MATLAB_R2016b.app/bin/matlab';
remote.condor.yvespeysson.matver.matdef = remote.condor.yvespeysson.matver.mat901;%default matlab on remote machine
remote.condor.yvespeysson.remoteuser = 'yvespeysson';
remote.condor.yvespeysson.bridge.url.host = 'tolbachik.hd.free.fr:8081';%nuc aix
remote.condor.yvespeysson.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%nuc aix
remote.condor.yvespeysson.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%nuc aix
%
% JOAN DECKER
%
% direct
%
remote.direct.joan = remote.direct.yvespeysson;% same remote user, same options
%
% condor
%
remote.condor.joan = remote.condor.yvespeysson;% same remote user, same options
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%


    