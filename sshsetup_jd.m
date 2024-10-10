function ssh = sshsetup_jd(host,username,keyfile,sshopts,timeout,password,proxy,rsync)
%
% builds the ssh and scp commands specifically for the provided host
%
if nargin < 8
    rsync = 0;
end
if nargin < 7
    proxy = '';
end
if nargin < 6
    password = '';
end
if nargin < 5
    timeout = 10;% in s
end
if nargin < 4
    sshopts = '';
end
if nargin < 3
    keyfile = '';
end
%
% ssh port
%
iportsep = strfind(host,':');
if isempty(iportsep)
    sshportstr = '';
    scpportstr = '';
elseif length(iportsep) > 1
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
if ~isempty(keyfile)
    keyfile = [fileparts(which(mfilename)),filesep,'Keys',filesep,keyfile];
    keyfilestr = [' -i ',keyfile];
else
    keyfilestr = '';
end
%
% ssh proxy jump
%
if ~isempty(proxy)
    password = '';% sshpass and ssh proxy jump are not compatible
    rsync = 1;% scp and ssh proxy jump are not compatible
    % 
    if ~isfield(proxy,'username') || isempty(proxy.username)
        proxy.username = username;
    end
    proxyopt = [' -J ',proxy.username,'@',proxy.host];
else
    proxyopt = '';
end
%
[res,txt] = unix('which sshpass');%local sshpass
%
batchmodestr = [' -q -o VisualHostKey=no -o ConnectTimeout=',num2str(timeout)];
%
if res == 0 && contains(txt,'sshpass') && ~isempty(password)
    batchmodestr = [batchmodestr,' -o StrictHostKeyChecking=no'];
else
    batchmodestr = [batchmodestr,' -o BatchMode=yes'];
end
%
ssh.sshcmd = ['timeout 10 ssh',proxyopt,sshopts,sshportstr,keyfilestr,batchmodestr,' ',username,'@',host];
%
if rsync
    ssh.scpcmd = {['rsync -a -e "ssh',proxyopt,sshopts,scpportstr,keyfilestr,batchmodestr,'"'],[username,'@',host]};
else
    ssh.scpcmd = {['scp -r ',sshopts,scpportstr,keyfilestr,batchmodestr],[username,'@',host]};
end
%
if res == 0 && contains(txt,'sshpass') && ~isempty(password)
    sshpassopts = [' -p ''',password,''' '];
    ssh.sshcmd = ['sshpass ',sshpassopts,ssh.sshcmd];
    ssh.scpcmd{1} = ['sshpass ',sshpassopts,ssh.scpcmd{1}]; 
end
