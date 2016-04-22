function [txt,res] = matremotessh(remote,remotecmd,ssh_opts)
%
if nargin < 3,
    ssh_opts = '';
end
%
[remote] = bridge_params(remote);
%
sshopts = remote.sshopts;
if isfield(remote.bridge.ssh,'keyfile') && ~isempty(remote.bridge.ssh.keyfile),
    keyfile = [fileparts(which(mfilename)),filesep,'Keys',filesep,remote.bridge.ssh.keyfile];
    sshopts = [sshopts,' -i ',keyfile];
end
%
if isfield(remote.bridge.ssh,'ports') && ~isempty(remote.bridge.ssh.ports),
    mapping1 = [' -L ',remote.bridge.ssh.ports{1},':localhost:',remote.bridge.ssh.ports{2}];
    mapping2 = [' -L ',remote.bridge.ssh.ports{2},':localhost:22'];
else
    mapping1 = '';
    mapping2 = '';
end

%
[res,txt] = unix(['ssh -o ConnectTimeout=10 -o BatchMode=yes ',sshopts,mapping1,' ',remote.bridge.ssh.username,'@',remote.bridge.ssh.host,' "ssh -o ConnectTimeout=10 -o BatchMode=yes',mapping2,' ',remote.remoteuser,'@',remote.host,' ''',remotecmd,'''"',ssh_opts]);%execute the remote command by ssh

