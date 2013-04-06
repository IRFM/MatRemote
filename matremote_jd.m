function [err,varargout] = matremote_luke_jd(fun,args_in,remote,job)
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
if isfield(remote,'debugmode'),
    debugmode = remote.debugmode;
else
    debugmode = 0;
end
%
if ~isempty(args_in) && isfield(args_in{1},'job'),% check result of previously launched job
    %
    output = remotegetbatch(remote,args_in{1}.job,debugmode,1);
    %
    if isempty(output),
        if debugmode,
            disp('Job still running.')
        end
        output.varargout{1}.job = args_in{1}.job;
    end
    %
else   
    %
    if nargin < 4,
        job = matstandardjob_jd(remote,'runmat');
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
        if isfield(remote,'remtimout') && remote.remtimout == 0,% return and check later
            output.varargout{1}.job = job;
        else
            output = remotegetbatch(remote,job,debugmode,0);% wait for result
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
    end
    %
end
%
if isfield(output,'err'),
    if debugmode,
        disp('Remote calculation failed. Calculation started locally if enforced.')
    end
    err = output.err;
elseif isfield(output,'varargout'),
    varargout = output.varargout;
end

