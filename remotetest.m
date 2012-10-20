function remotetest(timeid,debugmode)
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
        if isempty(debugmode),
            debugmode = 0;
        end
    end
    %
    if debugmode,
        filediary = ['matlab_diary.',timeid];
        diary(filediary);
    end
    %
    datapath = getenv('remotedatapath');
    logname = getenv('USER');
    testvar = getenv('TESTVAR');
    %
    filein = [datapath,'MAT_RUN_',logname,'_',timeid,'.mat'];
    fileout = [datapath,'MAT_OUT_',logname,'_',timeid,'.mat'];
    %
    if debugmode,
        disp('-------- in runluke.m --------');
        disp(['datapath = ',datapath]);
        disp(['logname = ',logname]);
        disp(['timeid = ',timeid]);
        disp(['filein = ',filein]);
        disp(['fileout = ',fileout]);
        disp(['testvar = ',testvar]);
        disp('------------------------------');
    end
    %
    load(filein,'strin');
    %
    strout = [strin,testvar,' - running under matlab version : ',version];
    %
    save(fileout,'strout');
    %
    pause(10)
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
