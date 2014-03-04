function [res,err] = scp2remote_yp(remotelogname,remotehost,filename,local_path,remote_path)
% LUKE - scp UNIX command with checking of the file or directory transfer for slow network
%
%   scp UNIX command with checking of the file or directory transfer for slow network
%
%   INPUT:
%
%       - remotelogname on the remote computer
%       - remotehost IP adress
%       - filename or dirname
%       - local_path
%       - remote_path
%
%   OUTPUT:
%
%       - res: status of the unix() matlab command
%       - err: result of the unix() matlab command
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
if nargin < 3,
    error('Not enough input arguments in scp2remote_yp.m.');
end
%
[res,err] = unix(['scp -r ',local_path,filename,' ',remotelogname,'@',remotehost,':',remote_path]);
%
% Check that the file transfer is fully achieved even when network is slow 
%
tmax = 1000;% maximum wait time for file transfer
dt = 0.2;% pause between two checks for filesize
%
if res == 0,
    %
    if isdir([local_path,filename]),
        %
        filelist = get_all_filesname_yp([local_path,filename]);
        %
        for ifile = 1:length(filelist),
            filelist{ifile} = filelist{ifile}(findstr(filelist{ifile},filename):end);
        end     
        %
    else
        filelist = {filename};
    end
    %
    for ifile = 1:length(filelist),
        %
        remotecmd = ['du -b ',remote_path,filelist{ifile}];
        %
        tstart = tic;
        %
        [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
        %
        if res ~= 0,
            return
        end
        %
        ierr = find(err == 9,1,'first');
        if isempty(ierr) || ierr == 1,
            err = 'error reading file size on remote machine';
            res = 1;
            return
        end
        %
        filesize = str2double(err(1:ierr(1)-1));
        %
        while toc(tstart) < tmax 
            %
            filesize0 = filesize;
            %
            pause(dt);
            %
            [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
            %
            if res ~= 0,
                return
            end
            %
            ierr = find(err == 9,1,'first');
            if isempty(ierr) || ierr == 1,
                err = 'error reading file size on remote machine';
                res = 1;
                return
            end
            %
            filesize = str2double(err(1:ierr(1)-1));
            %
            if filesize == filesize0,
                break
            end
            %
        end
    end
end
%