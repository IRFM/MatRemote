function soutput = remotegetbatch(remote,job,displaymode,check)
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
%       - check : check result directly (1-default) or set up wait loop (0) 
%
%   OUTPUTS : 
%   
%       - soutput : output data structure (optional)
%
% by J. Decker, Y. Peysson and M. Schneider, CEA/IRFM
%
if nargin < 4,
    check = 1;% check for result (1) or set-up wait loop (0)  
end
%
if nargin < 3,
    displaymode = 0;
end
%
if ~isfield(job,'id'),
    %
    locdisp(displaymode,'No id field in job structure; error starting job likely.');
    %
    if isfield(job,'err')
        soutput.err = job.err;
    end
    %
    return
end
%
if check == 0,
    %
    if isfield(remote,'remtimout'),% in minutes
        remtimout = remote.remtimout;
    else
        remtimout = Inf;
    end
    %
    if isfield(remote,'rempause'),% in minutes
        rempause = remote.rempause;
    else
        rempause = 1/6;
    end
    %
    trem = tic;
    %
    while toc(trem) < 60*remtimout,
        %
        pause(60*rempause);
        %
        soutput = remotegetbatch(remote,job,displaymode,1);
        %
        if ~isempty(soutput),
            break
        end
        %
        if displaymode,
            disp(['Run still executed remotely. Elapsed time (mins) ',num2str(toc(trem)/60),'/',num2str(remtimout)])
        end
        %
    end
    %
    return
    %
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
if isfield(remote,'users') && isfield(remote.users,logname) && ~isempty(remote.users.(logname)),
    remotelogname = remote.users.(logname);
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
    %
    remotecmd = [remoteset_jobid{1},job.hostname,remote.cmd{2},remote.password{1},remoteset_jobid{2},job.id];  
    %
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
    i_held = strfind(txt(i_job:end),'H');
    i_unexpanded = strfind(txt(i_job:end),'U');
    i_completed = strfind(txt(i_job:end),'C');
    i_submissionerror = strfind(txt(i_job:end),'E');
    i_removed = strfind(txt(i_job:end),'X');
    %
    if ~isempty(i_job),% job not completed
        if ~isempty(i_running)
            locdisp(displaymode,['Job # ',job.id,' still running...']);
        elseif ~isempty(i_pending),
            locdisp(displaymode,['Job # ',job.id,' still pending...']);
        elseif ~isempty(i_held),
            locdisp(displaymode,['Job # ',job.id,' is held...']);
        elseif ~isempty(i_unexpanded),
            locdisp(displaymode,['Job # ',job.id,' unexpanded...']);
        elseif ~isempty(i_completed),
            locdisp(displaymode,['Job # ',job.id,' completed...']);
        elseif ~isempty(i_submissionerror),
            locdisp(displaymode,['Job # ',job.id,' has a submission error...']);
        elseif ~isempty(i_removed),
            locdisp(displaymode,['Job # ',job.id,' has has been removed...']);
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
    %
    if ~isempty(strfind(txt,remoteset_jobid{3})), % job still running
        return
    elseif ~isempty(strfind(txt,remoteset_jobid{4})), % job pending
        return
    else
        if isempty(strfind(txt,remoteset_jobid{5})), % job has a problem (check if xgrid is in operation on the remote machine)
            disp(['Remote run check failed : ',txt]);
            return
        end
    end
    %
    % extract output and error files
    %
    remotecmd = [remoteset_jobid{1},job.hostname,remote.cmd{2},remote.password{1},remoteset_jobid{6},job.id,' -se ',job.remotedatapath,job.xgrid_dir,filesep,'error_file',' -so ',job.remotedatapath,job.xgrid_dir,filesep,'output_file -out'];  
    %
    if ~isempty(remotehost),
        %
        [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
        pause(0.1)
        %
    else
        %
        [res,err] = unix(remotecmd);
        %
    end
    %
    if res == 0,% error file successfuly transfered
        locdisp(displaymode,['    --> Remote transfer of xgrid error and output files for Job # ',job.id,' on the remote computer completed.']);
    else
        locdisp(displaymode,['Remote transfer of xgrid error and output files for Job # ',job.id,' failed : ',err]);
    end        
    %
    % extract result files
    %
    remotecmd = [remoteset_jobid{1},job.hostname,remote.cmd{2},remote.password{1},remoteset_jobid{6},job.id,' -out ',job.remotedatapath,job.xgrid_dir];  
    %
    if ~isempty(remotehost),
        %
        [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
        pause(0.1)
        %
    else
        %
        [res,err] = unix(remotecmd);
        %
    end
    %
    if res == 0,% result file successfuly transfered
        locdisp(displaymode,['    --> Remote transfer of xgrid result files for Job # ',job.id,' on the remote computer completed.']);
    else
        locdisp(displaymode,['File transfer from xgrid temp dir failed : ',err]);
        soutput.err = err;
        %
        return
    end            
end
%
% data transfer
%
if ~isempty(job.load_id),
    if ~isempty(remotehost),
        %
        locdisp(displaymode,['    --> Copying output file/folder ',job.load_id,' from remote host ',remotehost,':',job.remotedatapath,...
            ' as user ',remotelogname,' to location ',job.localdatapath,job.load_id])  
        %
        if job.xgridsearch,%Files must be first transfered from xgrid temp directory to the job folder on the remote computer before being transfered back to the local computer
            %
            [res,err] = unix(['scp -r ',remotelogname,'@',remotehost,':',job.remotedatapath,job.xgrid_dir,filesep,'output_file ',job.localdatapath,job.xgrid_dir,filesep,'output_file']);
            %
            if res ~= 0,
                locdisp(displaymode,['xgrid output file transfer failed : ',err]);
                soutput.err = err;
                %
                return
            end            
            %
            [res,err] = unix(['scp -r ',remotelogname,'@',remotehost,':',job.remotedatapath,job.xgrid_dir,filesep,'error_file ',job.localdatapath,job.xgrid_dir,filesep,'error_file']);
            %
            if res ~= 0,
                locdisp(displaymode,['xgrid error file transfer failed : ',err]);
                soutput.err = err;
                %
                return
            end
        end
        %
        [res,err] = unix(['scp -r ',remotelogname,'@',remotehost,':',job.remotedatapath,job.load_id,' ',job.localdatapath,job.load_id]);
        %
    elseif ~strcmp(job.localdatapath,job.remotedatapath),
        %
        locdisp(displaymode,['    --> Copying output file/folder ',job.remotedatapath,job.load_id,' to location ',job.localdatapath,job.load_id])
        %
        if job.xgridsearch,%data must be first transfered from xgrid temp folder to the job folder
            %
            remotecmd = [remoteset_jobid{1},job.hostname,remote.cmd{2},remote.password{1},remoteset_jobid{6},job.id,' -out ',job.remotedatapath,job.xgrid_dir];  
            %
            [res,err] = unix(remotecmd);
            %           
            if res ~= 0,
                locdisp(displaymode,['File transfer from xgrid temp dir failed : ',err]);
                soutput.err = err;
                %
                return
            end            
            %
            [res,err] = unix(['cp -r ',job.remotedatapath,job.xgrid_dir,filesep,'output_file ',job.localdatapath,job.xgrid_dir,filesep,'output_file']);
            %
            if res ~= 0,
                locdisp(displaymode,['xgrid output file transfer failed : ',err]);
                soutput.err = err;
                %
                return
            end            
            %
            [res,err] = unix(['cp -r ',job.remotedatapath,job.xgrid_dir,filesep,'error_file ',job.localdatapath,job.xgrid_dir,filesep,'error_file']);
            %
            if res ~= 0,
                locdisp(displaymode,['xgrid error file transfer failed : ',err]);
                soutput.err = err;
                %
                return
            end
            %
        end
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
    if ~iscell(soutput.err),
        soutput.err = {soutput.err};
    end
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
        if (~isfield(remote,'shclean') || isempty(remote.shclean) || remote.shclean == 0) && length(batchfileroot) > 3 && strcmp(batchfileroot(end-2:end),'.sh'),
            batchfileroot = batchfileroot(1:end-3);
        end
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
        %
        rmbatchcmd = [remoteset_jobid{1},job.hostname,remote.cmd{2},remote.password{1},remoteset_jobid{10},job.id];
        %
        if ~isempty(remotehost),
            %
            locdisp(displaymode,['    --> Removing batch output files from remote host ',remotehost,' as user ',remotelogname,' ...'])
            [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''',rmbatchcmd,'''']);
            pause(0.1)
            %
        else
            %
            locdisp(displaymode,'    --> Removing batch output files ...')
            [res,err] = unix(rmbatchcmd);
            %
        end       
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


