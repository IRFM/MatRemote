function [txt_url,res_url] = bridgeurl(remote,php_post,phpcmd)
%
[remote] = bridge_params(remote);
%
itmax = 10;
%
certificate_filename = '';%for SSL access. If empty, certificate validation is disabled
timeout = 60;
%
for it = 1:itmax,
    if ~isempty(strfind(remote.bridge.url.host,'http://')) || ~isempty(strfind(remote.bridge.url.host,'https://')),
        webaccess_options = weboptions('RequestMethod','post','Timeout',timeout,'CertificateFilename',certificate_filename);
        %
        if ~isempty(strfind(remote.bridge.url.host,'https://'))
            %if isempty(certificate_filename),disp('WARNING: https access to the bridge may be unsecure since certificate validation is disabled.');end
        end
        %
        webcmd = 'webwrite([remote.bridge.url.host,''/'',remote.bridge.url.path,''/'',phpcmd],';
        for ipost = 1:length(php_post),
            post = char(php_post{ipost});
            webcmd = [webcmd,'''',post,''','];
        end
        webcmd = [webcmd,'webaccess_options)'];
        %
        txt_url = eval(webcmd);%transfer data from the bridge batch dir to the remote batch dir
        res_url = 1;
        %
    else
        txt_url = 'ERROR: URL definition of the profile must be of the form: http://ip_address:port or https://ip_address:port';
        res_url = 0;
        it = itmax;
        break
    end
    %    
    if ~isempty(txt_url),% may be network error if txt is empty
        break
	end
end
%
if it == itmax,disp(['WARNING: bridgeurl failed after ',int2str(itmax),' attempts with a timeout of ',int2str(timeout),'s each -> Possible network connection issue.']);end
%
txt_url = strtrim(txt_url);
%
url_message1 = 'Successful ssh identification !';
url_message2 = 'scp2php_error:';
url_message3 = 'ssh2php_error:';
%
if ~isempty(strfind(txt_url,url_message1)),
    txt_url = strtrim(txt_url(length(url_message1)+1:end));
elseif ~isempty(strfind(txt_url,url_message2))...% remove empty scp2php_error message
        && isempty(txt_url(strfind(txt_url,url_message2)+length(url_message2):end)),
    txt_url = strtrim(txt_url(1:strfind(txt_url,url_message2)-1));

elseif ~isempty(strfind(txt_url,url_message3))...% remove empty ssh2php_error message
        && isempty(txt_url(strfind(txt_url,url_message3)+length(url_message3):end)),
    txt_url = strtrim(txt_url(1:strfind(txt_url,url_message3)-1));
    
else
    disp(['WARNING: -> the php command ''',phpcmd,''' failed in bridgurl.']);
    disp(txt_url);
    disp(['Host ---> ',remote.host])
end
