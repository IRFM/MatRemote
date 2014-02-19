function remotematrun(timeid,debugmode,remotepathfnc,remotematfnc)
%
% This function is a generic matlab function to be called when matlab is
% started in a remote location. The following variables are set by environment 
% variables but can be specified by inputs, typically for debugging purposes.
%
%   - timeid : identification for the job
%   - debugmode : debugging mode
%   - remotepathfnc : function setting remote matlab path
%   - remotematfnc : function called by remotematrun
%
% in debugmode, it is assumed that the function is called from the remotedatath location
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
    remotebatchdir = getenv('remotebatchdir');
    %
    proc_id = int2str(feature('getpid'));
    save([remotebatchdir,'pid_',proc_id]);
    %
    filein = [remotebatchdir,'MAT_RUN_',timeid,'.mat'];
    fileout = [remotebatchdir,'MAT_OUT_',timeid,'.mat'];
    %
    if nargin < 3,
        remotepathfnc = getenv('remotepathfnc');
    end
    %
    if ~isempty(remotepathfnc) && exist([remotepathfnc,'.m'],'file'),
        [remotepath,remotepathfnc] = fileparts(remotepathfnc);
        if ~isempty(remotepath),% function on the remote filesystem
            addpath(remotepath);
        end
        feval(remotepathfnc);% setup remote matlab path
    else
        remotepath = '';
    end
    %
    if nargin < 4,
        remotematfnc = getenv('remotematfnc');
    end
    %
    if isempty(remotematfnc) || ~exist(remotematfnc,'file'),
        error('remotematfnc not prescribed')
    end
    %
    if debugmode,
        filediary = [remotebatchdir,'matlab_diary.',timeid];
        diary(filediary);
    end
    %
    if debugmode,
        disp('-------- in remotematrun.m --------');
        disp(['pid:',proc_id]);
        disp(['remotebatchdir = ',remotebatchdir]);
        disp(['timeid = ',timeid]);
        disp(['filein = ',filein]);
        disp(['fileout = ',fileout]);
        disp(['remotepath = ',remotepath]);
        disp(['remotepathfnc = ',remotepathfnc]);
        disp('------------------------------');
    end
    %
    datain = load(filein);
    %
    dataout = feval(remotematfnc,datain);
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
    if exist('fileout','var'),
        save(fileout,'err')
    else
        save('error.mat','err')
    end
    %
end
%
if debugmode,
    diary off
end
%
