function [res,txt] = matremoteclean(remote,job,remotecmd)
%
if ~isempty(remote.host)
    %
    if any(remote.link_mode == [1,2])
        %
        [res1,txt1] = cleanbridge(remote,job);
        %
        if  remote.link_mode == 2
            %
            [txt_url] = matremoteurl(remote,job,remotecmd,'');
            %
            ie = strfind(txt_url,'ssh2php_error:');%the 'ssh2php_error:' separates the ssh output from the error in ssh.php
            error_txt = txt_url(ie+15:end);
            %
            if isempty(error_txt)
                res2 = 0;%force standard unix error.
                txt2 = strtrim(txt_url(1:ie-1));
            else
                res2 = 1;%force standard unix error.
                txt2 = error_txt;
            end
            %
        elseif remote.link_mode == 1
            %
            flag = 1;
            for ii = 1:20%the folder may be locked by the scheduler with some delay (use lsof +D batch_xxxxxxxx to check)
                [txt2,res2] = matremotessh(remote,remotecmd);
                if res2 == 0
                    flag = 0;
                    break;
                end
            end
            %
            if flag 
                disp(['WARNING: the directory ',remotecmd(strfind(remotecmd,'batch_'):end-1),' has not been removed on the remote server for an unkown reason. Delete it manually.']);
            end
            %
        end
        %
        txt = strcat(txt1,';',txt2);
        %
        res = res1*res2;
    else
        [res,txt] = unix([remote.ssh.sshcmd,' ''',remotecmd,'''']);%execute the remote command by ssh
    end
    %
elseif ~strcmp(job.localdatapath,job.remotedatapath)
    [res,txt] = unix(remotecmd);%execute the local command
else
    res = 0;
    txt = '';
end
%
