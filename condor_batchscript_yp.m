function filename = condor_batchscript_yp(job,data,debugmode)
%
% This function creates dynamically the batch script for remote
% calculations on a Mac cluster with CONDOR scheduler (can generate multiple
% jobs under the same timeid)
%
% by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 6,error('Not enough input arguments in condor_batchscript_yp.m');end
%
if nargin < 7,
    debugmode = 0;%no debug mode
end
%
filename = ['batch_matlab_',job.timeid,'.condor'];
fileid = fopen(job.localdatapath,job.condor_dir,filename,'w');
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
fprintf(fileid,['InputDir = ',job.remotedatapath,job.condor_dir,'\n']);%CONDOR simulation input dir
fprintf(fileid,[' ','\n']);
%
fprintf(fileid,['#','\n']);
fprintf(fileid,['OutputDir = ',job.remotedatapath,job.condor_dir,'\n']);%CONDOR simulation output dir
fprintf(fileid,[' ','\n']);
%
fprintf(fileid,['#','\n']);
fprintf(fileid,['Executable = ',job.remotedatapath,job.condor_dir,'condor_matlab.sh','\n']);%matlab shell script
fprintf(fileid,[' ','\n']);
%
fprintf(fileid,['#','\n']);
fprintf(fileid,['InitialDir = $(InputDir)','\n']);
fprintf(fileid,[' ','\n']);
%
if debugmode,
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
if isempty(data),%remote computing
    if debugmode,
        fprintf(fileid,['Arguments = runluke(',job.timeid,',1)\n']);
    else
        fprintf(fileid,['Arguments = runluke(',job.timeid,')\n']);
    end
else%dcluke
    fprintf(fileid,['Arguments = load(''input_dcluke_',job.timeid,'.mat'');noms = fieldnames(data.appdata);for  k = 1:length(noms),setappdata(0,noms{k},data.appdata.(noms{k}));end;cd(data.dir);diary(data.diaryfile);clear resultat;try,[resultat{1:nargout(data.commande)}] =  feval(data.commande,data.entrees{:});etat_sortie = 0;catch,etat_sortie = 1;resultat = [];end;etat_error = lasterr;save(data.outputdata,''resultat'',''etat_sortie'',''etat_error'');diary off;\n']);
end
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