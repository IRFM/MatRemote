function job = testremotebatch(remote,job)
%
% test for remote batch using a standard function.
%
% by J. Decker, Y. Peysson and M. Schneider (CEA/IRFM)   
%
% INPUTS : 
%   - remote : can be
%       o a structure, possibly created by a function of the type remote_CEA_CEPHEE('pbs','joan','JD211098');
%       o a number, which calls the corresponding profile in dkepath.remote
%
%   - job : can be
%       o a number : (0) use remoterunbatch and wait for result with remotegetbatch
%                    (1) use matremote_luke_jd and wait for result 
%                    (2) use matremote_luke_jd and return job for later check
%       o a structure containing the job started earlier with option (job = 2)
%
% OUTPUTS : 
%   - job : can be
%       o a structure containing the job started with option (job = 2)
%       o a flag giving (0) if test failed or (1) if test passed 
%
if nargin < 1,
    remote = 1;
end
%
if ~isstruct(remote)
    %
    dkepath = load_structures_yp('dkepath','','');
    remote = dkepath.remote(remote);
    %
end
%
remote.debugmode = 1;
remote.rempause = 1/60;% in minutes
%
if nargin < 2,
    job = 0;
end
%
if isstruct(job),% check previously started job
    %
    args_in{1}.job = job;
    [soutput.err,soutput] = matremote_luke_jd('remotetest',args_in,remote);
    %
else% start new job
    %
    % creates the remote directories and transfer necessary files for the test.
    % the files needed for remote matlab run are :
    %   - the script matlabbatch.sh
    %   - the test function remotetest.m
    %   - the standard matlab remote run function remotematrun.m
    %   - if matremote_luke_jd is used, the standard function runmat.m to manage variable inputs/outputs
    %
    remotehome = reminstall(remote);
    %
    test_job.script = [remotehome,'/remotebatchtest/bin/matlabbatch.sh'];% script to be run by scheduler on remote cluster
    test_job.savefcn = 'matstandardsave';% function saving the data locally 
    test_job.loadfcn = 'matstandardload';% function reading the data locally
    test_job.localdatapath = 'data/';%'';%forder where local data is stored - leave empty for local data folder
    test_job.remotedatapath = [remotehome,'/remotebatchtest/run'];%'';%folder where remote data is stored
    test_job.env.remotebatch_path = [remotehome,'/remotebatchtest/mat/']; % matlab path for remotetest.m (to test path transfer)
    %
    test_job.wait = 1;%0;% (0) return hand (1) wait for result
    test_job.nodes = 1;%number of nodes required
    test_job.ppn = 2;%number of cores required
    test_job.memory = 2000;% memory required (in mb) - leave empty if no requirement
    test_job.walltime = 1;%[];% time required (integers - in hours) - leave empty if no requirement
    %
    test_job.env.TESTVAR = 'luke'; % test variable
    test_job.debugmode = 1;
    %
    sinput.strin = 'The best code is : ';
    %
    displaymode = 1;
    %
    if job == 0,% use remoterunbatch and wait for result with remotegetbatch
        %
        test_job.env.remotematfnc = 'remotetest'; % remote matlab function to be called by remotematrun (case of direct call)
        %
        test_job = remoterunbatch(remote,test_job,sinput,displaymode);
        %
        if isfield(test_job,'err'),
            soutput = test_job.err;
        else
            %
            remote.remtimout = 5;% in minutes
            %
            soutput = remotegetbatch(remote,test_job,displaymode,0);
        end
        %
    else% use matremote_luke_jd
        %
        test_job.env.remotematfnc = 'runmat'; % remote matlab function to be called by remotematrun (case of standard call using runmat)
        %
        if job == 1,% use matremote_luke_jd and wait for result
            %
            remote.remtimout = 5;% in minutes
            %
        else% use matremote_luke_jd and return job for later check
            %
            remote.remtimout = 0;% in minutes
            %
        end
        %
        args_in{1} = sinput;
        [err,soutput] = matremote_luke_jd('remotetest',args_in,remote,test_job);
        %
        if ~isempty(err),
            soutput.err = err;
        end
        %
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
    %
    job = 0;
    %
elseif isfield(soutput,'job'),
    %
    % job started and returned for later check
    %
    job = soutput.job;
    %
elseif isfield(soutput,'strout'),
    %
    % result - should read 'The best code is : luke - running under matlab version : ', followed by the requested remote matlab version
    %
    disp(soutput.strout)
    %
    job = 1;
    %
else
    %
    % failed test
    %
    disp('The remote run failed for unknown reasons');
    %
    job = 0;
    %
end
%


