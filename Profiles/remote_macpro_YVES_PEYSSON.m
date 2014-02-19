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
default.profile = 'yves';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% direct
%
remote.direct.yves = default_remote_profile;
remote.direct.yves.host = 'tolbachik.hd.free.fr';
remote.direct.yves.hostname = 'macproyves';
remote.direct.yves.nproc = 6;
remote.direct.yves.cmd = 'bash';% direct calculation (csh, bash)
remote.direct.yves.get_jobid = {};%str_before,str_after
remote.direct.yves.set_jobid = {'ps -p ','','MATLAB'};%str_before,str_after,str_check
remote.direct.yves.matver.mat800.root = '/Applications/MATLAB_R2012b.app/bin/';
remote.direct.yves.matver.mat800.prefdir = '/Users/yvespeysson/.matlab/R2012b';
remote.direct.yves.matver.mat801.root = '/Applications/MATLAB_R2013a.app/bin/';
remote.direct.yves.matver.mat801.prefdir = '/Users/yvespeysson/.matlab/R2013a';
remote.direct.yves.matver.matdef = remote.direct.yves.matver.mat801;%default matlab on remote machine
remote.direct.yves.remoteuser = 'yvespeysson';
%
% condor
%
remote.condor.yves = default_remote_profile;
remote.condor.yves.host = 'tolbachik.hd.free.fr';
remote.condor.yves.hostname = 'macproyves';
remote.condor.yves.nproc = 6;
remote.condor.yves.cmd = 'condor_submit';
remote.condor.yves.get_jobid = {'** Proc ',':'};
remote.condor.yves.set_jobid = {'condor_q ',''};
remote.condor.yves.condor.CONDOR_CONFIG = '/usr/local/condor/etc/condor_config';
remote.condor.yves.condor.PATH = '/usr/local/condor/sbin:/usr/local/condor/bin:${PATH}';
remote.condor.yves.remotedatapath = '/Users/yvespeysson/condor/';
remote.condor.yves.matver.mat800.root = '/Applications/MATLAB_R2012b.app/bin/';
remote.condor.yves.matver.mat800.prefdir = '/Users/yvespeysson/.matlab/R2012b';
remote.condor.yves.matver.mat801.root = '/Applications/MATLAB_R2013a.app/bin/';
remote.condor.yves.matver.mat801.prefdir = '/Users/yvespeysson/.matlab/R2013a';
remote.condor.yves.matver.matdef = remote.condor.yves.matver.mat801;%default matlab on remote machine
remote.condor.yves.remoteuser = 'yvespeysson';
remote.condor.yves.bridge.url.host = 'tolbachik.hd.free.fr';
remote.condor.yves.bridge.url.path = '~yvespeysson/MatRemote';
remote.condor.yves.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.condor.yves.bridge.ftp.username = 'matremote';
remote.condor.yves.bridge.ftp.password = 'Rq59G4zzPSzZNC9LFMdTK';
%
% xgrid
%
% WARNING about Xgrid scheduler for mac OSX (> 10.5.x)
% Xgrid runs tasks using the "sandbox" facility. Tasks running as 'nobody' ie, 
% any task where either the submitting client or the receiving agent 
% are NOT using Kerberos authentication) have very restricted access to the
% filesystem. To by-pass this strong protection (no password) on a local
% cluster or a multi-core multi-processor machine, go to
% /usr/share/sandbox/xgridagentd_task_nobody.sb file (root rights needed)
% then, comment the following line (with a ';' at the beginning of the line):
% (allow process* sysctl* mach* network* system-socket)
% and replace it by
% (allow process* sysctl* mach* file-read* file-write* network* system-socket)
% omment the following lines (with a ';' at the beginning of the line):
% (allow file-read* (regex "^/(bin|dev|(private/)?(etc|tmp|var)|usr|System|Library)(/|$)"))
% (allow file-read* file-write* (regex "^/(private/)?(tmp|var)(/|$)"))
% and replace it by
% (allow file-read* file-write* (regex "^/all(/|$)"))
%
% NOTE that it should be done each time the system is updated.
% furthermore, all *.m and *.mex* files must be read by anybody.
% This lack of protection make the cluster more vulnerable to an external
% attack, but on a personal computer, this risk is limited.
%
% Furthermore, on the remote session, before any calculation, it is
% necessary to create a folder named 'xgrid' (~/xgrid)
% that will contain all the files for the remote calculations. The owner is the
% USER , and the group is 'nobody(-2)'. The rights are 777. It is also
% necessary to done it the same for the Matlab_R20xx_y application (all the
% package and inside) in such a way Matlab can write in the ~/xgrid folder.
%
% The IP address of the hostname must be given in the file /etc/hosts
%
% WARNING: most of the problems come from the SSH without login
% authentication, rights of the target directory and Matlab !
%
% YVES PEYSSON
%
remote.xgrid.yves = default_remote_profile;
remote.xgrid.yves.host = 'tolbachik.hd.free.fr';
remote.xgrid.yves.hostname = 'macproyves';
remote.xgrid.yves.nproc = 6;
remote.xgrid.yves.cmd = {'xgrid -h ',' -p ',' -job batch '};
remote.xgrid.yves.get_jobid = {'jobIdentifier = ',';'};
remote.xgrid.yves.set_jobid = {'xgrid -h ',' -job attributes -id ','jobStatus = Running','jobStatus = Pending','jobStatus = Finished',' -job results -id ',' -se ',' -so ',' -out ',' -job delete -id '};%
remote.xgrid.yves.remotedatapath = '/Users/yvespeysson/xgrid/';
remote.xgrid.yves.matver.mat800.root = '/Applications/MATLAB_R2012b.app/bin/';
remote.xgrid.yves.matver.mat800.prefdir = '/Users/yvespeysson/.matlab/R2012b';
remote.xgrid.yves.matver.mat801.root = '/Applications/MATLAB_R2013a.app/bin/';
remote.xgrid.yves.matver.mat801.prefdir = '/Users/yvespeysson/.matlab/R2013a';
remote.xgrid.yves.matver.matdef = remote.xgrid.yves.matver.mat801;%default matlab on remote machine
remote.xgrid.yves.remoteuser = 'yvespeysson';%'joandecker';
remote.xgrid.yves.bridge.url.host = 'tolbachik.hd.free.fr';
remote.xgrid.yves.bridge.url.path = '~yvespeysson/MatRemote';
remote.xgrid.yves.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.xgrid.yves.bridge.ftp.username = 'matremote';
remote.xgrid.yves.bridge.ftp.password = 'Rq59G4zzPSzZNC9LFMdTK';
%
% JOAN DECKER
%
% condor
%
remote.condor.joan = remote.condor.yves;% same remote user, same options
%
% xgrid
%
remote.xgrid.joan = remote.xgrid.yves;% same remote user, same options
%
% EMELIE NILSSON
%
% condor
%
remote.condor.emelie = remote.condor.yves;% same remote user, same options
%
% xgrid
%
remote.xgrid.emelie = remote.xgrid.yves;% same remote user, same options
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%


    