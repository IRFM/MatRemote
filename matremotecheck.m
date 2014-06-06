function [res,txt] = matremotecheck(remote,job,mask)
%
txt = '';
%
if ~isempty(remote.host),
    %
    remotecmd{1} = ['ls -l --full-time --time-style=full-iso ',job.remotedatapath,job.batch_dir];%GNU 
    remotecmd{2} = ['ls -lT ',job.remotedatapath,job.batch_dir];%POSIX (OS X)
    %
    if remote.link_mode == 2,
        %
        [txt_url,res_url] = matremoteurl(remote,job,remotecmd{1},'');
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
            [txt_url,res_url] = matremoteurl(remote,job,remotecmd{2},'');
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
        [txt,res] = matremotessh(remote,remotecmd{1});
        %
        if res,
            [txt,res] = matremotessh(remote,remotecmd{2});
        end
        %
    else
        %
        [res,txt] = unix(['ssh ',remote.sshopts,' ',remote.remoteuser,'@',remote.host,' ''',remotecmd{1},'''']);%execute the remote command by ssh 
        %
        if res,
            [res,txt] = unix(['ssh ',remote.sshopts,' ',remote.remoteuser,'@',remote.host,' ''',remotecmd{2},'''']);%execute the remote command by ssh 
        end
    end
    %
    if ~res,
        %
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
    else
        res = 1;
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
    else
        res = 1;
    end
    %
end   

