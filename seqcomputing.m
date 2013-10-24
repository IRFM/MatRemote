function [flag,varargout] = seqcomputing(fun_handle,args_in,arg_index,arg_range,scheduler)
% LUKE - Sequential computing of the loop
%
%   Sequential computing of the loop
%
%   INPUT:
%
%       - fun_handle: function handle
%       - args_in: input arguments list of the function {1,nargin}
%       - arg_index: index in the argument list args_in which must be changed [1,1]
%       - arg_range: list of values for the input argument arg_index [1,nrange]
%           => nrange = length(arg_range) = number of iterations 
%       - scheduler: scheduler information (for GPU calculation only)
%
%   OUTPUT:
%
%       - flag: status of the computation : 0 (OK) or -2 (failed) [1,nrange]
%       - varargout: output arguments list of the function {1,nargout-1}.
%           => Each element is a list of size {nrange,1}
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
nrange = length(arg_range);
varargout_array = cell(nrange,nargout-1);
flag = zeros(1,nrange);
%
varargout = cell(1,nargout-1);
%
[flag_GPU,gpuStatus] = checkmatlabgpu_yp(scheduler);
%
if ~isempty(gpuStatus),
    FreeMemory_gpu(1) = gpuStatus.FreeMemory;
end
%
for j_range = 1:nrange,%maximize the loop when GPU is activated (warm-up effect)
    %
    args_in{arg_index} = arg_range{j_range};
    %
    if flag_GPU,
        if scheduler.gpu == 1,
            flag = flag + i;
            args_in{arg_index} = gpuArray(single(args_in{arg_index}));%transfer data to GPU memory (single precision enforce)
        else
            flag = flag + 2*i;
            args_in{arg_index} = gpuArray(double(args_in{arg_index}));%transfer data to GPU memory (double precision enforce)
        end
    end
    %
    try
        if scheduler.gpu == 1,
            varargout_array_gpu = cell(1,nargout-1);
            [varargout_array_gpu{1,:}]  = feval(fun_handle,args_in{:});
            for j_argout = 1:nargout-1,
                varargout{j_argout}{j_range} = gather(varargout_array_gpu{1,j_argout});%to release some memory on GPU device
            end
            %
            if j_range > 2 && gpuStatus.FreeMemory - (FreeMemory_gpu(end) - FreeMemory_gpu(end-1)) < 0,
                reset(gpuDevice);
                FreeMemory_gpu(end) = gpuStatus.FreeMemory;
                disp('WARNING: A reset of the GPU device is performed as the free memory is becoming short. ');
            end
            FreeMemory_gpu(j_range) = gpuStatus.FreeMemory;
        else
            [varargout_array{j_range,:}] = feval(fun_handle,args_in{:});
        end 
    catch me_seq
        disp(['Error executing the iteration ',int2str(j_range),'/',int2str(nrange),'.']);
        disp(['===> Error : ',getReport(me_seq)]);
        flag(j_range) = -2;
    end
    %
end
%
%[varargout{:}] = deal(cell(N_range,1)); keep this line as an example of use of the function deal
%
for j_argout = 1:nargout-1,
    %
    varargout{j_argout} = cell(nrange,1);
    %
    if ~flag_GPU,
    	varargout{j_argout} = varargout_array(:,j_argout);
    end
end
