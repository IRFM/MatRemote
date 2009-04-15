function [cluster] = clustermode_luke(param,fun,cdisp);
%LUKE - Test cluster properties
%
% This function tests cluster properties and generate default values
%
% by J. Decker (CEA-IRFM) <joan.decker@cea.fr> and   Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr>
%
%
if nargin < 3,
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
    cluster.display = cdisp;
end
%
if isstruct(param),    
    if isfield(param,fun),
        if isfield(param.(fun),'mode'),
            cluster.mode = param.(fun).mode;
        else
            cluster.mode = 0;
        end
        %
        if isfield(param.(fun),'timeout'),
            cluster.timeout = param.(fun).timeout;
        else
            cluster.timeout = 60*10;%(s) ten minutes time out
        end
        %
        if isfield(param.(fun),'size'),
            cluster.size = param.(fun).size;
        else
            cluster.size = 1;
        end            
    elseif isfield(param,'multithreading'),
        multithreading_luke(param.multithreading);
    else
        cluster.mode = 0;
    	cluster.timeout = 100;%Jump into sequential processing if distributed processing is blocked (s)
        cluster.size = 1;  
        multithreading_luke('automatic');
    end
else
    cluster.mode = param;
    cluster.timeout = 100;%Jump into sequential processing if distributed processing is blocked (s)
    cluster.size = 1;
    multithreading_luke('automatic');              
end
%
flag_mdcetoolbox = 0;
cluster.info = 'Sequential mode chosen.';
%
try,%test the availability of the MatLab MDCE toolbox
    jm = findResource('scheduler','type','generic');
    flag_mdcetoolbox = 1;
end
%
if cluster.mode == 1 & flag_mdcetoolbox,
	cluster.info = 'Distributed computing mode with MatLab MDCE toolbox chosen.';
end
%   
% For LUKE distributed computing with batch queuing
%
if exist('dcluke_batch.sh') & exist('dcluke_etat.sh') & exist('dcluke_kill.sh') & exist('dcluke_kill.sh') & exist('dcluke.exe'),
 	[s,t] = unix('qsub --version');%test qsub command is recognized for batch queuing
 	if isempty(strfind(t,'command not found')),
		if cluster.mode == 2,
			cluster.info = 'Distributed computing mode with LUKE scripts chosen.';
     	end
     else	
		if cluster.mode == 2,
			if flag_mdcetoolbox,
				cluster.mode == 1;
				cluster.info = 'Batch queuing system for distributed computing not installed for this machine, but MatLab MDCE toolbox available. MDCE mode enforced.';
			else
				cluster.mode == 0;
				cluster.info = 'No distributed computing capabilities. Sequential mode enforced.';
			end
		end       	
	end
else
	if cluster.mode == 2,
		if flag_mdcetoolbox,
			cluster.mode == 1;
			cluster.info = 'Batch queuing scripts for distributed computing not available for this machine, but MatLab MDCE toolbox available. MDCE mode enforced.';
		else
			cluster.mode == 0;
			cluster.info = 'No distributed computing capabilities. Sequential mode enforced.';
		end
	end
end
%
if flag_mdcetoolbox,
	cluster.temppath = [pwd,'mdce_',timeid_jd(clock)];
	mkdir(cluster.temppath);
end
%
