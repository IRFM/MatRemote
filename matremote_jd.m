function [err,varargout] = matremote_luke_jd(fun,args_in,remote)
%
% This is a generic matlab function exectuting the function fun with
% arguments args_in remotely
%
varargout = cell(1,nargout-1);
%
err = '';
%
if isfield(remote,'debugmode'),
    debugmode = remote.debugmode;
else
    debugmode = 0;
end
%
job.env.luke_root = remote.luke_root;% luke path environment
job.env.remotematfnc = 'runmat';
%
job.script = [job.env.luke_root,filesep,'Tools/matlabbatch.sh'];
job.args = 'luke_root = getenv(''luke_root'');addpath([luke_root,''Project_DKE/DKE'']);setpath_luke_jd(luke_root);disp(['' Path set to '',luke_root]);remotematrun;';%argument to be passed into script
%
job.savefcn = 'matstandardsave';%'runlukesave';%
job.loadfcn = 'matstandardload';%'runlukeload';%
job.localdatapath = '';
job.remotedatapath = '/Users/yvespeysson/condor/';
%
job.wait = 0;% (0) return hand (1) wait for result
job.nodes = 1;%number of nodes required
job.nproc = 2;%number of cores required
job.walltime = [];% time required (integers - in hours) - leave empty if no requirement
%
if isfield(remote,'memory'),
    job.memory = remote.memory;% requested memory specified in dkeparam
end
%
job.debugmode = debugmode;
%
mat_input.fun = fun;
mat_input.args_in = args_in;
mat_input.nargout = nargout;
%
job = remoterunbatch(remote,job,mat_input,debugmode);
%
if ~isfield(job,'err'),% no error occured in the remote job start,
    %
    if isfield(remote,'remtimout'),
        remtimout = remote.remtimout;
    else
        remtimout = Inf;
    end
    %
    if isfield(remote,'rempause'),
        rempause = remote.rempause;
    else
        rempause = 0.1;
    end
    %
    trem = tic;
    %
    while toc(trem) < remtimout,
        %
        pause(rempause);
        %
        output = remotegetbatch(remote,job,debugmode);
        %
        if ~isempty(output),
            break
        end
        %
        if debugmode,
            disp(['Function ',fun,' still executed remotely. Elapsed time (mins) ',num2str(toc(trem)/60),'/',num2str(remtimout/60)])
        end
        %
    end
else
    output.err = job.err;
end
%
if isempty(output),
    if debugmode,
        disp('Timeout reached. Calculation started locally if enforced.')
    end
    err = 'timout';
elseif isfield(output,'err'),
    if debugmode,
        disp('Remote calculation failed. Calculation started locally if enforced.')
    end
    err = output.err;
else
    varargout = output.varargout;
end

