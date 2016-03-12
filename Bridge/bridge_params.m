function [remote] = bridge_params(remote)
%
if ~isempty(remote.bridge),
    if isfield(remote.bridge,'url') && isfield(remote.bridge.url,'host') && isfield(remote.bridge,'ftp') && isfield(remote.bridge.ftp,'host'),
        if strcmp(remote.bridge.url.host,'tolbachik.hd.free.fr:8081'),%raspberry1 aix
            remote.bridge.url.path = 'MatRemote';
        end
        %
        if strcmp(remote.bridge.ftp.host,'tolbachik.hd.free.fr:2121'),%raspberry1 bridge aix
            remote.bridge.ftp.username = 'matremote';
            remote.bridge.ftp.password = 'bridge22';
        end
    end
    %
    if isfield(remote.bridge,'ssh') && isfield(remote.bridge.ssh,'host'),
        %
        if strcmp(remote.bridge.ssh.host,'tolbachik.hd.free.fr -p 2222'),%raspberry1 bridge aix
            remote.bridge.ssh.username = 'yvespeysson';
            remote.bridge.ssh.temppath = 'tmp';
            remote.bridge.ssh.ports = {'1080','9999'};
        end
        %
        if strcmp(remote.bridge.ssh.host,'cybele.gat.com -p 2039'),%cybele bridge General Atomics
            remote.bridge.ssh.username = 'peyssony';
            remote.bridge.ssh.temppath = '.';
            remote.bridge.ssh.ports = {'1080','9999'};
        end
        %
        if strcmp(remote.bridge.ssh.host,'cmodws85.psfc.mit.edu'),%cmodws85 bridge PSFC/MIT
            remote.bridge.ssh.username = 'ypeysson';
            remote.bridge.ssh.temppath = 'tmp';
            remote.bridge.ssh.ports = {'1080','9999'};
        end
        %
        if strcmp(remote.bridge.ssh.host,'lac911.epfl.ch'),%lac bridge crpp/epfl
            remote.bridge.ssh.username = 'decker';
            remote.bridge.ssh.temppath = '/home/decker/tmp';
            remote.bridge.ssh.ports = {'1080','9999'};
        end
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
