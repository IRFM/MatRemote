function [res,txt] = bridge2remote(remote,job)
%
res = 0;
txt = '';
%
php_post = phppostremotejob(remote,job);%add extra data for php filtering
%
[txt_url,res_url] = bridgeurl(remote,php_post,'scp_putdir.php');
%
if ~isempty(strfind(txt_url,'Non standard script file command in MatRemote')),
    error('Non standard script file command in MatRemote. An automatic message has been  send to the administrator. Job aborted...');
end
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
%
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