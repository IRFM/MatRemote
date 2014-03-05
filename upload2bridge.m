function [res,txt] = upload2bridge(remote,job)
%
res = 0;
txt = '';
%
[remote] = bridge_params(remote);
%
flag_curl_ftp = testcurl('ftp');
%
if flag_curl_ftp,%ftp over curl method
    %
    filelist = dir(job.batch_dir(1:end-1));
    for ii = 1:length(filelist),
        if ~strcmp(filelist(ii).name,'.') && ~strcmp(filelist(ii).name,'..')
            cmd = ['curl --cacert ',job.batch_dir,filelist(ii).name,' --ftp-create-dirs -T ',job.batch_dir,filelist(ii).name,' -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password,' ftp://',remote.bridge.ftp.host,'/',job.batch_dir,filelist(ii).name];
            [res,txt] = unix(cmd);
        end
    end
    %
else%ftp embedded in matlab (not necessarily operational)
    %
    f = ftp(remote.bridge.ftp.host,remote.bridge.ftp.username,remote.bridge.ftp.password);%ftp access to the bridge
    mput(f,job.batch_dir(1:end-1));%Transfer data from the local batch dir to the bridge batch dir
    close(f);
    %
end