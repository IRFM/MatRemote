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
default.scheduler = 'sun';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'yvesp';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% YVES PEYSSON
%
remote.sun.yvesp = default_remote_profile;
remote.sun.yvesp.host = 'g04.efda-itm.eu';
remote.sun.yvesp.hostname = 'itm.rzg.mpg.de';
remote.sun.yvesp.nproc = 16;% limited to two jobs per PBS node to avoid cluster saturation
remote.sun.yvesp.wait = 0;% invalid option
remote.sun.yvesp.nodes = NaN;% invalid option
remote.sun.yvesp.ncpus = NaN;% invalid option
remote.sun.yvesp.memory = NaN;% invalid option
remote.sun.yvesp.walltime = NaN;% invalid option
remote.sun.yvesp.cmd = 'qsub ';% 
remote.sun.yvesp.remotedatapath = '/tmp/';
remote.sun.yvesp.get_jobid = {'Your job ',' '};%str_before,str_after
remote.sun.yvesp.set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
remote.sun.yvesp.matver.mat800.root = '/afs/ipp/common/soft/matlab_2012b/bin/';
remote.sun.yvesp.matver.mat800.prefdir = '/pfs/home/yvesp/.matlab/R2012b';%warning /pfs/home/ must replace /u/
remote.sun.yvesp.matver.matdef = remote.sun.yvesp.matver.mat800;%default matlab on remote machine
remote.sun.yvesp.cvs.CVSROOT = ':pserver:YP105119:Peys#4Yv@altair.partenaires.cea.fr:/usr/local/cvs/gcgc';%CVS root for LUKE
remote.sun.yvesp.cvs.cmd = 'update -d';%CVS command
remote.sun.yvesp.luke_root = '/pfs/home/yvesp/public/LUKE_ITM/trunk/LUKE/';%warning /pfs/home/ must replace /u/
remote.sun.yvesp.remoteuser = 'yvesp';
%
% JOAN DECKER
%
remote.sun.joan = remote.sun.yvesp;
remote.sun.joan.luke_root = '/pfs/home/yvesp/joandecker/LUKE/';%warning /pfs/home/ must replace /u/
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
