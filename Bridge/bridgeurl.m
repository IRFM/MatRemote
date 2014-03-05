function [txt_url,res_url] = bridgeurl(remote,php_post,phpcmd)
%
[remote] = bridge_params(remote);
%
[txt_url,res_url] = urlread(['http://',remote.bridge.url.host,'/',remote.bridge.url.path,'/',phpcmd],'post',php_post);%transfer data from the bridge batch dir to the remote batch dir
%
txt_url = strtrim(txt_url);
