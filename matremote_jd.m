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
job = matstandardjob_jd(remote,'runmat');
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
    output = remotegetbatch(remote,job,debugmode,0);
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

