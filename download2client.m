function [res,txt] = download2client(remote,job)
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
    filelist_local = dir(job.batch_dir(1:end-1));
    %
    cmd = ['curl ftp://',remote.bridge.ftp.host,'/',job.batch_dir,' -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password];
    %
    [res,txt] = unix(cmd);
    %
    if ~res,
        filelist_remote = regexp(txt, '[\f\n\r]', 'split');
    else
        error('Error: impossible to get the file list on the bridge');
    end
    %
    %
    for ii = 1:length(filelist_remote),
        %
        filelist_remote_parsed = regexp(filelist_remote{ii},' ', 'split');
        %
        flag = 0;
        %
        if ~isempty(filelist_remote_parsed{end}),
            %
            for jj = 1:length(filelist_local),
                %
                if strcmp(filelist_remote_parsed{end},filelist_local(jj).name),
                    if jj > 1 && jj < length(filelist_local),
                        filelist_local = [filelist_local(1:jj-1);filelist_local(jj+1:end)];
                    elseif jj == 1,
                        filelist_local = filelist_local(2:end);
                    elseif jj == length(filelist_local),
                        filelist_local = filelist_local(1:end-1);
                    end
                    %  
                    flag = 1;
                    %
                    break;
                end
            end
            %
            if ~flag,
                %
                cmd = ['curl ftp://',remote.bridge.ftp.host,'/',job.batch_dir,filelist_remote_parsed{end},' -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password,' -o ',job.batch_dir,filelist_remote_parsed{end}];
                %
                [res,txt] = unix(cmd);
                %
            end
        end
    end
else%ftp embedded in matlab (not necessarily operational) 
   %
   f = ftp(remote.bridge.ftp.host,remote.bridge.ftp.username,remote.bridge.ftp.password);%ftp access to the bridge
   mget(f,job.load_id);%Transfer ouput data from the bridge batch dir to the local batch dir
   close(f);
   %
end
