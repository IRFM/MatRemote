function job = remoterunbatch(remote,job,sinput,displaymode)
%
% This function starts a batch job on a local or remote host
%
%   INPUTS :
%   
%       - remote : cluster information structure
%           o host : host name (leave empty for local host). ex : 'saturne1.partenaires.cea.fr'
%           o cmd : batch command. ex: qsub
%           o get_jobid : syntax to read the job id : get_jobid{1},jobid,get_jobid{2}
%           o (logname) : user name correspondance. ex : remote.joan = 'JD211098' (same as local user if empty or missing)
%
%
%       - job : job parameters structure
%           o script : name (with full path) of the remote script
%           o savefcn (optional) : matlab function to process sinput with the syntax : save_id = savefcn(sinput,logname,timeid)
%           o localdatapath (optional) : location of local data
%           o remotedatapath (optional) : location of remote data
%           o env (optional) : structure of additional environment variables (strings). 
%               ex : 
%               - remotebatch_matlabroot : path to matlab (optional)
%               - remotebatch_path : matlab path (optional)
%               - ...
%           o wait (optional) : (0) return hand (1) wait for result
%           o nodes (optional) : number of nodes required)
%           o nproc (optional) : number of cores required
%           o memory (optional) : memory allocated to the job (in mb)
%           o walltime (optional) :  time required (in hours if walltime is a number) or ('hh:mm' if walltime is a string), and if remote.queue exists, walltime is defined by remote.***.queue.maxtime(remote.**.queue.qdef)) - leave empty if no requirement
%
%       - sinput (optional) : input data structure
%       - displaymode : display mode : (0) no display; (1) operation display (default : debugmode)
%
%   OUTPUTS : 
%   
%       - job : job parameters structure. Same as input, plus
%           o id : cluster id for the job
%           o timeid : time id for the job
%           o remotelogname : user name on cluster
%           o save_id : input file/folder (leave empty if no input file)
%           o load_id : output file/folder expected (leave empty if no output file)
%
% by J. Decker, Y. Peysson and M. Schneider, CEA/IRFM
%
if nargin < 3,
    sinput = '';
end
%
if ~isfield(job,'timeid') || isempty(job.timeid),
    job.timeid = timeid_jd(clock);
end
%
% job time structure to follow status (GMT time)
%
job.time.created = utctime_jd;% time of job creation
job.time.transfered = '';% time of job transfer on remote machine (creation of remote MAT_RUN file)
job.time.launched = '';% time of job command sent
job.time.started = '';% time of job started (pid file created)
job.time.finished = '';% time of job finished (creation of remote MAT_OUT file)
job.time.retrieved = '';% time of result transfer back to local machine
job.time.processed = '';% time to process the results and generate outputs
job.time.cleaned = '';% time of clean job temp files & folders
%
if ~isfield(job,'userid') || isempty(job.userid),
    job.userid = [getenv('USER'),'@',hostname_jd];
end
%
% path to matlab if applicable
%
if ~isfield(job,'env') || ~isfield(job.env,'remotebatch_matlabroot'),%matlab called remotely and not prescribed by job
    matver = matversion_yp;
    if isempty(remote.host),% same version for local calculations
        job.env.remotebatch_matlabroot = [matlabroot,'/bin/matlab'];
    elseif isfield(remote,'matver') && isfield(remote.matver,['mat',matver]) && ~isempty(remote.matver.(['mat',matver])),
        % same version on remote cluster, if available
        job.env.remotebatch_matlabroot = remote.matver.(['mat',matver]);
    elseif isfield(remote,'matver') && isfield(remote.matver,'matdef') && ~isempty(remote.matver.matdef),
        % default version on remote cluster, if available
        job.env.remotebatch_matlabroot = remote.matver.matdef;
    else% default version on remote cluster
        job.env.remotebatch_matlabroot = 'matlab';
    end
end
%
% Job parameters tested to be compatible with or enforced by remote
%
job = remote2job_jd(remote,job);
%
if nargin < 4 || isempty(displaymode),
    if isfield(job,'displaymode') && ~isempty(job.displaymode),
        displaymode = job.displaymode;
    else
        displaymode = 1 + job.debugmode;
    end
end
%
remotehost = remote.host;%  hostname (empty for local host)
%
job.pbssearch = 0;
job.sgesearch = 0;
job.slurmsearch = 0;
job.condorsearch = 0;
job.xgridsearch = 0;
job.directsearch = 0;
%
if strcmp(remote.scheduler ,'torque') || strcmp(remote.scheduler ,'pbs') || strcmp(remote.scheduler ,'sun')
    job.pbssearch = 1;
elseif strcmp(remote.scheduler ,'slurm'),
    job.slurmsearch = 1;
elseif strcmp(remote.scheduler ,'xgrid'),
    job.xgridsearch = 1;
elseif strcmp(remote.scheduler ,'condor'),
    job.condorsearch = 1;
elseif strcmp(remote.scheduler ,'sge'),
    job.sgesearch = 1;
    job.remote = remote;
elseif strcmp(remote.scheduler ,'direct'),
    job.directsearch = 1;
else
    error('Scheduler type not recognized');
end
%
% local data location
%
if ~isfield(job,'localdatapath') || isempty(job.localdatapath),% remote data location
    if isempty(remotehost) && ~isempty(job.remotedatapath),
        job.localdatapath = job.remotedatapath;
    else
        job.localdatapath = [pwd,filesep];
    end
end
if ~strcmp(job.localdatapath(end),filesep),
    job.localdatapath = [job.localdatapath,filesep];
end
%
% create local data folder if needed
%
if ~exist(job.localdatapath,'dir'),
    locdisp(displaymode,['    --> Creating local data folder ',job.localdatapath])  
    mkdir(job.localdatapath)
    locdisp(displaymode,' ... done');
end
%
% remote data location
%
if isempty(job.remotedatapath),% remote data location
    if ~isempty(remotehost),
        job.remotedatapath = './';
    else
        job.remotedatapath = job.localdatapath;
    end
elseif ~strcmp(job.remotedatapath(end),filesep),
    job.remotedatapath = [job.remotedatapath,filesep];
end
%
% full remotedatapath requested with link_mode = 2 
%
if ~isempty(remote.host) && remote.link_mode == 2 && ~strcmp(job.remotedatapath(1),filesep),
    %
    remotecmd = 'pwd';% test if remote directory exists
    %
    [res,txt] = matremotecmd(remote,job,remotecmd);
    %
    if res ~= 0,% cannot retrieve remote pwd
        %
        locdisp(displaymode,['Cannot retrieve remote pwd : ',txt]);
        job.err = txt;
        %
        return
        %
    else
        remotepwd = txt;
        %
        job.remotedatapath = [remotepwd,filesep,job.remotedatapath];
    end
end
%
% test remote connection - select ssh mode over bridge mode if possible
%
remote = testremoteprofile_jd(remote,NaN,true,displaymode);% test connection to remote host
%
% create remote data folder if needed - this also tests remote connection
%
remotecmd = ['test -d ',job.remotedatapath];% test if remote directory exists
%
[res,err] = matremotecmd(remote,job,remotecmd);
%
if res == 1,% remote directory does not exist
    remotecmd = ['mkdir ',job.remotedatapath];%create remote directory
    locdisp(displaymode,['    --> Creating remote data folder ',job.remotedatapath])  
    %
    [res,err] = matremotecmd(remote,job,remotecmd);
    %
    if res ~= 0,
        %
        locdisp(displaymode,['Remote data folder creation failed : ',err]);
        job.err = err;
        %
        return
        %
    end
    locdisp(displaymode,' ... done');
elseif res ~= 0,
    %
    locdisp(displaymode,['Remote directory check failed : ',err]);
    job.err = err;
    %
    return
    %
end   
%
if isfield(remote,'cvs'),
    if isstruct(remote.cvs) && ~isempty(remote.cvs.CVSROOT) && ~isempty(remote.cvs.cmd),
        %
        remotecmd = ['CVSROOT=',remote.cvs.CVSROOT,'; export CVSROOT; cvs ',remote.cvs.cmd];
        %
        locdisp(displaymode,['    --> CVS : ',remotecmd]) 
        %
        try
            [res,txt] = matremotecmd(remote,job,remotecmd);
        catch
            res = 1;
            txt = ['Error in CVS update'];
        end
    end
end
%
% process data
%
if isstruct(sinput),% data transfer to job,
    %
    if ~isfield(job,'savefcn') || ~exist(job.savefcn,'file'),
        error('No existing process function provided to save data')
    else
        job = feval(job.savefcn,sinput,job);% save_id is the data file/folder location
    end
    %
else
    job.save_id = sinput;% file/folder prepared externally, location given
end
%
if job.xgridsearch || job.condorsearch || job.directsearch,
    remotecmd_chmod = ['chmod -R 777 ',job.remotedatapath,job.save_id];
end  
%
% data transfer
%
if ~isempty(job.save_id),
    if ~isempty(remotehost),%remote calculation 
        locdisp(displaymode,['    --> Copying data file/folder ',job.localdatapath,job.save_id,' to remote host ',remotehost,':',job.remotedatapath,' as user ',remote.remoteuser,' ...'])  
    elseif ~strcmp(job.localdatapath,job.remotedatapath),
        locdisp(displaymode,['    --> Copying data file/folder ',job.localdatapath,job.save_id,' to location ',job.remotedatapath])  
    end
    %
    [res,err] = matremoteput(remote,job);
    %
    if res ~= 0,
        %
        locdisp(displaymode,['File transfer failed : ',err]);
        job.err = err;
        %
        return
        %
    else
        if job.xgridsearch || job.condorsearch || job.directsearch,
            [res_chmod,txt_chmod] = matremotecmd(remote,job,remotecmd_chmod);
            %
            if res_chmod ~= 0,
                locdisp(displaymode,['Warning: for xgrid and condor schedulers and direct mode only, chmod for directory',job.remotedatapath,job.save_id,' failed : ',txt_chmod]);
            end
        end
        %
    	if ~isempty(remotehost) || ~strcmp(job.localdatapath,job.remotedatapath),
        	locdisp(displaymode,' ... done');
    	end
    end
    %
end
%
[timeres,timestr] = matremotecheck(remote,job,['MAT_RUN_',job.timeid,'.mat']);
%
if ~timeres, 
    job.time.transfered = get_datetime_yp(timestr);% time of job transfer on remote machine (creation of remote MAT_RUN file)
end  
%
% start job
%
if job.directsearch,
    %
    % job environment variables
    %
    remenv = struct;
    if isfield(job,'env') && isstruct(job.env),
        remenv = conc_struct_jd(remenv,job.env);% environment variables stored in remote.env
    end
    %
    % common environment variables
    %
    remenv.jobtimeid = job.timeid;
    remenv.debugmode = num2str(job.debugmode);
    remenv.remotebatchdir = [job.remotedatapath,job.save_id];
    %
    envnames = fieldnames(remenv);
    remenvstr = '';
    %
    for ienv = 1:length(envnames),
        if strcmp(remote.cmd{1},'csh'),
            remenvstr = ['setenv ',envnames{ienv},' ',remenv.(envnames{ienv}),'; ',remenvstr];
        elseif strcmp(remote.cmd{1},'bash'),
            remenvstr = ['export ',envnames{ienv},'=',remenv.(envnames{ienv}),'; ',remenvstr];
        else
            error(['case with cmd = ',remote.cmd{1},' not yet implemented']);
        end
    end
    %
    remotecmd = [remenvstr,remote.cmd{2},job.remotedatapath,job.batch_dir,job.script,remote.cmd{3}];
    %
elseif job.pbssearch,
    %
    % command options
    %
    comopts = '';
    %
    if isfield(remote,'queue') && ~isempty(remote.queue),
        job.walltime = remote.queue.maxtime{remote.queue.qdef};
        comopts = [comopts,' -q ',remote.queue.name{remote.queue.qdef}];
    end
    %
    if isfield(job,'wait') && ~isempty(job.wait) && ~isnan(job.wait) && job.wait == 1,
        comopts = [comopts,' -W block=true'];
    end
    %
    if isfield(job,'nodes') && ~isempty(job.nodes) && ~isnan(job.nodes),
        comopts = [comopts,' -l nodes=',num2str(job.nodes)];
        %
        if isfield(job,'ppn') && ~isempty(job.ppn) && ~isnan(job.ppn),
            comopts = [comopts,':ppn=',num2str(job.ppn)];
        end
        %
    end
    %
    if isfield(job,'select') && ~isempty(job.select) && ~isnan(job.select),
        comopts = [comopts,' -l select=',num2str(job.select)];
        %
        if isfield(job,'ncpus') && ~isempty(job.ncpus) && ~isnan(job.ncpus),
            comopts = [comopts,':ncpus=',num2str(job.ncpus)];
        end
        %
    elseif isfield(job,'ncpus') && ~isempty(job.ncpus) && ~isnan(job.ncpus),
        comopts = [comopts,' -l ncpus=',num2str(job.ncpus)];
    end
    %
    if isfield(job,'memory') && ~isempty(job.memory) && ~isnan(job.memory),
        comopts = [comopts,' -l mem=',num2str(job.memory),'mb'];
    end
    %
    if isfield(job,'walltime') && ~isempty(job.walltime) && (all(ischar(job.walltime)) || ~isnan(job.walltime)),
        if ~all(ischar(job.walltime)),%if walltime is a number, it corresponds to hours only
            job.walltime = [num2str(job.walltime),':00'];
        end
        %
        comopts = [comopts,' -l walltime=',job.walltime,':00'];
    end
    %
    % job environment variables
    %
    jobenvstr = '';
    if isfield(job,'env') && isstruct(job.env),
        envnames = fieldnames(job.env);
        for ienv = 1:length(envnames),
            jobenvstr = [jobenvstr,',',envnames{ienv},'=',job.env.(envnames{ienv})];    
        end
    end
    %
    if iscell(remote.cmd),
        remotecmd = [remote.cmd{1},comopts,' -v jobtimeid=',job.timeid,',debugmode=',num2str(job.debugmode),',remotebatchdir=',job.remotedatapath,job.save_id,jobenvstr,' ',job.remotedatapath,job.batch_dir,job.script];% batch command
    else
        remotecmd = [remote.cmd,comopts,' -v jobtimeid=',job.timeid,',debugmode=',num2str(job.debugmode),',remotebatchdir=',job.remotedatapath,job.save_id,jobenvstr,' ',job.remotedatapath,job.batch_dir,job.script];% batch command
    end
    %
elseif job.slurmsearch,
    %
    % command options
    %
    comopts = '';
    %
    if isfield(job,'nodes') && ~isempty(job.nodes) && ~isnan(job.nodes),
        comopts = [comopts,' --nodes=',num2str(job.nodes)];
        %
        if isfield(job,'ppn') && ~isempty(job.ppn) && ~isnan(job.ppn),
            comopts = [comopts,' --mincpus=',num2str(job.ppn)];
        end
        %
    end
    %
    if isfield(job,'ncpus') && ~isempty(job.ncpus) && ~isnan(job.ncpus),
        comopts = [comopts,' --cpus-per-task=',num2str(job.ncpus)];
    end
    %
    if isfield(job,'memory') && ~isempty(job.memory) && ~isnan(job.memory),
        comopts = [comopts,' --mem=',num2str(job.memory)];
    end
    %
    if isfield(job,'walltime') && ~isempty(job.walltime) && (all(ischar(job.walltime)) || ~isnan(job.walltime)),
        if ~all(ischar(job.walltime)),%if walltime is a number, it corresponds to hours only
            job.walltime = [num2str(job.walltime),':00'];
        end
        %
        comopts = [comopts,' --time=',job.walltime,':00'];
    end
    %
    % job environment variables
    %
    jobenvstr = '';
    if isfield(job,'env') && isstruct(job.env),
        envnames = fieldnames(job.env);
        for ienv = 1:length(envnames),
            jobenvstr = [jobenvstr,',',envnames{ienv},'=',job.env.(envnames{ienv})];    
        end
    end
    %
    remotecmd = [remote.cmd,comopts,' --output=',job.remotedatapath,job.batch_dir,job.script,'_',job.timeid,'.out --error=',job.remotedatapath,job.batch_dir,job.script,'_',job.timeid,'.err --export=jobtimeid=',job.timeid,',debugmode=',num2str(job.debugmode),',remotebatchdir=',job.remotedatapath,job.save_id,jobenvstr,' ',job.remotedatapath,job.batch_dir,job.script];% batch command
    %
elseif job.sgesearch,
    %
    remotecmd = [remote.cmd,' ',job.remotedatapath,job.save_id,job.sge_script];
    %
elseif job.condorsearch,
    %
    % scheduler environment variables
    %
    remotecmd = ['export CONDOR_CONFIG=',remote.condor.CONDOR_CONFIG,'; export PATH=',remote.condor.PATH,'; export jobtimeid=',job.timeid,'; export debugmode=',num2str(job.debugmode),'; ',remote.cmd,' ',job.remotedatapath,job.save_id,job.condor_script,' -v'];
    %
elseif job.xgridsearch,
    %
    if ~isfield(remote,'password') || isempty(remote.password),
        remotecmd = [remote.cmd{1},job.hostname,remote.cmd{3},job.remotedatapath,job.save_id,job.xgrid_script];
        locdisp(displaymode,['    --> Starting run with command ',remotecmd]) 
    else
        remotecmd = [remote.cmd{1},job.hostname,remote.cmd{2},remote.password,remote.cmd{3},job.remotedatapath,job.save_id,job.xgrid_script];
        remotecmd_hiddenpwd = [remote.cmd{1},job.hostname,remote.cmd{2},'*********',remote.cmd{3},job.remotedatapath,job.save_id,job.xgrid_script];
        locdisp(displaymode,['    --> Starting run with command ',remotecmd_hiddenpwd]) 
    end
    %
end
%
if ~job.xgridsearch,
	locdisp(displaymode,['    --> Starting run with command ',remotecmd])
end
%
if iscell(remote.cmd) && (length(remote.cmd) == 4) && ~isempty(remote.cmd(4)),
    [res,txt] = matremotecmd(remote,job,remotecmd,remote.cmd{4});
else
    [res,txt] = matremotecmd(remote,job,remotecmd);
end
%
if res ~= 0,
    %
    locdisp(displaymode,['Remote run start failed : ',txt]);
    job.err = txt;
    %
    return
    %
else
    job.time.launched = utctime_jd;% time of job command sent
end
%
txt(double(txt) == 10) = [];
%
% Read the job id (if accessible)
%
if ~isempty(remote.get_jobid)
    if ~isempty(remote.get_jobid{1}),
        if ~iscell(remote.get_jobid{1}),
            remoteget_jobid = remote.get_jobid(1);% only one test
        else
            remoteget_jobid = remote.get_jobid{1};% more than one tests
        end
        %
        for itests = 1:length(remoteget_jobid),% tests in order
            %
            if isempty(remoteget_jobid{itests}),% empty case is a valid case
                istr0 = 1;
                break
            end
            %
            strl1 = length(remoteget_jobid{itests});
            istr0 = strl1 + min(strfind(txt,remoteget_jobid{itests}));
            %
            if ~isempty(istr0),
                break
            end
            %
        end
        if isempty(istr0),
            error('Job ID could not be retrieved')
        end
    else
        istr0 = 1;
    end
    %
    if ~isempty(remote.get_jobid{2}),
        if ~iscell(remote.get_jobid{2}),
            remoteget_jobid = remote.get_jobid(2);% only one test
        else
            remoteget_jobid = remote.get_jobid{2};% more than one tests
        end
        %
        for itests = 1:length(remoteget_jobid),% tests in order
            %
            if isempty(remoteget_jobid{itests}),% empty case is a valid case
                istr1 = length(txt);
                break
            end
            %
            istr1 = min(strfind(txt(istr0:end),remoteget_jobid{itests})) + istr0 - 2;
            %
            if ~isempty(istr1),
                break
            end
            %
        end
        if isempty(istr1),
            error('Job ID could not be retrieved')
        end
    else
        istr1 = length(txt);
    end
    %
    job.id = txt(istr0:istr1);
    %
    locdisp(displaymode,[' ... started with job id ',job.id]);
    %
else
    %
    job.id = '';
    %
    locdisp(displaymode,[' ... started with job time ID ',job.timeid]);
    %
end
%
job.remote = remote;
%
function locdisp(mode,s)
%
if mode > 1,
    disp(s)
end



