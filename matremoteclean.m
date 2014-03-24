function [res,txt] = matremoteclean(remote,job,remotecmd)
%
if ~isempty(remote.host),
    %
    if isfield(remote,'bridge') && ~isempty(remote.bridge) > 0,
        %
        [res1,txt1] = cleanbridge(remote,job);
        %
        if isfield(remote.bridge,'ftp') && ~isempty(remote.bridge.ftp.host) > 0,
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
                res2 = 1;%force standard unix error.
                txt2 = error_txt;
            end
            %
        elseif isfield(remote.bridge,'ssh') && ~isempty(remote.bridge.ssh.host) > 0,
            %
            [txt2,res2] = matremotessh(remote,remotecmd);
            %
        end
        %
        txt = strcat(txt1,';',txt2);
        %
        res = res1*res2;
    else
        [res,txt] = unix(['ssh ',remote.sshopts,' ',remote.remoteuser,'@',remote.host,' ''',remotecmd,'''']);%execute the remote command by ssh 
    end
    %
elseif ~strcmp(job.localdatapath,job.remotedatapath),
    [res,txt] = unix(remotecmd);%execute the local command
else
    res = 0;
    txt = '';
end
%
