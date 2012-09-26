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
%           o mem (optional) : syntax for memory allocation : remote.mem{1},num2str(job.memory),remote.mem{2}
%           o (logname) : user name correspondance. ex : remote.joan = 'JD211098' (same as local user if empty or missing)
%
%
%       - job : job parameters structure
%           o script : name of the remote script
%           o savefcn (optional) : matlab function to process sinput with the syntax : save_id = savefcn(sinput,logname,timeid)
%           o root (optional) : location of remote script
%           o memory (optional) : memory allocated to the job (in mb)
%           o localdatapath (optional) : location of local data
%           o remotedatapath (optional) : location of remote data
%           o env(optional) : structure of additional environment variables (strings)
%
%       - sinput : input data structure (optional)
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
job.timeid = timeid_jd(clock);
%
remotehost = remote.host;%  hostname (empty for local host)
remoteget_jobid = remote.get_jobid;% syntax to read the job id 
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
if isfield(remote,logname) && ~isempty(remote.(logname)),
    remotelogname = remote.(logname);
else
    remotelogname = logname;
end
job.remotelogname = remotelogname;
%
% remote script
%
if isfield(job,'root') 
    remoteroot = job.root;% location of remote script
else
    remoteroot = '';
end
%
% memory allocation
%
if isfield(job,'memory') && ~isempty(job.memory),% memory allocation if applicable
    if isfield(remote,'mem') && ~isempty(remote.mem),
        remotemem = [remote.mem{1},num2str(job.memory),remote.mem{2}];
    else
        locdisp(displaymode,'Warning : no memory syntax provided, allocation dismissed')
        remotemem = '';
    end
else
    remotemem = '';
end
%
% process data
%
if isstruct(sinput),% data transfer to job,
    %
    if ~isfield(job,'savefcn') || ~exist(job.savefcn,'file'),
        error('No existing process function provided to save data')
    else
        [save_id,load_id] = feval(job.savefcn,sinput,job);% save_id is the data file/folder location
    end
    %
else
    save_id = sinput;% file/folder prepared externally, location given
end
%
% local data location
%
if isfield(job,'localdatapath') && ~isempty(job.localdatapath),% remote data location
    localdatapath = [job.localdatapath,filesep];
else
    localdatapath = [pwd,filesep];
end
%
% remote data location
%
if isfield(job,'remotedatapath') && ~isempty(job.remotedatapath),% remote data location
    remotedatapath = [job.remotedatapath,filesep];
elseif ~isempty(remotehost),
    remotedatapath = './';
else
    remotedatapath = [pwd,filesep];
end
%
% data transfer
%
if ~isempty(save_id),
    if ~isempty(remotehost),%remote calculation 
        %
        locdisp(displaymode,['    --> Copying data file/folder ',localdatapath,save_id,' to remote host ',remotehost,':',remotedatapath,' as user ',remotelogname,' ...'])  
        [res,err] = unix(['scp -R ',localdatapath,save_id,' ',remotelogname,'@',remotehost,':',remotedatapath]);
        %
    elseif ~strcmp(localdatapath,remotedatapath),
        %
        locdisp(displaymode,['    --> Copying data file/folder ',localdatapath,save_id,' to location ',remotedatapath])  
        [res,err] = unix(['cp -R ',localdatapath,save_id,' ',remotedatapath]);
        %
    else
        res = 0;
    end
    %
    if res ~= 0,
        error(['File transfer failed : ',err])
    end
    locdisp(displaymode,' ... done');
    %
end
%
% additional environment variables
%
envstr = '';
if isfield(job,'env') && isstruct(job.env),
    envnames = fieldnames(job.env);
    for ienv = 1:length(envnames),
        envstr = [envstr,',',envnames{ienv},'=',job.env.(envnames{ienv})];
    end
end
%
% start job
%
remotecmd = [remote.cmd,remotemem,' -v jobtimeid=',job.timeid,',remotedatapath=',remotedatapath,envstr,' ',remoteroot,job.script];% batch command
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
    error(['Remote run start failed : ',err])
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
job.load_id = load_id;
job.save_id = save_id;
%
locdisp(displaymode,[' ... started with Job id ',job.id]);
%
function locdisp(mode,s)
%
if mode == 1,
    disp(s)
end



