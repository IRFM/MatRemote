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
elseif isfield(dkecluster,'scheduler') && isfield(dkecluster.scheduler,'debugmode'),% inherit MDCE debugmode
    debugmode = dkecluster.scheduler.debugmode;
else
    debugmode = 0;
end
%
if isfield(dkecluster,'cleanmode'),
    cleanmode = dkecluster.cleanmode;
elseif isfield(dkecluster,'scheduler') && isfield(dkecluster.scheduler,'cleanmode'),% inherit MDCE cleanmode
    cleanmode = dkecluster.scheduler.cleanmode;
else
    cleanmode = 2;
end
%
if isfield(dkecluster,'remtimout'),% in minutes
    remtimout = dkecluster.remtimout;
elseif isfield(dkecluster,'scheduler') && isfield(dkecluster.scheduler,'remtimout'),% inherit MDCE remtimout
    remtimout = dkecluster.scheduler.remtimout;
else
    remtimout = Inf;
end
%
if isfield(dkecluster,'rempause'),% in minutes
    rempause = dkecluster.rempause;
elseif isfield(dkecluster,'scheduler') && isfield(dkecluster.scheduler,'rempause'),% inherit MDCE rempause
    rempause = dkecluster.scheduler.rempause;
else
    rempause = 1/6;
end
%
if isfield(dkecluster,'localdatadir'),% in minutes
    localdatadir = dkecluster.localdatadir;
elseif isfield(dkecluster,'scheduler') && isfield(dkecluster.scheduler,'localdatadir'),% inherit MDCE rempause
    localdatadir = dkecluster.scheduler.localdatadir;
else
    localdatadir = [pwd,filesep];
end
%
remote = dkecluster.remote;
%
mdce_job = matstandardjob_jd('runmdce');
%
if isfield(dkecluster,'walltime'),
    mdce_job.walltime = dkecluster.walltime;
elseif isfield(dkecluster,'scheduler') && isfield(dkecluster.scheduler,'walltime'),% inherit MDCE walltime
    mdce_job.walltime = dkecluster.scheduler.walltime;
end
%
if isfield(dkecluster,'funcopy'),
    mdce_job.funcopy = dkecluster.funcopy;
elseif isfield(dkecluster,'scheduler') && isfield(dkecluster.scheduler,'funcopy'),% inherit MDCE funcopy
    mdce_job.funcopy = dkecluster.scheduler.funcopy;
else
    mdce_job.funcopy = true;
end
%
mdce_job.debugmode = debugmode;
mdce_job.clean = cleanmode;
mdce_job.remtimout = remtimout;
mdce_job.rempause = rempause;
mdce_job.localdatadir = localdatadir;
%
mdce_input.fun = fun;
mdce_input.args_in = args_in;
mdce_input.arg_index = arg_index;
mdce_input.arg_range = arg_range;
mdce_input.dkecluster.scheduler = dkecluster.scheduler;
mdce_input.nargout = nargout;
%
mdce_job = remoterunbatch(remote,mdce_job,mdce_input,debugmode);
%
if ~isfield(mdce_job,'err'),% no error occured in the remote job start,
    if remtimout == 0,% return hand for later job process
        output.varargout = varargout;
        output.varargout{1}{1}.job = mdce_job;
        output.flag = 4;
    else
        [~,output] = remotegetbatch(mdce_job,debugmode,0);
    end
else
    output.err = mdce_job.err;
end
%
if isempty(output),
    disp('Timeout reached, MDCE calculation started locally')
elseif isfield(output,'err'),
    disp('Remote MDCE run failed, calculation started locally')
else
    flag = 10 + output.flag;% add 10 for each remote step
    varargout = output.varargout;
end
