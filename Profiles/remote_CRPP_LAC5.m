function remote_profile = remote_CRPP_LAC5(varargin)
%
% This function regroups the remote profiles run on PC82 at the CRPP
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
remote.direct.decker.host = 'lac5.epfl.ch';
remote.direct.decker.hostname = 'crpppc401';
remote.direct.decker.nproc = 24;
remote.direct.decker.cmd = {'bash',' &'};% direct calculation (csh, bash)
remote.direct.decker.get_jobid = {};%str_before,str_after
remote.direct.decker.set_jobid = {'ps -p ',' -o comm=','MATLAB'};%str_before,str_after,str_check
remote.direct.decker.matver.mat710.root = '/usr/local/matlab710/bin/';
remote.direct.decker.matver.mat710.prefdir = '/home/decker/.matlab/R2010a';
remote.direct.decker.matver.mat711.root = '/usr/local/MATLAB/R2010b/bin/';
remote.direct.decker.matver.mat711.prefdir = '/home/decker/.matlab/R2010b';
remote.direct.decker.matver.mat713.root = '/usr/local/MATLAB/R2011b/bin/';
remote.direct.decker.matver.mat713.prefdir = '/home/decker/.matlab/R2011b';
remote.direct.decker.matver.mat714.root = '/usr/local/MATLAB/R2012a/bin/';
remote.direct.decker.matver.mat714.prefdir = '/home/decker/.matlab/R2012a';
remote.direct.decker.matver.mat800.root = '/usr/local/MATLAB/R2012b/bin/';
remote.direct.decker.matver.mat800.prefdir = '/home/decker/.matlab/R2012b';
remote.direct.decker.matver.mat801.root = '/usr/local/MATLAB/R2013a/bin/';
remote.direct.decker.matver.mat801.prefdir = '/home/decker/.matlab/R2013a';
remote.direct.decker.matver.matdef = remote.direct.decker.matver.mat801;%default matlab on remote machine
remote.direct.decker.remoteuser = 'decker';
%
%
% --------------------------------------------------
%
% JOSEF KAMLEITNER
%
% direct
%
remote.direct.kamleitn = remote.direct.decker;
remote.direct.kamleitn.matver.mat710.prefdir = '/home/kamleitn/.matlab/R2010a';
remote.direct.kamleitn.matver.mat711.prefdir = '/home/kamleitn/.matlab/R2010b';
remote.direct.kamleitn.matver.mat713.prefdir = '/home/kamleitn/.matlab/R2011b';
remote.direct.kamleitn.matver.mat714.prefdir = '/home/kamleitn/.matlab/R2012a';
remote.direct.kamleitn.matver.mat800.prefdir = '/home/kamleitn/.matlab/R2012b';
remote.direct.kamleitn.matver.mat801.prefdir = '/home/kamleitn/.matlab/R2013a';
remote.direct.kamleitn.matver.matdef = remote.direct.kamleitn.matver.mat801;%default matlab on remote machine
remote.direct.kamleitn.remoteuser = 'kamleitn';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
remote_profile = select_remote_profile_jd(remote,default,varargin{:});
%
