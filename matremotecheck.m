function [res,txt] = matremotecheck(remote,job,mask)
%
txt = '';
%
if ~isfield(remote,'shell'),
    set_lang = 'export LANG=en_us_8859_1;';%bash is considered as default otherwise setup in the profile
else
    if ~isempty(remote.shell) && strcmp(remote.shell,'csh')
        set_lang = 'setenv LANG en_us_8859_1;';%csh
    else
        set_lang = 'export LANG=en_us_8859_1;';%bash
    end
end
%
if ~isempty(remote.host),
    %
    remotecmd_gnu = [set_lang,'ls -l --full-time --time-style=full-iso ',job.remotedatapath,job.batch_dir];%GNU 
    remotecmd_posix = [set_lang,'ls -lT ',job.remotedatapath,job.batch_dir];%POSIX (OS X)
    %
    if remote.link_mode == 2,
        %
        [txt_url,res_url] = matremoteurl(remote,job,remotecmd_gnu,'');
        %
        ie = strfind(txt_url,'ssh2php_error:');%the 'ssh2php_error:' separates the ssh output from the error in ssh.php
        error_txt = txt_url(ie+15:end);
        %
        if isempty(error_txt),
            %
            res = 0;%force standard unix error.
            txt = strtrim(txt_url(1:ie-1));
            %
        else
            %
            [txt_url,res_url] = matremoteurl(remote,job,remotecmd_posix,'');
            %
            ie = strfind(txt_url,'ssh2php_error:');%the 'ssh2php_error:' separates the ssh output from the error in ssh.php
            error_txt = txt_url(ie+15:end);
            %
            if isempty(error_txt),
                %
                res = 0;%force standard unix error.
                txt = strtrim(txt_url(1:ie-1));
            else
                res = 1;%force standard unix error.
                txt = error_txt;
                return
            end
        end
        %
    elseif remote.link_mode == 1,
        %
        [txt,res] = matremotessh(remote,remotecmd_gnu);
        %
        if res,
            [txt,res] = matremotessh(remote,remotecmd_posix);
        end
        %
    else
        %
        [res,txt] = unix(['ssh ',remote.sshopts,' ',remote.remoteuser,'@',remote.host,' ''',remotecmd_gnu,'''']);%execute the remote command by ssh 
        %
        if res,
            [res,txt] = unix(['ssh ',remote.sshopts,' ',remote.remoteuser,'@',remote.host,' ''',remotecmd_posix,'''']);%execute the remote command by ssh 
        end
    end
    %
    if ~res,
        [res,txt] = searchstring(txt,mask);
    else
        res = 1;
    end
    %
    return;
else
    %
    localcmd_gnu = [set_lang,'ls -l --full-time --time-style=full-iso ',job.remotedatapath,job.batch_dir];%GNU 
    localcmd_posix = [set_lang,'ls -lT ',job.remotedatapath,job.batch_dir];%POSIX (OS X)
    %
    [res,txt] = unix(localcmd_gnu);
    %
    if res,
        [res,txt] = unix(localcmd_posix);
    end
    %
    if ~res,
        [res,txt] = searchstring(txt,mask);
    else
        res = 1;
    end
   
end  

end

function [res,txt] = searchstring(txt,mask)
            sep ='==========';
        %
        txt1 = regexprep(txt,'\r\n|\n|\r',sep);%replace carriage return
        %
        icheck0 = strfind(txt1,mask);
        %
        if ~isempty(icheck0),
            %
            res = 0;
            isep = strfind(txt1,sep);
            %
            for ii = 1:length(isep)-1,
                if isep(ii) < icheck0 && icheck0 < isep(ii+1)
                    txt = txt1(isep(ii)+length(sep):isep(ii+1)-1);
                end
            end
        else
            res = 1;
        end
end
