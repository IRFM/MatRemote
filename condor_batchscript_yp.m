function filename = condor_batchscript_yp(job)
%
% This function creates dynamically the batch script for remote
% calculations on a Mac cluster with CONDOR scheduler (can generate multiple
% jobs under the same timeid)
%
% by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
filename = ['batch_matlab_',job.timeid,'.condor'];
fileid = fopen([job.localdatapath,job.batch_dir,filename],'w');
%
fprintf(fileid,['####################','\n']);
fprintf(fileid,['##','\n']);
fprintf(fileid,['## Batch CONDOR file for remote job under id ',job.timeid,'\n']);
fprintf(fileid,['##','\n']);
fprintf(fileid,['## Type the following commands in Matlab cmd window to check the CONDOR status','\n']);
fprintf(fileid,['##','\n']);
fprintf(fileid,['## ! condor_status (for the number of available nodes)','\n']);
fprintf(fileid,['## ! condor_q (job queue)','\n']);
fprintf(fileid,['##','\n']);
fprintf(fileid,['####################','\n']);
fprintf(fileid,[' ','\n']);
%
fprintf(fileid,['#','\n']);
fprintf(fileid,['##User = ','\n']);%username, if specified in the CONDOR config.local file
fprintf(fileid,[' ','\n']);
%
fprintf(fileid,['#','\n']);%CONDOR universe
fprintf(fileid,['Universe = vanilla','\n']);
fprintf(fileid,[' ','\n']);
%
fprintf(fileid,['#','\n']);
fprintf(fileid,['InputDir = ',job.remotedatapath,job.batch_dir,'\n']);%CONDOR simulation input dir
fprintf(fileid,[' ','\n']);
%
fprintf(fileid,['#','\n']);
fprintf(fileid,['OutputDir = ',job.remotedatapath,job.batch_dir,'\n']);%CONDOR simulation output dir
fprintf(fileid,[' ','\n']);
%
fprintf(fileid,['#','\n']);
fprintf(fileid,['Executable = ',job.remotedatapath,job.batch_dir,job.script,'\n']);%matlab shell script
fprintf(fileid,[' ','\n']);
%
fprintf(fileid,['#','\n']);
fprintf(fileid,['InitialDir = $(InputDir)','\n']);
fprintf(fileid,[' ','\n']);
%
if job.debugmode,
    fprintf(fileid,['#','\n']);
    fprintf(fileid,['Error = $(OutputDir)/condor_err.',job.timeid,'\n']);
    fprintf(fileid,['Log = $(OutputDir)/condor_log.',job.timeid,'\n']);
    fprintf(fileid,[' ','\n']);
end
%
% job environment variables
%
jobenvstr = '';
if isfield(job,'env') && isstruct(job.env),
    envnames = fieldnames(job.env);
    for ienv = 1:length(envnames),
        jobenvstr = [jobenvstr,envnames{ienv},'=',job.env.(envnames{ienv}),';'];    
    end
    jobenvstr = jobenvstr(1:end-1);
end
fprintf(fileid,['#','\n']);
fprintf(fileid,['environment = ',jobenvstr,'\n']);
fprintf(fileid,[' ','\n']);
%
fprintf(fileid,['#','\n']);
fprintf(fileid,['GetEnv = true','\n']);
fprintf(fileid,[' ','\n']);
%
fprintf(fileid,['#','\n']);
fprintf(fileid,['##Transfer-Input-Files =  ','\n']);
fprintf(fileid,[' ','\n']);
%
fprintf(fileid,['#','\n']);
fprintf(fileid,['##Transfer-Output-Files = ','\n']);
fprintf(fileid,[' ','\n']);
%
fprintf(fileid,['#','\n']);
fprintf(fileid,['Arguments = ','\n']);%,job.args
%
fprintf(fileid,[' ','\n']);
%
fprintf(fileid,['#','\n']);
fprintf(fileid,['##Output = ','\n']);
fprintf(fileid,[' ','\n']);
%
fprintf(fileid,['#','\n']);
fprintf(fileid,['Queue 1','\n']);
fprintf(fileid,[' ','\n']);
%
fclose(fileid);
%