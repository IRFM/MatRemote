function [job,soutput] = remotegetbatch(job,displaymode,check)
%
% This function checks runs status and retrieves results from a batch or direct job on a local or remote host
%
%   INPUTS :
%   
%       - job : job parameters structure
%           o id : cluster id or process id for the job
%           o timeid : time id for the job
%           o remotelogname : user name on cluster
%           o load_id : output file/folder expected (leave empty if no output file)
%           o clean : (0) keep all local and remote files; (1) clean all remote and batch files; (2) clean all local and remote files (default)
%           o localdatapath : location of local data
%           o remotedatapath : location of remote data
%           o remote : cluster information structure
%           	- host : host name (leave empty for local host). ex : 'saturne1.partenaires.cea.fr'
%           	- cmd : batch command. ex: qsub
%           	- set_jobid : syntax to read the job status : set_jobid{1},jobid,set_jobid{2}
%           	- (logname) : user name correspondance. ex : remote.joan = 'JD211098' (same as local user if empty or missing)
%           o time : job evolution time structure
%
%       - displaymode : display mode : (0) no display; (1) operation display (default : 0)
%
%       - check : check result directly (1-default) or set up wait loop (0) 
%
%   OUTPUTS : 
%   
%       - job : job with updated parameters (time, id, ...)
%       - soutput : output data structure (optional)
%
% by J. Decker, Y. Peysson and M. Schneider, CEA/IRFM
%
if nargin < 3,
    check = 1;% check for result (1) or set-up wait loop (0)  
end
%
if nargin < 2 || isempty(displaymode),
    if isfield(job,'displaymode') && ~isempty(job.displaymode),
        displaymode = job.displaymode;
    else
        displaymode = 1 + job.debugmode;
    end
end 
%
if ~isfield(job,'id'),
    %
    locdisp(displaymode,'No id field in job structure; error starting job likely.');
    %
    if isfield(job,'err')
        soutput.err = job.err;
    else
        soutput.err = 'No id field in job structure';
    end
    %
    return
end
%
if ~isfield(job,'remote'),
    %
    soutput.err = 'No remote profile found in job.';
    %
    locdisp(displaymode,soutput.err);
    %
    return
end
%
remote = job.remote;
%
if check == 0,% set up wait loop
    %
    if isfield(job,'remtimout'),% in minutes
        remtimout = job.remtimout;
    else
        remtimout = Inf;
    end
    %
    if isfield(job,'rempause'),% in minutes
        rempause = job.rempause;
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
        [job,soutput] = remotegetbatch(job,displaymode,1);
        %
        displayrunningjob(job,[],displaymode);
        %
        if ~isempty(soutput),
            break
        end
        %
    end
    %
    if toc(trem) >= 60*remtimout && isempty(soutput),
        soutput.err = 'Time out';
    end
    %
    return
    %
end
%
soutput = '';
%
% check if pid file was created
%
if isempty(job.time.started),
    %
    [timeres,timestr] = matremotecheck(remote,job,['pid_',job.timeid]);
    %
    if ~timeres,% pid file is created, job has started
        %
        job.time.started = get_datetime_yp(timestr);% time of job started (pid file created)
        %
    end  
end
%
% update job.id as pid in direct mode
%
if isempty(job.id),
    %
    if ~isempty(job.time.started),% pid file is created
        %
        remotecmd = ['cat ',job.remotedatapath,job.batch_dir,'pid_',job.timeid];
        [res,txt] = matremotecmd(remote,job,remotecmd);
        %
        if ~res,% read pid
            %
            job.id = strtrim(txt);
            %
        else% could not read pid
            %
            soutput.err = ['Could not read the pid file : ',txt];
            return
            %
        end
    else% job not started yet
        return
    end
end
%
remotehost = remote.host;%  hostname (empty for local host)
remoteset_jobid = remote.set_jobid;% syntax to read the job status 
%
% test job status
%
if job.directsearch,% PID as job.id
    %
    remotecmd = [remoteset_jobid{1},job.id,remoteset_jobid{2}];
    %
elseif job.pbssearch || job.slurmsearch || job.sgesearch
    %
    remotecmd = [remoteset_jobid{1},job.id,remoteset_jobid{2}];
    %
elseif job.condorsearch,
    %
    % scheduler environment variables
    %
    remotecmd = ['export CONDOR_CONFIG=',remote.condor.CONDOR_CONFIG,'; export PATH=',remote.condor.PATH,'; ',remoteset_jobid{1},job.id,remoteset_jobid{2}];
    %
elseif job.xgridsearch,  
    %
    if ~isfield(remote,'password') || isempty(remote.password),
        remotecmd = [remoteset_jobid{1},job.hostname,remoteset_jobid{2},job.id];
    else
        remotecmd = [remoteset_jobid{1},job.hostname,remote.cmd{2},remote.password,remoteset_jobid{2},job.id];
    end
    %
end
%
locdisp(displaymode,['    --> Checking status of job # ',job.id]);
[res,txt] = matremotecmd(remote,job,remotecmd);
%
pause(0.1);
%
txt(double(txt) == 10) = [];
%
% process job status cases
%
if job.directsearch,
    %
    if any(strfind(txt,remoteset_jobid{3})),
        locdisp(displaymode,['Job # ',job.id,' still running...']);
        return
    end
    %
elseif job.pbssearch  || job.sgesearch,
    %
    if res == 0,% job still running
        %
        if ~isempty(strfind(txt,job.id)) && length(remoteset_jobid) > 3,% case where qstat shows completed job status for a while (ex : abacus)
            if isempty(strfind(txt,remoteset_jobid{4})),
                return;
            end
        else
            return
        end
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
elseif job.slurmsearch,
    %
    if res == 0,% if remoteset_jobid{3} == '', search for job.id in txt, otherwise search for remoteset_jobid{3}
        if (~isempty(remoteset_jobid{3}) && ~isempty(strfind(txt,remoteset_jobid{3})))...
        || (isempty(remoteset_jobid{3}) && ~isempty(strfind(txt,job.id))),
            return% run still running
        end
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
    if ~isfield(remote,'password') || isempty(remote.password),
        remotecmd = [remoteset_jobid{1},job.hostname,remoteset_jobid{6},job.id,' -se ',job.remotedatapath,job.batch_dir,'error_file',' -so ',job.remotedatapath,job.batch_dir,'output_file -out'];  
    else
        remotecmd = [remoteset_jobid{1},job.hostname,remote.cmd{2},remote.password,remoteset_jobid{6},job.id,' -se ',job.remotedatapath,job.batch_dir,'error_file',' -so ',job.remotedatapath,job.batch_dir,'output_file -out'];  
    end
    %
    [res,err] = matremotecmd(remote,job,remotecmd);
    %
    pause(0.1);
    %
    if res == 0,% error file successfuly transfered
        locdisp(displaymode,['    --> Remote transfer of xgrid error and output files for Job # ',job.id,' on the remote computer completed.']);
    else
        locdisp(displaymode,['Remote transfer of xgrid error and output files for Job # ',job.id,' failed : ',err]);
    end        
    %
    % extract result files
    %
    res = matremotecheck(remote,job,['MAT_OUT_',job.timeid,'.mat']);%check if the results are already back to the temp batch dir
    %
    if res,
        %
        if ~isfield(remote,'password') || isempty(remote.password),
            remotecmd = [remoteset_jobid{1},job.hostname,remoteset_jobid{6},job.id,' -out ',job.remotedatapath,job.batch_dir];  
        else
            remotecmd = [remoteset_jobid{1},job.hostname,remote.cmd{2},remote.password,remoteset_jobid{6},job.id,' -out ',job.remotedatapath,job.batch_dir];  
        end
        %
        [res,err] = matremotecmd(remote,job,remotecmd);
        %
        pause(0.1);
        %
        if res == 0,% result file successfuly transfered
            locdisp(displaymode,['    --> File transfer from xgrid temp dir for Job # ',job.id,' on the remote computer completed.']);
        else
            locdisp(displaymode,['File transfer from xgrid temp dir failed : ',err]);
            soutput.err = err;
            %
            return
        end 
    else
        locdisp(displaymode,['    --> File transfer from xgrid temp dir for Job # ',job.id,' on the remote computer completed.']);
    end
end
%
% data transfer (results are transfered back from the remote to the local computer) 
%
if ~isempty(job.load_id),
    %
    if ~isempty(remotehost),
        %
        locdisp(displaymode,['    --> Copying output file/folder ',job.load_id,' from remote host ',remotehost,':',job.remotedatapath,...
            ' as user ',remote.remoteuser,' to location ',job.localdatapath,job.load_id])  
        %
    elseif ~strcmp(job.localdatapath,job.remotedatapath),
        %
        locdisp(displaymode,['    --> Copying output file/folder ',job.remotedatapath,job.load_id,' to location ',job.localdatapath,job.load_id])
        %
    end    
    %
    itmax = 50;
    remotefilemtime = 0;
    %
    for it = 0:itmax,% check that the MAT_OUT file is written completely
        [timeres,timestr] = matremotecheck(remote,job,['MAT_OUT_',job.timeid,'.mat']);
        if timeres == 0,% MAT_OUT file exists
            if strcmp(remotefilemtime,timestr),% MAT_OUT file is written completely
                break
            else
                remotefilemtime = timestr;
            end
        end
    end
    %
    if timeres,
        soutput.err = ['Error: the output file MAT_OUT_',job.timeid,'.mat has not been saved in the directory ',job.remotedatapath,job.batch_dir,' whereas the job is done.'];
        locdisp(displaymode,soutput.err);
        %
        return
    elseif ~strcmp(remotefilemtime,timestr)
        locdisp(displaymode,['WARNING : the output file MAT_OUT_',job.timeid,'.mat may not have been written completely before being copied.']);
    end
    %
    job.time.finished = get_datetime_yp(timestr);%considered to be the time at which the simulation stops
    %
    [res,err] = matremoteget(remote,job);
    %
    if res ~= 0,
        locdisp(displaymode,['File transfer failed : ',err]);
        soutput.err = err;
        %
        return
        %
    else
        job.time.retrieved = utctime_jd;% time of result transfer back to local machine
    end
    %
    if ~isempty(remotehost) || ~strcmp(job.localdatapath,job.remotedatapath),
        locdisp(displaymode,' ... done');
    end
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
        %
        job.time.processed = utctime_jd;% time to process the results and generate outputs
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
outputclear = ~strcmp([fileparts(job.load_id),filesep],job.save_id);% case where job.load_id is not equal or included in job.save_id
%
if job.clean >= 1,%clean remote and batch files
    %
    % remote files & folders
    %
    rminputcmd = ['rm -fr ',job.remotedatapath,job.save_id];
    %
    if ~isempty(remotehost)
        %
        locdisp(displaymode,['    --> Removing remote input file/folder ',remotehost,':',job.remotedatapath,job.save_id,' as user ',remote.remoteuser,' ...'])
    elseif ~strcmp(job.localdatapath,job.remotedatapath),
        locdisp(displaymode,['    --> Removing remote input file/folder ',job.remotedatapath,job.save_id,' ...'])
    end
    %
    [res,err] = matremoteclean(remote,job,rminputcmd);
    %
    if res ~= 0,
        locdisp(displaymode,['Warning, remote input file/folder delete failed : ',err])
    elseif ~isempty(remotehost) || ~strcmp(job.localdatapath,job.remotedatapath),
        locdisp(displaymode,' ... done');          
    end
    %
    if outputclear,
        rmoutputcmd = ['rm -fr ',job.remotedatapath,job.load_id];
        %
    	if ~isempty(remotehost)
        	locdisp(displaymode,['    --> Removing remote output file/folder ',remotehost,':',job.remotedatapath,job.load_id,' as user ',remote.remoteuser,' ...'])
    	elseif ~strcmp(job.localdatapath,job.remotedatapath),
        	locdisp(displaymode,['    --> Removing remote output file/folder ',job.remotedatapath,job.load_id,' ...'])
    	end
    	%
    	[res,err] = matremoteclean(remote,job,rmoutputcmd);
        %
        if res ~= 0,
            locdisp(displaymode,['Warning, remote output file/folder delete failed : ',err])
        elseif ~isempty(remotehost) || ~strcmp(job.localdatapath,job.remotedatapath),
            locdisp(displaymode,' ... done');          
        end
    end
    %
    % batch or temp files
    %
    if job.directsearch,
        %
        for ii = 1:length(remote.cmd),
            if iscell(remote.cmd) && ~isempty(strfind(remote.cmd{ii},'nohup')),
                %
                rmbatchcmd = 'rm -f nohup.out';
                locdisp(displaymode,'    --> Removing nohup.out output file ...')
                [res,err] = matremotecmd(remote,job,rmbatchcmd);
                break;
                %
            end
        end
        %
    elseif job.pbssearch || job.sgesearch,
        %
        batchfileroot = job.script(max(1+[0,strfind(job.script,filesep)]):end);
        %
        if (~isfield(remote,'shclean') || isempty(remote.shclean) || remote.shclean == 0) && length(batchfileroot) > 3 && strcmp(batchfileroot(end-2:end),'.sh'),
            batchfileroot = batchfileroot(1:end-3);
        end
        %
        rmbatchcmd = ['rm -f ',batchfileroot,'.e',job.id,' ',batchfileroot,'.o',job.id];
        %
        if ~isempty(remotehost)
            %
            locdisp(displaymode,['    --> Removing batch output files from remote host ',remotehost,' as user ',remote.remoteuser,' ...'])
            [res,err] = matremotecmd(remote,job,rmbatchcmd);
            %
        else
            %
            locdisp(displaymode,'    --> Removing batch output files ...')
            [res,err] = matremotecmd(remote,job,rmbatchcmd);
            %
        end
        %
    elseif job.slurmsearch,
        %
        rmbatchcmd = ['rm -f slurm-',job.id,'.out'];
        %
        if ~isempty(remotehost)
            %
            locdisp(displaymode,['    --> Removing batch output files from remote host ',remotehost,' as user ',remote.remoteuser,' ...'])
            [res,err] = matremotecmd(remote,job,rmbatchcmd);
            %
        else
            %
            locdisp(displaymode,'    --> Removing batch output files ...')
            [res,err] = matremotecmd(remote,job,rmbatchcmd);
            %
        end
        %
    elseif job.condorsearch,
        %
        res = 0;
        %
    elseif job.xgridsearch,
        %
        if ~isfield(remote,'password') || isempty(remote.password),
            rmbatchcmd = [remoteset_jobid{1},job.hostname,remoteset_jobid{10},job.id];
        else
            rmbatchcmd = [remoteset_jobid{1},job.hostname,remote.cmd{2},remote.password,remoteset_jobid{10},job.id];
        end
        %
        if ~isempty(remotehost),
            %
            locdisp(displaymode,['    --> Removing batch output files from remote host ',remotehost,' as user ',remote.remoteuser,' ...'])
            [res,err] = matremotecmd(remote,job,rmbatchcmd);
            pause(0.1)
            %
        else
            %
            locdisp(displaymode,'    --> Removing batch output files ...')
            [res,err] = matremotecmd(remote,job,rmbatchcmd);
            %
        end       
    end
    %
    if res ~= 0,
        locdisp(displaymode,['Warning, batch files delete failed : ',err])
    elseif job.pbssearch || job.slurmsearch || job.xgridsearch,
        locdisp(displaymode,' ... done');          
    end
    %
end
%
if job.clean >= 2,%clean local files
    %
    rminputcmd = ['rm -fr ',job.localdatapath,job.save_id];
    %
    locdisp(displaymode,['    --> Removing local input file/folder ',job.localdatapath,job.save_id,' ...'])
    %
    [res,err] = unix(rminputcmd);
    %
    if res ~= 0,
        locdisp(displaymode,['Warning, local input file/folder delete failed : ',err])
    else
        locdisp(displaymode,' ... done');          
    end
    %
    if outputclear,% case where job.load_id is not equal or included in job.save_id
        %
        rmoutputcmd = ['rm -fr ',job.localdatapath,job.load_id];
        %
        locdisp(displaymode,['    --> Removing local output file/folder ',job.localdatapath,job.load_id,' ...'])
        [res,err] = unix(rmoutputcmd);
        %
        if res ~= 0,
            locdisp(displaymode,['Warning, local output file/folder delete failed : ',err])
        else
            locdisp(displaymode,' ... done');          
        end
    end
end
%
job.time.cleaned = utctime_jd;% time of clean job temp files & folders
%
end
%
function locdisp(mode,s)
    if mode > 1,
        disp(s)
    end
end
%
