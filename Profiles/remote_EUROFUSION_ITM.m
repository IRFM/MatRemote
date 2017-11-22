function remote_profile = remote_EUROFUSION_ITM(varargin)
%
% This function regroups the remote profiles run on EUROFUSION cluster at CINECA (Italy)
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'pbs';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'g2yvesp';% default user profile if 'remoteuser' is not an existing user profile
%
% YVES PEYSSON
%
% direct
%
remote.direct.g2yvesp = default_remote_profile;
remote.direct.g2yvesp.host = 'login.eufus.eu';
remote.direct.g2yvesp.hostname = '@s';
remote.direct.g2yvesp.nproc = 10;
remote.direct.g2yvesp.cmd = {'bash','',' &',' &'};% direct calculation (csh, bash)
remote.direct.g2yvesp.get_jobid = {};%str_before,str_after
remote.direct.g2yvesp.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.g2yvesp.remotedatapath = '/afs/eufus.eu/user/g/g2yvesp/';
remote.direct.g2yvesp.matver.mat713 = '/gw/switm/matlab/matlab2011b/bin/matlab';
remote.direct.g2yvesp.matver.mat902 = '/gw/swvend/matlab/r2017a/bin/matlab';
remote.direct.g2yvesp.matver.matdef = remote.direct.g2yvesp.matver.mat902;%default matlab on remote machine
remote.direct.g2yvesp.remoteuser = 'g2yvesp';
remote.direct.g2yvesp.bridge.url.host = 'https://tolbachik.hd.free.fr';%nuc aix
remote.direct.g2yvesp.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%nuc aix
remote.direct.g2yvesp.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%nuc aix
%
% pbs
%
remote.pbs.g2yvesp = default_remote_profile;
remote.pbs.g2yvesp.host = 'login.eufus.eu';
remote.pbs.g2yvesp.hostname = '@s';
remote.pbs.g2yvesp.nproc = 10;
remote.pbs.g2yvesp.cmd = 'qsub ';% remote calculation with the pbs scheduler
remote.pbs.g2yvesp.shclean = 1;
remote.pbs.g2yvesp.get_jobid = {'','.r000u17l01'};%str_before,str_after
remote.pbs.g2yvesp.set_jobid = {'qstat ','.r000u17l01','Unknown Job Id',' C '};%str_before,str_after,str_check
remote.pbs.g2yvesp.remotedatapath = '/afs/eufus.eu/user/g/g2yvesp/';
remote.pbs.g2yvesp.matver.mat713 = '/gw/switm/matlab/matlab2011b/bin/matlab';
remote.pbs.g2yvesp.matver.mat902 = '/gw/swvend/matlab/r2017a/bin/matlab';
remote.pbs.g2yvesp.matver.matdef = remote.pbs.g2yvesp.matver.mat902;%default matlab on remote machine
remote.pbs.g2yvesp.remoteuser = 'g2yvesp';
remote.pbs.g2yvesp.bridge.url.host = 'https://tolbachik.hd.free.fr';%nuc aix
remote.pbs.g2yvesp.bridge.ftp.host = 'tolbachik.hd.free.fr:2121';%nuc aix
remote.pbs.g2yvesp.bridge.ssh.host = 'tolbachik.hd.free.fr:2222';%nuc aix
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
