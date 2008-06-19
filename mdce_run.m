function [flag,varargout] = mdce_luke(fun,args_in,arg_index,arg_range,cluster)
%LUKE - Distributed LUKE calculations on multiple processors
%
%   Function for distributing LUKE calculations on multiple processors:
%		 - option 1) with MatLab Distributed Computing Environment (toolbox) if available
%		 - option 2) if dcluke library is set up for LUKE (see ~/LUKE/Project_DKE/Packages/MDCE/dcluke/)
%
%   INPUT:
%
%       - fun: function handle
%       - args_in: input arguments list of the function
%       - arg_index: index in the argument list args_in which must be changed
%       - arg_range: list of values to be calcualted for the input argument arg_index, length(arg_range) = number of times a calculation must be performed
%       - cluster: cluster parameters (structure)
%
%   OUTPUT:
%
%       - flag: if 0, the MatLab Distributed Computing Toolbox is not available for LUKE calculations
%       - varargout: output arguments list of the function
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
	if nargin < 4,error('Wrong number of input arguments in mdce_luke.m !');end
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
	if nargin < 5,
        [cluster] = clustermode_luke;%default values
	end
	%
	temppath = [cluster.path,timeid_jd(clock)];
	mkdir(temppath);%Create calculation directory
	%
	if cluster.mode == 1,
		configmat = ver;
		if ~isempty(configmat),
	    	for is = 1:length(configmat),
	        	if ~isempty(strfind(configmat(is).Name,'Distributed Computing Toolbox')),
	             	flag = 1;
	            	break;
	           	else
	           		flag = -1;
	        	end
	    	end
		end
	elseif cluster.mode == 2,
		if exist('dcluke'),
			[s,t] = unix('qsub xxxxxxxxxx');
			if isempty(strfind(t,'command not found')),
				flag = 2;
			else
				flag = -2;
			end
		end
	else
		flag = 0;
	end
	%
	if flag == 0,
		if cluster.display,info_dke_yp(2,'The distributed computing environment is not activated.');end  
	elseif flag == 1 & cluster.mode == 1,
	    if cluster.display,info_dke_yp(2,'The MatLab Distributed Computing Toolbox is available for LUKE calculations and is activated.');end 
	elseif flag == -1 & ~cluster.mode == 1,
	    if cluster.display,info_dke_yp(2,'The MatLab Distributed Computing Toolbox is not available for LUKE calculations.');end   
	elseif flag == 2 & ~cluster.mode == 2,
	    if cluster.display,info_dke_yp(2,'The LUKE Distributed Computing Toolbox is available for LUKE calculations and can be used.');end 
	elseif flag == -2 & ~cluster.mode == 2,
	    if cluster.display,info_dke_yp(2,'The LUKE Distributed Computing Toolbox is available for LUKE calculations but batch queuing is not operational (install openPBS first).');end 
	end
	%
	if flag == 1 & cluster.mode == 1,%Initiate the job server
		try,
			jm = findResource('scheduler','type','generic');
			set(jm,'DataLocation',temppath);
	    	set(jm,'HasSharedFileSystem',true);
	    	set(jm,'ClusterMatlabRoot',matlabroot);
	    	set(jm,'SubmitFcn',@pbsSubmitFcn);
	    	set(jm,'ParallelSubmitFcn',@pbsParallelSubmitFcn);
	        set(jm,'ClusterSize', cluster.size);
%	        get(jm)
		catch
			jm = [];%Number of users exceed number of DIstributed Computing Toolbox licenses or the toolbox is not available or MatLab version is less than 7.5 (R2007B)
	    	info_dke_yp(2,['WARNING: calculations are performed on a single processor since the job scheduler is not available (MatLab version too old, limited number of licenses,...) for ',func2str(fun),'.m']);    
		end
	end
	%
	if flag == 1 & cluster.mode == 1 & (cluster.size >= 1) & (nargout >= 2) & ~isempty(jm),%distributed computing environment
	    %
	    for j_nargout = 1:nargout-1,
	    	varargout{j_nargout} = {};
	    end
	    %
	    for iloop_full = 1:floor(length(arg_range)/cluster.size),%to maximize chance to use the cluster in distributed computing mode
	    	job = createJob(jm);
	    	%
	    	arg_job = [];
	    	%
	    	for ijob = (iloop_full-1)*cluster.size + 1:(iloop_full-1)*cluster.size + cluster.size,
	        	args_in{arg_index} = arg_range{ijob};
	        	arg_job{ijob - (iloop_full-1)*cluster.size} = args_in;      
	    	end
			% 
	    	createTask(job, fun, nargout-1,arg_job);
	    	submit(job);
	    	waitForState(job, 'finished', cluster.timeout);
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
	    		info_dke_yp(2,['WARNING: calculations are performed on a single processor since distributed computing timed out (',int2str(cluster.timeout),' s) using ',func2str(fun),'.m']);    
	    		flag = -1;%timeout case
	    		args_temp = seqcomputing(fun,args_in,arg_index,arg_range((iloop_full-1)*cluster.size + 1:(iloop_full-1)*cluster.size + cluster.size),nargout);		
	    		args_out = '';
	    		for iarg = 1:length(args_temp),
	    			args_out = [args_out,args_temp{iarg}];
	    		end
	    	end
	    	%
	    	for j_nargout = 1:nargout-1,
				if isempty(args_out),
					varargout{j_nargout} = {''};
					info_dke_yp(2,['WARNING: output is empty using ',func2str(fun),'.m']);    
				else
					varargout{j_nargout} = [varargout{j_nargout};args_out(1:end,j_nargout)];
				end 
             end	
	   	end
		%	
	    if length(arg_range) - floor(length(arg_range)/cluster.size)*cluster.size,%to maximize chance to use the cluster in distributed computing mode, residual part
	    	job = createJob(jm);
	    	%
	    	arg_job = [];
	    	%
	    	if isempty(iloop_full),iloop_full = 0;end
	    	%
	    	for ijob = iloop_full*cluster.size + 1:length(arg_range)
	        	args_in{arg_index} = arg_range{ijob};
	        	arg_job{ijob - iloop_full*cluster.size} = args_in;      
	    	end
			% 
	    	createTask(job, fun, nargout-1,arg_job);
	    	submit(job);
	    	waitForState(job, 'finished', cluster.timeout);
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
	    		info_dke_yp(2,['WARNING: calculations are performed on a single processor since distributed computing timed out (',int2str(cluster.timeout),' s) using ',func2str(fun),'.m']);    
	    		flag = -1;%timeout case
	    		args_temp = seqcomputing(fun,args_in,arg_index,arg_range(iloop_full*cluster.size + 1:length(arg_range)),nargout);
	    		args_out = '';
	    		for iarg = 1:length(args_temp),
	    			args_out = [args_out,args_temp{iarg}];
	    		end
	    	end
	    	%
	    	for j_nargout = 1:nargout-1,
				if isempty(args_out),
					varargout{j_nargout} = {''};
					info_dke_yp(2,['WARNING: output is empty using ',func2str(fun),'.m']);    
				else
					varargout{j_nargout} = [varargout{j_nargout};args_out(1:end,j_nargout)];
				end 
             end	
	    	
	   	end	   	
	    %
	elseif flag == 2 & cluster.mode == 2 & (nargout >= 2),%distributed computing environment
		[flag,varargout] = dclukecomputing(fun,args_in,arg_index,arg_range,nargout);
		if flag == -2,
			info_dke_yp(2,['WARNING: calculations are performed on a single processor since LUKE distributed computing had a network problem while using ',func2str(fun),'.m']);    
			info_dke_yp(2,['WARNING: see the diary files to identify it.']);    
			[varargout] = seqcomputing(fun,args_in,arg_index,arg_range,nargout);
		end
	else,%sequential computing
		[varargout] = seqcomputing(fun,args_in,arg_index,arg_range,nargout);
	end
	%
	rmdir(temppath,'s');%Remove calculation directory
end

function [results] = seqcomputing(fun,args_in,arg_index,arg_range,nargout_in)
%LUKE - Sequential computing of the loop in case of failure of the Distributed Computing Environment
%
%   Sequential computing of the loop in case of failure of the Distributed Computing Environment
%
%   INPUT:
%
%       - fun: function handle
%       - args_in: input arguments list of the function
%       - arg_index: index in the argument list args_in which must be changed
%       - arg_range: list of values to be calculated for the input argument arg_index, length(arg_range) = number of times a calculation must be performed
%       - nargout_in: number of output arguments in the parent function
%
%   OUTPUT:
%
%       - results: output arguments list of the function
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
    for j_range = 1:length(arg_range),
        cmd = ['[arg_out{1,',int2str(j_range),'}'];
        if nargout_in-1 > 1,
            for j_nargout = 2:nargout_in-1,
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

function [flag,results] = dclukecomputing(fun,args_in,arg_index,arg_range,nargout_in)
%LUKE - LUKE distributed computing environment
%
%   Distributed computing using the LUKE distributed computing environment
%
%   INPUT:
%
%       - fun: function handle
%       - args_in: input arguments list of the function
%       - arg_index: index in the argument list args_in which must be changed
%       - arg_range: list of values to be calculated for the input argument arg_index, length(arg_range) = number of times a calculation must be performed
%       - nargout_in: number of output arguments in the parent function
%
%   OUTPUT:
%
%		- flag: status of the computing (OK = 0, ERROR = 1)
%       - results: output arguments list of the function
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
    try,
    	dirini = pwd;
		if exist(fullfile(getenv('HOME'),'tmp'))
			cd(fullfile(getenv('HOME'),'tmp'));
			filelist = ls;
			if isempty(filelist),
				delete('*');
			end
		end
		cd(dirini);
		%
		dcluke(0,'RESET');
		%
    	for j_range = 1:length(arg_range),
        	args_in{arg_index} = arg_range{j_range};
        	id(j_range) =  dcluke(func2str(fun),args_in{:});      
    	end
    	%
    	dcluke;
    	%
    	for j_range = 1:length(arg_range),
        	cmd = ['[arg_out{1,',int2str(j_range),'}'];
        	if nargout_in-1 > 1,
            	for j_nargout = 2:nargout_in-1,
                	cmd = [cmd,',arg_out{',int2str(j_nargout),',',int2str(j_range),'}'];
            	end
        	end
        	cmd = [cmd,'] = dcluke(',int2str(id(j_range)),');'];      
        	eval(cmd);
    	end
    	%
    	for j_nargout = 1:nargout_in-1,
        	results{j_nargout} = reshape(arg_out(j_nargout,:),length(arg_range),1);
    	end
    	%
    	flag = 2;
    catch
        for j_nargout = 1:nargout_in-1,
        	results{j_nargout} = '';
    	end
    	flag = -2;
    end
    %
end