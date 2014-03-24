function [res,txt] = matremotecheck(remote,job,mask)
%
if ~isempty(remote.host),
    %
    remotecmd = ['ls ',job.remotedatapath,job.batch_dir];
    %
    if isfield(remote.bridge,'url') && ~isempty(remote.bridge.url.host) > 0,
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
            res = 1;%force standard unix error.
            txt = error_txt;
            return
        end
        %
    elseif isfield(remote.bridge,'ssh') && ~isempty(remote.bridge.ssh.host) > 0,
        %
        [txt,res] = matremotessh(remote,remotecmd);
        %
    else
        %
        [res,txt] = unix(['ssh ',remote.sshopts,' ',remote.remoteuser,'@',remote.host,' ''',remotecmd,'''']);%execute the remote command by ssh 
        %
    end
    %
    if ~res,
        %
        txt = regexprep(txt,'\r\n|\n|\r','');%remove carriage return
        %
        icheck0 = strfind(txt,mask);
        %
        if ~isempty(icheck0),
            %
            res = 0; 
            txt = '';%
        else
            res = 1;
            txt = '';
        end
    else
        res = 1;
        txt = '';
    end
    %
    return;
else
    %
    matoutfile_search = ls([job.remotedatapath,job.batch_dir]);
    %
    if ~isempty(strfind(matoutfile_search,mask)),
        %
        res = 0;
        txt = '';
    else
        res = 1;
        txt = '';
    end
    %
end   

