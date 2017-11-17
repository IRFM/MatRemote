function remotematrun(debugmode,remotematfnc)
%
% This function is a generic matlab function to be called when matlab is
% started in a remote location. The following variables are set by environment 
% variables when called by remoterunbatch and matlabbatch.sh
%
%   - remotebatchdir : path to where batch job is setup
%   - jobtimeid : identification for the job
%   - debugmode : debugging mode
%   - remotematfnc : function called by remotematrun
%
% for debugging purposes, the variables aboved can be entered or deducted from local
% environment, assuming that :
%   - the correct version of matlab was launched
%   - necessary path profiles are set properly
%   - this function is run from remotebatchdir 
%
% This function is to be combined with matstandardsave and matstandardload
% on the client machine.
%
% by J. Decker and Y. Peysson.
%
initdir = pwd;
%
try
    %
    remotebatchdir = getenv('remotebatchdir');
    %
    if nargin < 1 
        debugmode = str2double(getenv('debugmode'));        
    end
    if isempty(debugmode) || isnan(debugmode),
        debugmode = 0;
    end
    %
    if ~isempty(remotebatchdir),% function called by matlabbatch.sh
        %
        if ~exist(remotebatchdir,'dir'),
            error(['remotebatchdir : ',remotebatchdir,' does not exist from current location :',pwd]);
        elseif ~strcmp(remotebatchdir(1),filesep) % relative path
            addpath([pwd,filesep,remotebatchdir]);
        end
        %
        timeid = getenv('jobtimeid');
        if isempty(timeid),
            error('timeid not prescribed')
        end
        %
        remotematfnc = getenv('remotematfnc');
        if isempty(remotematfnc) || ~exist(remotematfnc,'file'),
            error('remotematfnc not prescribed or not transfered')
        end
        %
    else% function called manually 
        %
        remotebatchdir = [pwd,filesep];
        %
        addpath(remotebatchdir);
        %
        [~,localdir] = fileparts(pwd);
        %
        if length(localdir) <= 7 || ~strcmp(localdir(1:6),'batch_'),
            error('local environment is not recognized by remotematrun')
        else
            timeid = localdir(7:end);
        end
        %
        if nargin < 2,
            files = dir(remotebatchdir);
            matchlist = {'runmat.m','runmdce.m','remotetest.m'};
            remotematfnc = '';
            for ifile = 1:length(files),
                imatch = find(strcmp(files(ifile).name,matchlist),1,'first');
                if ~isempty(imatch),
                    remotematfnc = matchlist{imatch}(1:end-2);
                    break
                end
            end
            if isempty(remotematfnc),
                error('The function ''remotematfnc'' could not be identified from the local environment. Please prescribe as input.')
            end
            %        
        elseif ~exist([remotebatchdir,remotematfnc],'file')
            error(['The file ',remotebatchdir,remotematfnc,' does not exist'])
        end
        %
    end
    %
    proc_id = int2str(feature('getpid'));
    unix(['echo ',proc_id,' > ',remotebatchdir,'pid_',timeid]);
    %
    filein = [remotebatchdir,'MAT_RUN_',timeid,'.mat'];
    fileout = [remotebatchdir,'MAT_OUT_',timeid,'.mat'];
    %
    datain = load(filein);
    %
    datadir = [remotebatchdir,'datadir_',timeid,filesep];%output data directory
    %
    if ~exist(datadir,'dir'),
        datadir = remotebatchdir;
    end
    %
    cd(datadir);
    %
    if debugmode,
        filediary = ['matlab_diary.',timeid];
        diary(filediary);
        %
        disp('-------- in remotematrun.m --------');
        disp(['pid:',proc_id]);
        disp(['remotebatchdir = ',remotebatchdir]);
        disp(['timeid = ',timeid]);
        disp(['filein = ',filein]);
        disp(['fileout = ',fileout]);
        if exist('hostname_jd','file')
            disp(['hostname (from hostname_jd) = ',hostname_jd]);
        end
        disp('----------- Matlab Path -----------');
        path;
        disp('-----------------------------------');
    end
    %
    dataout = feval(remotematfnc,datain);
    %
    cd(initdir);
    %
    save(fileout,'-struct','dataout','-v7.3');
    %
catch lsterr
    %
    err = {'The action was cancelled due to the following error:','',lsterr.message};
    for il = 1:length(lsterr.stack),
        err = [err,['In ',lsterr.stack(il).file,' at line ',num2str(lsterr.stack(il).line)]];
    end
    %
    cd(initdir);
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
