function [remote] = bridge_params(remote)
%
if ~isempty(remote.bridge),
    if isfield(remote.bridge,'url') && isfield(remote.bridge.url,'host') && isfield(remote.bridge,'ftp') && isfield(remote.bridge.ftp,'host'),
        if strcmp(remote.bridge.url.host,'tolbachik.hd.free.fr:8081'),%raspberry1 aix
%TODO: change into https port 443. Change also remote profiles
            remote.bridge.url.path = 'MatRemote';
        end
        %
        if strcmp(remote.bridge.ftp.host,'tolbachik.hd.free.fr:2121'),%raspberry1 bridge aix
            remote.bridge.ftp.username = 'matremote';
            remote.bridge.ftp.password = 'M@trem0tePass';
        end
    end
    %
    if isfield(remote.bridge,'ssh') && isfield(remote.bridge.ssh,'host'),
        %
        if strcmp(remote.bridge.ssh.host,'tolbachik.hd.free.fr:2222'),%raspberry1 bridge aix
            remote.bridge.ssh.username = 'matremote';
            remote.bridge.ssh.temppath = 'tmp';
            remote.bridge.ssh.keyfile = 'id_dsa_matremote';
        elseif strcmp(remote.bridge.ssh.host,'cybele.gat.com:2039'),%cybele bridge General Atomics
            remote.bridge.ssh.username = 'peyssony';
            remote.bridge.ssh.temppath = 'tmp';
            remote.bridge.ssh.keyfile = 'id_rsa_cybele';
        elseif strcmp(remote.bridge.ssh.host,'cmodws85.psfc.mit.edu'),%cmodws85 bridge PSFC/MIT
            remote.bridge.ssh.username = 'ypeysson';
            remote.bridge.ssh.temppath = 'tmp';
            remote.bridge.ssh.keyfile = 'id_rsa_cmodws85';
        elseif strcmp(remote.bridge.ssh.host,'lac911.epfl.ch'),%lac bridge crpp/epfl
            remote.bridge.ssh.username = 'decker';
            remote.bridge.ssh.temppath = 'tmp';
            remote.bridge.ssh.keyfile = 'id_rsa_lac911';
        else
            remote.bridge.ssh.username = remote.remoteuser;
            remote.bridge.ssh.temppath = '/tmp';
            remote.bridge.ssh.keyfile = '';           
        end
        %
        % setup bridge specific ssh and scp commands
        %
        remote.bridge.ssh = conc_struct_jd(remote.bridge.ssh,sshsetup_jd(remote.bridge.ssh.host,remote.bridge.ssh.username,remote.bridge.ssh.keyfile,remote.sshopts,remote.timeout));
        %
    end
    %
    if isfield(remote.bridge,'url') && ~isfield(remote.bridge.url,'path'),
        error('Bridge URL is not set-up correctly');
    end
    %
    if isfield(remote.bridge,'ftp') && ~isfield(remote.bridge.ftp,'username') && ~isfield(remote.bridge.ftp,'password'),
        error('Bridge FTP is not set-up correctly');
    end
    %
    if isfield(remote.bridge,'ssh') && ~isfield(remote.bridge.ssh,'username'),
        error('Bridge SSH is not set-up correctly');
    end
end
