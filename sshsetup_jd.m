function ssh = sshsetup_jd(host,username,keyfile,sshopts,timeout)
%
% builds the ssh and scp commands specifically for the provided host
%
if nargin < 5,
    timeout = 10;% in s
end
if nargin < 4,
    sshopts = '';
end
if nargin < 3,
    keyfile = '';
end
%
% ssh port
%
iportsep = strfind(host,':');
if isempty(iportsep),
    sshportstr = '';
    scpportstr = '';
elseif length(iportsep) > 1,
    error(['syntax error is bridge ssh host : ',host])
else% ssh port different from 22
    port = host(iportsep+1:end);
    host = host(1:iportsep-1);
    sshportstr = [' -p ',port];
    scpportstr = [' -P ',port];
end
%
% key file
%
if ~isempty(keyfile),
    keyfile = [fileparts(which(mfilename)),filesep,'Keys',filesep,keyfile];
    keyfilestr = [' -i ',keyfile];
else
    keyfilestr = '';
end
%
batchmodestr = [' -o ConnectTimeout=',num2str(timeout),' -o BatchMode=yes'];
%
ssh.sshcmd = ['ssh ',sshopts,sshportstr,keyfilestr,batchmodestr,' ',username,'@',host];
ssh.scpcmd = {['scp -r ',sshopts,scpportstr,keyfilestr,batchmodestr],[username,'@',host]};
