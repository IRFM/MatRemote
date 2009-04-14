function [cluster] = clustermode_luke(cdisp,param,dkepath,fun);
%LUKE - Test cluster properties
%
% This function tests cluster properties and generate default values
%
% by J. Decker (CEA-IRFM) <joan.decker@cea.fr> and   Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr>
%
%
if nargin < 4,
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
cluster.temppath = dkepath.temppathroot; 
%
flag_mdcetoolbox = 0;
%
try,%test if MDCE toolbox is available
    jm = findResource('scheduler','type','generic');
    flag_mdcetoolbox = 1;
end
%   
% For LUKE distributed computing with batch queuing
%
if exist(['dcluke/',dkepath.hostname]),
    cluster.scriptspath = [dkepath.luke_root,'Project_DKE/Packages/MDCE/dcluke/',dkepath.hostname];
    [s,t] = unix('qsub xxxxxxxxxx');
    if isempty(strfind(t,'command not found')),
        flag_mdcetoolbox = 1;
    end
end    
%
if isempty(cluster.temppath) & cluster.mode == 1 & flag_mdcetoolbox,
    cluster.temppath = fullfile(getenv('HOME'),'mdce_');
    disp(['WARNING: Temporary path directory name for distributed computing is ',cluster.path]);
end           
