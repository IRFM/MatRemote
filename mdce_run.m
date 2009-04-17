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
%       - arg_range: list of values to be calcualted for the input argument arg_index, length(arg_range) = number of times a calculation must be performed
%       - dkecluster: cluster parameters (structure)
%
%   OUTPUT:
%
%       - flag: if 0, the MatLab Distributed Computing Toolbox is not available for LUKE calculations
%       - varargout: output arguments list of the function
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
if nargin < 5,
    error('Wrong number of input arguments in mdce_luke.m !');
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
        arg_range = num2cell(arg_range(:));
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
if dkecluster.mode == 1,%Initiate the job server
    %
    try,
        jm = findResource('scheduler','type','generic');
        set(jm,'DataLocation',dkecluster.temppath);
        set(jm,'HasSharedFileSystem',true);
        set(jm,'ClusterMatlabRoot',matlabroot);
        set(jm,'SubmitFcn',@pbsSubmitFcn);
        set(jm,'ParallelSubmitFcn',@pbsParallelSubmitFcn);
        set(jm,'ClusterSize', dkecluster.size);
%	        get(jm)
    catch
        jm = [];%Number of users exceed number of Distributed Computing Toolbox licenses or the toolbox is not available or MatLab version is less than 7.5 (R2007B)
        info_dke_yp(2,['WARNING: calculations are performed on a single processor since the job scheduler is not available (MatLab version too old, limited number of licenses,...) for ',func2str(fun),'.m']);
    end
end
%
if dkecluster.mode == 1 & (dkecluster.size >= 1) & (nargout >= 2) & ~isempty(jm),%Matlab toolbox distributed computing environment (mdce)
    %
    for j_nargout = 1:nargout-1,
        varargout{j_nargout} = {};
    end
    %
    for iloop_full = 1:floor(narg_range/dkecluster.size),%to adapt the calculations to the size of the dkecluster 
        job = createJob(jm);
        %
        arg_job = [];
        %
        for ijob = (iloop_full-1)*dkecluster.size + 1:(iloop_full-1)*dkecluster.size + dkecluster.size,
            args_in{arg_index} = arg_range{ijob};
            arg_job{ijob - (iloop_full-1)*dkecluster.size} = args_in;      
        end
        % 
        createTask(job, fun, nargout-1,arg_job);
        submit(job);
        waitForState(job, 'finished', dkecluster.timeout);
        jobstate = get(job, 'State');
        %
        if strcmp(jobstate,'finished'),
            %
            args_out = getAllOutputArguments(job);
            %
            destroy(job);
            %
        else,%back to sequential computing (for robustness of the function in case of problems on the cluster)
            destroy(job);
            info_dke_yp(2,['WARNING: calculations are performed on a single processor since distributed computing timed out (',int2str(dkecluster.timeout),' s) using the function ',func2str(fun),'.m']);    
            flag = -1;%timeout case
            args_out = seqcomputing(fun,args_in,arg_index,arg_range((iloop_full-1)*dkecluster.size + 1:(iloop_full-1)*dkecluster.size + dkecluster.size),nargout);		
        end
        %
        for j_nargout = 1:nargout-1,
            if isempty(args_out),
                varargout{j_nargout} = {''};
                info_dke_yp(2,['WARNING: output is empty using ',func2str(fun),'.m']);    
            else
                varargout{j_nargout} = [varargout{j_nargout};args_out{1:end,j_nargout}];
            end 
         end	
    end
    %	
    if narg_range - floor(narg_range/dkecluster.size)*dkecluster.size,%to maximize chance to use the cluster in distributed computing mode, residual part
        job = createJob(jm);
        %
        arg_job = [];
        %
        if isempty(iloop_full),iloop_full = 0;end
        %
        for ijob = iloop_full*dkecluster.size + 1:narg_range
            args_in{arg_index} = arg_range{ijob};
            arg_job{ijob - iloop_full*dkecluster.size} = args_in;      
        end
        % 
        createTask(job, fun, nargout-1,arg_job);
        submit(job);
        waitForState(job, 'finished', dkecluster.timeout);
        jobstate = get(job, 'State');
        %
        if strcmp(jobstate,'finished'),
            %
            args_out = getAllOutputArguments(job);
            %
            destroy(job);
            %
        else,%back to sequential computing (for robustness of the function in case of problems on the cluster)
            destroy(job);
            info_dke_yp(2,['WARNING: calculations are performed on a single processor since distributed computing timed out (',int2str(dkecluster.timeout),' s) using the function ',func2str(fun),'.m']);    
            flag = -1;%timeout case
            args_out = seqcomputing(fun,args_in,arg_index,arg_range(iloop_full*dkecluster.size + 1:narg_range),nargout);
        end
        %
        for j_nargout = 1:nargout-1,
            if isempty(args_out),
                varargout{j_nargout} = {''};
                info_dke_yp(2,['WARNING: output is empty using ',func2str(fun),'.m']);    
            else
                varargout{j_nargout} = [varargout{j_nargout};args_out{1:end,j_nargout}];
            end 
         end	

    end
    %
elseif dkecluster.mode == 2 && dkecluster.size >= 1,%distributed computing environment
    %
    for iloop_full = 1:ceil(narg_range/dkecluster.size),%to adapt the calculations to the size of the dkecluster  
        %
        range_index = (iloop_full-1)*dkecluster.size + 1:min(iloop_full*dkecluster.size,narg_range);
        %
        [flag,args_out] = dclukecomputing(fun,args_in,arg_index,arg_range(range_index),nargout-1,dkecluster);
        %
        if flag == - 2,%back to sequential computing (for robustness of the function in case of problems on the cluster)
            info_dke_yp(2,['WARNING: calculations are performed on a single processor because of a problem occured on the cluster using the function ',func2str(fun),'.m']);    
            args_out = seqcomputing(fun,args_in,arg_index,arg_range(range_index),nargout-1);		
        end
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
    end
    %
else %sequential computing
    %
    [varargout] = seqcomputing(fun,args_in,arg_index,arg_range,nargout-1);
    %
end
%


