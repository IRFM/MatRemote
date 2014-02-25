function [txt_url,res_url] = matremoteurl(remote,job,remotecmd,filename)
%
if isempty(remotecmd) && ~isempty(filename)
    php_post{1} = 'filename';%php variable
    php_post{2} = filename;
    %
    php_post = phppostremotejob(remote,job,php_post);%add extra data for php filtering
    %
    [txt_url,res_url] = urlread(['http://',remote.bridge.url.host,'/',remote.bridge.url.path,'/scp_getfile.php'],'post',php_post);%transfer data from the bridge batch dir to the remote batch dir
end
%
if ~isempty(remotecmd) && isempty(filename)
    php_post{1} = 'remotecmd';%php variable
    php_post{2} = remotecmd;
    %
    php_post = phppostremotejob(remote,job,php_post);%add extra data for php filtering
    %
    [txt_url,res_url] = urlread(['http://',remote.bridge.url.host,'/',remote.bridge.url.path,'/ssh.php'],'post',php_post);%execute the remote command from the bridge (ssh over php) 
    %
end
%
txt_url = strtrim(txt_url);
%
if ~isempty(strfind(txt_url,'Non standard unix command in MatRemote. An automatic message has been  send to the administrator. Job aborted...')),
    error('Non standard unix command in MatRemote. An automatic message has been  send to the administrator. Job aborted...');
end