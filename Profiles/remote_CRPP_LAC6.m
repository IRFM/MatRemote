function remote_profile = remote_CRPP_LAC6(varargin)
%
% This function regroups the remote profiles run on LAC5 at the CRPP
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'direct';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'decker';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% JOAN DECKER
%
% direct
%
remote.direct.decker = default_remote_profile;
remote.direct.decker.host = 'lac6.epfl.ch';
remote.direct.decker.hostname = 'crpppc94.epfl.ch';
remote.direct.decker.nproc = 20;%total 40 cpus, 2 nodes, 10 cores/node, 2 threads/core
remote.direct.decker.memtot = 96000;%total 192000 (4.8 gb/cpu)
remote.direct.decker.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.decker.remotedatapath = '/tmp/decker/';
remote.direct.decker.get_jobid = {};%str_before,str_after
remote.direct.decker.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.decker.matver.mat710 = '/usr/local/matlab710/bin/matlab';
% remote.direct.decker.matver.mat711 = '/usr/local/MATLAB/R2010b/bin/matlab';
% remote.direct.decker.matver.mat713 = '/usr/local/MATLAB/R2011b/bin/matlab';
% remote.direct.decker.matver.mat714 = '/usr/local/MATLAB/R2012a/bin/matlab';
remote.direct.decker.matver.mat800 = '/usr/local/MATLAB/R2012b/bin/matlab';
remote.direct.decker.matver.mat801 = '/usr/local/MATLAB/R2013a/bin/matlab';
remote.direct.decker.matver.mat803 = '/usr/local/MATLAB/R2014a/bin/matlab';
remote.direct.decker.matver.mat902.enforce = true;
remote.direct.decker.matver.mat902.cmd = '"/usr/local/MATLAB/R2017a/bin/matlab -c /etc/network.lic"';
remote.direct.decker.matver.matdef = remote.direct.decker.matver.mat803;%default matlab on remote machine
remote.direct.decker.remoteuser = 'decker';
remote.direct.decker.bridge.ssh.host = 'lac911.epfl.ch';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
