function [err,job,varargout] = matremote_jd(arg1,args_in,remote,job)
%
% This is a generic matlab function exectuting the function fun with
% arguments args_in remotely according to profile remote
%
% Note : this function can be used with a wait loop (job.remtimeout or remote.remtimeout > 0)
%                 or return the job for later check (job.remtimeout or remote.remtimeout == 0)
%
% Use : 
%   - [err,job,varargout] = matremote_jd(fun,args_in,remote,[job])
%       -> run the function [varargout] = fun(args_in) remotely 
%          according to remote profile 'remote' and optionnal job parameters 'job'
% 
%   - [err,job,varargout] = matremote_jd(job)
%       -> check the status of the job 'job' and return the result if completed
%
varargout = cell(1,nargout-2);
%
err = '';
%
if nargin == 1,% check the status of the job 'job' and return the result if completed
    %
    [job,output] = remotegetbatch(arg1,[],1);% arg1=job;
    displayrunningjob(job);
    %
elseif nargin > 2 && ~isempty(remote),% new batch job 
    %
    if nargin < 4,
        job = matstandardjob_jd('runmat');
    end
    %
    if ~isfield(job,'funcopy'),
        job.funcopy = true;
    end
    %
    mat_input.fun = arg1;% arg1=fun;
    mat_input.args_in = args_in;
    mat_input.nargout = nargout-1;
    %
    job = remoterunbatch(remote,job,mat_input);
    %
    if ~isfield(job,'err'),% no error occured in the remote job start,
        if isfield(job,'remtimout') && job.remtimout == 0,% return and check later
            output = '';
        else
            [job,output] = remotegetbatch(job,[],0);% wait for result
            displayrunningjob(job);
        end
    else
        output.err = job.err;
    end
    %
elseif nargin == 2 || (nargin > 2 && isempty(remote)),
    %
    % direct calculation
    %
    job = '';
    %
    try 
        [varargout{:}] = feval(arg1,args_in{:});% arg1=fun;
        output.varargout = varargout;
    catch lsterr
        output.err = disperr_jd(lsterr);
    end
else
    error('Wrong number of inputs calling matremote_jd')
end
%
if isfield(output,'err'),
    disp('Remote calculation failed.')
    if isempty(output.err),
        err = 'unknown error';
    else        
        err = output.err;
    end
elseif isfield(output,'varargout'),
    varargout = output.varargout;
end

