function testremotebatch(remote)
%
% test for remote batch using a standard function.
%
% by J. Decker, Y. Peysson and M. Schneider (CEA/IRFM)   
%
% Note : remote can be :
%
%   - a structure, possibly created by a function of the type remote_CEA_CEPHEE('pbs','joan','JD211098');
%   - a number, which calls the corresponding profile in dkepath.remote
%
%
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
test_job.ppn = 2;%number of cores required
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


