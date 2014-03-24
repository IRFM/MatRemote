function [res,txt] = bridge2remote(remote,job)
%
res = 0;
txt = '';
%
if isfield(remote.bridge,'url') && isfield(remote.bridge,'ftp'),
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
        res1 = 0;%force standard unix error.
        txt1 = strtrim(txt_url(1:ie-1));
    else
        res1 = 1;%force standard unix error.
        txt1 = error_txt;
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
        res2 = 0;%force standard unix error.
        txt2 = strtrim(txt_url(1:ie-1));
    else
        %
        if strfind(remotecmd,'xgrid')
            if strfind(error_txt,'ulimit:'),%wrong error
                res2 = 0;%force standard unix error.
            else
                res2 = 1;%force standard unix error.
            end          
        else
            res2 = 1;%force standard unix error.
        end
        %
        txt2 = error_txt;     
    end
    %
    txt = strcat(txt1,';',txt2);
    %
    res = res1*res2;
    %
elseif isfield(remote.bridge,'ssh'),
    %
    remotecmd = ['scp -r ',remote.bridge.ssh.temppath,job.save_id,' ',remote.remoteuser,'@',remote.host,':',job.remotedatapath];
    [txt1,res1] = matremotessh(remote,remotecmd);  
    %
    remotecmd = ['chmod -R 777 ',job.remotedatapath,job.save_id];%because all files in the bridge have low level rights
    [txt2,res2] = matremotessh(remote,remotecmd);  
    %
    txt = strcat(txt1,';',txt2);
    %
    res = res1*res2;
end