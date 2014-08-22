function [flag,varargout] = remcomputing(fun_handle,args_in,arg_index,arg_range,scheduler)
% 
% remote distributed computing environment
%
%   Distributed computing using remote jobs
%
%   INPUT:
%
%       - fun_handle: function handle
%       - args_in: input arguments list of the function {1,nargin}
%       - arg_index: index in the argument list args_in which must be changed [1,1]
%       - arg_range: list of values for the input argument arg_index [1,nrange]
%           => nrange = length(arg_range) = number of jobs 
%       - scheduler: scheduler information
%
%   OUTPUT:
%
%       - flag: status of the computation : scheduler.mode (OK with remcomputing) or -2 (failed) [1,nrange]
%       - varargout: output arguments list of the function {1,nargout-1}.
%           => Each element is a list of size {nrange,1}
%
%   by J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr) and Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr)
%
nrange = length(arg_range);
varargout_array = cell(nrange,nargout-1);
flag = zeros(1,nrange);
%
try
    %
    if isfield(scheduler,'remtimout'),% in minutes
        remtimout = scheduler.remtimout;
    else
        remtimout = Inf;
    end
    %
    if isfield(scheduler,'rempause'),% in minutes
        rempause = scheduler.rempause;
    else
        rempause = 1/6;
    end
    %
    if isfield(scheduler,'display'),
        displaymode = scheduler.display;
    else
        displaymode = 0;
    end
    %
    job = matstandardjob_jd('runmat');
    %
    if isfield(scheduler,'debugmode'),
        job.debugmode = scheduler.debugmode;
    end
    %
    if isfield(scheduler,'memory'),
        job.memory = scheduler.memory;% requested memory specified by scheduler
    end
    %
    if isfield(scheduler,'walltime'),
        job.walltime = scheduler.walltime;% requested memory specified by scheduler
    end
    %
    if isfield(scheduler,'localdatapath'),
        job.localdatapath = scheduler.localdatapath;% path to store batch_timeid folders
    elseif isfield(scheduler,'temppath'),
        job.localdatapath = scheduler.temppath;
    end
    %
    if isfield(scheduler,'cleanmode'),
        job.clean = scheduler.cleanmode;
    else
        job.clean = 2;
    end
    %
    if isfield(scheduler,'funcopy'),
        job.funcopy = scheduler.funcopy;% requested memory specified by scheduler
    else
        job.funcopy = true;
    end
    %
    mat_input.fun = fun_handle;
    mat_input.args_in = args_in;
    mat_input.nargout = nargout;
    %
    jobs = cell(1,nrange);
    %
    for j_range = 1:nrange,
        mat_input.args_in{arg_index} = arg_range{j_range};
        %
        jobs{j_range} = remoterunbatch(scheduler.remote,job,mat_input,displaymode);%submit job     
        %
        if isfield(jobs{j_range},'err'),% an error occured in the remote job start,
            flag(j_range) = -3;
            varargout_array{j_range,1}.err = jobs{j_range}.err;
        end
    end
    %
    trem = tic;
    %
    while toc(trem) < 60*remtimout,
        %
        for j_range = find(abs(flag) == 0),
            %
            [jobs{j_range},output] = remotegetbatch(jobs{j_range},displaymode,1);
            displayrunningjob(jobs{j_range},j_range,displaymode);
            %
            if ~isempty(output),
                %
                if isfield(output,'err'),
                    if displaymode,
                        disp(['Remote calculation failed for index #',num2str(j_range),'/',num2str(nrange)])
                    end
                    flag(j_range) = -4;
                    varargout_array{j_range,1}.err = output.err;
                else
                    flag(j_range) = 3;% scheduler.mode;
                    varargout_array(j_range,:) = output.varargout;
                end
            end
            %
        end
        %
        if ~any(abs(flag) == 0),
            break
        end
        %
        if displaymode,
            disp(['Run still executed remotely. Elapsed time (mins) ',num2str(toc(trem)/60),'/',num2str(remtimout)])
        end
        %
        pause(60*rempause);
        %
    end
    %
    for j_range = find(abs(flag) == 0),
        %
        if remtimout == 0,%return job for later process,
            varargout_array{j_range,1}.job = jobs{j_range};
            flag(j_range) = 4;
        else
            if displaymode,
                disp(['Remote calculation reached timeout for index #',num2str(j_range),'/',num2str(nrange)])
            end
            flag(j_range) = -5;
            %
        end
    end
    %
catch me_remcomputing
    disp('Error running remcomputing : flagged for sequential run');
    disp(['===> Error : ',getReport(me_remcomputing)]);
    flag = -2*ones(1,nrange);
end
%
varargout = cell(1,nargout-1);
%
%[varargout{:}] = deal(cell(N_range,1)); keep this line as an example of use of the function deal
%
for j_argout = 1:nargout-1,
    %
    varargout{j_argout} = varargout_array(:,j_argout);
    %
end
%