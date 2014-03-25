function [res,txt] = matremotepid(remote,job)
%
if ~isempty(remote.host),
    %
    remotecmd = ['ls ',job.remotedatapath,job.batch_dir];
    %
    if remote.link_mode == 2,
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
    elseif remote.link_mode == 1,
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
        ipid0 = strfind(txt,'pid_');
        %
        if ~isempty(ipid0),
            %
            ipid1 = strfind(txt(ipid0+4:end),'.mat');
            %
            txt = txt(ipid0+4:ipid0+4+ipid1-2);
            %
%            remotecmd = ['cd ',job.batch_dir,';rm pid_',txt,'.mat'];%remove pid file
            %
            txt = ['pid=',txt];%to specify that the PID file has been used for the PID extraction
            %
%            unix(['ssh ',remote.sshopts,' ',remote.remoteuser,'@',remote.host,' ''',remotecmd,'''']);%execute the remote command by ssh 
            %
        else
            txt = '';
        end
    else
        txt = '';
    end
    %
    res = 0;
    return;
    %
else
    pidsearch = ls([job.remotedatapath,job.batch_dir]);
    %
    if ~isempty(strfind(pidsearch,'pid')),
        %
        pidfile = ls([job.remotedatapath,job.batch_dir,'pid_*']);
        %
        txt = pidfile(length([job.remotedatapath,job.batch_dir])+5:end-5);
        txt = ['pid=',txt];%to specify that the PID file has been used for the PID extraction
        %
        unix(['rm ',pidfile]);
        %
        res = 0;
    else
        txt = '';
        res = 0;
    end
    %
end   

