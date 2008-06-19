function [cluster] = clustermode_luke(cdisp,param,ppath,fun);
%LUKE - Test cluster properties
%
% This function tests cluster properties
%
% by J. Decker (CEA-IRFM) <joan.decker@cea.fr> and   Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr>
%
    if nargin == 0,
        cdisp = 0;
        param = 0;
        ppath = '';
        fun = '';
    end
    %
    if nargin > 0 & nargin < 4,
        error('Wrong number of input arguments in clustermode_luke.m')
    end
    %
    if isstruct(cdisp),
        if ~isfield(cdisp,'mdce'),
            cluster.display = 0;
        else 
            cluster.display = cdisp.mdce;
        end
    else
        cluster.display = 0;
    end
    %
    if isstruct(param),    
        if isfield(param,'clustermode'),
            if isfield(param.clustermode,fun),
                if isfield(param.clustermode.(fun),'mode'),
                    cluster.mode = param.clustermode.(fun).mode;
                else
                    cluster.mode = 0;
                end
                %
                if isfield(param.clustermode.(fun),'timeout'),
                    cluster.timeout = param.clustermode.(fun).timeout;
                else
                    cluster.timeout = 60*10;%(s) ten minutes time out
                end
                %
                if isfield(param.clustermode.(fun),'size'),
                    cluster.size = param.clustermode.(fun).size;
                else
                    cluster.size = 1;
                end            
            elseif isfield(param.clustermode,'multithreading'),
                multithreading_luke(param.clustermode.multithreading);
            else
                cluster.mode = 0;
                cluster.timeout = 0;
                cluster.size = 1;  
                multithreading_luke('automatic');
            end
        else
            cluster.mode = 0;
            cluster.timeout = 0;
            cluster.size = 1;
            multithreading_luke('automatic');
        end
    else
        cluster.mode = 0;
        cluster.timeout = 0;
        cluster.size = 1;
        multithreading_luke('automatic');              
    end
    %
    if isempty(ppath),
       cluster.path = '';
    else
		cluster.path = ppath; 
		cluster.path = '';
    end
    %
    flag_mdcetoolbox = 0;
    %
    if cluster.mode == 1,
        try,%test if MDCE toolbox is available
            jm = findResource('scheduler','type','generic');
            flag_mdcetoolbox = 1;
        end
    elseif cluster.mode == 2,
		if exist('dcluke'),
			[s,t] = unix('qsub xxxxxxxxxx');
			if isempty(strfind(t,'command not found')),
				flag_mdcetoolbox = 1;
			end
		end    
    end
    %
    if isempty(cluster.path) & cluster.mode == 1 & flag_mdcetoolbox,
        cluster.path = fullfile(getenv('HOME'),'mdce_');
        disp(['WARNING: Temporary path directory name for distributed computing is ',cluster.path]);
    end           
end