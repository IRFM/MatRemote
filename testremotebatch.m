function soutputs = testremotebatch(sinputs,remote,debugmode)
% ------------------------------------------------
% test for remote batch using a standard function.
% ------------------------------------------------
%
% This function tests the MatRemote package using eitehr batch or direct
% calculations. Given the option sinputs, three modes can be tested :
%
%   - the direct use of remoterunbatch and remotegetbatch
%
%   - the use of matremote_jd(fun,args_in,remote,job), where 'fun' is the
%   matlab function to be executed remotely, 'args_in' are the arguments used
%   by 'fun', 'remote' is the remote (or local!) profile, and the optional
%   input 'job' specifies job parameters.
%
%   - the use of matremote_jd by returning job info to be checked later
%
% by J. Decker, Y. Peysson and M. Schneider (CEA/IRFM)   
%
% INPUTS : 
%
%   - sinputs : can be
%       o a number : (0) use remoterunbatch and wait for result with remotegetbatch
%                    (1) use matremote_jd and wait for result 
%                    (2) use matremote_jd and return job for later check
%       o a cell array containing the job(s) started earlier with option (job = 2), or the results of completed jobs
%
%   - remote : only if isnumeric(sinputs)
%           o (NaN)     : load all profiles and ask for user selection 
%           o (struct)  : profile contained in structure 'remote' 
%           o (string)  : identification of profile to be selected as remote_(string).m 
% (default) o ('')      : load & return all profiles 
%           o ('local') : idendify and return local cluster
%
%   - debugmode : [0 or 1] if 1, provides step by step information, and save diary file in remote job folder 
%
% OUTPUTS : 
%
%   - soutputs is a cell array containing
%       o a structure containing the job started with option (job = 2)
%       o the job output or error message if the job is completed
%
% The test works by checking remote access and transfers, remote path,
% remote matlab version, remote command (remotetest), variable transfer ('The best code is : ')
% and environment variable ('luke').
% 

%
% Set path to MatRemote & MatTools toolboxes
%
matremote_path = [fileparts(which(mfilename)),filesep];
mattools_path = [matremote_path,'../MatTools/'];% change if needed
%
addpath(matremote_path);% MatRemote toolbox
addpath([matremote_path,'Profiles/']);% remote profiles
addpath(mattools_path);% MatTools toolbox
%
sinput.strin = 'The best code is : ';% input to function remotetest
testvar = 'luke'; % test variable
%
% Debugmode
%
if nargin < 3,
    debugmode = 0;% default mode is direct use of remoterunbatch and remotegetbatch
end
%
% Test direct calculation with matremote_jd
%
if debugmode,
    setenv('TESTVAR',testvar);
    [err,soutput_init] = matremote_jd('remotetest',{sinput});
    %
    if ~isempty(err),
        soutput_init.err = err;
    end
end
%
% Test remote calculation
%
if nargin < 1,
    sinputs = 0;% default mode is direct use of remoterunbatch and remotegetbatch
end
%
if nargin < 2,
    remote = '';% test all profiles
end
%
if isnumeric(sinputs),% start new test
    %
    % Select local and remote profiles to be tested
    %
    [remoteprofiles,profilestr] = load_remoteprofiles_jd(remote,true,true,NaN,NaN,true,debugmode);
    %
    nrem = length(remoteprofiles);
    %
    soutputs = cell(1,nrem);% output structure cell array: can be output, jobs, or error message depending on options and results 
    %
    % loop on tested profiles
    %
    for irem = 1:nrem,
        %
        disp(' ');
        disp('-------------------------------------------------------------------')
        disp([' ---> Testing profile [',profilestr{irem},']']);
        disp('-------------------------------------------------------------------')
        disp(' ');
        %
        remote = remoteprofiles(irem);
        %remote.debugmode = 1;
        %remote.disp_cmd = 1;
        remote.rempause = 1/60;% in minutes
        %
        test_job = matstandardjob_jd;
        %
        test_job.wait = 1;%0;% (0) return hand (1) wait for result
        test_job.nodes = 1;%number of nodes required
        test_job.ppn = 1;%number of cores required
        test_job.memory = 2000;% memory required (in mb) - leave empty if no requirement
        test_job.walltime = 1;%[];% time required (integers - in hours) - leave empty if no requirement
        %
        test_job.env.TESTVAR = testvar;
        test_job.debugmode = debugmode;
        %
        displaymode = debugmode;% display step by step information in debugmode
        %
        try
            if sinputs == 0,% use remoterunbatch and wait for result with remotegetbatch
                %
                test_job.env.remotematfnc = 'remotetest'; % matlab function to be called remotely by remotematrun (case of direct call)
                %
                test_job = remoterunbatch(remote,test_job,sinput,displaymode);
                %
                if isfield(test_job,'err'),
                    soutputs{irem}.err = test_job.err;
                else
                    test_job.remtimout = 5;% in minutes
                    %
                    soutputs{irem} = remotegetbatch(test_job,displaymode,0);
                end
                %
            else% use matremote_jd
                %
                test_job.funcopy = true;% to copy function remotetest to remote folder
                %
                if sinputs == 1,% use matremote_jd and wait for result
                    %
                    remote.remtimout = 5;% in minutes
                    %
                else% use matremote_jd and return job for later check
                    %
                    remote.remtimout = 0;% in minutes
                    %
                end
                %
                test_job.env.remotematfnc = 'runmat'; % matlab function to be called remotely by remotematrun (case of standard call using runmat)
                %
                [err,soutput] = matremote_jd('remotetest',{sinput},remote,test_job);
                %
                if ~isempty(err),
                    soutputs{irem}.err = err;
                else
                    soutputs{irem} = soutput;
                end
                %
            end
        catch job_err
            %
            soutputs{irem}.err = job_err.message;
        end
        %
    end
    %
else% check previously started job
    %
    nrem = length(sinputs);
    %
    soutputs = cell(1,nrem);% output structure cell array: can be output, jobs, or error message depending on options and results 
    %
    % loop on tested profiles
    %
    for irem = 1:nrem,
        %
        if isfield(sinputs{irem},'job'),% previously running job
            %
            [err,soutput] = matremote_jd('remotetest',sinputs(irem));
            %
            if ~isempty(err),
                soutputs{irem}.err = err;
            else
                soutputs{irem} = soutput;
            end
            %
            soutputs{irem}.remoteprofile = list_remoteprofiles_jd(sinputs{irem}.job.remote);
            %
        else% completed jobs
            %
            soutputs{irem} = sinputs{irem};
            %
        end
        %
    end
    %
end
%
% Display results
%
disp(' ');
disp('-------------------------------------------------------------------')
disp('                     TEST RESULTS');
disp('-------------------------------------------------------------------')
disp(' ');
%
if debugmode,
    disp(' ---> Direct local calculation');
    disp(' ');
    %
    if isfield(soutput_init,'err'),
        %
        % failed test
        %
        disp('The remote job failed : ');
        disperr_jd(soutput_init.err)
        %
    elseif isfield(soutput_init,'strout'),
        %
        % result - should read 'The best code is : luke - running under matlab version : ', followed by the requested remote matlab version
        %
        disp(soutput_init.strout)
        %
    else
        %
        % failed test
        %
        disp('The direct local calculation failed for unknown reasons');
        %
    end
end
%
for irem = 1:nrem,
    %
    disp(' ');
    disp('-------------------------------------------------------------------')
    disp(' ');
    if isnumeric(sinputs),
        disp([' ---> Profile [',profilestr{irem},']']);
    else
        disp([' ---> Profile [',soutputs{irem}.remoteprofile{end},']']);% here {end} is used to select batch mode when localhost
    end
    disp(' ');
    %
    if isfield(soutputs{irem},'err'),
        %
        % failed test
        %
        disp('The remote job failed : ');
        disperr_jd(soutputs{irem}.err)
        %
    elseif isfield(soutputs{irem},'job'),
        %
        % job started and returned for later check
        %
        disp(['The remote job is running under id ',soutputs{irem}.job.id]);
        %
    elseif isfield(soutputs{irem},'strout'),
        %
        % result - should read 'The best code is : luke - running under matlab version : ', followed by the requested remote matlab version
        %
        disp(soutputs{irem}.strout)
        %
    else
        %
        % failed test
        %
        disp('The remote job failed for unknown reasons');
        %
    end
end
%

