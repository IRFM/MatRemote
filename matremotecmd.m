function [res,txt] = matremotecmd(remote,job,remotecmd,ssh_opts)
    %
    if nargin < 4,
        ssh_opts = '';
    end
    %
    if isfield(remote,'disp_cmd') && remote.disp_cmd,
        disp('------------------------------------------------------------------------------------')
        disp(['-----> URL cmd: ',remotecmd])
        disp('------------------------------------------------------------------------------------')
    end
    %
    if isempty(remote),
        res = 1;
        txt = 'Error: Remote structure is empty.';
        return
    end
    %
    if ~isempty(remote.host),
        %
        if isempty(job) && isempty(remote.link_mode)
            remote.link_mode = 1;
        end
        %
        if remote.link_mode == 2,
            %
            [txt_url,res_url] = matremoteurl(remote,job,remotecmd,'');
            %
            ie = strfind(txt_url,'ssh2php_error:');%the 'ssh2php_error:' separates the ssh output from the error in ssh.php
            if isempty(ie),
                error_txt = '';
            else
                error_txt = strtrim(txt_url(ie+15:end));
            end
            %
            if isempty(error_txt),
                res = 0;%force standard unix error.
                if isempty(ie),
                    txt = strtrim(txt_url);
                else
                    txt = strtrim(txt_url(1:ie-1));
                end
            else
                %
				if strfind(remotecmd,'condor')
                    if strfind(error_txt,'was unused by condor_submit. Is it a typo'),%wrong warning
                        res = 0;%force standard unix error.
                        txt = strtrim(txt_url(1:ie-1));
                    else
                        res = 1;%force standard unix error.
                        txt = error_txt; 
                    end
                else
                    res = 1;%force standard unix error.
                    txt = error_txt; 
                end
                %

            end
            %
        elseif remote.link_mode == 1,
            %
            [txt,res] = matremotessh(remote,fixquotes(fixquotes(remotecmd,'"'),''''),ssh_opts);
            %
        else
            %
            [res,txt] = unix([remote.ssh.sshcmd,' "',fixquotes(remotecmd,'"'),'"',ssh_opts]);%execute the remote command by ssh 
            %
        end
    else
        %
        wd = pwd;
        cd(getenv('HOME'))
        [res,txt] = unix(remotecmd);%execute the local command
        cd(wd);
        %
    end   
    %
end
%
function cmd2 = fixquotes(cmd,quote)
    %
    iquote = strfind(cmd,quote);
    %
    if isempty(iquote),
        cmd2 = cmd;
        return
    else
        %
        cmd2 = '';
        iquote = [0,iquote];
        for ifix = 2:length(iquote),
            cmd2 = [cmd2,cmd(iquote(ifix-1)+1:iquote(ifix)-1),'\',quote];
        end
        cmd2 = [cmd2,cmd(iquote(end)+1:end)];
    end
    %
end
