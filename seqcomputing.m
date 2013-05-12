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
[flag_GPU,gpuStatus] = checkmatlabgpu_yp(scheduler);
%
for j_range = 1:nrange,%maximize the loop when GPU is activated (warm-up effect)
    %
    args_in{arg_index} = arg_range{j_range};
    %
    if flag_GPU,
        if scheduler.gpu == 1,
            args_in{arg_index} = gpuArray(single(args_in{arg_index}));%transfer data to GPU memory (single precision enforce)
        else
            args_in{arg_index} = gpuArray(double(args_in{arg_index}));%transfer data to GPU memory (double precision enforce)
        end
    end
    %
    try
        [varargout_array{j_range,:}] = feval(fun_handle,args_in{:});
    catch me_seq
        disp(['Error executing the iteration ',int2str(j_range),'/',int2str(nrange),'.']);
        disp(['===> Error : ',getReport(me_seq)]);
        flag(j_range) = -2;
    end
    %
end
%
varargout = cell(1,nargout-1);
%
%[varargout{:}] = deal(cell(N_range,1)); keep this line as an example of use of the function deal
%
for j_argout = 1:nargout-1,
    %
    varargout{j_argout} = cell(nrange,1);
    %
    for j_range = 1:nrange,
        if flag_GPU,
            varargout{j_argout}{j_range} = gather(varargout_array{j_range,j_argout});
        else
            varargout{j_argout}{j_range} = varargout_array{j_range,j_argout};    
        end
    end
end
