function filename = sge_batchscript_yp(job)
%
% This function creates dynamically the batch script for remote
% calculations using the SUN grid engine (SGE) scheduler 
%
% by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if strcmp(job.shell,'bash'),
    envcmd = {'export ','='};
elseif strcmp(job.shell,'csh'),
    envcmd = {'setenv ',' '};
else
    error('Unkown shell on the remote computer')
end
%
filename = ['batch_matlab_',job.timeid,'.sh'];
fileid = fopen([job.localdatapath,job.batch_dir,filename],'w');
%
if isfield(job,'params'),
    %
    for ijp = 1:length(job.params);
        %
        param = job.params{ijp};
        %
        if strcmp(param,'#$ -N'),
            %
            batchfileroot = job.script(max(1+[0,strfind(job.script,filesep)]):end);
            %
            if length(batchfileroot) > 3 && strcmp(batchfileroot(end-2:end),'.sh'),
                %
                batchfileroot = batchfileroot(1:end-3);
                %
                fprintf(fileid,[param,' ',batchfileroot,'\n']);
                %
            else
                fprintf(fileid,[param,' matremote'\n']);
            end
            %
        elseif strcmp(param,'#$ -M'),
            %
            if isfield(job,'usermail') && ~isempty(job.usermail),
                %
                fprintf(fileid,[param,' ',job.usermail,'\n']);
                %
            end
            %
        else
            fprintf(fileid,[param,'\n']);
        end
    end
end
%
% job environment variables
%
fprintf(fileid,[envcmd{1},'jobtimeid',envcmd{2},job.timeid,'\n']);
fprintf(fileid,[envcmd{1},'debugmode',envcmd{2},job.timeid,'\n']);
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
fprintf(fileid,[' ','\n']);
%
fclose(fileid);
%