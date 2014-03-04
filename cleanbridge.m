function [res,txt] = cleanbridge(remote,job)
%
%try      
%
%   f = ftp(remote.bridge.ftp.host,remote.bridge.ftp.username,remote.bridge.ftp.password);%ftp access to the bridge
%   listfiles = dir(f,job.batch_dir(1:end-1));%list all files in batch dir of the bridge
%   for ilf = 1:length(listfiles),
%       delete(f,[job.batch_dir,listfiles(ilf).name]);%delete all files in batch dir of the bridge
%   end
%   %
%   if isempty(listfiles),
%       rmdir(f,job.batch_dir(1:end-1));%delete batch dir of the bridge
%   end
%   %
%   close(f);
%   %
%catch
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
%end
