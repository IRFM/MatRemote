function [res,txt] = matremotecheck(job,remote,mask,debugmode)
%
if nargin < 4, 
    debugmode = '0';
end
%
if ~isempty(remote.host),
    %
    remotecmd = '';
    %
    if isfield(remote.bridge,'url') && ~isempty(remote.bridge.url.host) > 0,
        %
        remotecmd = ['ls ',job.remotedatapath,job.batch_dir];
        [txt_url,res_url] = matremoteurl(remote,'',remotecmd,'',debugmode);
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
        if ~res,
            %
            txt = regexprep(txt,'\r\n|\n|\r','');%remove carriage return
            %
            icheck0 = strfind(txt,mask);
            %
            if ~isempty(icheck0),
                %
                res = 0;%force standard unix error.
                txt = '';
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
        %
    elseif isfield(remote,'remote'),
        %
        % TODO    
        %
    else
        %
        remotecmd = ['ls ',job.remotedatapath,job.batch_dir];
        [res,txt] = unix(['ssh ',remote.sshopts,' ',remote.remoteuser,'@',remote.host,' ''',remotecmd,'''']);%execute the remote command by ssh 
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
    end
else
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

