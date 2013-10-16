function remotematrun(timeid,debugmode)
%
% This function is a generic matlab function to be called when matlab is
% started in a remote location. timeid and debugmode are meant to be loaded
% from environment variables but can be prescribed directly, typically for
% debugging purposes.
%
% This function is to be combined with matstandardsave and matstandardload
% on the client machine.
%
% by J. Decker and Y. Peysson.
%
try
    %
    if nargin < 1,
        timeid = getenv('jobtimeid');
        if isempty(timeid),
            error('timeid not prescribed')
        end
    else
        stimeid = whos('timeid');
        if ~strcmp(stimeid.class,'char'),
            timeid = int2str(timeid);% in case timeid is integer
        end
    end
    %
    if nargin < 2,
        debugmode = str2double(getenv('debugmode'));
    end
    %
    if isempty(debugmode) || isnan(debugmode),
        debugmode = 0;
    end
    %
    datapath = getenv('remotedatapath');
    logname = getenv('USER');
    remotematfnc = getenv('remotematfnc');
    %
    if debugmode,
        filediary = [datapath,'matlab_diary.',timeid];
        diary(filediary);
    end
    %
    filein = [datapath,'MAT_RUN_',logname,'_',timeid,'.mat'];
    %
    if any(strfind(datapath,['xgrid_',timeid])),
        fileout = ['MAT_OUT_',logname,'_',timeid,'.mat'];
    else
        fileout = [datapath,'MAT_OUT_',logname,'_',timeid,'.mat'];
    end
    %
    if debugmode,
        disp('-------- in remotematrun.m --------');
        disp(['datapath = ',datapath]);
        disp(['logname = ',logname]);
        disp(['timeid = ',timeid]);
        disp(['filein = ',filein]);
        disp(['fileout = ',fileout]);
        disp('------------------------------');
    end
    %
    datain = load(filein);
    %
    % create function to be run remotely if datain.funstr exists
    %
    if isfield(datain,'fun') && ~ischar(datain.fun),% datain.fun is function handle
        datain.fun = func2str(datain.fun);
    end
    %
    if isfield(datain,'funstr'),% function string was passed on to worker
        % 
        addpath(datapath);
        %
        datain.fun = [datain.fun,'_',timeid];% new function name
        %
        tmpfilename = [datapath,datain.fun,'.m'];% tmp function file
        %
        diary(tmpfilename);% create tmp file
        %
        disp(datain.funstr);
        %
        diary off
        %
        niwait = 100;% maximum waiting time in s
        %
        for iwait = 1:niwait,% wait for tmp file to be written
            if ~isempty(which(datain.fun)),
                pause(1);
                break
            end
            pause(1);
        end
        %
    end
    %
    dataout = feval(remotematfnc,datain);
    %
    if isfield(datain,'funstr'),
        delete(tmpfilename);
    end
    %
    save(fileout,'-struct','dataout','-v7.3');
    %
catch
    %
    lsterr = lasterror;
    %
    err = {'The action was cancelled due to the following error:','',lsterr.message};
    for il = 1:length(lsterr.stack),
        err = [err,['In ',lsterr.stack(il).file,' at line ',num2str(lsterr.stack(il).line)]];
    end
    %
    save(fileout,'err')
    %
end
%
if debugmode,
    diary off
end
%
