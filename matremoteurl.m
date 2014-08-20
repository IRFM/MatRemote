function [txt_url,res_url] = matremoteurl(remote,job,remotecmd,filename)
%
if isempty(remotecmd) && ~isempty(filename)
    php_post{1} = 'filename';%php variable
    php_post{2} = filename;
    %
    php_post = phppostremotejob(remote,job,php_post);%add extra data for php filtering
    %
    [txt_url,res_url] = bridgeurl(remote,php_post,'scp_getfile.php');
end
%
if ~isempty(remotecmd) && isempty(filename)
    php_post{1} = 'remotecmd';%php variable
    php_post{2} = remotecmd;
    %
    php_post = phppostremotejob(remote,job,php_post);%add extra data for php filtering
    %
    [txt_url,res_url] = bridgeurl(remote,php_post,'ssh.php');
end
%
if ~isempty(strfind(txt_url,'Non standard unix command in MatRemote')),
    error('Non standard unix command in matremoteurl.m. An automatic message has been  send to the administrator. Job aborted...');
end