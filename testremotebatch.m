%
% test for remote batch using a standard function.
%
% by J. Decker, Y. Peysson and M. Schneider (CEA/IRFM)   
%
clear all
%
remnum = -4;%remote profile number : (-1,-2,-3) local parameters (for testing new profile)
%                                   (1,2,3,...) profile number in dkepath.remote
%
if remnum > 0,
    %
    dkepath = load_structures_yp('dkepath','','');
    remote = dkepath.remote(remnum);
    %
elseif remnum == -1,
    %
    % local or ssh run on cephee with qsub
    %
    remote.host = 'cephee15.intra.cea.fr';%'';%
    remote.cmd = 'qsub -l inter=false';
    remote.get_jobid = {'','.cephee'};
    remote.set_jobid = {'qstat ','.cephee','Unknown Job Id'};
    %
    remote.joan = 'JD211098';
    remote.yves = 'YP105119';
    %
    % the following rules might be common to all PBS calls - to be checked
    %
    %remote.res = {',ncpus=',''};
    %remote.wall = {'walltime=',''};
    %remote.mem = {',mem=','mb'};
    %
elseif remnum == -2,
    %
    % ssh run on saturne with qsub
    %
    remote.host = 'saturne1.partenaires.cea.fr';
    remote.cmd = 'qsub -q batch.q';
    remote.get_jobid = {'Your job ',' '};
    remote.set_jobid = {'qstat -j ','','Following jobs do not exist'};
    %
    remote.joan = 'JD211098';
    %
    % the following rules might be common to all PBS calls - to be checked
    %
    %remote.res = {',ncpus=',''};
    %remote.wall = {'walltime=',''};
    %remote.mem = {',mem=','mb'};
    %
elseif remnum == -3,
    %
    % local run on yves laptop with condor
    %
    remote.host = '';
    remote.cmd = 'condor_submit';
    remote.get_jobid = {'** Proc ',':'};
    remote.set_jobid = {'condor_q ',''};
    %
    remote.env.CONDOR_CONFIG = '/usr/local/condor/etc/condor_config';
    remote.env.PATH = '/usr/local/condor/sbin:/usr/local/condor/bin:${PATH}';
    %
elseif remnum == -4,
    %
    % local run on yves laptop with condor
    %
    remote.host = 'tolbachik.hd.free.fr';
    remote.cmd = 'condor_submit';
    remote.get_jobid = {'** Proc ',':'};
    remote.set_jobid = {'condor_q ',''};
    %
    remote.env.CONDOR_CONFIG = '/usr/local/condor/etc/condor_config';
    remote.env.PATH = '/usr/local/condor/sbin:/usr/local/condor/bin:${PATH}';
    remote.env.remotebatch_matlabroot = '/Applications/MATLAB_R2012a.app/bin/';
    %
    remote.yves = 'yvespeysson';
    %
end
%
remotehome = reminstall(remote);
%
pbssearch = ~iscell(remote.cmd) && ~isempty(strfind(remote.cmd,'qsub'));
%condorsearch = iscell(remote.cmd) && any(~cellfun('isempty',strfind(remote.cmd,'condor')));
condorsearch = ~iscell(remote.cmd) && ~isempty(strfind(remote.cmd,'condor'));
xgridsearch = iscell(remote.cmd) && any(~cellfun('isempty',strfind(remote.cmd,'xgrid')));
%
if condorsearch + xgridsearch + pbssearch ~= 1,
    error('scheduler type identification problem')
end
if pbssearch,
    test_job.script = [remotehome,'/remotebatchtest/bin/remotebatch'];% script to be run by scheduler on remote cluster
elseif condorsearch,
    test_job.script = [remotehome,'/remotebatchtest/bin/condor_matlab.sh'];% script to be run by scheduler on remote cluster
elseif xgridsearch,
    %***TODO***
end
%
test_job.savefcn = 'matstandardsave';% function saving the data locally 
test_job.loadfcn = 'matstandardload';% function reading the data locally
test_job.localdatapath = 'data/';%'';%forder where local data is stored - leave empty for local data folder
test_job.remotedatapath = [remotehome,'/remotebatchtest/run'];%'';%folder where remote data is stored
test_job.env.remotebatch_matlabroot = '';%  path to matlab (optional)
test_job.env.remotebatch_path = [remotehome,'/remotebatchtest/mat/']; % matlab path for remotetest.m (to test path transfer)
%
if isempty(test_job.env.remotebatch_matlabroot) && isfield(remote,'env') && isfield(remote.env,'remotebatch_matlabroot')
    test_job.env.remotebatch_matlabroot = remote.env.remotebatch_matlabroot;
end
%
test_job.wait = 1;%0;% (0) return hand (1) wait for result
test_job.nodes = 1;%number of nodes required
test_job.nproc = 2;%number of cores required
test_job.memory = 2000;% memory required (in mb) - leave empty if no requirement
test_job.walltime = 1;%[];% time required (integers - in hours) - leave empty if no requirement
%
test_job.env.TESTVAR = 'luke'; % test variable
%
sinput.strin = 'The best code is : ';
%
time_step = 1;
nit = 60;
%
displaymode = 1;
%
test_job = remoterunbatch(remote,test_job,sinput,displaymode);
%
for it = 1:nit,
    %
    pause(time_step)
    %
    soutput = remotegetbatch(remote,test_job,displaymode);
    %
    if ~isempty(soutput),
        break
    end
end
%
if isfield(soutput,'err'),
    %
    % failed test
    %
    disp('The remote run failed : ');
    if ~iscell(soutput.err),
        disp(soutput.err)
    else
        for ierr = 1:length(soutput.err),
            disp(soutput.err{ierr})
        end
    end
elseif isfield(soutput,'strout'),
    %
    % result - should read 'The best code is : luke - running under matlab version : ', followed by the requested remote matlab version
    %
    disp(soutput.strout)
    %
else
    %
    % failed test
    %
    disp('The remote run failed for unknown reasons');
end
%


