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
%           o walltime (optional) :  time required (in hours) - leave empty if no requirement
%
%       - sinput (optional) : input data structure
%       - displaymode : display mode : (0) no display; (1) operation display (default : 0)
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
if nargin < 4,
    displaymode = 0;
end
if nargin < 3,
    sinput = '';
end
%
if ~isfield(job,'timeid') || isempty(job.timeid),
    job.timeid = timeid_jd(clock);
end
%
if ~isfield(job,'debugmode'),
    job.debugmode = 0;
end
%
% path to matlab if applicable
%
if ~isfield(job,'env') || ~isfield(job.env,'remotebatch_matlabroot'),%matlab called remotely and not prescribed by job
    matver = matversion_yp;
    if isempty(remote.host),% same version for local calculations
        job.env.remotebatch_matlabroot = [matlabroot,'/bin/'];
        job.env.remotebatch_matlabprefdir = prefdir;        
    elseif isfield(remote,'matver') && isfield(remote.matver,['mat',matver]) && ~isempty(remote.matver.(['mat',matver])),
        % same version on remote cluster, if available
        job.env.remotebatch_matlabroot = remote.matver.(['mat',matver]).root;
        job.env.remotebatch_matlabprefdir = remote.matver.(['mat',matver]).prefdir;
    elseif isfield(remote,'matver') && isfield(remote.matver,'matdef') && ~isempty(remote.matver.matdef),
        % default version on remote cluster, if available
        job.env.remotebatch_matlabroot = remote.matver.matdef.root;
        job.env.remotebatch_matlabprefdir = remote.matver.matdef.prefdir;
    else% default version on remote cluster
        job.env.remotebatch_matlabroot = '';
        job.env.remotebatch_matlabprefdir = '';
    end
end
%
% Job parameters tested to be compatible with or enforced by remote
%
job = remote2job_jd(remote,job);
%
remotehost = remote.host;%  hostname (empty for local host)
remoteget_jobid = remote.get_jobid;% syntax to read the job id 
%
job.pbssearch = ~iscell(remote.cmd) && ~isempty(strfind(remote.cmd,'qsub'));
%job.condorsearch = iscell(remote.cmd) && any(~cellfun('isempty',strfind(remote.cmd,'condor')));
job.condorsearch = ~iscell(remote.cmd) && ~isempty(strfind(remote.cmd,'condor'));
job.xgridsearch = iscell(remote.cmd) && any(~cellfun('isempty',strfind(remote.cmd,'xgrid')));
%
if job.condorsearch + job.xgridsearch + job.pbssearch ~= 1,
    error('scheduler type identification problem')
end
%
% get local user name
%
[res,logname] = unix('whoami');
%
if res ~= 0,
    error('Local login name could not be obtained')
end
%
% get remote user name
%
logname(double(logname) == 10) = [];% remove return character
%
if isfield(remote,'users') && isfield(remote.users,logname) && ~isempty(remote.users.(logname)),
    remotelogname = remote.users.(logname);
else
    remotelogname = logname;
end
job.remotelogname = remotelogname;
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
if ~isfield(job,'remotedatapath') || isempty(job.remotedatapath),% remote data location
    if ~isempty(remotehost),
        job.remotedatapath = './';
    else
        job.remotedatapath = job.localdatapath;
    end
elseif ~strcmp(job.remotedatapath(end),filesep),
    job.remotedatapath = [job.remotedatapath,filesep];
end
%
% create remote data folder if needed - this also tests remote connection
%
remotecmd = ['test -d ',job.remotedatapath];% test if remote directory exists
if ~isempty(remotehost),
    [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
else
    [res,err] = unix(remotecmd);
end
%
if res == 1,% remote directory does not exist
    remotecmd = ['mkdir ',job.remotedatapath];%create remote directory
    locdisp(displaymode,['    --> Creating remote data folder ',job.remotedatapath])  
    if ~isempty(remotehost),
        [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
    else
        [res,err] = unix(remotecmd);
    end
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
        dir_init = pwd;
        %
        remotecmd = ['CVSROOT=',remote.cvs.CVSROOT,'; export CVSROOT; cd ',remote.luke_root,'; cvs ',remote.cvs.cmd];
        %
        locdisp(displaymode,['    --> CVS : ',remotecmd]) 
        %
        if ~isempty(remotehost),
            %
            try
                [res,txt] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
            catch
                res = 1;
                txt = ['Error in CVS update'];
            end
            %
        else
            %
            try
                [res,txt] = unix(remotecmd);
            catch
                res = 1;
                txt = ['Error in CVS update'];
            end
            %
        end
        %
        cd(dir_init);
    end
end
%
% determine remote hostname (xgrid)
%
if job.xgridsearch,
    %
    remotecmd = 'echo $HOSTNAME';
    %
    locdisp(displaymode,['    --> Retrieving remote hostname : ',remotecmd]) 
    %
    if ~isempty(remotehost),
        %
        [res,txt] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
        %
    else
        %
        [res,txt] = unix(remotecmd);
        %
    end
    %
    if res ~= 0,
        %
        locdisp(displaymode,['Remote hostname check failed : ',txt]);
        job.err = txt;
        %
        return
        %
    else
        %
        job.hostname = txt(1:end-1);
        %
        locdisp(displaymode,[' ... done. Remote hostname : ',job.hostname])
        %
    end
end
%
% copy function to data as string 
%
if isfield(sinput,'fun') && isfield(job,'scriptcopy') && job.scriptcopy
    if ~ischar(sinput.fun),
        funname = func2str(sinput.fun);
    else
        funname = sinput.fun;
    end
    %
    if ~strcmp(funname(end-1:end),'.m'),
        funname = [funname,'.m'];
    end
    sinput.funstr = fileread(funname);
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
if job.xgridsearch | job.condorsearch,
    remotecmd_chmod = ['chmod -R 777 ',job.remotedatapath,job.save_id];
end  
%
% data transfer
%
if ~isempty(job.save_id),
    if ~isempty(remotehost),%remote calculation 
        %
        locdisp(displaymode,['    --> Copying data file/folder ',job.localdatapath,job.save_id,' to remote host ',remotehost,':',job.remotedatapath,' as user ',remotelogname,' ...'])  
        [res,err] = unix(['scp -r ',job.localdatapath,job.save_id,' ',remotelogname,'@',remotehost,':',job.remotedatapath]);
        %
        if job.xgridsearch | job.condorsearch,
            [res_chmod,txt] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd_chmod,'''']);
        end
        %
    elseif ~strcmp(job.localdatapath,job.remotedatapath),
        %
        locdisp(displaymode,['    --> Copying data file/folder ',job.localdatapath,job.save_id,' to location ',job.remotedatapath])  
        [res,err] = unix(['cp -r ',job.localdatapath,job.save_id,' ',job.remotedatapath]);
        %
        if job.xgridsearch | job.condorsearch,
            [res_chmod,txt] = unix(remotecmd_chmod);        
        end
        %
    else
        res = 0;
    end
    %
    if res ~= 0,
        %
        locdisp(displaymode,['File transfer failed : ',err]);
        job.err = err;
        %
        return
        %
    end
    locdisp(displaymode,' ... done');
    %
end
%
pause(5)
%
% start job
%
if job.pbssearch,
    %
    % command options
    %
    comopts = '';
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
    if isfield(job,'ncpus') && ~isempty(job.ncpus) && ~isnan(job.ncpus),
        comopts = [comopts,' -l ncpus=',num2str(job.ncpus)];
    end
    %
    if isfield(job,'memory') && ~isempty(job.memory) && ~isnan(job.memory),
        comopts = [comopts,' -l mem=',num2str(job.memory),'mb'];
    end
    %
    if isfield(job,'walltime') && ~isempty(job.walltime) && ~isnan(job.walltime),
        comopts = [comopts,' -l walltime=',num2str(job.walltime),':00:00'];
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
    remotecmd = [remote.cmd,comopts,' -v jobtimeid=',job.timeid,',debugmode=',num2str(job.debugmode),',remotedatapath=',job.remotedatapath,jobenvstr,' ',job.script];% batch command
    %
elseif job.condorsearch,
    %
    % scheduler environment variables
    %
    remenvstr = '';
    if isfield(remote,'env') && isstruct(remote.env),
        envnames = fieldnames(remote.env);
        for ienv = 1:length(envnames),
            remenvstr = ['export ',envnames{ienv},'=',remote.env.(envnames{ienv}),'; ',remenvstr];
        end
    end
    %
    remotecmd = [remenvstr,'export jobtimeid=',job.timeid,'; export debugmode=',num2str(job.debugmode),'; ',remote.cmd,' ',job.remotedatapath,job.condor_dir,filesep,job.condor_script,' -v'];
    %
elseif job.xgridsearch,
    %
    remotecmd = [remote.cmd{1},job.hostname,remote.cmd{2},remote.password{1},remote.cmd{3},job.remotedatapath,job.xgrid_dir,filesep,job.xgrid_script];
    %
end
%
locdisp(displaymode,['    --> Starting run with command ',remotecmd]) 
%
if ~isempty(remotehost),
    %
    [res,txt] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
    %
else
    %
    [res,txt] = unix(remotecmd);
    %
end
%
if res ~= 0,
    %
    locdisp(displaymode,['Remote run start failed : ',txt]);
    job.err = txt;
    %
    return
    %
end
%
txt(double(txt) == 10) = [];
%
if ~isempty(remoteget_jobid{1}),
    strl1 = length(remoteget_jobid{1});
    istr0 = strl1 + min(strfind(txt,remoteget_jobid{1}));
    if isempty(istr0),
        error('Job ID could not be retrieved')
    end
else
    istr0 = 1;
end
%
if ~isempty(remoteget_jobid{2}),
    istr1 = min(strfind(txt(istr0:end),remoteget_jobid{2})) + istr0 - 2;
    if isempty(istr1),
        error('Job ID could not be retrieved')
    end
else
    istr1 = length(txt);
end
%
job.id = txt(istr0:istr1);
%
job.remote = remote;
%
locdisp(displaymode,[' ... started with Job id ',job.id]);
%
function locdisp(mode,s)
%
if mode == 1,
    disp(s)
end



