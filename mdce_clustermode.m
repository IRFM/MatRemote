function [dkecluster] = clustermode_luke(param,fun,cdisp,remote,mem)
%LUKE - Test cluster properties
%
% This function tests cluster properties and generate default values
%
% by J. Decker (CEA-IRFM) <joan.decker@cea.fr> and   Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr>
%
%
if nargin < 4,
    remote = '';
end
if nargin < 3,
    error('Wrong number of input arguments in clustermode_luke.m')
end
%
dkecluster.temppath = [pwd,'/mdce_',timeid_jd(clock,3),'/'];
dkecluster.info = '';
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
if dkecluster.mode == 1,
    %
    try %test the availability of the MatLab MDCE toolbox
        %
    	findResource('scheduler','type','generic');
        dkecluster.info = 'Distributed computing mode with MatLab MDCE toolbox chosen.';
        disp(['==> ',dkecluster.info])
        %
    catch 
        %
        dkecluster.info = 'No Matlab MDCE resource found. Try LUKE batch DC. ';
        disp(['==> ',dkecluster.info])
        dkecluster.mode = 2;
        %
    end
end
%   
% For LUKE distributed computing with batch queuing
%
if dkecluster.mode == 2,
    %
    if ~isstruct(remote),
        %
        dkecluster.info = [dkecluster.info,'No cluster information found. Sequential mode enforced.'];
        disp(['==> ',dkecluster.info])
        dkecluster.mode = 0;
        return
        %
    end
    %
    nrem = length(remote);
    rem_list = ones(1,nrem);
    %
    %  LUKE batch DC calculations on local host only
    %
    for irem = 1:nrem,
        if ~isempty(remote(irem).host),
            rem_list(irem) = 0;
        end
    end
    %
    if ~any(rem_list),
        dkecluster.info = [dkecluster.info,'No local cluster. Sequential mode enforced.'];
        disp(['==> ',dkecluster.info])
        dkecluster.mode = 0;
        return
    end            
    %
    for irem = find(rem_list),
        if isfield(remote(irem),'luke_root') && ~any(strfind(path,remote(irem).luke_root))
            rem_list(irem) = 0;
        end
    end
    %
    if sum(rem_list) == 0,
        dkecluster.info = [dkecluster.info,' Cluster LUKE path different from local one. Sequential mode enforced.'];
        disp(['==> ',dkecluster.info])
        dkecluster.mode = 0;
        return
    end
    %
    if sum(rem_list) > 1
        dkecluster.info = [dkecluster.info,' Warning : more than one compatible cluster configuration for LUKE batch DC. First one selected.'];
    else
        dkecluster.info = 'Distributed computing mode with LUKE scripts chosen.';        
    end
    disp(['==> ',dkecluster.info])
    %
    remote = remote(find(rem_list,1,'first'));
    %
    dkecluster.cmd = remote.cmd;
    if isfield(remote,'mem'),%batch run memory allocation information
        dkecluster.mem = remote.mem;
        if nargin >= 5,%memory allocated specified by user
            dkecluster.mem{3} = num2str(mem);
        end
    else
        dkecluster.mem = '';
    end
    dkecluster.get_jobid = remote.get_jobid;
    dkecluster.set_jobid = remote.set_jobid;
    %
end
%
