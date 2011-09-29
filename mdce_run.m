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
    else
        error('The argument ''arg_range'' in mdce_luke.m must be a list or an array object');
    end
end
%
narg_range = length(arg_range);
%
varargout = cell(1,nargout-1);
flag = 0;
%
for j_nargout = 1:nargout-1,
    varargout{j_nargout} = {};
end
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
        disp('WARNING: parallel computing is inconsistently set-up: ''mode'' must be chosen. Sequential mode enforced.');
    else
        if ~isfield(dkecluster.scheduler,'temppath'),
            dkecluster.scheduler.temppath = [pwd,filesep,'mdce_',timeid_jd(clock),filesep];%Local calculation
        end
        %
        if ~isfield(dkecluster.scheduler,'type'),         
            dkecluster.scheduler.type = 'local';%Local calculations
        end
        %    
        if ~isfield(dkecluster.scheduler,'info'),
            dkecluster.scheduler.info = 'Default parallel computing set-up by mdce_luke.m function.';
        end
        %
        if ~isfield(dkecluster.scheduler,'display'),
            dkecluster.scheduler.display = 0;%No display
        end
        %
        if ~isfield(dkecluster.scheduler,'size'),
            dkecluster.scheduler.size = 1;%One core or processor
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
        if ~strcmp(dkecluster.scheduler.type,'local') && ~strcmp(dkecluster.scheduler.type,'generic') && ~strcmp(dkecluster.scheduler.type,'jobmanager') && ~strcmp(dkecluster.scheduler.type,'hpcserver') && ~strcmp(dkecluster.scheduler.type,'lsf') && ~strcmp(dkecluster.scheduler.type,'pbspro') && ~strcmp(dkecluster.scheduler.type,'torque') && ~strcmp(dkecluster.scheduler.type,'mpiexec'), 
            dkecluster.scheduler.type = 'local';
            disp('WARNING: the local scheduler has been enforced for distributed calculations because no scheduler type supported by Matlab has been recognized (mode 1).');
        end
        %
        try
            jm = findResource('scheduler','type',dkecluster.scheduler.type);%Initiate the job server for Matlab Distributed Computing Environment  
        catch
            jm = [];%Number of users exceed number of Distributed Computing Toolbox licenses or the toolbox is not available or MatLab version is less than 7.5 (R2007B)
            info_dke_yp(2,['WARNING: calculations are performed on a single processor since the job scheduler is not available (MatLab version too old, limited number of licenses, dkepath inconsistently set...) for ',func2str(fun),'.m (mode 1).']);
        end
        %
        if isfield(dkecluster.scheduler,'temppath'),
            if ~exist(dkecluster.scheduler.temppath, 'dir'),
               mkdir(dkecluster.scheduler.temppath);
               fileattrib(dkecluster.scheduler.temppath,'+w');
            end
        end
        %
        if isfield(dkecluster.scheduler,'temppath'),set(jm,'DataLocation',dkecluster.scheduler.temppath);end
        %
        ClusterSize = get(jm,'ClusterSize');
        %
        if isfield(dkecluster.scheduler,'size'),            
            if strcmp(dkecluster.scheduler.type,'local') && dkecluster.scheduler.size > 8,
                set(jm,'ClusterSize',8);
            else
                set(jm,'ClusterSize',dkecluster.scheduler.size);
            end
        end
        %
        if isfield(dkecluster.scheduler,'HasSharedFileSystem'),set(jm,'HasSharedFileSystem',dkecluster.scheduler.HasSharedFileSystem);end
        if isfield(dkecluster.scheduler,'ClusterMatlabRoot'),set(jm,'ClusterMatlabRoot',dkecluster.scheduler.ClusterMatlabRoot);end
        if isfield(dkecluster.scheduler,'SubmitFcn'),set(jm,'SubmitFcn',dkecluster.scheduler.SubmitFcn);end
        if isfield(dkecluster.scheduler,'ParallelSubmitFcn'),set(jm,'ParallelSubmitFcn',dkecluster.scheduler.ParallelSubmitFcn);end
        %
        if (nargout >= 2) && ~isempty(jm),
            %
            args_out = cell(narg_range,nargout-1);
            %
            for iloop_full = 1:narg_range,
                job{iloop_full} = createParallelJob(jm);
                %
                arg_job = args_in;  
                %
                arg_job{arg_index} = arg_range{iloop_full};
                %
                createTask(job{iloop_full}, fun, nargout-1,arg_job);
                %
                set(job{iloop_full},'MinimumNumberOfWorkers',1);
                set(job{iloop_full},'MaximumNumberOfWorkers',1);
                %
                %set(job{iloop_full},'FileDependencies',{'main_C3PO_jd.m'})
                %
                submit(job{iloop_full});
            end
            %
            flag_tot = 0;
            %
            while 1,
                for iloop_full = 1:narg_range,
                    flag_tot = flag_tot + waitForState(job{iloop_full},'finished');
                end
                %
                if flag_tot == narg_range,
                    break;
                else
                    flag_tot = 0;
                end
            end      
            %
            
            %
            for iloop_full = 1:narg_range,
                %
                if dkecluster.scheduler.display,
                    getDebugLog(jm,job{iloop_full})
                end
                %
                jobstate(iloop_full) = strcmp(get(job{iloop_full}, 'State'),'finished');
                %
                if jobstate(iloop_full),
                    out = getAllOutputArguments(job{iloop_full});
                    if ~isempty(out)
                        args_out(iloop_full,:) = out;
                    end
                    %
                    flag = -1;%timeout case
                end
            end       
            %       
            for iloop_full = 1:narg_range, 
                destroy(job{iloop_full});
            end                      
            %
            for iloop_full = 1:narg_range, 
                if ~jobstate(iloop_full),
                	args_out(iloop_full,:) = seqcomputing(fun,args_in,arg_index,{arg_range{iloop_full}},nargout-1);
                end
            end
            %
            for iloop_full = 1:narg_range, 
                if jobstate(iloop_full) && isempty(args_out{iloop_full}),
                	args_out(iloop_full,:) = seqcomputing(fun,args_in,arg_index,{arg_range{iloop_full}},nargout-1);
                    flag = -2;%Empty output
                end
            end
            %
            set(jm,'ClusterSize',ClusterSize);%back to the initial cluster size
        end
    	%
    	% Data output
    	%
    	for j_nargout = 1:nargout-1,
            if isempty(args_out),
                varargout{j_nargout} = {''};
                info_dke_yp(2,['WARNING: output is empty using ',func2str(fun),'.m']);    
            else
                varargout{j_nargout} = [varargout{j_nargout};args_out{1:end,j_nargout}];
            end 
        end
        %
    elseif dkecluster.scheduler.mode == 2,%LUKE distributed computing environment (ldce)
        %
        mkdir(dkecluster.scheduler.temppath);
        fileattrib(dkecluster.scheduler.temppath,'+w');
    	%
    	for iloop_full = 1:ceil(narg_range/dkecluster.scheduler.size),%to adapt the calculations to the size of the dkecluster  
            %
            range_index = (iloop_full-1)*dkecluster.scheduler.size + 1:min(iloop_full*dkecluster.scheduler.size,narg_range);
            %
            varargout_dcl = cell(1,nargout-1);
            [flag,varargout_dcl{:}] = dclukecomputing(fun,args_in,arg_index,arg_range(range_index),dkecluster.scheduler);
            %
            for j_nargout = 1:nargout-1,
                varargout{j_nargout}(range_index) = varargout_dcl{j_nargout};
            end	
            %
            mask_seq = (flag == -2);%flagged for sequential computing
            %
            if any(mask_seq) && (~isfield(dkecluster.scheduler,'enforce') || dkecluster.scheduler.enforce == 1),%back to sequential computing (for robustness of the function in case of problems on the cluster)
                varargout_seq = cell(1,nargout-1);
                [flag(mask_seq),varargout_seq{:}] = seqcomputing(fun,args_in,arg_index,arg_range(mask_seq));
                %
                for j_nargout = 1:nargout-1,
                    varargout{j_nargout}(mask_seq) = varargout_seq{j_nargout};
                end	
                %
            end
    	end
        %
    elseif dkecluster.scheduler.mode == 3,
        if dkecluster.scheduler.display,disp(['---> ''parfor'' loop for the function ',func2str(fun),'.m']);end
        [flag,varargout{:}] = parcomputing(fun,args_in,arg_index,arg_range);
        %
        mask_seq = (flag == -2);%flagged for sequential computing
        %
        if any(mask_seq) && (~isfield(dkecluster.scheduler,'enforce') || dkecluster.scheduler.enforce == 1),%back to sequential computing (for robustness of the function in case of problems on the cluster)
            varargout_seq = cell(1,nargout-1);
            [flag(mask_seq),varargout_seq{:}] = seqcomputing(fun,args_in,arg_index,arg_range(mask_seq));
            %
            for j_nargout = 1:nargout-1,
                varargout{j_nargout}(mask_seq) = varargout_seq{j_nargout};
            end	
            %
        end
    else
        if dkecluster.scheduler.display,disp(['---> ''for'' loop for the function ',func2str(fun),'.m']);end
    	[flag,varargout{:}] = seqcomputing(fun,args_in,arg_index,arg_range);
    end
    %
    if exist(dkecluster.scheduler.temppath, 'dir'),
        rmdir(dkecluster.scheduler.temppath,'s');
    end
    %
elseif isfield(dkecluster,'batch'),
    % not yet implemented
end



