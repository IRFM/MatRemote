function [res,txt] = cleanbridge(remote,job)
%
res = 0;
txt = '';
%
remote = bridge_params(remote);
%
if remote.link_mode == 2,
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
            %
            ftp_rmdir(f,job.batch_dir(1:end-1))
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
elseif remote.link_mode == 1,
    %
    remotecmd = ['rm -fr ',remote.bridge.ssh.temppath,'/',job.save_id];
    [res,txt] = unix(['ssh ',remote.bridge.ssh.username,'@',remote.bridge.ssh.host,' ''',remotecmd,'''']);%execute the remote command by ssh 
    %
end
end

function ftp_rmdir(f,rmpath)
    %
    listfiles = dir(f,rmpath);%list all files in batch dir of the bridge
    %
    for ilf = 1:length(listfiles),
        if listfiles(ilf).isdir,
            ftp_rmdir(f,[rmpath,'/',listfiles(ilf).name]);
        else
            delete(f,[rmpath,'/',listfiles(ilf).name]);%delete all files in batch dir of the bridge
        end
    end
    %
    rmdir(f,rmpath);%delete batch dir of the bridge
end
