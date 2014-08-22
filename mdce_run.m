function [flag,varargout] = mdce_run(fun,args_in,arg_index,arg_range,dkecluster)
    %
    % Distributed calculations on multiple processors
    %
    %   Function for distributing calculations on multiple processors:
    %		 - option 1) with MatLab Distributed Computing Environment (toolbox) if available : job scheduler or parfor options
    %		 - option 2) with remcomputing, on a local or remote cluster
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
    %       - flag: if 0, the MatLab Distributed Computing Toolbox is not available
    %       - varargout: output arguments list of the function
    %
    %   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
    %
    if nargin < 4,
        error('Wrong number of input arguments in mdce_run.m !');
    end
    %
    if nargin < 5,
        dkecluster = [];
    end
    %
    if isempty(arg_index)
        error('The argument ''arg_index'' in mdce_run.m must be defined !');
    end
    if ~isfinite(arg_index),
        error('The argument ''arg_index'' in mdce_run.m must be finite !');
    end
    if isnan(arg_index),
        error('The argument ''arg_index'' in mdce_run.m cannot be a NaN !');
    end
    if arg_index == 0,
        error('The argument ''arg_index'' in mdce_run.m cannot be a zero !');
    end        
    if arg_index > length(args_in),
        error(['The argument ''arg_index'' in mdce_run.m cannot be greater than ',str2num(length(args_in)),' !']);
    end        
    if isempty(arg_range)
        error('The argument ''arg_range'' in mdce_run.m must be defined !');
    end
    %
    if nargout < 1,
        error('At least one output argument (flag) must be defined.');
    end
    %
    if ischar(fun),
        fun = str2func(fun);
    end
    %
    if ~iscell(arg_range),
        if isnumeric(arg_range),
            if size(arg_range,1) == 1 || size(arg_range,2) == 1,
                arg_range = num2cell(arg_range(:));% case where arg_range is a vector defining instances
            else
                arg_range = num2cell(arg_range,1);% case where instances are defined by size(arg_range,1)
            end
        elseif isstruct(arg_range),
            narg_range = length(arg_range);
            new_arg_range = cell(1,narg_range);
            for i_range = 1:narg_range,
                new_arg_range{i_range} = arg_range(i_range);
            end
            arg_range = new_arg_range;
        else
            error('The argument ''arg_range'' in mdce_run.m must be a list or an array object');
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
    % remote calculation - mdce_run is exported to remote cluster
    %
    if isfield(dkecluster,'remote'),
        %
        [flag_remote,varargout{:}] = mdce_remote(fun,args_in,arg_index,arg_range,dkecluster);
        %
        mask_loc = (flag_remote < 0);%flagged for local computing
        %
        flag = zeros(size(flag_remote));
        %
        if any(mask_loc) && (~isfield(dkecluster,'scheduler') || ~isfield(dkecluster.scheduler,'enforce') || dkecluster.scheduler.enforce == 1),%back to local computing 
            %
            disp(['WARNING: Remote distributed computing failed for ',num2str(sum(mask_loc)),'/',num2str(length(mask_loc)),' cases. Switching to local computing for these cases.']);
            %
            dkecluster_loc = mdce_clustermode(dkecluster.scheduler);% local dkecluster
            %
            varargout_loc = cell(1,nargout-1);
            [flag(mask_loc),varargout_loc{:}] = mdce_run(fun,args_in,arg_index,arg_range(mask_loc),dkecluster_loc);
            %
            for j_nargout = 1:nargout-1,
                varargout{j_nargout}(mask_loc) = varargout_loc{j_nargout};
            end	
            %
        end
        %
        flag = flag_remote + 1i*flag;
        %
        return
        %
    end
    %
    flag = 0;
    %
    if isempty(dkecluster),
        dkecluster = mdce_clustermode;%All cluster parameters and paths (sequential mode by default)
    end
    %
    % Parameter validation of different parallel computing techniques
    %
    if isfield(dkecluster,'scheduler'),
        if ~isfield(dkecluster.scheduler,'mode'),
            dkecluster = mdce_clustermode;%All cluster parameters and paths (sequential mode by default)
            disp('WARNING: distributed computing is inconsistently set-up: ''mode'' must be chosen. Sequential mode enforced.');
        else
            if ~isfield(dkecluster.scheduler,'temppath'),
                dkecluster.scheduler.temppath = [pwd,filesep,'mdce_',timeid_jd(clock),filesep];%Local calculation
            end
            %    
            if ~isfield(dkecluster.scheduler,'info'),
                dkecluster.scheduler.info = 'Default parallel computing set-up by mdce_run.m function.';
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
        dkecluster = mdce_clustermode;%All cluster parameters and paths (sequential mode by default)
        disp('WARNING: batch parallel computing is not yet implemented. Sequential mode enforced.');
    else
        dkecluster = mdce_clustermode;%All cluster parameters and paths (sequential mode by default)
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
        elseif dkecluster.scheduler.mode == 2,% Parallel computing toolbox, parfor
            %
            [flag,varargout{:}] = process_loop_jd(@parcomputing,fun,args_in,arg_index,arg_range,dkecluster.scheduler);
            %
        elseif dkecluster.scheduler.mode == 3,% remote computing on cluster dkecluster.scheduler.remote
            %
            [flag,varargout{:}] = create_loop_jd(@remcomputing,fun,args_in,arg_index,arg_range,dkecluster.scheduler);
            %
        else
            if dkecluster.scheduler.display,disp(['---> ''for'' loop for the function ',func2str(fun),'.m']);end
            [flag,varargout{:}] = seqcomputing(fun,args_in,arg_index,arg_range,dkecluster.scheduler);
        end
        %
    elseif isfield(dkecluster,'batch'),
        % not yet implemented
    end
end
%
% This function divides the MDCE calculation in groups for the methods that require it (JOB MDCE, remcomputing)
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
        %
        if isfield(scheduler,'gpu'),
            gpu_status = scheduler.gpu;
            scheduler.gpu = 0;%no GPU when distributed computing failed
        end
        %
        [flag(mask_seq),varargout_seq{:}] = seqcomputing(fun,args_in,arg_index,arg_range(mask_seq),scheduler);
        %
        if isfield(scheduler,'gpu'),
            scheduler.gpu = gpu_status;%back to the initial GPU status
        end
        %
        for j_nargout = 1:nargout-1,
            varargout{j_nargout}(mask_seq) = varargout_seq{j_nargout};
        end	
        %
    end
    %
end



