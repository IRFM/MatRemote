function job = matstandardsave(sinput,job)
%
% This function saves the structure sinput in a mat file tagged by logname and timeid 
%
job.load_id = ['MAT_OUT_',job.remotelogname,'_',job.timeid,'.mat'];%output data filename
%
datafile = ['MAT_RUN_',job.remotelogname,'_',job.timeid,'.mat'];%input data filename
%
if job.pbssearch,
    %
    localdatapath = job.localdatapath;% save input directly into data folder
    %
    job.save_id = datafile;% input data file to be transfered
    %    
elseif job.condorsearch,
    %
    job.condor_dir = ['/condor_',job.timeid];
    localdatapath = [job.localdatapath,job.condor_dir];% job directory for condor
    %
    % save condor batch file into job directory 
    %
    job.condor_script = condor_batchscript_yp(job,'',1);
    %
    job.save_id = localdatapath;% entire directory to be transfered
    %
elseif job.xgridsearch,
    %%%% TO DO
end
%
save([localdatapath,datafile],'-struct','sinput');% save input data into file
%

    
    
