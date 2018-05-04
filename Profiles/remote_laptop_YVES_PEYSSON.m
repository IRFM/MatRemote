function remote_profile = remote_laptop_YVES_PEYSSON(varargin)
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
default.profile = 'yves';% default user profile if 'remoteuser' is not an existing user profile
%
default.filename = mfilename;%remote_xxx_yyy.m file name
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% direct
%
remote.direct.yves = default_remote_profile;
remote.direct.yves.host = '127.0.0.1';
remote.direct.yves.hostname = 'macbookyves';
remote.direct.yves.nproc = 4;
remote.direct.yves.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &'};% direct calculation (csh, bash)
remote.direct.yves.get_jobid = {};%str_before,str_after
remote.direct.yves.set_jobid = {'ps -p ','','MATLAB'};%str_before,str_after,str_check
remote.direct.yves.remotedatapath = '/Users/yves/';
remote.direct.yves.matver.mat903 = '/Applications/MATLAB_R2017a.app/bin/matlab';
remote.direct.yves.matver.mat904 = '/Applications/MATLAB_R2018a.app/bin/matlab';
remote.direct.yves.matver.matdef = remote.direct.yves.matver.mat904;%default matlab on remote machine
remote.direct.yves.remoteuser = 'yves';
%
% condor
%
remote.condor.yves = default_remote_profile;
remote.condor.yves.host = '127.0.0.1';
remote.condor.yves.hostname = 'macbookyves';
remote.condor.yves.nproc = 4;
remote.condor.yves.cmd = 'condor_submit';
remote.condor.yves.get_jobid = {'** Proc ',':'};
remote.condor.yves.set_jobid = {'condor_q ',''};
remote.condor.yves.condor.CONDOR_CONFIG = '/Users/yves/Travail/Projets/Packages/Bin/HTCONDOR/condor-8.2.3-x86_64_MacOSX7-unstripped/etc/condor_config';
remote.condor.yves.condor.PATH = '/Users/yves/Travail/Projets/Packages/Bin/HTCONDOR/condor-8.2.3-x86_64_MacOSX7-unstripped/sbin:/Users/yves/Travail/Projets/Packages/Bin/HTCONDOR/condor-8.2.3-x86_64_MacOSX7-unstripped/bin:${PATH}';
remote.condor.yves.remotedatapath = '/Users/yves/condor/';
remote.condor.yves.matver.mat903 = '/Applications/MATLAB_R2017b.app/bin/matlab';
remote.condor.yves.matver.mat904 = '/Applications/MATLAB_R2018a.app/bin/matlab';
remote.condor.yves.matver.matdef = remote.condor.yves.matver.mat904;%default matlab on remote machine
remote.condor.yves.remoteuser = 'yves';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
    