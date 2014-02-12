function [flag,varargout] = mdce_remote(fun,args_in,arg_index,arg_range,dkecluster)
%
% This function transfers the distributed calculation to a remote cluster
%
%
narg_range = length(arg_range);
%
varargout = cell(1,nargout-1);
%
for j_nargout = 1:nargout-1,
    varargout{j_nargout} = cell(narg_range,1);
end
%
flag = [-Inf]*ones(1,narg_range);% failed remote calc. flag
%
if isfield(dkecluster,'debugmode'),
    debugmode = dkecluster.debugmode;
else
    debugmode = 0;
end
%
if isfield(dkecluster,'cleanmode'),
    cleanmode = dkecluster.cleanmode;
else
    cleanmode = 2;
end
%
remote = dkecluster.remote;
%
mdce_job = matstandardjob_jd('runmdce');
%
if isfield(dkecluster,'funcopy'),
    mdce_job.funcopy = dkecluster.funcopy;
else
    mdce_job.funcopy = true;
end
%
mdce_job.debugmode = debugmode;
mdce_job.clean = cleanmode;
%
mdce_input.fun = fun;
mdce_input.args_in = args_in;
mdce_input.arg_index = arg_index;
mdce_input.arg_range = arg_range;
mdce_input.dkecluster = rmfield(dkecluster,'remote');
mdce_input.nargout = nargout;
%
mdce_job = remoterunbatch(remote,mdce_job,mdce_input,debugmode);
%
if ~isfield(mdce_job,'err'),% no error occured in the remote job start,
    output = remotegetbatch(mdce_job,debugmode,0);
else
    output.err = mdce_job.err;
end
%
if isempty(output),
    disp('Timeout reached, MDCE calculation started locally')
elseif isfield(output,'err'),
    disp('Remote MDCE run failed, calculation started locally')
else
    flag = output.flag;
    varargout = output.varargout;
end
