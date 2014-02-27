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
        error_txt = txt_url(ie+15:end);
        %
        if isempty(error_txt),
            res = 0;%force standard unix error.
            txt = strtrim(txt_url(1:ie-1));
        else
            %
            if strfind(remotecmd,'xgrid')
                if strfind(error_txt,'ulimit:'),%wrong error
                    res = 0;%force standard unix error.
                else
                    res = 1;%force standard unix error.
                end          
            else
                res = 1;%force standard unix error.
            end
            %
            txt = error_txt;     
        end
        %
    elseif isfield(remote,'remote'),
        %
        % TODO    
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
