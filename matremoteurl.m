function [txt_url,res_url] = matremoteurl(remote,job,remotecmd,filename,debugmode)
%
if ~ischar(debugmode) && abs(debugmode) >= 1, debugmode = '1';end
if ~ischar(debugmode) && debugmode == 0, debugmode = '0';end
%
php_post{1} = 'debugmode';%php variable
php_post{2} = debugmode;
%
if isempty(remotecmd) && ~isempty(filename)
    php_post{3} = 'filename';%php variable
    php_post{4} = filename;
    %
    php_post = phppostremotejob(remote,job,php_post);%add extra data for php filtering
    %
    [txt_url,res_url] = urlread(['http://',remote.bridge.url.host,'/',remote.bridge.url.path,'/scp_getfile.php'],'post',php_post);%transfer data from the bridge batch dir to the remote batch dir
end
%
if ~isempty(remotecmd) && isempty(filename)
    php_post{3} = 'remotecmd';%php variable
    php_post{4} = remotecmd;
    %
    php_post = phppostremotejob(remote,job,php_post);%add extra data for php filtering
    %
    [txt_url,res_url] = urlread(['http://',remote.bridge.url.host,'/',remote.bridge.url.path,'/ssh.php'],'post',php_post);%execute the remote command from the bridge (ssh over php) 
    %
end
%
txt_url = strtrim(txt_url);
%
if isfield(remote,'disp_cmd') && remote.disp_cmd,
    disp('------------------------------------------------------------------------------------')
    disp(['-----> URL cmd: ',remotecmd])
    disp('------------------------------------------------------------------------------------')
end