function [flag,varargout] = jobcomputing(fun,args_in,arg_index,arg_range,scheduler)
% LUKE - Parallel computing of the loop
%
%   computing of the loop using user-created jobs
%
%   INPUT:
%
%       - fun_handle: function handle
%       - args_in: input arguments list of the function {1,nargin}
%       - arg_index: index in the argument list args_in which must be changed [1,1]
%       - arg_range: list of values for the input argument arg_index [1,nrange]
%           => nrange = length(arg_range) = number of iterations 
%       - scheduler: scheduler information
%
%   OUTPUT:
%
%       - flag: status of the computation : scheduler.mode (OK with jobcomputing), -1 (timeout) or -2 (failed) [1,nrange]
%       - varargout: output arguments list of the function {1,nargout-1}.
%           => Each element is a list of size {nrange,1}
%
%   by J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr) and Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) 
%
nargout_in = nargout - 1;
nrange = length(arg_range);
varargout_array = cell(1,nrange);
flag = scheduler.mode*ones(1,nrange);
%
% output initialization
%
varargout = cell(1,nargout_in);
for j_argout = 1:nargout_in,
    varargout{j_argout} = cell(nrange,1);
end
%
try
    jm = findResource('scheduler','configuration',scheduler.configuration);%Initiate the job server for Matlab Distributed Computing Environment  
    %
    jmfields = get(jm);%save original scheduler properties
	jminit = struct;
catch
    info_dke_yp(2,['WARNING: exiting jobcomputing since the job scheduler is not available (MatLab version too old, limited number of licenses, dkepath inconsistently set...) for ',func2str(fun),'.m (mode 1).']);
    flag(:) = -2;
    return
end
%
if isfield(scheduler,'temppath'),
    set(jm,'datalocation',scheduler.temppath);
	jminit.datalocation = jmfields.DataLocation;
end
%
if isfield(scheduler,'clustersize'),            
    set(jm,'clustersize',min([scheduler.clustersize,jmfields.ClusterSize]));
	jminit.clustersize = jmfields.ClusterSize;
end
%
%if isfield(scheduler,'hasSharedFileSystem'),set(jm,'HasSharedFileSystem',scheduler.HasSharedFileSystem);end
%if isfield(scheduler,'ClusterMatlabRoot'),set(jm,'ClusterMatlabRoot',scheduler.ClusterMatlabRoot);end
%if isfield(scheduler,'SubmitFcn'),set(jm,'SubmitFcn',scheduler.SubmitFcn);end
%if isfield(scheduler,'ParallelSubmitFcn'),set(jm,'ParallelSubmitFcn',scheduler.ParallelSubmitFcn);end
%
job = createJob(jm);
set(job,'PathDependencies',strread(path,'%s','delimiter',':'));
%
for j_range = 1:nrange,
    %
    arg_job = args_in;  
    %
    arg_job{arg_index} = arg_range{j_range};
    %
    createTask(job, fun, nargout-1,arg_job);
    %
end
%
submit(job);
waitForState(job)
%
if strcmp(get(job,'State'),'finished')
    out = getAllOutputArguments(job);
	if size(out,2) == nargout_in
		for j_range = 1:nrange,
			emptyoutput = zeros(1,nargout_in);
			for j_argout = 1:nargout_in,
				emptyoutput(j_argout) = isempty(out{j_range,j_argout});
			end
			if all(emptyoutput),
				varargout_array{j_range} = cell(1,nargout_in);
				flag(j_range) = -1;%problem in task
			else
				varargout_array{j_range} = out(j_range,:);
			end
		end
	else
		for j_range = 1:nrange,
			varargout_array{j_range} = cell(1,nargout_in);
			flag(j_range) = -2;%problem in job process
		end
	end
else
    flag(:) = -2;%error in job process
    return
end
%   
destroy(job);
%
set(jm,jminit)%restore original scheduler properties
%
%[varargout{:}] = deal(cell(N_range,1)); keep this line as an example of use of the function deal
%
for j_argout = 1:nargout_in,
    for j_range = 1:nrange,
        varargout{j_argout}{j_range} = varargout_array{j_range}{j_argout};
    end
end













      