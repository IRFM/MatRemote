function [res,txt] = cleanbridge(remote,job)
%
res = 0;
txt = '';
%
remote = bridge_params(remote);
%
if isfield(remote.bridge,'ftp'),
    %
    flag_curl_ftp = testcurl('ftp');
    %
    if flag_curl_ftp,%ftp over curl method
        %
        cmd = ['curl ftp://',remote.bridge.ftp.host,'/',job.batch_dir,' -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password];
        %
        [res,txt] = unix(cmd);
        %
        if ~res,
            filelist_remote = regexp(txt, '[\f\n\r]', 'split');
            %
            for ii = 1:length(filelist_remote),
                %
                filelist_remote_parsed = regexp(filelist_remote{ii},' ', 'split');
                %
                if ~isempty(filelist_remote_parsed{end}),
                    %           
                    cmd = ['curl -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password,' --quote "DELE ',job.batch_dir,filelist_remote_parsed{end},'" ftp://',remote.bridge.ftp.host];
                    %
                    [res,txt] = unix(cmd);
                    %
                end
            end
            %
            cmd = ['curl -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password,' --quote "RMD ',job.batch_dir,'" ftp://',remote.bridge.ftp.host];
            [res,txt] = unix(cmd);
            %
        end
    end
    %
    if ~flag_curl_ftp || res ~= 0,%ftp embedded in matlab
        %
        res = 0;
        txt = '';
        %
        try
            f = ftp(remote.bridge.ftp.host,remote.bridge.ftp.username,remote.bridge.ftp.password);%ftp access to the bridge
            listfiles = dir(f,job.batch_dir(1:end-1));%list all files in batch dir of the bridge
            for ilf = 1:length(listfiles),
                delete(f,[job.batch_dir,listfiles(ilf).name]);%delete all files in batch dir of the bridge
            end
            %
            if isempty(listfiles),
                rmdir(f,job.batch_dir(1:end-1));%delete batch dir of the bridge
            end
            %
            close(f);
            %
        catch err
            res = 1;
            txt = err.message;
        end
        %
    end
    %
elseif isfield(remote.bridge,'ssh'),
    %
    remotecmd = ['rm -fr ',remote.bridge.ssh.temppath,'/',job.save_id];
    [res,txt] = unix(['ssh ',remote.bridge.ssh.username,'@',remote.bridge.ssh.host,' ''',remotecmd,'''']);%execute the remote command by ssh 
    %
end
