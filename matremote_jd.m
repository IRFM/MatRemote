function [err,varargout] = matremote_jd(fun,args_in,remote,job)
%
% This is a generic matlab function exectuting the function fun with
% arguments args_in remotely according to profile remote
%
% Note : this function can be used with a wait loop (remote.remtimeout > 0)
%        or return the job for later check (remote.remtimeout == 0)
%        later check is done by calling the function again with the field args_in.job
%
varargout = cell(1,nargout-1);
%
err = '';
%
if ~isempty(args_in) && isfield(args_in{1},'job'),% check result of previously launched job
    %
    soutput = remotegetbatch(args_in{1}.job,args_in{1}.job.debugmode,1);
    %
    if isempty(soutput) || ~isstruct(soutput),
        %
        job = args_in{1}.job;
        %
        if ~isempty(soutput) && ~isempty(strfind(soutput,'pid=')),
            job.id = soutput(5:length(soutput));%PID extraction by file
        elseif ~isempty(soutput) && ~isempty(strfind(soutput,remote.get_jobid{1})),
            job.id = soutput(length(job.remote.get_jobid{1})+1:end);
        end
        %
        if job.debugmode,
            disp('Job still running.')
        end
        output.varargout{1}.job = job;
        %
    else
        output = soutput;
    end
    %
elseif nargin > 2 && ~isempty(remote),% batch job received   
    %
    if nargin < 4,
        job = matstandardjob_jd('runmat');
    end
    %
    if ~isfield(job,'funcopy'),
        job.funcopy = true;
    end
    %
    mat_input.fun = fun;
    mat_input.args_in = args_in;
    mat_input.nargout = nargout;
    %
    job = remoterunbatch(remote,job,mat_input);
    %
    if ~isfield(job,'err'),% no error occured in the remote job start,
        if isfield(job,'remtimout') && job.remtimout == 0,% return and check later
            output.varargout{1}.job = job;
        else
            output = remotegetbatch(job,[],0);% wait for result
        end
    else
        output.err = job.err;
    end
    %
    if isempty(output),
        if displaymode,
            disp('Timeout reached. Calculation started locally if enforced.')
        end
        err = 'timout';
    end
    %
else% direct calculation
    %
    try 
        [varargout{:}] = feval(fun,args_in{:});
        output.varargout = varargout;
    catch
        %
        lsterr = lasterror;
        %
        err = {'The action was cancelled due to the following error:','',lsterr.message};
        for il = 1:length(lsterr.stack),
            err = [err,['In ',lsterr.stack(il).file,' at line ',num2str(lsterr.stack(il).line)]];
        end
        %
        output.err = err;
        %
    end
end
%
if isfield(output,'err'),
    disp('Remote calculation failed. Calculation started locally if enforced.')
    if isempty(output.err),
        err = 'unknown error';
    else        
        err = output.err;
    end
elseif isfield(output,'varargout'),
    varargout = output.varargout;
end

