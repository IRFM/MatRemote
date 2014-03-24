function [txt,res] = matremotessh(remote,remotecmd)
%
[remote] = bridge_params(remote);
%
if ~isempty(remotecmd),
    [res,txt] = unix(['ssh ',remote.sshopts,' -L',remote.bridge.ssh.ports{1},':localhost:',remote.bridge.ssh.ports{2},' ',remote.bridge.ssh.username,'@',remote.bridge.ssh.host,' ''ssh -L',remote.bridge.ssh.ports{2},':localhost:22 ',remote.remoteuser,'@',remote.host,' "',remotecmd,'"''']);%execute the remote command by ssh 
else
    error('No remote command'),
end
%