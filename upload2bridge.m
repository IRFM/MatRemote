function [res,txt] = upload2bridge(remote,job)
%
%try 
%    f = ftp(remote.bridge.ftp.host,remote.bridge.ftp.username,remote.bridge.ftp.password);%ftp access to the bridge
%    mput(f,job.batch_dir(1:end-1));%Transfer data from the local batch dir to the bridge batch dir
%    close(f);
%catch
    filelist = dir(job.batch_dir(1:end-1));
    for ii = 1:length(filelist),
        if ~strcmp(filelist(ii).name,'.') && ~strcmp(filelist(ii).name,'..')
            cmd = ['curl --cacert ',job.batch_dir,filelist(ii).name,' --ftp-create-dirs -T ',job.batch_dir,filelist(ii).name,' -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password,' ftp://',remote.bridge.ftp.host,'/',job.batch_dir,filelist(ii).name];
            [res,txt] = unix(cmd);
        end
    end
%end