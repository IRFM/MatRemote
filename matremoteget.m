function [res,txt] = matremoteget(remote,target,rempath,locpath)
    %
    % This function transfers a file or folder 'target' 
    % from the remote (or local) location 'rempath' 
    % to a local location 'locpath' 
    % using the 'remote' structure
    %
    if nargin < 4,
        locpath = './';
    end
    if nargin < 3,
        rempath = './';
    end
    if nargin < 2,
        error('Not enough arguments')
    elseif isempty(target) || ~ischar(target),
        error('target must be a non-empty string')
    elseif strcmp(target(end),filesep),% target is a directory : ensure it is not copied into itself!
        target = target(1:end-1);
    end
    %    
    targetpath = fileparts(target);
    %
    if ~isempty(remote.host),
        %
        if remote.link_mode == 2,
            %
            [res,txt] = scp_over_php(remote,target,rempath);
            %
            if res ~= 0,
                return
            end
            %
            [res,txt] = download2client(remote,target,locpath);
            %
        elseif remote.link_mode == 1,
            %
            [remote] = bridge_params(remote);
            %
            if isfield(remote.bridge.ssh,'remotepassword') && ~isempty(remote.bridge.ssh.remotepassword)
                remote.ssh.scpcmd{1} = ['sshpass -p ''',remote.bridge.ssh.remotepassword,''' ',remote.ssh.scpcmd{1}];%remote sshpass (must be installed and accessible)
                remote.ssh.scpcmd{1} = strrep(remote.ssh.scpcmd{1},'yes','no');%BatchMode=no
            end
            %
            if isfield(remote.bridge.ssh,'password') && ~isempty(remote.bridge.ssh.password)
                remote.bridge.ssh.sshcmd = ['sshpass -p ''',remote.bridge.ssh.password,''' ',remote.bridge.ssh.sshcmd];%remote sshpass (must be installed and accessible)
                remote.bridge.ssh.sshcmd = strrep(remote.bridge.ssh.sshcmd,'yes','no');%BatchMode=no
            end
            %
            remotecmd = [remote.ssh.scpcmd{1},' ',remote.ssh.scpcmd{2},':',rempath,target,' ',remote.bridge.ssh.temppath,'/',targetpath];%download from remote to bridge
            %
            [res,txt] = unix([remote.bridge.ssh.sshcmd,' "',remotecmd,'"']);
            %
            if res ~= 0,
                return
            end
            %
            [res,txt] = download2client(remote,target,[locpath,targetpath]);        
            %
        else
            %
            [res,txt] = unix([remote.ssh.scpcmd{1},' ',remote.ssh.scpcmd{2},':',rempath,target,' ',locpath,targetpath]);%execute the remote command by ssh
            %
        end
        %
    elseif ~strcmp(locpath,rempath),
        %
        [res,txt] = unix(['cp -r ',rempath,target,' ',locpath,targetpath]);        
        %
    else% nothing to do
        %
        res = 0;
        txt = '';
    end
end
%
function [res,txt] = scp_over_php(remote,target,rempath)
    %
    txt_url = matremoteurl(remote,struct('remotedatapath',rempath),'',target);% remotedatapath is only requested information for file transfer
    %
    ie = strfind(txt_url,'scp2php_error:');%the 'scp2php_error:' separates the scp output from the error in scp.php
    error_txt = txt_url(ie+15:end);
    %
    if isempty(error_txt),
        res = 0;%force standard unix error.
        txt = strtrim(txt_url(1:ie-1));
    else
        res = 1;%force standard unix error.
        txt = error_txt;
    end
    %
end
