function [txt_url,res_url] = matremoteurl(remote,job,remotecmd,filename,debugmode)
%
if ~ischar(debugmode) && abs(debugmode) >= 1, debugmode = '1';end
if ~ischar(debugmode) && debugmode == 0, debugmode = '0';end
%
php_post{1} = 'remotehost';%php variable
php_post{2} = remote.host;
php_post{3} = 'debugmode';%php variable
php_post{4} = debugmode;
%
if isempty(remotecmd) && ~isempty(job) && ~isempty(filename)
    php_post{5} = 'remotedatapath';%php variable
    php_post{6} = job.remotedatapath;
    php_post{7} = 'filename';%php variable
    php_post{8} = filename;
    %
    [txt_url,res_url] = urlread(['http://',remote.bridge.url.host,'/',remote.bridge.url.path,'/scp_getfile.php'],'post',php_post);%transfer data from the bridge batch dir to the remote batch dir
end
%
if ~isempty(remotecmd) && isempty(job) && isempty(filename)
    php_post{5} = 'remotecmd';%php variable
    php_post{6} = remotecmd;
    %
    [txt_url,res_url] = urlread(['http://',remote.bridge.url.host,'/',remote.bridge.url.path,'/ssh.php'],'post',php_post);%execute the remote command from the bridge (ssh over php) 

end
%
txt_url = strtrim(txt_url);
%