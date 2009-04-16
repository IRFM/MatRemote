function [dkecluster] = clustermode_luke(param,fun,cdisp);
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
        dkecluster.display = 0;
    else 
        dkecluster.display = cdisp.mdce;
    end
else
    dkecluster.display = cdisp;
end
%
if isstruct(param),    
    if isfield(param,fun),
        if isfield(param.(fun),'mode'),
            dkecluster.mode = param.(fun).mode;
        else
            dkecluster.mode = 0;
        end
        %
        if isfield(param.(fun),'timeout'),
            dkecluster.timeout = param.(fun).timeout;
        else
            dkecluster.timeout = 60*10;%(s) ten minutes time out
        end
        %
        if isfield(param.(fun),'size'),
            dkecluster.size = param.(fun).size;
        else
            dkecluster.size = 1;
        end            
    else
        dkecluster.mode = 0;
    	dkecluster.timeout = 100;%Jump into sequential processing if distributed processing is blocked (s)
        dkecluster.size = 1;  
    end
else
    dkecluster.mode = param;
    dkecluster.timeout = 100;%Jump into sequential processing if distributed processing is blocked (s)
    dkecluster.size = 1;
end
%
flag_mdcetoolbox = 0;
dkecluster.info = 'Sequential mode chosen.';
%
try,%test the availability of the MatLab MDCE toolbox
    jm = findResource('scheduler','type','generic');
    flag_mdcetoolbox = 1;
end
%
if dkecluster.mode == 1 & flag_mdcetoolbox,
	dkecluster.info = 'Distributed computing mode with MatLab MDCE toolbox chosen.';
end
%   
% For LUKE distributed computing with batch queuing
%
if exist('dcluke_batch.sh') & exist('dcluke_etat.sh') & exist('dcluke_kill.sh') & exist('dcluke_kill.sh') & exist('dcluke.exe'),
 	[s,t] = unix('qsub --version');%test qsub command is recognized for batch queuing
 	if isempty(strfind(t,'command not found')),
		if dkecluster.mode == 2,
			dkecluster.info = 'Distributed computing mode with LUKE scripts chosen.';
			flag_mdcetoolbox = 2;
     	end
     else	
		if dkecluster.mode == 2,
			if flag_mdcetoolbox,
				dkecluster.mode == 1;
				dkecluster.info = 'Batch queuing system for distributed computing not installed for this machine, but MatLab MDCE toolbox available. MDCE mode enforced.';
			else
				dkecluster.mode == 0;
				dkecluster.info = 'No distributed computing capabilities. Sequential mode enforced.';
			end
		end       	
	end
else
	if dkecluster.mode == 2,
		if flag_mdcetoolbox,
			dkecluster.mode == 1;
			dkecluster.info = 'Batch queuing scripts for distributed computing not available for this machine, but MatLab MDCE toolbox available. MDCE mode enforced.';
		else
			dkecluster.mode == 0;
			dkecluster.info = 'No distributed computing capabilities. Sequential mode enforced.';
		end
	end
end
%
if flag_mdcetoolbox,
	dkecluster.temppath = [pwd,'/mdce_',timeid_jd(clock),'/'];
	mkdir(dkecluster.temppath);
end
%
