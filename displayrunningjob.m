function [runtime_str,duration_str,runtime_num,duration_num] = displayrunningjob(job,displaymode)
%MATREMOTE - calculate and display the status of a job (elapsed run time and total duration once done
%
% Calculate and display the status of a job (elapsed run time and total duration once done
%
if nargin == 1,
    displaymode = 1;
end
%
duration_num = 0;
duration_str = '';
runtime_num = 0;
runtime_str = '';
%
if isfield(job,'timestopremote'),
    %
	duration_str = datestr(etime(datevec(job.timestopremote),datevec(job.timestartremote))/86400,'HH:MM:SS');
	duration_num = datenum(duration_str);
    %
    if displaymode,disp([' - Job # ',job.id,' has been executed in ',duration_str,' (HH:MM:SS)']);end 
    %
else
    %
    if ~isfield(job,'timecurrentremote') && ~isfield(job,'timestartremote')
        %
        if displaymode,disp([' - Job # ',job.id,' is still running...']);end
        %
    else
        %
        runtime_str = datestr(etime(datevec(job.timecurrentremote),datevec(job.timestartremote))/86400,'HH:MM:SS');
        runtime_num = datenum(runtime_str);
        %
        if displaymode,disp([' - Job # ',job.id,' is still running since ',runtime_str,' (HH:MM:SS)']);end
        %
    end
    %
end