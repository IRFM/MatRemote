function [txt,res] = matremotessh(remote,remotecmd,ssh_opts)
%
if nargin < 3,
    ssh_opts = '';
end
%
[remote] = bridge_params(remote);
%
[res,txt] = unix(['ssh ',remote.sshopts,' -L',remote.bridge.ssh.ports{1},':localhost:',remote.bridge.ssh.ports{2},' ',remote.bridge.ssh.username,'@',remote.bridge.ssh.host,' ''ssh -L',remote.bridge.ssh.ports{2},':localhost:22 ',remote.remoteuser,'@',remote.host,' "',remotecmd,'"''',ssh_opts]);%execute the remote command by ssh     

