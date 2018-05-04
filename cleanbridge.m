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
        cmd = ['curl ftp://',remote.bridge.ftp.host,'/ftp/transfer/',job.batch_dir,' -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password];
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
                    if strfind(filelist_remote_parsed{end},'datadir'),
                        %
                        cmd_datadir = ['curl ftp://',remote.bridge.ftp.host,'/ftp/transfer/',job.batch_dir,filelist_remote_parsed{end},'/ -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password];
                        %
                        [res_datadir,txt_datadir] = unix(cmd_datadir);
                        %
                        if ~res_datadir,
                            %
                            filelist_datadir_remote = regexp(txt_datadir, '[\f\n\r]', 'split');
                            %
                            for ii_datadir = 1:length(filelist_datadir_remote),
                                %
                                filelist_datadir_remote_parsed = regexp(filelist_datadir_remote{ii_datadir},' ', 'split');
                                %
                                if ~isempty(filelist_datadir_remote_parsed{end}),
                                    %
                                    cmd_datadir_file = ['curl -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password,' --quote "DELE ftp/transfer/',job.batch_dir,filelist_remote_parsed{end},'/',filelist_datadir_remote_parsed{end},'" ftp://',remote.bridge.ftp.host];
                                    %
                                    [res_datadir_file,txt_datadir_file] = unix(cmd_datadir_file);                        
                                end
                            end
                            %
                            cmd_datadir_dir = ['curl -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password,' --quote "RMD ftp/transfer/',job.batch_dir,filelist_remote_parsed{end},'/" ftp://',remote.bridge.ftp.host];
                            %
                            [res_datadir_dir,txt_datadir_dir] = unix(cmd_datadir_dir);
                            %
                        end
                    else
                        cmd = ['curl -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password,' --quote "DELE ftp/transfer/',job.batch_dir,filelist_remote_parsed{end},'" ftp://',remote.bridge.ftp.host];
                        %
                        [res,txt] = unix(cmd);
                    end
                    %
                end
            end
            %
            cmd = ['curl -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password,' --quote "RMD ftp/transfer/',job.batch_dir,'" ftp://',remote.bridge.ftp.host];
            [res,txt] = unix(cmd);
            %
        end
    end
    %
    if res~= 0, 
       disp(['WARNING: ',txt,' -> cleanbridge is done by Matlab FTP, and not FTP over curl'])
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
    remotecmd = ['python -c \"import shutil; shutil.rmtree(''',remote.bridge.ssh.temppath,'/',job.save_id,''')\"'];%remove without rm command to preserve safety with ssh_filter
    [res,txt] = unix([remote.bridge.ssh.sshcmd,' "',remotecmd,'"']);%execute the remote command by ssh 
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
