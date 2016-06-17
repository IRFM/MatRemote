function remote_profile = remote_macpro_YVES_PEYSSON(varargin)
%
% This function regroups the remote profiles run on the MACPRO of Yves Peysson
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
remote.direct.yvespeysson.hostname = 'macproyves';
remote.direct.yvespeysson.nproc = 6;
% remote.direct.yvespeysson.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &'};% direct calculation (csh, bash)
remote.direct.yvespeysson.cmd = {'bash','nohup ',' &'};% direct calculation (csh, bash)
remote.direct.yvespeysson.get_jobid = {};%str_before,str_after
remote.direct.yvespeysson.set_jobid = {'ps -p ','','MATLAB'};%str_before,str_after,str_check
remote.direct.yvespeysson.remotedatapath = '/Users/yvespeysson/';
% remote.direct.yvespeysson.matver.mat800 = '/Applications/MATLAB_R2012b.app/bin/matlab';
% remote.direct.yvespeysson.matver.mat801 = '/Applications/MATLAB_R2013a.app/bin/matlab';
% remote.direct.yvespeysson.matver.mat803 = '/Applications/MATLAB_R2014a.app/bin/matlab';
remote.direct.yvespeysson.matver.mat804 = '/Applications/MATLAB_R2014b.app/bin/matlab';
remote.direct.yvespeysson.matver.mat805 = '/Applications/MATLAB_R2015a.app/bin/matlab';
remote.direct.yvespeysson.matver.mat806 = '/Applications/MATLAB_R2015b.app/bin/matlab';
remote.direct.yvespeysson.matver.mat900 = '/Applications/MATLAB_R2016a.app/bin/matlab';
remote.direct.yvespeysson.matver.matdef = remote.direct.yvespeysson.matver.mat900;%default matlab on remote machine
remote.direct.yvespeysson.remoteuser = 'yvespeysson';
remote.direct.yvespeysson.bridge.url.host = 'tolbachik.hd.free.fr:8081';%raspberry1 aix
remote.direct.yvespeysson.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%raspberry1 aix
remote.direct.yvespeysson.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%raspberry1 aix
%
% condor
%
remote.condor.yvespeysson = default_remote_profile;
remote.condor.yvespeysson.host = 'tolbachik.hd.free.fr';
remote.condor.yvespeysson.hostname = 'macproyves';
remote.condor.yvespeysson.nproc = 6;
remote.condor.yvespeysson.cmd = 'condor_submit';
remote.condor.yvespeysson.get_jobid = {'** Proc ',':'};
remote.condor.yvespeysson.set_jobid = {'condor_q ',''};
remote.condor.yvespeysson.condor.CONDOR_CONFIG = '/Users/yvespeysson/Shared/Packages/Bin/HTCONDOR/condor-8.2.3-x86_64_MacOSX7-unstripped/etc/condor_config';
remote.condor.yvespeysson.condor.PATH = '/Users/yvespeysson/Shared/Packages/Bin/HTCONDOR/condor-8.2.3-x86_64_MacOSX7-unstripped/sbin:/Users/yvespeysson/Shared/Packages/Bin/HTCONDOR/condor-8.2.3-x86_64_MacOSX7-unstripped/bin:${PATH}';
remote.condor.yvespeysson.remotedatapath = '/Users/yvespeysson/condor/';
remote.condor.yvespeysson.matver.mat800 = '/Applications/MATLAB_R2012b.app/bin/matlab';
remote.condor.yvespeysson.matver.mat801 = '/Applications/MATLAB_R2013a.app/bin/matlab';
remote.condor.yvespeysson.matver.mat803 = '/Applications/MATLAB_R2014a.app/bin/matlab';
remote.condor.yvespeysson.matver.mat804 = '/Applications/MATLAB_R2014b.app/bin/matlab';
remote.condor.yvespeysson.matver.mat805 = '/Applications/MATLAB_R2015a.app/bin/matlab';
remote.condor.yvespeysson.matver.mat806 = '/Applications/MATLAB_R2015b.app/bin/matlab';
remote.condor.yvespeysson.matver.mat900 = '/Applications/MATLAB_R2016a.app/bin/matlab';
remote.condor.yvespeysson.matver.matdef = remote.condor.yvespeysson.matver.mat900;%default matlab on remote machine
remote.condor.yvespeysson.remoteuser = 'yvespeysson';
remote.condor.yvespeysson.bridge.url.host = 'tolbachik.hd.free.fr:8081';%raspberry1 aix
remote.condor.yvespeysson.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%raspberry1 aix
remote.condor.yvespeysson.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%raspberry1 aix
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


    