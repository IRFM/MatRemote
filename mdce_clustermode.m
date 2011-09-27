function [dkecluster] = clustermode_luke(param,fun,dkepath,configname)
%LUKE - Test cluster properties
%
% This function tests cluster properties and generate default values
%
% by J. Decker (CEA-IRFM) <joan.decker@cea.fr> and Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr>
%
%
if nargin < 3,
    error('Wrong number of input arguments in clustermode_luke.m')
end
%
if nargin < 4,
    configname = [];
end
%
if isempty(configname),
    configname = 'local';
end
%
% Temp folder
%
temppath = ['mdce_',timeid_jd(clock),filesep];
%
% Parameters from dkepath
%
if isfield(dkepath,'temppathroot');
    temppath = [dkepath.temppathroot,temppath];
else
    temppath = [pwd,filesep,temppath];% Local folder
end
if isfield(dkepath,'remote');
    remote = dkepath.remote;
else
    remote = '';% no dcluke information
end
%
% Minimum set of for parallel computing 
%
dkecluster.scheduler.mode = 0;%No parallel computing
dkecluster.scheduler.timeout = 100;%100 s time out for job submission
dkecluster.scheduler.size = 1;%One core or processor
dkecluster.scheduler.memory = NaN;%no memory requirements
dkecluster.scheduler.temppath = temppath;
dkecluster.scheduler.type = configname;
dkecluster.scheduler.display = 0;
dkecluster.scheduler.info = 'No parallel computation.';
%
% Parameters for parallel computing specific to a function given in dkeparam or C3POparam for example
%
if isstruct(param),% when function-specific DC parameters are present 
    if isfield(param,fun),% DC parameters found for the specific function
        if isfield(param.(fun),'scheduler'),
            dkecluster.scheduler = conc_struct_jd(dkecluster.scheduler,param.(fun).scheduler);
        elseif isfield(param.(fun),'batch'),
            %not yet implemented
        end        
    end
else% only the DC mode is provided
    dkecluster.scheduler.mode = param;
end
%
% Close pool of matlab sessions for parallel computations 
%
if dkecluster.scheduler.mode <= 2,
    %
    [vmatlab,testtoolbox] = matlabstatus_yp('Parallel Computing Toolbox');
    %
    if vmatlab >= 77 && testtoolbox,
        if matlabpool('size'),%Close existing pool of matlab sessions for parallel computations
            matlabpool close force
        end
    end
    %
end
%
% Specific operations depending on DC mode
%
if dkecluster.scheduler.mode == 1,%MDCE mode
    %
    try %test the availability of the MatLab MDCE toolbox
        %
        out = findResource('scheduler','type',dkecluster.scheduler.type);
        dkecluster.scheduler.info = ['Matlab Distributed Computing Environment operational for the scheduler <',dkecluster.scheduler.type,'>'];
        disp(['==> ',dkecluster.scheduler.info])
        dkecluster.scheduler.size = out.ClusterSize;
        %
    catch 
        %
        dkecluster.scheduler.info = 'No resource found for Matlab Distributed Computing Environment. Sequential mode enforced.';
        disp(['==> ',dkecluster.scheduler.info])
        dkecluster.scheduler.mode = 0;
        %
    end
    %
elseif dkecluster.scheduler.mode == 2,%LDCE mode
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
        dkecluster.scheduler.info = [dkecluster.scheduler.info,' No local cluster. Sequential mode enforced.'];
        disp(['==> ',dkecluster.scheduler.info])
        dkecluster.scheduler.mode = 0;
        return
    end            
    %
    for irem = find(rem_list),
        if isfield(remote(irem),'luke_root') && ~isempty(remote(irem).luke_root) && ~any(strfind(path,remote(irem).luke_root))
            rem_list(irem) = 0;
        end
    end
    %
    if sum(rem_list) == 0,
        dkecluster.scheduler.info = [dkecluster.scheduler.info,' Cluster LUKE path different from local one. Sequential mode enforced.'];
        disp(['==> ',dkecluster.scheduler.info])
        dkecluster.scheduler.mode = 0;
        return
    end
    %
    if sum(rem_list) > 1
        dkecluster.scheduler.info = [dkecluster.scheduler.info,' Warning : more than one compatible cluster configuration for LUKE batch DC. First one selected.'];
    else
        dkecluster.scheduler.info = 'Distributed computing mode with LUKE scripts chosen.';        
    end
    disp(['==> ',dkecluster.scheduler.info])
    %
    remote = remote(find(rem_list,1,'first'));
    %
    dkecluster.scheduler.cmd = remote.cmd;
    dkecluster.scheduler.get_jobid = remote.get_jobid;
    dkecluster.scheduler.set_jobid = remote.set_jobid;
    if dkecluster.scheduler.size == 1 || dkecluster.scheduler.size > remote.nproc,
        dkecluster.scheduler.size = remote.nproc;%maximum number of processors on cluster
    end
    if isfield(remote,'mem'),%batch run memory allocation information
        dkecluster.scheduler.mem = remote.mem(1:3);
        if ~isnan(dkecluster.scheduler.memory),%memory allocated specified by dkecluster
            dkecluster.scheduler.mem{3} = num2str(dkecluster.scheduler.memory);
        end
    else
        dkecluster.scheduler.mem = '';
    end
    %
elseif dkecluster.scheduler.mode == 3,%parfor mode
    %
    [vmatlab,testtoolbox] = matlabstatus_yp('Parallel Computing Toolbox');
    %
    if vmatlab >= 77 && testtoolbox,
        if ~matlabpool('size'),%Open pool of matlab sessions for parallel computations if not already existing
            matlabpool('open',configname);%Automatic number of workers
        end
        %
        dkecluster.scheduler.size = matlabpool('size');
    else
        disp(['WARNING: ''matlabpool'' command may not be used with the present version ',version('-release'),' of Matlab or the ''Parallel Computing Toolbox'' may be missing. Use Matlab > R2008b (7.7) for this functionality with the appropriate library. Sequential mode enforced']);
        dkecluster.scheduler.mode = 0;
    end
end
%
