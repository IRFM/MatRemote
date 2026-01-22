% 
% /////////////////////////////////////////
%
% Software name : MatRemote, part of LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function [res,err] = scp2remote_yp(sshcmd,scpcmd,filename,local_path,remote_path)
% LUKE - scp UNIX command with checking of the file or directory transfer for slow network
%
%   scp UNIX command with checking of the file or directory transfer for slow network
%
%   INPUT:
%
%       - sshcmd : ssh command to remote computer
%       - scpcmd : scpcmd command to remote computer
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
if nargin < 5,
    error('Not enough input arguments in scp2remote_yp.m.');
end
if ~strcmp(remote_path(end),filesep),
    remote_path = [remote_path,filesep];
end
%
filename = strip(filename,'right','/');
%
[res,err] = unix([scpcmd{1},' ',local_path,filename,' ',scpcmd{2},':',remote_path,filename]);
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
        remotecmds = {'stat -f','stat -f "%z"','stat -c %s'};
        res = 1;
        %
        for icmd = 1:length(remotecmds),
            %
            remotecmd = remotecmds{icmd};
            %
            [res,err] = unix([sshcmd,' ''',remotecmd,' ',remote_path,filelist{ifile},'''']);
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
            [res,err] = unix([sshcmd,' ''',remotecmd,' ',remote_path,filelist{ifile},'''']);
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