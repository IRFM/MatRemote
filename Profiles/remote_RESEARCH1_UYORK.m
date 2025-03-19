function remote_profile = remote_RESEARCH1_UYORK(varargin)
%
% This function regroups the remote profiles run on the RESEARCH1 cluster (York University, UK)
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'direct';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'pll543';% default user profile if 'remoteuser' is not an existing user profile
%
default.filename = mfilename;%remote_xxx_yyy.m file name
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% direct
%
remote.direct.pll543 = default_remote_profile;
remote.direct.pll543.host = 'research1';%put external IP last in a list of IP addresses (shenma.ipp.ac.cn not accessible when login shenma)
remote.direct.pll543.hostname = 'research1';%
remote.direct.pll543.nproc = 16;
%remote.direct.pll543.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &',''};% direct calculation (csh, bash)
remote.direct.pll543.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.pll543.get_jobid = {};%sr_before,str_after
remote.direct.pll543.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.pll543.timeout = 10;
remote.direct.pll543.remotedatapath = '/tmp/';
remote.direct.pll543.matver.mat242 = '/usr/bin/matlab';%create executable bash script named mat903.sh with module purge;module load matlab/2017b;matlab "$@"
remote.direct.pll543.matver.matdef = remote.direct.pll543.matver.mat242;%default matlab on remote machine
remote.direct.pll543.remoteuser = 'pll543';
%
% JONATHAN CARROTTE 
%
remote.direct.rnf508 = remote.direct.pll543;
remote.direct.rnf508.host = 'research1';
remote.direct.rnf508.remoteuser = 'rnf508';
remote.direct.rnf508.remotedatapath = '/tmp';
%
% TOM WILSON
%
remote.direct.tw1723 = remote.direct.pll543;
remote.direct.tw1723.host = 'research1';
remote.direct.tw1723.remoteuser = 'tw1723';
remote.direct.tw1723.remotedatapath = '/tmp/';
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%