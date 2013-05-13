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
%%%% TODO: YP -> update the distributed computing syntax for matlab version > 810 (R2013a)
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
    if str2double(matversion_yp) <= 801,%old matlab syntax
        jm = findResource('scheduler','configuration',scheduler.configuration);%Initiate the job server for Matlab Distributed Computing Environment  
    else%new matlab syntax
        jm = parcluster(scheduler.configuration);
    end
    %
    jmfields = get(jm);%save original scheduler properties
    jminit = struct;
catch err
    info_dke_yp(2,['WARNING: exiting jobcomputing for ',func2str(fun),'.m (mode 1) because of error: ',err.message]);
    flag(:) = -2;
    return
end
%
if isfield(scheduler,'temppath'),
    if str2double(matversion_yp) <= 801,%old matlab syntax
        set(jm,'datalocation',scheduler.temppath);
        jminit.datalocation = jmfields.DataLocation;
    else
        set(jm,'JobStorageLocation',scheduler.temppath);
        jminit.JobStorageLocation = jmfields.JobStorageLocation;
    end      
end
%
if isfield(scheduler,'clustersize'),    
    if str2double(matversion_yp) <= 801,%old matlab syntax
        set(jm,'clustersize',min([scheduler.clustersize,jmfields.ClusterSize]));
        jminit.clustersize = jmfields.ClusterSize;
    else
        set(jm,'NumWorkers',min([scheduler.clustersize,jmfields.NumWorkers]));
        jminit.NumWorkers = jmfields.NumWorkers;
    end
end
%
%if isfield(scheduler,'hasSharedFileSystem'),set(jm,'HasSharedFileSystem',scheduler.HasSharedFileSystem);end
%if isfield(scheduler,'ClusterMatlabRoot'),set(jm,'ClusterMatlabRoot',scheduler.ClusterMatlabRoot);end
%if isfield(scheduler,'SubmitFcn'),set(jm,'SubmitFcn',scheduler.SubmitFcn);end
%if isfield(scheduler,'ParallelSubmitFcn'),set(jm,'ParallelSubmitFcn',scheduler.ParallelSubmitFcn);end
%
job = createJob(jm);
if str2double(matversion_yp) <= 801,%old matlab syntax
    set(job,'PathDependencies',strread(path,'%s','delimiter',':'));
else
    set(job,'AdditionalPaths',strread(path,'%s','delimiter',':'));
end
%
[flag_GPU,gpuStatus] = checkmatlabgpu_yp(scheduler);
%
if flag_GPU,
    spmd
        selectGPUDeviceForLab();
    end
end
%
for j_range = 1:nrange,
    %
    arg_job = args_in;  
    %
    if flag_GPU,
        if scheduler.gpu == 1,
            flag = flag + i;
            arg_job{arg_index} = gpuArray(single(arg_range{j_range}));%transfer data to GPU memory (single precision enforce)
        else
            flag = flag + 2*i;
            arg_job{arg_index} = gpuArray(double(arg_range{j_range}));%transfer data to GPU memory (double precision enforce)
        end
    else
        arg_job{arg_index} = arg_range{j_range};
    end
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
        if flag_GPU,
            varargout{j_argout}{j_range} = gather(varargout_array{j_range}{j_argout});
        else
            varargout{j_argout}{j_range} = varargout_array{j_range}{j_argout};
        end
    end
end
%
function ok = selectGPUDeviceForLab()
persistent hasGPU;

if isempty(hasGPU)
    devIdx = mod(labindex-1,gpuDeviceCount())+1;
    try
        dev = gpuDevice(devIdx);
        hasGPU = dev.DeviceSupported;
    catch %#ok
        hasGPU = false;
    end
end
ok = hasGPU;












      