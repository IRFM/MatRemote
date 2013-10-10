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
if nargin < 3,error('Not enough input arguments in scp2remote_yp.m.');end
%
[res,err] = unix(['scp -r ',local_path,filename,' ',remotelogname,'@',remotehost,':',remote_path]);
%
% Check that the file transfer is fully achieved even when network is slow 
%
keyboard
if res == 0,
    %
    if isdir([local_path,filename]),
        %
        filelist = get_all_filesname_yp([local_path,filename]);
        %
        for ifile = 1:length(filelist),
            filelist{ifile} = filelist{ifile}(findstr(filelist{ifile},filename)+1:end)
        end     
        %
    else
        filelist = {filename};
    end
    %
    for ifile = 1:length(filelist),
    %
        remotecmd = ['ls -al ',remote_path,filelist{ifile}];
        %
        tstart = tic;
        %
        while 1,
            %
            [res0,err0] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
            %
            pause(1);
            %
            [res1,err1] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
            %
            if res0+res1 == 0,
                %
                token0 = err0(1:strfind(err0,'Oct')-2);
                itoken0 = strfind(token0,' ');
                filesize0 = token0(itoken0(end):end);
                %
                token1 = err1(1:strfind(err1,'Oct')-2);
                itoken1 = strfind(token1,' ');
                filesize1 = token1(itoken1(end):end);
                %
                if strcmp(filesize0,filesize1) && str2num(filesize1) > 0,
                    break;   
                end
                %
                telapsed = toc(tstart);
                %
                if telapsed > 1000,%to leave anyway in case of problem
                    break; 
                end
                %
            else
                %
                if res0 ~= 0,
                    res = res0;
                    err = err0;
                end
                %
                if res1 ~= 0,
                    res = res1;
                    err = err1;
                end
                %
                break
                %
            end
        end
    end
end

%