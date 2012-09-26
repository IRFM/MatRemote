function soutput = remotegetbatch(remote,job,displaymode)
%
% This function retrieve results from a batch job on a local or remote host
%
%   INPUTS :
%   
%       - remote : cluster information structure
%           o host : host name (leave empty for local host). ex : 'saturne1.partenaires.cea.fr'
%           o cmd : batch command. ex: qsub
%           o get_jobid : syntax to read the job id : get_jobid{1},jobid,get_jobid{2}
%           o set_jobid : syntax to read the job status : set_jobid{1},jobid,set_jobid{2}
%           o mem (optional) : syntax for memory allocation : remote.mem{1},num2str(job.memory),remote.mem{2}
%           o (logname) : user name correspondance. ex : remote.joan = 'JD211098' (same as local user if empty or missing)
%
%
%       - job : job parameters structure
%           o id : cluster id for the job
%           o timeid : time id for the job
%           o remotelogname : user name on cluster
%           o save_id : input file/folder (leave empty if no input file)
%           o load_id : output file/folder expected (leave empty if no output file)
%           o script : name of the remote script
%           o clean : (0) keep all local and remote files; (1) clean all remote and batch files; (2) clean all local and remote files (default)
%           o localdatapath (optional) : location of local data
%           o remotedatapath (optional) : location of remote data
%
%       - displaymode : display mode : (0) no display; (1) operation display (default : 0)
%
%   OUTPUTS : 
%   
%       - soutput : output data structure (optional)
%
% by J. Decker, Y. Peysson and M. Schneider, CEA/IRFM
%
if nargin < 3,
    displaymode = 0;
end
%
soutput = '';
%
remotehost = remote.host;%  hostname (empty for local host)
remoteset_jobid = remote.set_jobid;% syntax to read the job status 
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
%
% test job status
%
remotecmd = [remoteset_jobid{1},job.id,remoteset_jobid{2}];
%
if ~isempty(remotehost),
    %
    [res,txt] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
    pause(0.1)
    %
else
    %
    [res,txt] = unix(remotecmd);
    %
end
%
txt(double(txt) == 10) = [];
%
if res == 0,% job still running
    %
    locdisp(displaymode,['Job # ',job.id,' still running...']);
    return
    %
elseif isempty(strfind(txt,remoteset_jobid{3})),% run check failed
    %
    locdisp(displaymode,['Run check failed : ',txt]);
    soutput.err = txt;
    %
    return
    %
end
%
% local data location
%
if isfield(job,'localdatapath') && ~isempty(job.localdatapath),% remote data location
    localdatapath = [job.localdatapath,filesep];
else
    localdatapath = './';
end
%
% remote data location
%
if isfield(job,'remotedatapath') && ~isempty(job.remotedatapath),% remote data location
    remotedatapath = [job.remotedatapath,filesep];
else
    remotedatapath = './';
end
%
% data transfer
%
if ~isempty(job.load_id),
    if ~isempty(remotehost),
        %
        locdisp(displaymode,['    --> Copying output file/folder ',job.load_id,'from remote host ',remotehost,':',remotedatapath,...
            ' as user ',remotelogname,' to location ',localdatapath])  
        [res,err] = unix(['scp -R ',remotelogname,'@',remotehost,':',remotedatapath,job.load_id,' ',localdatapath]);
        %
    elseif ~strcmp(localdatapath,remotedatapath),
        %
        locdisp(displaymode,['    --> Copying output file/folder ',remotedatapath,job.load_id,' to location ',localdatapath])
        [res,err] = unix(['cp -R ',remotedatapath,job.load_id,' ',localdatapath]);        
        %
    else
        res = 0;
    end    
    %
    if res ~= 0,
        locdisp(displaymode,['File transfer failed : ',err]);
        soutput.err = err;
        %
        return
    end
    locdisp(displaymode,' ... done');
    %
end
%
% data process
%
if nargout > 0,% data transfer back to matlab,
    %
    if ~isfield(job,'loadfcn') || ~exist(job.loadfcn,'file'),
        error('No existing function provided to process loaded data')
    else
        soutput = feval(job.loadfcn,job);% note : job.load_id is the output data file/folder location
    end
    %
end
%
if isfield(soutput,'err'),
    locdisp(displaymode,'The remote script failed for the following reason : ');
    for istr = 1:length(soutput.err),
        locdisp(displaymode,soutput.err{istr});
    end
end
%
% clean batch files
%
if ~isfield(job,'clean'),
    job.clean = 2;% clean all local and remote files
end
%
if job.clean >= 1,%clean remote and batch files
    %
    rminputcmd = ['rm -fr ',remotedatapath,job.save_id];
    rmoutputcmd = ['rm -fr ',remotedatapath,job.load_id];
    rmbatchcmd = ['rm -f ',job.script,'.e',job.id,' ',job.script,'.o',job.id];
    %
    if ~isempty(remotehost)
        %
        locdisp(displaymode,['    --> Removing remote input file/folder ',remotehost,':',remotedatapath,job.save_id,' as user ',remotelogname,' ...'])
        [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''',rminputcmd,'''']);
        %
    elseif ~strcmp(localdatapath,remotedatapath),
        %
        locdisp(displaymode,['    --> Removing remote input file/folder ',remotedatapath,job.save_id,' ...'])
        [res,err] = unix(rminputcmd);
        %
    end        
    %
    if res ~= 0,
        locdisp(displaymode,['Warning, remote input file/folder delete failed : ',err])
    else
        locdisp(displaymode,' ... done');          
    end
    %
    if ~isempty(remotehost)
        %
        locdisp(displaymode,['    --> Removing remote output file/folder ',remotehost,':',remotedatapath,job.load_id,' as user ',remotelogname,' ...'])
        [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''',rmoutputcmd,'''']);
        %
    elseif ~strcmp(localdatapath,remotedatapath),
        %
        locdisp(displaymode,['    --> Removing remote output file/folder ',remotedatapath,job.load_id,' ...'])
        [res,err] = unix(rmoutputcmd);
        %
    end        
    %
    if res ~= 0,
        locdisp(displaymode,['Warning, remote output file/folder delete failed : ',err])
    else
        locdisp(displaymode,' ... done');          
    end
    %
    if ~isempty(remotehost)
        %
        locdisp(displaymode,['    --> Removing batch output files from remote host ',remotehost,' as user ',remotelogname,' ...'])
        [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''',rmbatchcmd,'''']);
        %
    elseif ~strcmp(localdatapath,remotedatapath),
        %
        locdisp(displaymode,'    --> Removing batch output files ...')
        [res,err] = unix(rmbatchcmd);
        %
    end        
    %
    if res ~= 0,
        locdisp(displaymode,['Warning, batch files delete failed : ',err])
    else
        locdisp(displaymode,' ... done');          
    end
    %
end
%
if job.clean >= 2,%clean local files
    %
    rminputcmd = ['rm -fr ',localdatapath,job.save_id];
    rmoutputcmd = ['rm -fr ',localdatapath,job.load_id];
    %
    locdisp(displaymode,['    --> Removing local input file/folder ',localdatapath,job.save_id,' ...'])
    [res,err] = unix(rminputcmd);
    %
    if res ~= 0,
        locdisp(displaymode,['Warning, local input file/folder delete failed : ',err])
    else
        locdisp(displaymode,' ... done');          
    end
    %
    locdisp(displaymode,['    --> Removing local output file/folder ',localdatapath,job.load_id,' ...'])
    [res,err] = unix(rmoutputcmd);
    %
    if res ~= 0,
        locdisp(displaymode,['Warning, local output file/folder delete failed : ',err])
    else
        locdisp(displaymode,' ... done');          
    end
    %
end
%
function locdisp(mode,s)
%
if mode == 1,
    disp(s)
end


