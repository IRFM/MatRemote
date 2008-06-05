function [flag,varargout] = mdce_luke(fun,args_in,arg_index,arg_range,nprocmax,dkepath,dkedisplay,mode)
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
%
configmat = ver('Distributed');
%
flag = 0;
%
if ~isempty(configmat),
    for is = 1:length(configmat),
        if strfind(configmat(is),'Distributed Computing Toolbox'),
            flag = 1;
            break;
        end
    end
end
%
if ~flag,
    if dkedisplay.display_mode,info_dke_yp(2,'The MatLab Distributed Computing Toolbox is not available for LUKE calculations.');end   
elseif flag & mode
    if dkedisplay.display_mode,info_dke_yp(2,'The MatLab Distributed Computing Toolbox is available for LUKE calculations and is activated.');end 
elseif flag & ~mode
    if dkedisplay.display_mode,info_dke_yp(2,'The MatLab Distributed Computing Toolbox is available for LUKE calculations and is not activated.');end    
end
%
if flag & mode & (nprocmax > 1),%distributed computing
    %    
    jm = findResource('scheduler','type','generic');
    set(jm,'DataLocation',dkepath.temppath);
    set(jm,'HasSharedFileSystem',true);
    set(jm,'ClusterMatlabRoot',matlabroot);
    set(jm,'SubmitFcn',@pbsSubmitFcn)
    set(jm,'ParallelSubmitFcn',@pbsParallelSubmitFcn);
    %        
    nfulldis = fix(length(arg_range)/nprocmax);%Number of cycles with nprocmax processors
    npartialdis = length(arg_range) - nfulldis*nprocmax;%Number of cycles with less than nprocmax processors
    %
    ifulldis = 0;
    %
    for ifulldis = 1:nfulldis,
        job = createJob(jm);
        %
        for j = 1:nprocmax,
            args_in{arg_index} = arg_range{(ifulldis - 1)*nprocmax + j};
            createTask(job,fun,length(args_in),args_in);
        end
        %
        submit(job);
        %
        waitForState(job);
        %
        args_temp{ifulldis} = getAllOutputArguments(job);
        %
        destroy(job);
    end
    %
    for ipartialdis = ifulldis+1:npartialdis,
        job = createJob(jm);
        %
        for j = 1:npartialdis,
            args_in{arg_index} = arg_range{(ipartialdis - 1)*nprocmax + j};
            createTask(job,fun,length(args_in),args_in);
        end
        %
        submit(job);
        %
        waitForState(job);
        %
        args_temp{ipartialdis} = getAllOutputArguments(job);
        %
        destroy(job);
    end
    %
    args_out = args_temp{:};
    %
else,%sequential computing
    %
    for j_range = 1:length(arg_range),
        cmd = ['[arg_out{1,',int2str(j_range),'}'];
        if nargout-1 > 1,
            for j_nargout = 2:nargout-1,
                cmd = [cmd,',arg_out{',int2str(j_nargout),',',int2str(j_range),'}'];
            end
        end
        cmd = [cmd,'] = feval(fun,args_in{:});'];      
        args_in{arg_index} = arg_range{j_range};
        eval(cmd);
    end
    %
    for j_nargout = 1:nargout-1,
        varargout{j_nargout} = arg_out(j_nargout,:);
    end
end