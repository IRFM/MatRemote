function remote_profile = remote_CEA_SATURNE(varargin)
%
% This function regroups the remote profiles run on the SATURNE cluster
%
%   INPUTS : 
%       - schedulername (optinal) : name of selected scheduler
%       - profilename (optinal) : name of selected profile
%
%   OUTPUTS : 
%       - remote_profile : name of selected remote profile(s)
%
default.scheduler = 'sun';% default scheduler profile if 'schedulername' is not an existing scheduler profile
default.profile = 'joan';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% saturne (sun batch system)
%
%
% JOAN DECKER
%
remote.sun.joan = default_remote_profile;
remote.sun.joan.host = 'saturne3.partenaires.cea.fr';% empty for local host
remote.sun.joan.hostname = 'saturne';
remote.sun.joan.nproc = 12;% limited to two jobs per PBS node to avoid cluster saturation
remote.sun.joan.wait = 0;% invalid option
remote.sun.joan.nodes = NaN;% invalid option
remote.sun.joan.ncpus = NaN;% invalid option
remote.sun.joan.memory = NaN;% invalid option
remote.sun.joan.walltime = NaN;% invalid option
remote.sun.joan.cmd = 'qsub -q batch.q';% 
remote.sun.joan.get_jobid = {'Your job ',' '};%str_before,str_after
remote.sun.joan.set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
remote.sun.joan.matver.mat705.root = '/usr/local/matlab7/bin/';
remote.sun.joan.matver.mat705.prefdir = '/home/JD211098/.matlab/R2007b';
remote.sun.joan.matver.matdef = remote.sun.joan.matver.mat705;%default matlab on remote machine
remote.sun.joan.remoteuser = 'JD211098';
%
% YVES PEYSSON
%
remote.sun.yves = default_remote_profile;
remote.sun.yves.host = 'saturne3.partenaires.cea.fr';
remote.sun.yves.hostname = 'saturne';
remote.sun.yves.nproc = 12;% limited to two jobs per PBS node to avoid cluster saturation
remote.sun.yves.wait = 0;% invalid option
remote.sun.yves.nodes = NaN;% invalid option
remote.sun.yves.ncpus = NaN;% invalid option
remote.sun.yves.memory = NaN;% invalid option
remote.sun.yves.walltime = NaN;% invalid option
remote.sun.yves.cmd = 'qsub -q batch.q';% 
remote.sun.yves.get_jobid = {'Your job ',' '};%str_before,str_after
remote.sun.yves.set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
remote.sun.yves.matver.mat705.root = '/usr/local/matlab7/bin/';
remote.sun.yves.matver.mat705.prefdir = '/home/YP105119/.matlab/R2007b';
remote.sun.yves.matver.matdef = remote.sun.yves.matver.mat705;%default matlab on remote machine
remote.sun.yves.remoteuser = 'YP105119';
remote.sun.yves.bridge.url.host = 'tolbachik.hd.free.fr';
remote.sun.yves.bridge.ftp.host = 'tolbachik.hd.free.fr';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
