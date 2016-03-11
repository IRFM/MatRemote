function remote_profile = remote_laptop_GUILLAUME_BROCHARD(varargin)
%
% This function regroups the remote profiles run on the MACPRO of Guillaume Brochard
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'condor';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'guillaumebrochard';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% GUILLAUME_BROCHARD
%
% direct
%
remote.direct.guillaumebrochard = default_remote_profile;
remote.direct.guillaumebrochard.host = '127.0.0.1';
remote.direct.guillaumebrochard.hostname = 'macbookguillaume';
remote.direct.guillaumebrochard.nproc = 4;
remote.direct.guillaumebrochard.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &'};% direct calculation (csh, bash)
remote.direct.guillaumebrochard.get_jobid = {};%str_before,str_after
remote.direct.guillaumebrochard.set_jobid = {'ps -p ','','MATLAB'};%str_before,str_after,str_check
remote.direct.guillaumebrochard.remotedatapath = '/Users/guillaumebrochard/';
remote.direct.guillaumebrochard.matver.mat805 = '/Applications/MATLAB_R2015a.app/bin/matlab';
remote.direct.guillaumebrochard.matver.mat806 = '/Applications/MATLAB_R2015b.app/bin/matlab';
remote.direct.guillaumebrochard.matver.matdef = remote.direct.guillaumebrochard.matver.mat805;%default matlab on remote machine
remote.direct.guillaumebrochard.remoteuser = 'guillaumebrochard';
%
% condor
%
remote.condor.guillaumebrochard = default_remote_profile;
remote.condor.guillaumebrochard.host = '127.0.0.1';
remote.condor.guillaumebrochard.hostname = 'macbookguillaume';
remote.condor.guillaumebrochard.nproc = 4;
remote.condor.guillaumebrochard.cmd = 'condor_submit';
remote.condor.guillaumebrochard.get_jobid = {'** Proc ',':'};
remote.condor.guillaumebrochard.set_jobid = {'condor_q ',''};
remote.condor.guillaumebrochard.condor.CONDOR_CONFIG = '/Users/guillaumebrochard/Packages/Bin/HTCONDOR/condor-8.5.1-x86_64_MacOSX7-stripped/etc/condor_config';
remote.condor.guillaumebrochard.condor.PATH = '/Users/guillaumebrochard/Packages/Bin/HTCONDOR/condor-8.5.1-x86_64_MacOSX7-stripped/sbin:/Users/guillaumebrochard/Packages/Bin/HTCONDOR/condor-8.5.1-x86_64_MacOSX7-stripped/bin:${PATH}';
remote.condor.guillaumebrochard.remotedatapath = '/Users/guillaumebrochard/condor/';
remote.condor.guillaumebrochard.matver.mat805 = '/Applications/MATLAB_R2015a.app/bin/matlab';
remote.condor.guillaumebrochard.matver.mat806 = '/Applications/MATLAB_R2015b.app/bin/matlab';
remote.condor.guillaumebrochard.matver.matdef = remote.condor.guillaumebrochard.matver.mat805;%default matlab on remote machine
remote.condor.guillaumebrochard.remoteuser = 'guillaumebrochard';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
    