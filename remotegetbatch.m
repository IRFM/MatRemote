function soutput = remotegetbatch(remote,job,displaymode)
%
% This function retrieve results from a batch job on a local or remote host
%
%   INPUTS :
%   
%       - remote : cluster information structure
%           o host : host name (leave empty for local host). ex : 'saturne1.partenaires.cea.fr'
%           o cmd : batch command. ex: qsub
%           o set_jobid : syntax to read the job status : set_jobid{1},jobid,set_jobid{2}
%           o (logname) : user name correspondance. ex : remote.joan = 'JD211098' (same as local user if empty or missing)
%
%
%       - job : job parameters structure
%           o id : cluster id for the job
%           o timeid : time id for the job
%           o remotelogname : user name on cluster
%           o load_id : output file/folder expected (leave empty if no output file)
%           o clean : (0) keep all local and remote files; (1) clean all remote and batch files; (2) clean all local and remote files (default)
%           o localdatapath : location of local data
%           o remotedatapath : location of remote data
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
if job.pbssearch,
    %
    remotecmd = [remoteset_jobid{1},job.id,remoteset_jobid{2}];
    %
elseif job.condorsearch,
    %
    % scheduler environment variables
    %
    remenvstr = '';
    if isfield(remote,'env') && isstruct(remote.env),
        envnames = fieldnames(remote.env);
        for ienv = 1:length(envnames),
            remenvstr = ['export ',envnames{ienv},'=',remote.env.(envnames{ienv}),';',remenvstr];
        end
    end
    %
    remotecmd = [remenvstr,remoteset_jobid{1},job.id,remoteset_jobid{2}];
    %
elseif job.xgridsearch,  
    %%%% TO DO
end
%
locdisp(displaymode,['    --> Checking status of job # ',job.id]);
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
% process job status cases
%
if job.pbssearch,
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
elseif job.condorsearch,
    %
    i_job = strfind(txt,job.id);
    i_running = strfind(txt(i_job:end),'R');
    i_pending = strfind(txt(i_job:end),'I');
    %
    if ~isempty(i_job),% job not completed
        if ~isempty(i_running)
            locdisp(displaymode,['Job # ',job.id,' still running...']);
        elseif ~isempty(i_pending),
            locdisp(displaymode,['Job # ',job.id,' still pending...']);
        else
            %
            locdisp(displaymode,['Run check failed : ',txt]);
            soutput.err = txt;
            %
        end
        %
        return
        %
    end
    %
elseif job.xgridsearch,  
    %%%% TO DO
end
%
% data transfer
%
if ~isempty(job.load_id),
    if ~isempty(remotehost),
        %
        locdisp(displaymode,['    --> Copying output file/folder ',job.load_id,' from remote host ',remotehost,':',job.remotedatapath,...
            ' as user ',remotelogname,' to location ',job.localdatapath,job.load_id])  
        [res,err] = unix(['scp -r ',remotelogname,'@',remotehost,':',job.remotedatapath,job.load_id,' ',job.localdatapath,job.load_id]);
        %
    elseif ~strcmp(job.localdatapath,job.remotedatapath),
        %
        locdisp(displaymode,['    --> Copying output file/folder ',job.remotedatapath,job.load_id,' to location ',job.localdatapath,job.load_id])
        [res,err] = unix(['cp -r ',job.remotedatapath,job.load_id,' ',job.localdatapath,job.load_id]);        
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
    rminputcmd = ['rm -fr ',job.remotedatapath,job.save_id];
    rmoutputcmd = ['rm -fr ',job.remotedatapath,job.load_id];
    %
    if ~isempty(remotehost)
        %
        locdisp(displaymode,['    --> Removing remote input file/folder ',remotehost,':',job.remotedatapath,job.save_id,' as user ',remotelogname,' ...'])
        [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''',rminputcmd,'''']);
        %
    elseif ~strcmp(job.localdatapath,job.remotedatapath),
        %
        locdisp(displaymode,['    --> Removing remote input file/folder ',job.remotedatapath,job.save_id,' ...'])
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
        locdisp(displaymode,['    --> Removing remote output file/folder ',remotehost,':',job.remotedatapath,job.load_id,' as user ',remotelogname,' ...'])
        [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''',rmoutputcmd,'''']);
        %
    elseif ~strcmp(job.localdatapath,job.remotedatapath),
        %
        locdisp(displaymode,['    --> Removing remote output file/folder ',job.remotedatapath,job.load_id,' ...'])
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
    if job.pbssearch,
        %
        batchfileroot = job.script(max(1+[0,strfind(job.script,filesep)]):end);
        rmbatchcmd = ['rm -f ',batchfileroot,'.e',job.id,' ',batchfileroot,'.o',job.id];
        %
        if ~isempty(remotehost)
            %
            locdisp(displaymode,['    --> Removing batch output files from remote host ',remotehost,' as user ',remotelogname,' ...'])
            [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''',rmbatchcmd,'''']);
            %
        else
            %
            locdisp(displaymode,'    --> Removing batch output files ...')
            [res,err] = unix(rmbatchcmd);
            %
        end        
    elseif job.condorsearch,
        %%%% TO DO
    elseif job.xgridsearch,
        %%%% TO DO
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
    rminputcmd = ['rm -fr ',job.localdatapath,job.save_id];
    rmoutputcmd = ['rm -fr ',job.localdatapath,job.load_id];
    %
    locdisp(displaymode,['    --> Removing local input file/folder ',job.localdatapath,job.save_id,' ...'])
    [res,err] = unix(rminputcmd);
    %
    if res ~= 0,
        locdisp(displaymode,['Warning, local input file/folder delete failed : ',err])
    else
        locdisp(displaymode,' ... done');          
    end
    %
    locdisp(displaymode,['    --> Removing local output file/folder ',job.localdatapath,job.load_id,' ...'])
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


