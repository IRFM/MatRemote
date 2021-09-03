function [dkecluster] = mdce_clustermode(param)
%
% Test & configure cluster properties for use by mdce_run
%
% INPUTS : 
%   - param : parameters for distributed computing
%
%       o if param is not a structure (default = 0)
%           o (0)       : sequential
%           o (1)       : job scheduler (Matlab MDCE required)             (+i enables GPU calculations)
%           o (2)       : parfor parallel computing (Matlab MDCE required) (+i enables GPU calculations)
%           o (3)       : use of remcomputing with local cluster
%           o remote id : extended use of remcomputing (cluster identification, see below for details)
%           
%
%       o if param is a structure : param or param.(fun).scheduler contains optional mdce parameters among these :
%           - mode : see param above
%           - gpu (default : 0) : gpu distributed computing
%           - type (default : 'local') : name of cluster configuration (mode = 1,2)
%           - inter (default : 0) : (1) interactive mode (for remote profile, scheduler and profile name) or (0) automatic mode
%           - configurations (default : struct) : cluster configurations parameters
%           - clustersize (default : Inf) : number of workers
%           - memory (default : NaN) : memory requirements
%           - enforce (default : 1) : enforce sequential if distributed failed
%           - debugmode (default : 0) : debuging mode
%           - cleanmode (default : 2) : clean remote and local files (2), remote files only (1), no files (0)
%           - display (default : 0) : disply mode
%           - timeout  (default : 100) : time out for job submission (s)
%           - info (default : '') : info on mdce configuration
%           - temppath (default : [pwd,filesep,'mdce_',timeid_jd(clock),filesep]) : folder where tmp files are saved
%           - remote (default : {}) : cell array of remote cluster identification, to transfert calculation recursively to clusters remote{1}, remote{2}, ...
%
%       cluster identification (param, param.mode or param.remote{irem})
%           o (struct)       : calculation distributed to the profile stored in the structure 'remote'
%           o (NaN)          : prompt user for profile (if inter = 1) or same as 'local' if inter = 0
%           o ('local')      : identifies and select local cluster
%           o (string)       : profile from remote_(remote).m (ex : 'macpro_YVES_PEYSSON')
%
% OUTPUT :
%   - dkecluster : structure containing MDCE properties
%
% by J. Decker (CEA-IRFM) <joan.decker@cea.fr> and Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr>
%
%
if ~ismember('mute_mdce_clustermode', who('global'))
    mute_mdce_clustermode = 0;
else
    global mute_mdce_clustermode
end
%
if nargin < 1 || (~isstruct(param) && ~ischar(param) && ~isempty(mdce_mode) && (~isscalar(param) || (~any(param == 0:3) && ~isnan(param)))),% test param for valid formats
    param = 0;
end
%
% default scheduler properties
%
dkecluster.scheduler.mode = 0;
dkecluster.scheduler.gpu = 0;
dkecluster.scheduler.type = 'local';
dkecluster.scheduler.inter = 0;% interactive mode (for profile, scheduler and profile name)
dkecluster.scheduler.configurations = struct;
dkecluster.scheduler.remote = {};% for use of mdce_remote
dkecluster.scheduler.funcopy = false;% copy distributed function to remote cluster
%
dkecluster.scheduler.clustersize = Inf;%8 is maximum for local configuration
dkecluster.scheduler.memory = NaN;% no memory requirements
dkecluster.scheduler.enforce = 1;% enforce sequential if distributed failed
dkecluster.scheduler.debugmode = 0;
dkecluster.scheduler.cleanmode = 2;  
dkecluster.scheduler.display = 0;
dkecluster.scheduler.timeout = 100;%100 s time out for job submission
dkecluster.scheduler.info = '';
%
dkecluster.scheduler.remtimout = Inf;% calculation timeout (in mins) (use of remcomputing only)
dkecluster.scheduler.rempause = 1/6;% calculation status check period (in mins) (use of remcomputing only)
dkecluster.scheduler.localdatadir = '';% data saved locally
%
% Parameters for parallel computing specific to a function given in dkeparam or C3POparam for example
%
if isstruct(param),
    dkecluster.scheduler = conc_struct_jd(dkecluster.scheduler,param);% override default parameters
else% only override dkecluster.mode
    dkecluster.scheduler.mode = param;
end
%
if dkecluster.scheduler.clustersize == 0,
    dkecluster.scheduler.mode = 0;%sequential mode enforced
end
%
% calculation transfered to remote cluster using mdce_remote.m 
%
if ~isempty(dkecluster.scheduler.remote),
    %
    % loads remote profile & test connection
    %
    if iscell(dkecluster.scheduler.remote),
        remote = dkecluster.scheduler.remote{1};
        dkecluster.scheduler.remote = dkecluster.scheduler.remote(2:end);% if recursive use of mdce_remote.m 
    else
        remote = dkecluster.scheduler.remote;% non-recursive case
        dkecluster.scheduler.remote = {};
    end
    %
    if isfield(dkecluster,'scheduler') && isfield(dkecluster.scheduler,'remnum')
        remnum = dkecluster.scheduler.remnum;
    else
        remnum = 0;
    end
    [remote,profilestr] = load_remoteprofiles_jd(remote,dkecluster.scheduler.enforce);
    %
    if dkecluster.scheduler.enforce == 1 && remnum > 0 && isempty(remote),%remote link fails
        dkecluster.scheduler.enforce = dkecluster.scheduler.enforce + i*remnum;%when local calculation enforced
    end
    %
    % parameters set recursively
    %
    if length(dkecluster.scheduler.remtimout) == 1,% prescription is for mdce_remote, and downstream calls are with dkecluster.scheduler.remtimout = Inf
        remtimout = dkecluster.scheduler.remtimout;
        dkecluster.scheduler.remtimout = Inf;
    else% prescriptions are given for each remote step
        remtimout = dkecluster.scheduler.remtimout(1);
        dkecluster.scheduler.remtimout = dkecluster.scheduler.remtimout(2:end);
    end
    %
    if length(dkecluster.scheduler.rempause) == 1,% prescription is for mdce_remote, and downstream calls are with dkecluster.scheduler.rempause = 1/6;
        rempause = dkecluster.scheduler.rempause;
        dkecluster.scheduler.rempause = 1/6;
    else% prescriptions are given for each remote step
        rempause = dkecluster.scheduler.rempause(1);
        dkecluster.scheduler.rempause = dkecluster.scheduler.rempause(2:end);
    end
    %
    if iscell(dkecluster.scheduler.localdatadir),
        localdatadir = dkecluster.scheduler.localdatadir{1};
        dkecluster.scheduler.localdatadir = dkecluster.scheduler.localdatadir(2:end);% if recursive use of mdce_remote.m 
    else
        localdatadir = dkecluster.scheduler.localdatadir;% non-recursive case
        dkecluster.scheduler.localdatadir = '';
    end
    if ischar(dkecluster.scheduler.mode),
        if strcmp(dkecluster.scheduler.mode,'local'),
            dkecluster.scheduler.mode = 3;
        else
            error('param.mode is not recognized.')
        end
    end
    %
    if isempty(dkecluster.scheduler.remote) && dkecluster.scheduler.mode == 3,% local remcomputing after next and last mdce_remote
        dkecluster.scheduler.mode = remote;%to ensure proper environment
        dkecluster.scheduler.mode.host = '';
        dkecluster.scheduler.mode.link_mode = [];% necessary for localhost
        dkecluster.scheduler.mode.remotedatapath = '';% to avoid unnecessary copies
    end
    %
    if mute_mdce_clustermode == 0
        disp(' ');
    end
    %
    if ~isempty(remote)
        %
        dkecluster.remote = remote;
        dkecluster.remtimout = remtimout;
        dkecluster.rempause = rempause;
        dkecluster.localdatadir = localdatadir;
        %
        if mute_mdce_clustermode == 0
            disp(['==> Distributed calculation transfered to : ',profilestr{1}])
        end
        %
        return
        %
    else
        %
        if mute_mdce_clustermode == 0
            disp('==> WARNING : invalid remote profile. Local calculation enforced.')
        end
        %
    end
end    
%
dkecluster.scheduler.temppath = [pwd,filesep,'mdce_',timeid_jd(clock),filesep];
%
% Specific operations depending on DC mode
%
if isnumeric(dkecluster.scheduler.mode) && dkecluster.scheduler.mode == 0,% sequential
    %
elseif isnumeric(dkecluster.scheduler.mode) && dkecluster.scheduler.mode == 1,% MDCE mode
    %
	dkecluster.scheduler.configuration = selectconfiguration_jd(dkecluster.scheduler.type,dkecluster.scheduler.configurations);
	%
    try %test the availability of the MatLab MDCE toolbox and set clustersize
        %
        if str2double(matversion_yp) < 801,%old matlab syntax
        	scheduler = findResource('scheduler','configuration',dkecluster.scheduler.configuration);
            dkecluster.scheduler.info = ['Matlab Distributed Computing Environment operational for the configuration <',dkecluster.scheduler.configuration,'>'];
            dkecluster.scheduler.clustersize = min([dkecluster.scheduler.clustersize,scheduler.clustersize]);
        else%new matlab syntax
            scheduler = parcluster(dkecluster.scheduler.configuration);
            dkecluster.scheduler.info = ['Matlab Distributed Computing Environment operational for the configuration <',dkecluster.scheduler.configuration,'>'];
            dkecluster.scheduler.clustersize = min([dkecluster.scheduler.clustersize,scheduler.NumWorkers]);
        end
        %
        if mute_mdce_clustermode == 0
            disp(['==> ',dkecluster.scheduler.info])
        end
        %
    catch err
        %
        dkecluster.scheduler.info = ['Impossible to use JOBS MDCE with configuration ',dkecluster.scheduler.configuration,...
            ' because of the following error : ',err.message,'. Sequential mode enforced.'];
        if mute_mdce_clustermode == 0
            disp(['==> ',dkecluster.scheduler.info])
        end
        dkecluster.scheduler.mode = 0;
        %
    end
    %
elseif isnumeric(dkecluster.scheduler.mode) && dkecluster.scheduler.mode == 2,% parfor mode
    %
	dkecluster.scheduler.configuration = selectconfiguration_jd(dkecluster.scheduler.type,dkecluster.scheduler.configurations);
    %
    [vmatlab,~,testtoolbox] = matversion_yp('Parallel Computing Toolbox');
    %
    if str2double(vmatlab) < 77 || ~testtoolbox
        if mute_mdce_clustermode == 0
            disp(['WARNING: ''matlabpool'' command may not be used with the present version ',version('-release'),' of Matlab or the ''Parallel Computing Toolbox'' may be missing. Use Matlab >= R2008b (7.7) for this functionality with the appropriate library. Sequential mode enforced']);
        end
        dkecluster.scheduler.mode = 0;
    end
    %
else% remote computing mode
    %
    if isnumeric(dkecluster.scheduler.mode) && dkecluster.scheduler.mode == 3;% remcomputing on local cluster
        dkecluster.scheduler.mode = 'local';
    end
    %    
    [dkecluster.scheduler.remote,profilestr] = load_remoteprofiles_jd(dkecluster.scheduler.mode,dkecluster.scheduler.enforce,dkecluster.scheduler.inter);% test validity and connection of remote profile
    if dkecluster.scheduler.enforce == 1 && isempty(dkecluster.scheduler.remote) && ~isreal(dkecluster.scheduler.remnum),%remote link fails
        dkecluster.scheduler.enforce = dkecluster.scheduler.enforce + dkecluster.scheduler.remnum;%local calculation enforced
    end
    %
    if ~isempty(dkecluster.scheduler.remote),
        %
        dkecluster.scheduler.mode = 3;% use of remcomputing
        %    
        if dkecluster.scheduler.clustersize > dkecluster.scheduler.remote.nproc,
            dkecluster.scheduler.clustersize = dkecluster.scheduler.remote.nproc;%maximum number of processors on cluster enforced by remote - generally to avoid cluster overuse
        end
        %    
        if ~isempty(dkecluster.scheduler.remote.memtot) && dkecluster.scheduler.clustersize*dkecluster.scheduler.memory > dkecluster.scheduler.remote.memtot,
            dkecluster.scheduler.clustersize = fix(dkecluster.scheduler.remote.memtot/dkecluster.scheduler.memory);%maximum number of processors on cluster enforced by remote - generally to avoid cluster overuse
            if dkecluster.scheduler.clustersize == 0,%not enough memory on remote host
                if mute_mdce_clustermode == 0
                    disp('WARNING: not enough memory on remote host. Sequential mode enforced');
                end
                dkecluster.scheduler.mode = 0;
            end
        end
        %
        if ~isfield(dkecluster.scheduler.remote,'localdatapath') || isempty(dkecluster.scheduler.remote.localdatapath),
            dkecluster.scheduler.remote.localdatapath = dkecluster.scheduler.temppath;
        end
        %
        dkecluster.scheduler.remote.debugmode = dkecluster.scheduler.debugmode;%maximum number of processors on cluster enforced by remote - generally to avoid cluster overuse
        %
        dkecluster.scheduler.info = ['Remote distributed computing mode with profile ',profilestr{1},' chosen.'];   
        if mute_mdce_clustermode == 0
            disp(['==> ',dkecluster.scheduler.info])
        end
        %
    else
        if mute_mdce_clustermode == 0
            disp('WARNING: invalid remote profile. Sequential mode enforced');
        end
        dkecluster.scheduler.mode = 0;
    end
    %
end
%
if dkecluster.scheduler.mode == 0,
    dkecluster.scheduler.clustersize = 1;% enforce one iteration by default if mode = 0,
end
%
    