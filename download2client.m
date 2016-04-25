function [res,txt] = download2client(remote,target,locpath)
%
res = 0;
txt = '';
%
[remote] = bridge_params(remote);
%
if remote.link_mode == 2,
    %
    initdir = pwd;
    cd(locpath);
    %
    flag_curl_ftp = testcurl('ftp');
    %
    if flag_curl_ftp,%ftp over curl method
        %
        parentdir = fileparts(target);
        if isempty(parentdir),
            parentdir = '.';
        end
        parentdir = [parentdir,filesep];
        %   
        filelist_local = dir(parentdir);
        filelist_local = filelist_local(arrayfun(@(x) x.name(1), filelist_local) ~= '.');
        %
        cmd = ['curl ftp://',remote.bridge.ftp.host,'/transfer/',parentdir,' -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password];
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
                flag = 0;
                %
                if ~isempty(filelist_remote_parsed{end}),
                    %
                    for jj = 1:length(filelist_local),
                        %
                        if strcmp(filelist_remote_parsed{end},filelist_local(jj).name),
                            if  ~isdir([parentdir,filelist_local(jj).name]),
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
                            else
                                %
                                flag = 2;
                                %
                                break;
                            end
                        end
                    end
                    %
                    if flag == 0,
                        %
                        cmd = ['curl ftp://',remote.bridge.ftp.host,'//transfer/',parentdir,filelist_remote_parsed{end},' -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password,' -o ',parentdir,filelist_remote_parsed{end}];
                        %
                        [res,txt] = unix(cmd);
                        %
                    elseif flag == 2,%transfer of all files in datadir
                        %
                        cmd_datadir = ['curl ftp://',remote.bridge.ftp.host,'//transfer/',parentdir,filelist_local(jj).name,'/ -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password];
                        %
                        [res_datadir,txt_datadir] = unix(cmd_datadir);          
                        %
                        if ~res_datadir,
                            if ~isempty(txt_datadir),
                                filelist_datadir_remote = regexp(txt_datadir, '[\f\n\r]', 'split');
                                %
                                for ii = 1:length(filelist_datadir_remote),
                                    %
                                    filelist_datadir_remote_parsed = regexp(filelist_datadir_remote{ii},' ', 'split');
                                    %
                                    cmd_datadir_file = ['curl ftp://',remote.bridge.ftp.host,'//transfer/',parentdir,filelist_local(jj).name,'/',filelist_datadir_remote_parsed{end},' -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password,' -o ',parentdir,filelist_local(jj).name,'/',filelist_datadir_remote_parsed{end}];
                                    %
                                    [res_datadir_file,txt_datadir_file] = unix(cmd_datadir_file);
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    %
	if res~= 0, 
        disp(['WARNING: ',txt,' -> download2client is done by Matlab FTP, and not FTP over curl'])
	end
    %
    if ~flag_curl_ftp || res ~= 0,%ftp embedded in matlab
        %
        res = 0;
        txt = '';
        %
        try
            f = ftp(remote.bridge.ftp.host,remote.bridge.ftp.username,remote.bridge.ftp.password);%ftp access to the bridge           
            mget(f,target);%Transfer ouput data from the bridge batch dir to the local batch dir
            close(f);
        catch err
            res = 1;
            txt = err.message;
        end
        %
    end
    %
    cd(initdir);
    %
elseif remote.link_mode == 1,
    [res,txt] = unix([remote.bridge.ssh.scpcmd{1},' ',remote.bridge.ssh.scpcmd{2},':',remote.bridge.ssh.temppath,'/',target,' ',locpath]);
end