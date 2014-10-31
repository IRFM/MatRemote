function job = matstandardsave(sinput,job)
%
% This function creates the batch directory and saves therein :
%   - the structure sinput in a mat file MAT_RUN_... tagged by logname and timeid 
%   - the script to be run as batch
%   - the 
%
job.batch_dir = ['batch_',job.timeid,filesep];
mkdir([job.localdatapath,job.batch_dir]);% create batch directory
%
savefile = ['MAT_RUN_',job.timeid,'.mat'];%input data filename
loadfile = ['MAT_OUT_',job.timeid,'.mat'];%output data filename
datadir = ['datadir_',job.timeid,filesep];%output data directory
mkdir([job.localdatapath,job.batch_dir,datadir])
%
% create specific scripts for condor jobs
%
if job.condorsearch,
    %
    % save condor batch file into job directory 
    %
    job.condor_script = condor_batchscript_yp(job);
    %
elseif job.sgesearch,
    %
    % save sge batch file into job directory 
    %
    job.sge_script = sge_batchscript_yp(job);
    %
end
%
save([job.localdatapath,job.batch_dir,savefile],'-struct','sinput');% save input data into file
%
% copy script file to local folder
%
if job.funcopy >= 0,
    if isfield(job,'script') && ~isempty(job.script),
        safecopyfile(job.script,[job.localdatapath,job.batch_dir]);% script to be called by scheduler (ex : matlabbatch.sh)
    end
    %
    % for standard remote matlab job, also copy path and remote matlab functions to local folder
    %
    if isfield(job,'env') && isfield(job.env,'remotebatch_matlabfun') && ~isempty(job.env.remotebatch_matlabfun),
        safecopyfile(job.env.remotebatch_matlabfun,[job.localdatapath,job.batch_dir]);% matlab function (ex : remotematrun) to be called by batch script (only with matlabbatch.sh)
    end
    %
    if isfield(job,'env') && isfield(job.env,'remotematfnc') && ~isempty(job.env.remotematfnc),
        safecopyfile(job.env.remotematfnc,[job.localdatapath,job.batch_dir]);% matlab function to take the input structure 'sinput' (only with remotematrun)
    end
    %
    if isfield(sinput,'fun') && ~isempty(sinput.fun) && job.funcopy == 1,
        safecopyfile(sinput.fun,[job.localdatapath,job.batch_dir]);% matlab function to be called by batch script
    end
end
%
job.save_id = job.batch_dir;% batch directory to be transfered if remote cluster
job.load_id = [job.batch_dir,loadfile];
job.datadir = [job.batch_dir,datadir];
%
end
%
function safecopyfile(filename,savedir)
    if ~ischar(filename)
        filename = func2str(filename);
    end
    filepath = which(filename);
    if ~isempty(filepath),
        copyfile(filepath,savedir);
    else
        error(['The file = ',filename,' cannot be found on the local matlab path']);
    end
end
    
    
