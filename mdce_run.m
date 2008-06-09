function [flag,varargout] = mdce_luke(fun,args_in,arg_index,arg_range,nprocmax,dkepath,mdcedisplay,mode,timeout)
%LUKE - Distributed LUKE calculations on multiple processors if MatLab Distributed Computing Environment (toolbox) is available
%
%   Distribute LUKE calculations on multiple processor if MatLab Distributed Computing Environment (toolbox) is available
%
%   INPUT:
%
%       - fun: function handle
%       - args_in: input arguments list of the function
%       - arg_index: index in the argument list args_in which must be changed
%       - arg_range: list of values to be calcualted for the input argument arg_index, length(arg_range) = number of times a calculation must be performed
%       - nprocmax: maximum number of processors on which the calculation is distributed
%       - dkepath: dkepath structure
%       - mode: if ~0, distributed computing can be performed if available
%
%   OUTPUT:
%
%       - args_out: output arguments list of the function
%       - flag: if 0, the MatLab Distributed Computing Toolbox is not available for LUKE calculations
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
	if nargin < 8,error('');end
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
	if nargin < 9,
		timeout = 60*5;%default timeout (s)
	end
	%
	temppath = [dkepath.temppathroot,timeid_jd(clock)];
	mkdir(temppath);%Create calculation directory
	%
	configmat = ver;
	%
	flag = 0;
	%
	if ~isempty(configmat),
	    for is = 1:length(configmat),
	        if ~isempty(strfind(configmat(is).Name,'Distributed Computing Toolbox')),
	             flag = 1;
	            break;
	        end
	    end
	end
	%
	if ~flag,
	    if mdcedisplay,info_dke_yp(2,'The MatLab Distributed Computing Toolbox is not available for LUKE calculations.');end   
	elseif flag & mode
	    if mdcedisplay,info_dke_yp(2,'The MatLab Distributed Computing Toolbox is available for LUKE calculations and is activated.');end 
	elseif flag & ~mode
	    if mdcedisplay,info_dke_yp(2,'The MatLab Distributed Computing Toolbox is available for LUKE calculations and is not activated.');end    
	end
	%
	if flag & mode,%Initiate the job server
		try,
			jm = findResource('scheduler','type','generic');
			set(jm,'DataLocation',temppath);
	    	set(jm,'HasSharedFileSystem',true);
	    	set(jm,'ClusterMatlabRoot',matlabroot);
	    	set(jm,'SubmitFcn',@pbsSubmitFcn);
	    	set(jm,'ParallelSubmitFcn',@pbsParallelSubmitFcn);
		catch
			jm = [];%Number of users exceed number of DIstributed Computing Toolbox licenses or the toolbox is not available or MatLab version is less than 7.5 (R2007B)
	    	info_dke_yp(2,['WARNING: calculations are performed on a single processor since the scheduler is not available (MatLab version too old, limited number of licenses,...) ',func2str(fun),'.m']);    
		end
	end
	%
	if flag & mode & (nprocmax > 1) & (nargout >= 2) & ~isempty(jm),%distributed computing environment
	    %
	    job = createJob(jm);
	    %
	    for ijob = 1:length(arg_range),
	        args_in{arg_index} = arg_range{ijob};
	        arg_job{ijob} = args_in;      
	    end
		% 
	    createTask(job, fun, nargout-1,arg_job);
	    submit(job)
	    waitForState(job, 'finished', timeout)
	    jobstate = get(job, 'State');
	%
	    if strcmp(jobstate,'finished'),
	    	%
	    	args_out = getAllOutputArguments(job);
	    	%
	    	destroy(job);
	    	%
	    	for j_nargout = 1:nargout-1,
	        	varargout{j_nargout} = args_out(1:end,j_nargout);
	    	end
	    else,%back to sequential computing (for robustness of the function in case of problems on the cluster)
	    	destroy(job);
	    	info_dke_yp(2,['WARNING: calculations are performed on a single processor since distributed computing timed out using ',func2str(fun),'.m']);    
	    	flag = -1;%timeout case
	    	[varargout] = seqcomputing(fun,args_in,arg_index,arg_range,nargout);
	    end
	    %
	else,%sequential computing
		[varargout] = seqcomputing(fun,args_in,arg_index,arg_range,nargout);
	end
	%
	rmdir(temppath,'s');%Remove calculation directory
end

function [results] = seqcomputing(fun,args_in,arg_index,arg_range,nargout_in)
%
%
%
    for j_range = 1:length(arg_range),
        cmd = ['[arg_out{1,',int2str(j_range),'}'];
        if nargout_in-1 > 1,
            for j_nargout_in = 2:nargout_in-1,
                cmd = [cmd,',arg_out{',int2str(j_nargout),',',int2str(j_range),'}'];
            end
        end
        cmd = [cmd,'] = feval(fun,args_in{:});'];      
        args_in{arg_index} = arg_range{j_range};
        eval(cmd);
    end
    %
    for j_nargout = 1:nargout_in-1,
        results{j_nargout} = reshape(arg_out(j_nargout,:),length(arg_range),1);
    end
end


