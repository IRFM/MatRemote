function [flag,varargout] = mdce_luke(fun,args_in,arg_index,arg_range,dkecluster)
%LUKE - Distributed LUKE calculations on multiple processors
%
%   Function for distributing LUKE calculations on multiple processors:
%		 - option 1) with MatLab Distributed Computing Environment (toolbox) if available
%		 - option 2) if dcluke library is set up for LUKE on the cluster where calculations are done (see ~/LUKE/Project_DKE/Packages/MDCE/dcluke/)
%
%   INPUT:
%
%       - fun: function handle
%       - args_in: input arguments list of the function
%       - arg_index: index in the argument list args_in which must be changed
%       - arg_range: list of values to be calculated for the input argument arg_index, length(arg_range) = number of times a calculation must be performed
%       - dkecluster: cluster parameters (structure)
%
%   OUTPUT:
%
%       - flag: if 0, the MatLab Distributed Computing Toolbox is not available for LUKE calculations
%       - varargout: output arguments list of the function
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
if nargin < 4,
    error('Wrong number of input arguments in mdce_luke.m !');
end
%
if nargin < 5,
    dkecluster = [];
end
%
if isempty(arg_index)
    error('The argument ''arg_index'' in mdce_luke.m must be defined !');
end
if ~isfinite(arg_index),
    error('The argument ''arg_index'' in mdce_luke.m must be finite !');
end
if isnan(arg_index),
    error('The argument ''arg_index'' in mdce_luke.m cannot be a NaN !');
end
if arg_index == 0,
    error('The argument ''arg_index'' in mdce_luke.m cannot be a zero !');
end        
if arg_index > length(args_in),
    error(['The argument ''arg_index'' in mdce_luke.m cannot be greater than ',str2num(length(args_in)),' !']);
end        
if isempty(arg_range)
    error('The argument ''arg_range'' in mdce_luke.m must be defined !');
end
%
if nargout < 1,
    error('At least one output argument (flag) must be defined.');
end
%
if ~iscell(arg_range),
    if isnumeric(arg_range),
        if size(arg_range,1) == 1 || size(arg_range,2) == 1,
            arg_range = num2cell(arg_range(:));
        else
            arg_range = num2cell(arg_range,1);
        end
    elseif isstruct(arg_range),
        narg_range = length(arg_range);
        new_arg_range = cell(1,narg_range);
        for i_range = 1:narg_range,
            new_arg_range{i_range} = arg_range(i_range);
        end
        arg_range = new_arg_range;
    else
        error('The argument ''arg_range'' in mdce_luke.m must be a list or an array object');
    end
end
%
narg_range = length(arg_range);
%
varargout = cell(1,nargout-1);
%
for j_nargout = 1:nargout-1,
    varargout{j_nargout} = cell(narg_range,1);
end
%
% remote calculation
%
if isfield(dkecluster,'remnum'),
    %
    [flag,varargout{:}] = mdce_luke_remote(fun,args_in,arg_index,arg_range,dkecluster);
    %
    mask_loc = (flag < 0);%flagged for local computing
    %
    if any(mask_loc),%back to local computing 
        %
        disp(['WARNING: Remote distributed computing failed for ',num2str(sum(mask_loc)),'/',num2str(length(mask_loc)),' cases. Switching to local computing for these cases.']);
        %
        dkecluster_loc = clustermode_luke(dkecluster.param,dkecluster.fun,dkecluster.dkepath,dkecluster.schedulertype,0);% local dkecluster
        %
        varargout_loc = cell(1,nargout-1);
        [flag(mask_loc),varargout_loc{:}] = mdce_luke(fun,args_in,arg_index,arg_range(mask_loc),dkecluster_loc);
        %
        for j_nargout = 1:nargout-1,
            varargout{j_nargout}(mask_loc) = varargout_loc{j_nargout};
        end	
        %
    end
    %
    return
    %
end
%
flag = 0;
%
if isempty(dkecluster),
    dkecluster = clustermode_luke(0,'',dkepath);%All cluster parameters and paths (sequential mode by default)
end
%
% Parameter validation of different parallel computing techniques
%
if isfield(dkecluster,'scheduler'),
    if ~isfield(dkecluster.scheduler,'mode'),
        dkecluster = clustermode_luke(0,'',dkepath);%All cluster parameters and paths (sequential mode by default)
        disp('WARNING: distributed computing is inconsistently set-up: ''mode'' must be chosen. Sequential mode enforced.');
    else
        if ~isfield(dkecluster.scheduler,'temppath'),
            dkecluster.scheduler.temppath = [pwd,filesep,'mdce_',timeid_jd(clock),filesep];%Local calculation
        end
        %
        %if ~isfield(dkecluster.scheduler,'type'),         
        %    dkecluster.scheduler.type = 'local';%Local calculations
        %end
        %    
        if ~isfield(dkecluster.scheduler,'info'),
            dkecluster.scheduler.info = 'Default parallel computing set-up by mdce_luke.m function.';
        end
        %
        if ~isfield(dkecluster.scheduler,'display'),
            dkecluster.scheduler.display = 0;%No display
        end
        %
        if ~isfield(dkecluster.scheduler,'clustersize'),
            dkecluster.scheduler.clustersize = 1;%One core or processor
        end
        %
        if ~isfield(dkecluster.scheduler,'timeout'),
            dkecluster.scheduler.timeout = 100;%100 s
        end
    end
elseif isfield(dkecluster,'batch'),
    dkecluster = clustermode_luke(0,'',dkepath);%All cluster parameters and paths (sequential mode by default)
    disp('WARNING: batch parallel computing is not yet implemented. Sequential mode enforced.');
else
    dkecluster = clustermode_luke(0,'',dkepath);%All cluster parameters and paths (sequential mode by default)
    disp('WARNING: unknown parallel computing mode. Sequential mode enforced.');
end
%
% Parallel computing 
%
if isfield(dkecluster,'scheduler'),
    %
    if dkecluster.scheduler.mode == 1,%General matlab toolbox distributed computing environment (mdce), calculations may be local or not local
        %
        [flag,varargout{:}] = create_loop_jd(@jobcomputing,fun,args_in,arg_index,arg_range,dkecluster.scheduler);
        %
    elseif dkecluster.scheduler.mode == 2,%LUKE distributed computing environment (ldce)
        %
        [flag,varargout{:}] = create_loop_jd(@dclukecomputing,fun,args_in,arg_index,arg_range,dkecluster.scheduler);
        %
    elseif dkecluster.scheduler.mode == 3,
        %
        [flag,varargout{:}] = process_loop_jd(@parcomputing,fun,args_in,arg_index,arg_range,dkecluster.scheduler);
        %
    elseif dkecluster.scheduler.mode == 4,
        %
        [flag,varargout{:}] = process_loop_jd(@gpucomputing,fun,args_in,arg_index,arg_range,dkecluster.scheduler);
        %
    elseif dkecluster.scheduler.mode < 0,% remote computing on cluster dkepath.remote(-dkecluster.scheduler.mode)
        %
        [flag,varargout{:}] = create_loop_jd(@remcomputing,fun,args_in,arg_index,arg_range,dkecluster.scheduler);
        %
    else
        if dkecluster.scheduler.display,disp(['---> ''for'' loop for the function ',func2str(fun),'.m']);end
    	[flag,varargout{:}] = seqcomputing(fun,args_in,arg_index,arg_range);
    end
    %
elseif isfield(dkecluster,'batch'),
    % not yet implemented
end
end
%
% This function divides the MDCE calculation in groups for the methods that require it (DCLUKE, JOB MDCE)
%
function [flag,varargout] = create_loop_jd(method,fun,args_in,arg_index,arg_range,scheduler)
%
narg_range = length(arg_range);
flag = NaN(1,narg_range);
%
varargout = cell(1,nargout-1);
%
for j_nargout = 1:nargout-1,
    varargout{j_nargout} = cell(narg_range,1);
end
%
for iloop_full = 1:ceil(narg_range/scheduler.clustersize),%to adapt the calculations to the size of the dkecluster  
    %
    range_index = (iloop_full-1)*scheduler.clustersize + 1:min(iloop_full*scheduler.clustersize,narg_range);
    %
    varargout_dcl = cell(1,nargout-1);
    %
    [flag(range_index),varargout_dcl{:}] = process_loop_jd(method,fun,args_in,arg_index,arg_range(range_index),scheduler);
    %
    for j_nargout = 1:nargout-1,
        varargout{j_nargout}(range_index) = varargout_dcl{j_nargout};
    end	
    %
end
%
end
%
% This function calls the chosen MDCE method and reverts to sequential computing in case of failure
%
function [flag,varargout] = process_loop_jd(method,fun,args_in,arg_index,arg_range,scheduler)
%
if scheduler.display,
    disp(['---> Method ''',func2str(method),''' to process loop for the function ',func2str(fun),'.m']);
end
%
mkdir(scheduler.temppath);
fileattrib(scheduler.temppath,'+w');
%
varargout = cell(1,nargout-1);
%
[flag,varargout{:}] = method(fun,args_in,arg_index,arg_range,scheduler);
%
try
    rmdir(scheduler.temppath,'s');
catch
    disp(['WARNING : tmp directory ',scheduler.temppath,' could not be removed.'])
end
%
mask_seq = (flag < 0);%flagged for sequential computing
%
if any(mask_seq) && (~isfield(scheduler,'enforce') || scheduler.enforce == 1),%back to sequential computing (for robustness of the function in case of problems on the cluster)
    %
    disp(['WARNING: Distributed computing failed for ',num2str(sum(mask_seq)),'/',num2str(length(mask_seq)),' cases. Switching to sequential computing for these cases.']);
    %
    varargout_seq = cell(1,nargout-1);
    [flag(mask_seq),varargout_seq{:}] = seqcomputing(fun,args_in,arg_index,arg_range(mask_seq));
    %
    for j_nargout = 1:nargout-1,
        varargout{j_nargout}(mask_seq) = varargout_seq{j_nargout};
    end	
    %
end
%
end



