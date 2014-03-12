function filename = sge_batchscript_yp(job)
%
% This function creates dynamically the batch script for remote
% calculations using the SUN grid engine (SGE) scheduler 
%
% by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if ~isfield(job,'remote'),
    error('Unkown remote field for sge_batchscript_yp.m')
end
%
if strcmp(job.remote.shell,'bash'),
    envcmd = {'export ','='};
elseif strcmp(job.remote.shell,'csh'),
    envcmd = {'setenv ',' '};
else
    error('Unkown shell on the remote computer')
end
%
filename = ['batch_matlab_',job.timeid,'.sh'];
fileid = fopen([job.localdatapath,job.batch_dir,filename],'w');
%
fprintf(fileid,['#!/bin/bash\n']);
%
if isempty(job.walltime),
    error('Undefined job walltime value.');
else
    fprintf(fileid,['#$ -l h_rt=',num2str(job.walltime),':00:00\n']);
end
%
if isempty(job.memory),
    error('Undefined job memory value.');
else
    fprintf(fileid,['#$ -l h_vmem=',num2str(job.memory),'M\n']);
end
%
fprintf(fileid,['#$ -cwd\n']);
%
batchfileroot = job.script(max(1+[0,strfind(job.script,filesep)]):end);
%
if length(batchfileroot) > 3 && strcmp(batchfileroot(end-2:end),'.sh'),
    %
    batchfileroot = batchfileroot(1:end-3);
    %
    fprintf(fileid,['#$ -N ',batchfileroot,'\n']);
    %
else
    fprintf(fileid,['#$ -N matremote'\n']);%name of the sge job
end
%
if isfield(job.remote,'usermail') && ~isempty(job.remote.usermail),
    fprintf(fileid,['#$ -M ',job.remote.usermail,'\n']);%mail about the sge job
else
    fprintf(fileid,['#$ -M\n']);
end

fprintf(fileid,['#$ -m e\n']);
fprintf(fileid,['#$ -notify\n']);
%
ip = 1;
%
while 1,
    %
    if isfield(job.remote.sge,['batchscript_params',int2str(ip)]),
        %
        fprintf(fileid,[job.remote.sge.(['batchscript_params',int2str(ip)]){1},'\n']);
        ip = ip + 1;
        %
    else
        %
        break;
    end
    %
end
%
% job environment variables
%
fprintf(fileid,[envcmd{1},'jobtimeid',envcmd{2},job.timeid,'\n']);
%
if isfield(job,'debugmode') && ~ischar(job.debugmode),
    fprintf(fileid,[envcmd{1},'debugmode',envcmd{2},num2str(job.debugmode),'\n']);
elseif isfield(job,'debugmode') && ischar(job.debugmode),
    fprintf(fileid,[envcmd{1},'debugmode',envcmd{2},job.debugmode,'\n']);
end
%
if isfield(job,'env') && isstruct(job.env),
    envnames = fieldnames(job.env);
    for ienv = 1:length(envnames),
        fprintf(fileid,[envcmd{1},envnames{ienv},envcmd{2},job.env.(envnames{ienv}),'\n']);
    end
end
%
fprintf(fileid,['cd ',job.remotedatapath,job.batch_dir,'\n']);
fprintf(fileid,[job.remotedatapath,job.batch_dir,job.script,'\n']);
%
fclose(fileid);
%