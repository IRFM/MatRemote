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
remote.direct.yvespeysson.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &'};% direct calculation (csh, bash)
remote.direct.yvespeysson.get_jobid = {};%str_before,str_after
remote.direct.yvespeysson.set_jobid = {'ps -p ','','MATLAB'};%str_before,str_after,str_check
remote.direct.yvespeysson.remotedatapath = '/Users/yvespeysson/';
remote.direct.yvespeysson.matver.mat800 = '/Applications/MATLAB_R2012b.app/bin/matlab';
remote.direct.yvespeysson.matver.mat801 = '/Applications/MATLAB_R2013a.app/bin/matlab';
remote.direct.yvespeysson.matver.mat803 = '/Applications/MATLAB_R2014a.app/bin/matlab';
remote.direct.yvespeysson.matver.matdef = remote.direct.yvespeysson.matver.mat801;%default matlab on remote machine
remote.direct.yvespeysson.remoteuser = 'yvespeysson';
remote.direct.yvespeysson.bridge.url.host = 'tolbachik.hd.free.fr';
remote.direct.yvespeysson.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.direct.yvespeysson.bridge.ssh.host = 'tolbachik.hd.free.fr';
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
remote.condor.yvespeysson.condor.CONDOR_CONFIG = '/usr/local/condor/etc/condor_config';
remote.condor.yvespeysson.condor.PATH = '/usr/local/condor/sbin:/usr/local/condor/bin:${PATH}';
remote.condor.yvespeysson.remotedatapath = '/Users/yvespeysson/condor/';
remote.condor.yvespeysson.matver.mat800 = '/Applications/MATLAB_R2012b.app/bin/matlab';
remote.condor.yvespeysson.matver.mat801 = '/Applications/MATLAB_R2013a.app/bin/matlab';
remote.condor.yvespeysson.matver.mat803 = '/Applications/MATLAB_R2014a.app/bin/matlab';
remote.condor.yvespeysson.matver.matdef = remote.condor.yvespeysson.matver.mat801;%default matlab on remote machine
remote.condor.yvespeysson.remoteuser = 'yvespeysson';
remote.condor.yvespeysson.bridge.url.host = 'tolbachik.hd.free.fr';
remote.condor.yvespeysson.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.condor.yvespeysson.bridge.ssh.host = 'tolbachik.hd.free.fr';
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
remote.xgrid.yvespeysson = default_remote_profile;
remote.xgrid.yvespeysson.host = 'tolbachik.hd.free.fr';
remote.xgrid.yvespeysson.hostname = 'macproyves';
remote.xgrid.yvespeysson.nproc = 6;
remote.xgrid.yvespeysson.cmd = {'xgrid -h ',' -p ',' -job batch '};
remote.xgrid.yvespeysson.get_jobid = {'jobIdentifier = ',';'};
remote.xgrid.yvespeysson.set_jobid = {'xgrid -h ',' -job attributes -id ','jobStatus = Running','jobStatus = Pending','jobStatus = Finished',' -job results -id ',' -se ',' -so ',' -out ',' -job delete -id '};%
remote.xgrid.yvespeysson.remotedatapath = '/Users/yvespeysson/xgrid/';
remote.xgrid.yvespeysson.startuppath = '/Users/yvespeysson/Documents/MATLAB';%path to add for matlab startup
remote.xgrid.yvespeysson.matver.mat800 = '/Applications/MATLAB_R2012b.app/bin/matlab';
remote.xgrid.yvespeysson.matver.mat801 = '/Applications/MATLAB_R2013a.app/bin/matlab';
remote.xgrid.yvespeysson.matver.mat803 = '/Applications/MATLAB_R2014a.app/bin/matlab';
remote.xgrid.yvespeysson.matver.matdef = remote.xgrid.yvespeysson.matver.mat801;%default matlab on remote machine
remote.xgrid.yvespeysson.remoteuser = 'yvespeysson';%'joandecker';
remote.xgrid.yvespeysson.bridge.url.host = 'tolbachik.hd.free.fr';
remote.xgrid.yvespeysson.bridge.ftp.host = 'tolbachik.hd.free.fr';
remote.xgrid.yvespeysson.bridge.ssh.host = 'tolbachik.hd.free.fr';
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
% xgrid
%
remote.xgrid.joan = remote.xgrid.yvespeysson;% same remote user, same options
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%


    