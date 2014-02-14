function [res,txt] = matremotecmd(remote,remotecmd,debugmode)
%
if nargin < 3, 
    debugmode = '0';
end
%
if isfield(remote.bridge,'url') && ~isempty(remote.bridge.url.host) > 0,
    %
    if ~ischar(debugmode) && abs(debugmode) >= 1, debugmode = '1';end
    if ~ischar(debugmode) && debugmode == 0, debugmode = '0';end
    %
    php_post{1} = 'remotehost';%php variable
    php_post{2} = remote.host;
    php_post{3} = 'remotecmd';%php variable
    php_post{4} = remotecmd;
    php_post{5} = 'debugmode';%php variable
    php_post{6} = debugmode;
    %
    [txt_url,res_url] = urlread(['http://',remote.bridge.url.host,'/',remote.bridge.url.path,'/ssh.php'],'post',php_post);%execute the remote command from the bridge (ssh over php) 
    txt_url = strtrim(txt_url);
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
    if ~isempty(remote.host),
        [res,txt] = unix(['ssh ',remote.sshopts,' ',remote.remoteuser,'@',remote.host,' ''',remotecmd,'''']);%execute the remote command by ssh 
    else
        [res,txt] = unix(remotecmd);%execute the local command
    end
    %
end   
%
