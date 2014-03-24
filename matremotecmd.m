function [res,txt] = matremotecmd(remote,job,remotecmd,ssh_opts)
%
if isfield(remote,'disp_cmd') && remote.disp_cmd,
    disp('------------------------------------------------------------------------------------')
    disp(['-----> URL cmd: ',remotecmd])
    disp('------------------------------------------------------------------------------------')
end
%
if isfield(remote,'bridge_enforce') && islogical(remote.bridge_enforce) && remote.bridge_enforce,
    flag_bridge_enforce = 1;
elseif isfield(remote,'bridge_enforce') && islogical(remote.bridge_enforce) && ~remote.bridge_enforce,
    flag_bridge_enforce = 0;
else
    flag_bridge_enforce = 1;
end
%
if ~isempty(remote.host),
    %
    if isfield(remote.bridge,'url') && ~isempty(remote.bridge.url.host) > 0 && flag_bridge_enforce,
        %
        [txt_url,res_url] = matremoteurl(remote,job,remotecmd,'');
        %
        ie = strfind(txt_url,'ssh2php_error:');%the 'ssh2php_error:' separates the ssh output from the error in ssh.php
        error_txt = strtrim(txt_url(ie+15:end));
        %
        if isempty(error_txt),
            res = 0;%force standard unix error.
            txt = strtrim(txt_url(1:ie-1));
        else
            %
            if strfind(remotecmd,'xgrid')
                if strfind(error_txt,'ulimit:'),%wrong error
                    res = 0;%force standard unix error.
                    txt = strtrim(txt_url(1:ie-1));
                else
                    res = 1;%force standard unix error.
                    txt = error_txt; 
                end
            elseif strfind(remotecmd,'condor')
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
    elseif isfield(remote.bridge,'ssh') && ~isempty(remote.bridge.ssh.host) > 0 && flag_bridge_enforce,
        %
        if (nargin == 4),
            [txt,res] = matremotessh(remote,remotecmd,ssh_opts);
        else
            [txt,res] = matremotessh(remote,remotecmd);
        end
        %
    else
        %
        if (nargin == 4),
            [res,txt] = unix(['ssh ',remote.sshopts,' ',remote.remoteuser,'@',remote.host,' ''',remotecmd,'''',ssh_opts]);%execute the remote command by ssh 
        else
            [res,txt] = unix(['ssh ',remote.sshopts,' ',remote.remoteuser,'@',remote.host,' ''',remotecmd,'''']);%execute the remote command by ssh 
        end
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
