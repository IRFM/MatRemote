function [res,txt] = matremoteput(job,remote,debugmode)
%
% upload batch dir to the remote computer (through the bridge)
%
if nargin < 3, 
    debugmode = '0';
end
%
if isfield(remote.bridge,'ftp') && ~isempty(remote.bridge.ftp.host) > 0,
    %
    f = ftp(remote.bridge.ftp.host,remote.bridge.ftp.username,remote.bridge.ftp.password);%ftp access to the bridge
    mput(f,job.batch_dir(1:end-1));%Transfer data from the local batch dir to the bridge batch dir
    close(f);
    %
    if ~ischar(debugmode) && abs(debugmode) >= 1, 
        debugmode = '1';
    end
    if ~ischar(debugmode) && debugmode == 0, 
        debugmode = '0';
    end
    %
    php_post{1} = 'remotehost';%php variable
    php_post{2} = remote.host;
    php_post{3} = 'remotedatapath';%php variable
    php_post{4} = job.remotedatapath;
    php_post{5} = 'batch_dir';%php variable
    php_post{6} = job.batch_dir;
    php_post{7} = 'debugmode';%php variable
    php_post{8} = debugmode;
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
elseif isfield(remote,'remote'),
    %
    % TODO    
    %
else
    %
	if ~isempty(remote.host),       
        [res,txt] = scp2remote_yp(remote.remoteuser,remote.host,job.save_id,job.localdatapath,job.remotedatapath);%transfer data from the local batch dir to the remote batch dir
    elseif ~strcmp(job.localdatapath,job.remotedatapath),
        [res,txt] = unix(['cp -r ',job.localdatapath,job.save_id,' ',job.remotedatapath]);%transfer data from the local batch dir to the local batch dir
    else
        res = 0;
        txt = '';
    end
    %
end   
%
