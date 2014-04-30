function remote_profile = remote_EFDA_ITM(varargin)
%
% This function regroups the remote profiles run on the european EFDA ITM cluster
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'sge';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'yvesp';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% YVES PEYSSON
%
% sun grid engine (sge)
%
remote.sge.yvesp = default_remote_profile;
remote.sge.yvesp.host = 'g01.efda-itm.eu';
remote.sge.yvesp.hostname = 'itm.rzg.mpg.de';
remote.sge.yvesp.usermail = 'ypeysson@free.fr';
remote.sge.yvesp.shell = 'bash';
remote.sge.yvesp.nproc = 16;% limited to two jobs per PBS node to avoid cluster saturation
remote.sge.yvesp.wait = 0;% invalid option
remote.sge.yvesp.nodes = [];% invalid option
remote.sge.yvesp.ncpus = [];% invalid option
remote.sge.yvesp.memory = [2000,15000];% default/max values
remote.sge.yvesp.walltime = [];% invalid option
remote.sge.yvesp.cmd = 'qsub';%
remote.sge.yvesp.sge.batchscript_params1 = {'module load itmenv'};
remote.sge.yvesp.sge.batchscript_params2 = {'source $ITMSCRIPTDIR/ITMv1.sh kepler test 4.09a'};%Call to UAL release 4.09a
%remote.sge.yvesp.sge.batchscript_params2 = {'source $ITMSCRIPTDIR/ITMv1.sh kepler test 4.10a'};%Call to UAL release 4.10a
remote.sge.yvesp.remotedatapath = '/pfs/home/yvesp/tmp/';
remote.sge.yvesp.get_jobid = {'Your job ',' '};%str_before,str_after
remote.sge.yvesp.set_jobid = {'qstat -j ','','jobs do not exist'};%str_before,str_after,str_check
remote.sge.yvesp.matver.mat800 = '/afs/ipp/common/soft/matlab_2012b/bin/matlab import_ual';%for UAL 
remote.sge.yvesp.matver.matdef = remote.sge.yvesp.matver.mat800;%default matlab on remote machine
remote.sge.yvesp.remoteuser = 'yvesp';
remote.sge.yvesp.bridge.url.host = 'tolbachik.hd.free.fr';
remote.sge.yvesp.bridge.ftp.host = 'tolbachik.hd.free.fr';
%
% direct
%
remote.direct.yvesp = default_remote_profile;
remote.direct.yvesp.host = 'g01.efda-itm.eu';
remote.direct.yvesp.hostname = 'itm.rzg.mpg.de';
remote.direct.yvesp.nproc = 16;
%remote.direct.yvesp.cmd = {'bash','nohup ',' `</dev/null` >nohup.out 2>&1 &',''};% direct calculation (csh, bash). Note the Call to UAL release is done in the .bashrc file
remote.direct.yvesp.cmd = {'bash','',' &',''};% direct calculation (csh, bash). Note the Call to UAL release is done in the .bashrc file
remote.direct.yvesp.get_jobid = {};%str_before,str_after
remote.direct.yvesp.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.yvesp.matver.mat800 = '/afs/ipp/common/soft/matlab_2012b/bin/matlab import_ual';%for UAL
remote.direct.yvesp.matver.matdef = remote.direct.yvesp.matver.mat800;%default matlab on remote machine
remote.direct.yvesp.remoteuser = 'yvesp';
remote.direct.yvesp.bridge.url.host = 'tolbachik.hd.free.fr';
remote.direct.yvesp.bridge.ftp.host = 'tolbachik.hd.free.fr';
%
% JOAN DECKER
%
remote.sge.joan = remote.sge.yvesp;
remote.direct.joan = remote.direct.yvesp;
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
