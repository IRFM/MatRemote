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
    end
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
            remotecmd = ['scp -r ',remote.remoteuser,'@',remote. host,':',rempath,target,' ',remote.bridge.ssh.temppath,'/',target];%download from remote to bridge
            [res,txt] = unix(['ssh ',remote.bridge.ssh.username,'@',remote.bridge.ssh.host,' "',remotecmd,'"']);
            %
            if res ~= 0,
                return
            end
            %
            [res,txt] = download2client(remote,target,locpath);        
            %
        else
            %
            [res,txt] = unix(['scp -r ',remote.remoteuser,'@',remote. host,':',rempath,target,' ',locpath,target]);
            %
        end
        %
    elseif ~strcmp(locpath,rempath),
        %
        [res,txt] = unix(['cp -r ',rempath,target,' ',locpath,target]);        
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
