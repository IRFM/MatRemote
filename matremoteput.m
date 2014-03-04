function [res,txt] = matremoteput(remote,job)
%
% upload batch dir to the remote computer (through the bridge)
%
if ~isempty(remote.host),       
    %
    if isfield(remote.bridge,'ftp') && ~isempty(remote.bridge.ftp.host) > 0,
        %        
        [res,txt] = upload2bridge(remote,job);%file transfer to the bridge
        %
        php_post = phppostremotejob(remote,job);%add extra data for php filtering
        %
        [txt_url,res_url] = urlread(['http://',remote.bridge.url.host,'/',remote.bridge.url.path,'/scp_putdir.php'],'post',php_post);%transfer data from the bridge batch dir to the remote batch dir
        txt_url = strtrim(txt_url);
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
        remotecmd = ['chmod -R 777 ',job.remotedatapath,job.save_id];%because all files in the bridge have low level rights
        [txt_url,res_url] = matremoteurl(remote,job,remotecmd,'');
        %
        ie = strfind(txt_url,'ssh2php_error:');%the 'ssh2php_error:' separates the ssh output from the error in ssh.php
        error_txt = txt_url(ie+15:end);
        %
        if isempty(error_txt),
            res = 0;%force standard unix error.
            txt = strtrim(txt_url(1:ie-1));
        else
            %
            if strfind(remotecmd,'xgrid')
                if strfind(error_txt,'ulimit:'),%wrong error
                    res = 0;%force standard unix error.
                else
                    res = 1;%force standard unix error.
                end          
            else
                res = 1;%force standard unix error.
            end
            %
            txt = error_txt;     
        end
        %
    elseif isfield(remote,'remote'),
        %
        % TODO    
        %
    else
        [res,txt] = scp2remote_yp(remote.remoteuser,remote.host,job.save_id,job.localdatapath,job.remotedatapath);%transfer data from the local batch dir to the remote batch dir
        %
    end
    %
elseif ~strcmp(job.localdatapath,job.remotedatapath),
    %
    [res,txt] = unix(['cp -r ',job.localdatapath,job.save_id,' ',job.remotedatapath]);%transfer data from the local batch dir to the local batch dir
    %
else
    res = 0;
    txt = '';
end
%
