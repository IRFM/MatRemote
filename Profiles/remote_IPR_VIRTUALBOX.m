function remote_profile = remote_IPR_VIRTUALBOX(varargin)
%
% This function regroups the remote profiles run on the IPR VIRTUALBOX (Gandhinagar, Gujarat, India)
%
%   INPUTS : 
%
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'condor';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'peysson';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% Note : direct mode disabled because login for pid check could occur on a different machine
%
% torque
%
remote.condor.peysson = default_remote_profile;
remote.condor.peysson.host = '103.49.147.27';% empty for local host (192.168.5.2)
remote.condor.peysson.hostname = 'ipr-virtualbox';
remote.condor.peysson.nproc = 12;% default number of nodes for job on shenma
remote.condor.peysson.cmd = 'condor_submit';
remote.condor.peysson.get_jobid = {'** Proc ',':'};
remote.condor.peysson.set_jobid = {'condor_q ',''};
remote.condor.peysson.condor.CONDOR_CONFIG = 'HTCONDOR/condor-8.2.3-x86_64_MacOSX7-unstripped/etc/condor_config';
remote.condor.peysson.condor.PATH = 'HTCONDOR/condor-8.2.3-x86_64_MacOSX7-unstripped/sbin:/Users/yvespeysson/Shared/Packages/Bin/HTCONDOR/condor-8.2.3-x86_64_MacOSX7-unstripped/bin:${PATH}';
remote.condor.peysson.remotedatapath = '/home/peysson/tmp/';
remote.condor.peysson.matver.mat805 = '/usr/local/bin/matlab';
remote.condor.peysson.matver.matdef = remote.condor.peysson.matver.mat805;%default matlab on remote machine1
remote.condor.peysson.remoteuser = 'peysson';
remote.condor.peysson.bridge.url.host = 'tolbachik.hd.free.fr:8081';%raspberry1 aix
remote.condor.peysson.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%raspberry1 aix
remote.condor.peysson.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%raspberry1 aix
%
% direct
%
remote.direct.peysson = default_remote_profile;
remote.direct.peysson.host = '103.49.147.27';
remote.direct.peysson.hostname = 'ipr-virtualbox';
remote.direct.peysson.nproc = 20;
remote.direct.peysson.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.peysson.get_jobid = {};%str_before,str_after
remote.direct.peysson.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.peysson.timeout = 60;
remote.direct.peysson.remotedatapath = '/home/Yves/';
remote.direct.peysson.matver.mat805 = '/usr/local/bin/matlab';
remote.direct.peysson.matver.matdef = remote.direct.peysson.matver.mat805;%default matlab on remote machine
remote.direct.peysson.remoteuser = 'peysson';
remote.direct.peysson.bridge.url.host = 'tolbachik.hd.free.fr:8081';%raspberry1 aix
remote.direct.peysson.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%raspberry1 aix
remote.direct.peysson.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%raspberry1 aix
%
% HARSHITA RAJ
%
remote.condor.ipr= remote.condor.peysson;
remote.condor.ipr.remoteuser = 'ipr';
remote.condor.ipr.remotedatapath = '/home/ipr/tmp/';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
