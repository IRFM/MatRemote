function [dkecluster] = clustermode_luke(param,fun,dkepath,schedulertype,remnum)
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
if nargin < 4 || isempty(schedulertype),
    schedulertype = 'local';
end
%
if nargin < 5 || isempty(remnum),
    remnum = 0;
end
%
% remote calculation  : remnum provides the profile number in dkepath.remote
%
if remnum > 0,
    %
    if remnum <= length(dkepath.remote),
        %
        dkecluster.remnum = remnum;
        dkecluster.param = param;
        dkecluster.fun = fun;
        dkecluster.dkepath = dkepath;
        dkecluster.schedulertype = schedulertype;
        %
        disp(['==> Distributed calculation transfered to remote location ',dkepath.remote(remnum).host,'.'])
        %
        return
        %
    else
        %
        disp(['==> WARNING : dkepath.remote(',num2str(remnum),') profile is not defined. Local calculation enforced'])
        %
    end
end    
%
% Temp folder
%
temppath = ['mdce_',timeid_jd(clock),filesep];
%
% Parameters from dkepath
%
if isfield(dkepath,'temppathroot'),
    temppathroot = dkepath.temppathroot;
else
    temppathroot = [pwd,filesep];% Local folder
end
%
if isfield(dkepath,'remote'),
    remote = dkepath.remote(1);%first cluster is always considered
else
    remote = '';% no dcluke information
end
%
if isfield(dkepath,'configurations'),
    configurations = dkepath.configurations;
else
    configurations = struct;% no dcluke information
end
%
% default scheduler properties
%
dkecluster.scheduler.mode = 0;
dkecluster.scheduler.type = schedulertype;
dkecluster.scheduler.configfile = '';
dkecluster.scheduler.timeout = 100;%100 s time out for job submission
dkecluster.scheduler.clustersize = Inf;%8 is maximum for local configuration
dkecluster.scheduler.memory = NaN;%no memory requirements
dkecluster.scheduler.temppathroot = temppathroot;
dkecluster.scheduler.display = 0;
dkecluster.scheduler.info = '';
%
dkecluster.scheduler.temppath = [dkecluster.scheduler.temppathroot,filesep,temppath];
%
% Parameters for parallel computing specific to a function given in dkeparam or C3POparam for example
%
if isstruct(param),
    %
    if ~isempty(fun)% when function-specific DC parameters are present 
        %
        if isfield(param,fun),% DC parameters found for the specific function
            if isfield(param.(fun),'scheduler'),
                dkecluster.scheduler = conc_struct_jd(dkecluster.scheduler,param.(fun).scheduler);
            elseif isfield(param.(fun),'batch'),
                %not yet implemented
            else
                disp('Warning : dkecluster type not recognized')
                dkecluster.scheduler.mode = 0;%dkecluster type not recognized, sequential mode enforced
            end        
        else
            dkecluster.scheduler.mode = 0;%function not referenced in param, sequential mode enforced
        end
        %
    else% when param contains overriding scheduler fields
        %
        dkecluster.scheduler = conc_struct_jd(dkecluster.scheduler,param);
        %
    end
else% only the DC mode is provided
    dkecluster.scheduler.mode = param;
end
%
% Specific operations depending on DC mode
%
if dkecluster.scheduler.mode == 1,%MDCE mode
    %
	dkecluster.scheduler.configuration = selectconfiguration_jd(dkecluster.scheduler.type,configurations);
	%
    try %test the availability of the MatLab MDCE toolbox and set clustersize
        %
        scheduler = findResource('scheduler','configuration',dkecluster.scheduler.configuration);
        dkecluster.scheduler.info = ['Matlab Distributed Computing Environment operational for the configuration <',dkecluster.scheduler.configuration,'>'];
        dkecluster.scheduler.clustersize = min([dkecluster.scheduler.clustersize,scheduler.clustersize]);
        disp(['==> ',dkecluster.scheduler.info])
        %
    catch err
        %
        dkecluster.scheduler.info = ['Impossible to use JOBS MDCE with configuration ',dkecluster.scheduler.configuration,...
            ' because of the following error : ',err.message,'. Sequential mode enforced.'];
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
    for irem = 1:nrem,% reject remote hosts
        if ~iscell(remote(irem).host) && ~isempty(remote(irem).host),
            rem_list(irem) = 0;
        elseif iscell(remote(irem).host) && (length(remote(irem).host) == 1 || ~strcmp(remote(irem).host{1},remote(irem).host{2}))
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
    for irem = find(rem_list),% test LUKE path
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
    %
    if iscell(remote.cmd),
        xgridsearch = strfind(remote.cmd{1},'xgrid');%find if the xgrid task scheduler is used (mac,...)
        condorsearch = strfind(remote.cmd{1},'condor');%find if the condor task scheduler is used (mac,...)
    else
        xgridsearch = '';
        condorsearch = '';
    end
    %
    if ~isempty(xgridsearch),
        dkecluster.scheduler.cluster = remote.cluster;
        dkecluster.scheduler.matlabroot = remote.matlabroot;
        dkecluster.scheduler.luke_root = remote.luke_root;
        dkecluster.scheduler.prefdir = remote.prefdir;
        dkecluster.scheduler.password = remote.password; 
        remotefields = fieldnames(remote);
        dkecluster.scheduler.logname = remote.(remotefields{end});  
    elseif ~isempty(condorsearch),
        dkecluster.scheduler.cluster = remote.cluster;
        dkecluster.scheduler.matlabroot = remote.matlabroot;
        dkecluster.scheduler.home = remote.home;
        dkecluster.scheduler.luke_root = remote.luke_root;
        dkecluster.scheduler.prefdir = remote.prefdir;
        dkecluster.scheduler.password = ''; 
        dkecluster.scheduler.logname = ''; 
        dkecluster.scheduler.path = remote.path;
    end
    %
    dkecluster.scheduler.get_jobid = remote.get_jobid;
    dkecluster.scheduler.set_jobid = remote.set_jobid;
    if dkecluster.scheduler.clustersize > remote.nproc,
        dkecluster.scheduler.clustersize = remote.nproc;%maximum number of processors on cluster
    end
    %
    if isfield(remote,'mem'),%batch run memory allocation information
        if ~isempty(remote.mem),
            dkecluster.scheduler.mem = remote.mem(1:3);
            if ~isnan(dkecluster.scheduler.memory),%memory allocated specified by dkecluster
                dkecluster.scheduler.mem{3} = num2str(dkecluster.scheduler.memory);
            end
        else
            dkecluster.scheduler.mem = '';
        end
    else
        dkecluster.scheduler.mem = '';
    end
    %
elseif dkecluster.scheduler.mode == 3,%parfor mode
    %
	dkecluster.scheduler.configuration = selectconfiguration_jd(dkecluster.scheduler.type,configurations);
    %
    [vmatlab,testtoolbox] = matlabstatus_yp('Parallel Computing Toolbox');
    %
    if vmatlab >= 77 && testtoolbox,% test removed because already existing in parcomputing
% 		try %test the availability of the MatLab MDCE toolbox
% 			%
% 			matlabpool('open',dkecluster.scheduler.configuration,1)
% 			matlabpool close
% 			dkecluster.scheduler.info = ['Matlab PARFOR mode operational for the scheduler <',dkecluster.scheduler.configuration,'>'];
% 			disp(['==> ',dkecluster.scheduler.info])
% 			%
%         catch err
%             %
%             dkecluster.scheduler.info = ['Impossible to use PARFOR MDCE with configuration ',dkecluster.scheduler.configuration,...
%             ' because of the following error : ',err.message,'. Sequential mode enforced.'];
% 			disp(['==> ',dkecluster.scheduler.info])
% 			dkecluster.scheduler.mode = 0;
% 			%
% 		end
    else
        disp(['WARNING: ''matlabpool'' command may not be used with the present version ',version('-release'),' of Matlab or the ''Parallel Computing Toolbox'' may be missing. Use Matlab > R2008b (7.7) for this functionality with the appropriate library. Sequential mode enforced']);
        dkecluster.scheduler.mode = 0;
    end
elseif dkecluster.scheduler.mode < 0,%remote computing mode
    %
    if -dkecluster.scheduler.mode <= length(dkepath.remote),
        %
        dkecluster.scheduler.remote = dkepath.remote(-dkecluster.scheduler.mode);
        %
        dkecluster.scheduler.info = ['Remote distributed computing mode with profile ',num2str(-dkecluster.scheduler.mode),' chosen.'];        
        disp(['==> ',dkecluster.scheduler.info])
        %
    else
        disp(['WARNING: The profile number ',num2str(-dkecluster.scheduler.mode),' does not exist in dkepath.remote. Sequential mode enforced']);
        dkecluster.scheduler.mode = 0;
    end
    %
end
%
if dkecluster.scheduler.mode == 0,
    dkecluster.scheduler.clustersize = 1;% enforce one iteration by default if mode = 0,
end
    