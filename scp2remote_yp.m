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
if ~strcmp(remote_path(end),filesep),
    remote_path = [remote_path,filesep];
end
%
if strfind(remotehost,'-p')
    remotehost1 = deblank(remotehost(1:strfind(remotehost,'-p')-1));
    remotehost2 = remotehost(strfind(remotehost,'-p'):end);%for non-standard port
    [res,err] = unix(['scp ',upper(remotehost2),' -r ',local_path,filename,' ',remotelogname,'@',remotehost1,':',remote_path]);
else
    [res,err] = unix(['scp -r ',local_path,filename,' ',remotelogname,'@',remotehost,':',remote_path]);
end
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
        remotecmds = {'stat -f "%z"','stat -c %s'};
        res = 1;
        %
        for icmd = 1:length(remotecmds),
            %
            remotecmd = remotecmds{icmd};
            %
            [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,' ',remote_path,filelist{ifile},'''']);
            %
            if res == 0,
                break
            end
        end
        %
        if res ~= 0,
            return
        end
        %
        err(err == 10) = [];%remote EoF
        %
        filesize = str2double(err);
        if isnan(filesize),
            filesize = length(err);
        end
        %
        tstart = tic;
        %
        while toc(tstart) < tmax 
            %
            filesize0 = filesize;
            %
            pause(dt);
            %
            [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,' ',remote_path,filelist{ifile},'''']);
            %
            if res ~= 0,
                return
            end
            %
            err(err == 10) = [];%remote EoF
            %
            filesize = str2double(err);
            if isnan(filesize),
                filesize = length(err);
            end
            %
            if filesize == filesize0,
                break
            end
            %
        end
    end
end
%