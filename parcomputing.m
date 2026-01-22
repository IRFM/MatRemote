% 
% /////////////////////////////////////////
%
% Software name : MatRemote, part of LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function [flag,varargout] = parcomputing(fun,args_in,arg_index,arg_range,scheduler)
% LUKE - Parallel computing of the loop
%
%   parfor computing of the loop
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
%       - flag: status of the computation : scheduler.mode (OK with parcomputing) or -2 (failed) [1,nrange]
%       - varargout: output arguments list of the function {1,nargout-1}.
%           => Each element is a list of size {nrange,1}
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
nargout_in = nargout - 1;
nrange = length(arg_range);
varargout_array = cell(1,nrange);
flag = scheduler.mode*ones(1,nrange);
%
try
    if str2double(matversion_yp) < 801,%old matlab syntax
        configuration = findResource('scheduler','configuration',scheduler.configuration);
        scheduler.clustersize = min([scheduler.clustersize,configuration.ClusterSize]);
    else%new matlab syntax
        configuration = parcluster(scheduler.configuration);
        scheduler.clustersize = min([scheduler.clustersize,configuration.NumWorkers]);
    end
    %
    if str2double(matversion_yp) < 803
        matlabpool('open',scheduler.configuration,scheduler.clustersize);
    else
        poolid = parpool(scheduler.configuration,scheduler.clustersize);
    end
catch err
    info_dke_yp(2,['WARNING: exiting parcomputing for function ',func2str(fun),'.m (mode 3) because of error: ',err.message]);
    flag(:) = -2;
    return
end
%
varargout = cell(1,nargout-1);
%
[flag_GPU,gpuStatus] = checkmatlabgpu_yp(scheduler);
%
if ~isempty(gpuStatus),
    FreeMemory_gpu(1) = gpuStatus.FreeMemory;
end
%
if flag_GPU,
    spmd
        selectGPUDeviceForLab();
    end
    if scheduler.gpu == 1,
        flag = flag + 1i;
    else
        flag = flag + 2i;
    end
end
%
parfor j_range = 1:nrange,
    %
    args_loc = args_in;
    %
    if flag_GPU,
        if scheduler.gpu == 1,
            args_loc{arg_index} = gpuArray(single(arg_range{j_range}));%transfer data to GPU memory (single precision enforce)
        else
            args_loc{arg_index} = gpuArray(double(arg_range{j_range}));%transfer data to GPU memory (double precision enforce)
        end
    else
        args_loc{arg_index} = arg_range{j_range};
    end
    %
    varargout_loc = cell(1,nargout_in);
    %
    try
        [varargout_loc{:}] = feval(fun,args_loc{:});
    catch me_seq
        disp(['Error executing the iteration ',int2str(j_range),'/',int2str(nrange),'.']);
        disp(['===> Error : ',getReport(me_seq)]);
        flag(j_range) = -2;
    end
    %
    varargout_array{j_range} = varargout_loc;
    %
end
%
%[varargout{:}] = deal(cell(N_range,1)); keep this line as an example of use of the function deal
%
for j_argout = 1:nargout_in,
    %
    varargout{j_argout} = cell(nrange,1);
    %
    for j_range = 1:nrange,
        if ~flag_GPU,
            varargout{j_argout}{j_range} = varargout_array{j_range}{j_argout};
        end
    end
    %
end
%
if str2double(matversion_yp) < 803,
    matlabpool close force
else
    delete(poolid);
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
