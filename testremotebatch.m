%
% test for remote batch using a standard function.
%
% by J. Decker, Y. Peysson and M. Schneider (CEA/IRFM)   
%
clear all
%
remnum = -4;%1;%remote profile number : (-1,-2,-3) local parameters (for testing new profile)
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
    % local run on yves laptop or macpro yvespeysson with condor
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
    % remote run on yves desktop with condor
    % commented lines not needed here but for LUKE
    %
    remote.host = 'tolbachik.hd.free.fr';
    remote.cmd = 'condor_submit';
    remote.get_jobid = {'** Proc ',':'};
    remote.set_jobid = {'condor_q ',''};
    %remote.remotedatapath = '/Users/yvespeysson/condor/';
    %
    remote.env.CONDOR_CONFIG = '/usr/local/condor/etc/condor_config';
    remote.env.PATH = '/usr/local/condor/sbin:/usr/local/condor/bin:${PATH}';
    %
    %remote.mat714.root = '/Applications/MATLAB_R2012a.app/bin/';
    %remote.mat714.prefdir = '/Users/yvespeysson/.matlab/R2012a';
    %remote.matdef = remote.mat714;%default matlab on remote machine
    %
    remote.mat800.root = '/Applications/MATLAB_R2012a.app/bin/';
    remote.mat800.prefdir = '/Users/yvespeysson/.matlab/R2012a';
    remote.matdef = remote.mat800;%default matlab on remote machine
    %
    %remote.luke_root = '/Users/yvespeysson/joandecker/Work/LUKE_1_10/';
    %
    remote.yves = 'yvespeysson';
    remote.joan = 'yvespeysson';
    remote.JD211098 = 'yvespeysson';
    %
elseif remnum == -5,
    %
    % remote run on yvespeysson desktop with xgrid 
    % commented lines not needed here but for LUKE
    %
    remote.host = 'tolbachik.hd.free.fr';
    remote.cmd = {'xgrid -h ',' -p ',' -job batch '};%
    remote.get_jobid = {'jobIdentifier = ',';'};%
    remote.set_jobid = {'xgrid -h ',' -job attributes -id ','jobStatus = Running','jobStatus = Pending','jobStatus = Finished',' -job results -id ',' -se ',' -so ',' -out ',' -job delete -id '};%
    %remote.remotedatapath = '/Users/yvespeysson/xgrid/';
    %
    %remote.mat714.root = '/Applications/MATLAB_R2012a.app/bin/';
    %remote.mat714.prefdir = '/Users/yvespeysson/.matlab/R2012a';
    %remote.matdef = remote.mat714;%default matlab on remote machine
    %
    remote.mat800.root = '/Applications/MATLAB_R2012b.app/bin/';
    remote.mat800.prefdir = '/Users/yvespeysson/.matlab/R2012b';
    remote.matdef = remote.mat800;%default matlab on remote machine
    %
    %remote.luke_root = '/Users/yvespeysson/joandecker/Work/LUKE_1_10/';
    %
    remote.password = {'ghm93'};
    remote.yves = 'yvespeysson';
    remote.joan = 'yvespeysson';
    %
end
%
remotehome = reminstall(remote);
%
test_job.script = [remotehome,'/remotebatchtest/bin/matlabbatch.sh'];% script to be run by scheduler on remote cluster
test_job.savefcn = 'matstandardsave';% function saving the data locally 
test_job.loadfcn = 'matstandardload';% function reading the data locally
test_job.localdatapath = 'data/';%'';%forder where local data is stored - leave empty for local data folder
test_job.remotedatapath = [remotehome,'/remotebatchtest/run'];%'';%folder where remote data is stored
test_job.env.remotebatch_path = [remotehome,'/remotebatchtest/mat/']; % matlab path for remotetest.m (to test path transfer)
test_job.env.remotematfnc = 'remotetest'; % remote matlab function to be called
%
test_job.wait = 1;%0;% (0) return hand (1) wait for result
test_job.nodes = 1;%number of nodes required
test_job.nproc = 2;%number of cores required
test_job.memory = 2000;% memory required (in mb) - leave empty if no requirement
test_job.walltime = 1;%[];% time required (integers - in hours) - leave empty if no requirement
%
test_job.env.TESTVAR = 'luke'; % test variable
test_job.debugmode = 1;
%
sinput.strin = 'The best code is : ';
%
remote.rempause = 1/60;% in minutes
remote.remtimout = 5;% in minutes
%
displaymode = 1;
%
test_job = remoterunbatch(remote,test_job,sinput,displaymode);
%
if isfield(test_job,'err'),
    soutput = test_job.err;
else
    soutput = remotegetbatch(remote,test_job,displaymode,0);
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


