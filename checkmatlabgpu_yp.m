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
function [flag_GPU,gpuStatus] = checkmatlabgpu_yp(scheduler)
%
% Tests the GPU card computational capabilities with Matlab, and resest the
% GPU memory if available
%
%   INPUTS:
%
%       - scheduler: structure (scheduler.gpu = 0 or 1) and (scheduler.display = 0 or 1) 
%
%   OUTPUTS:
%   
%       - flag_GPU: available GPU id [1,n]
%       - gpuStatus: structure that contains all information on GPU devices
%
% by Yves Peysson <yves.peysson@cea.fr> (CEA-IRFM) and Joan Decker <joan.decker@cea.fr> (CEA-IRFM)
%	
if nargin == 0, error('Wrong number of input arguments in checkmatlabgpu_yp.m');end
%
if ~isfield(scheduler,'gpu')
    gpu_mode = 0;
else
    gpu_mode = scheduler.gpu;
end
%
if ~isfield(scheduler,'display')
    display_mode = 0;
else
    display_mode = scheduler.display;
end
%
flag_GPU = 0;
%
if abs(gpu_mode) > 0,
    %
    [vmatlab,dummy,testtoolbox] = matversion_yp('Parallel Computing Toolbox');
    %
    if str2double(vmatlab) < 711 || ~testtoolbox,
        disp(['WARNING: GPU calculations may not be used with the present version ',version('-release'),' of Matlab or the ''Parallel Computing Toolbox'' may be missing. Use Matlab >= R2010b (7.11) for this functionality with the appropriate library. Sequential mode without GPU enforced']);
    else
        for igpu = 1:gpuDeviceCount,%scan compatible GPU devices
            reset(gpuDevice(igpu));%reset memory on each GPU unit (should be done to have the largest memory available)
            gpuStatus(igpu) = gpuDevice(igpu);%call each GPU unit to get the graphics card status, and the CUDA compatibility
            %
            if gpuStatus(igpu).DeviceSupported,
                if display_mode,
                    disp(['GPU calculations on the ',gpuStatus(igpu).Name,' graphic card are supported.']);
                    disp(['Max. GPU free memory available : ',num2str(round(gpuStatus(igpu).FreeMemory/1e6)),' MBytes.']);
                end
                %
                flag_GPU(igpu) = 1;
            else
                disp(['GPU calculations on the ',gpuStatus(igpu).Name,' graphic card are not supported.']);
                flag_GPU(igpu) = 0;
            end
        end
        %
        if sum(flag_GPU) == 0,
            disp('No graphic cards supported for GPU calculations in Matlab.');
        end
    end
    %
    if ~exist('gpuStatus'),
        gpuStatus = [];
    end
else
    gpuStatus = [];
    flag_GPU = 0;
end