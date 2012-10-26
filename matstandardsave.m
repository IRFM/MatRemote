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
    localdatapath = [job.localdatapath,job.condor_dir,filesep];% job directory for condor
    mkdir(localdatapath);
    %
    % save condor batch file into job directory 
    %
    job.condor_script = condor_batchscript_yp(job,'');
    %
    job.save_id = job.condor_dir;% entire directory to be transfered
    %
    job.load_id = [job.condor_dir,filesep,job.load_id];
    %
elseif job.xgridsearch,
    %
    job.xgrid_dir = ['/xgrid_',job.timeid];
    localdatapath = [job.localdatapath,job.xgrid_dir,filesep];% job directory for xgrid
    mkdir(localdatapath);
    %
    % determine remote hostname
    %
    remotecmd = 'echo $HOSTNAME';
    %
    locdisp(displaymode,['    --> Retrieving remote hostname : ',remotecmd]) 
    %
    if ~isempty(remotehost),
        %
        [res,txt] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
        %
    else
        %
        [res,txt] = unix(remotecmd);
        %
    end
    %
    if res ~= 0,
        %
        locdisp(displaymode,['Remote hostname check failed : ',txt]);
        job.err = txt;
        %
        return
        %
    else
        %
        job.hostname = txt(1:end-1);
        %
        locdisp(displaymode,[' ... done. Remote hostname : ',job.hostname])
        %
    end
    %
    % save xgrid batch file into job directory 
    %
    job.xgrid_script = xgrid_batch2xml_yp(job,'');
    %
    job.save_id = job.xgrid_dir;% entire directory to be transfered
    %
    job.load_id = [job.xgrid_dir,filesep,job.load_id];
    %
end
%
save([localdatapath,datafile],'-struct','sinput');% save input data into file
%

    
    
