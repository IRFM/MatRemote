function [flag,waitime,runtime,jobtime,message] = displayrunningjob(job,isim,displaymode)
%
% MATREMOTE 
%
% Calculate and display the status of a job
%
% OUTPUTS:
%
%       - flag :
%           o (0) job launched but not started
%           o (1) job started but not finished (running)
%           o (2) job completed
%
%       - waitime : time since job was launched or from launch to start time
%       - runtime : time since job was started or from start to finished time
%       - jobtime : time from job creation to completion
%
%       - message : status message
%
if nargin < 3,
    displaymode = 1;
end
%
if nargin < 2,
    isim = [];
end
%
if isempty(job.id),
    jobidstr = ['Job with timeid ',job.timeid];
else
    jobidstr = ['Job with ID ',job.id];
end
%
if isempty(isim),
    jobstr = [' - ',jobidstr];
else
    jobstr = [' - Simulation #',int2str(isim),' -> ',jobidstr];
end
%
waitime = '';
runtime = '';
jobtime = '';
%
if ~isempty(job.time.cleaned),
    %
    % job completed
    %
    flag = 2;
    jobtime = datestr(etime(datevec(job.time.cleaned),datevec(job.time.created))/86400,'HH:MM:SS');
    message = [jobstr,' is completed in ',jobtime,' (HH:MM:SS).'];
    %
    if ~isempty(job.time.started),% remote wait time accessible
        waitime = datestr(etime(datevec(job.time.started),datevec(job.time.launched))/86400,'HH:MM:SS');
        message = [message,' Remote wait time was ',waitime,' (HH:MM:SS).'];
        if ~isempty(job.time.finished)% remote run time accessible
            runtime = datestr(etime(datevec(job.time.finished),datevec(job.time.started))/86400,'HH:MM:SS');
            message = [message,' Remote run time was ',runtime,' (HH:MM:SS).'];
        end
    end
    %
elseif ~isempty(job.time.started),
    %
    % job started but not completed
    % 
    flag = 1;
    runtime = datestr(etime(datevec(utctime_jd),datevec(job.time.started))/86400,'HH:MM:SS');
    waitime = datestr(etime(datevec(job.time.started),datevec(job.time.launched))/86400,'HH:MM:SS');
    message = [jobstr,' has been running for ',runtime,' (HH:MM:SS). Remote wait time was ',waitime,' (HH:MM:SS).'];
    %
else% job launched but not started
    %
    flag = 0;
    waitime = datestr(etime(datevec(utctime_jd),datevec(job.time.launched))/86400,'HH:MM:SS');
    message = [jobstr,' was launched ',waitime,' (HH:MM:SS) ago.'];
    %
end
%
if displaymode,
    disp(message)
end
