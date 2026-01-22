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
function [flag,varargout] = mdce_get(joblist)
%
% This function checks and eventually returns the results of remote and/or
% distributed jobs started using the MDCE toolbox (mdce_run)
%
% - either a single job was sent using mdce_remote, or
% - one or several jobs were started using remcomputing
%
% INPUTS :
%       - joblist can be any of the following :
%
%           - a cell array, each cell containing a structure with a field 'job' (MDCE)
%           - a cell array, with
%               o the first cell containing a structure with a field 'job' and  jobs{1}.env.remotematfnc = runmdce (mdce_remote)
%               o all other cells empty (which determine the size of the structure)
%
% TODO : extension of the use of mdce_get to process
%
% - a cell array containing a job structure
% - a structure or structure array with a field 'job'
% - a structure or structure array of jobs
%
if iscell(joblist),
    njobs = length(joblist);
else
    error('joblist must be a cell array');
end
%
varargout = cell(1,nargout-1);
for j_nargout = 1:nargout-1,
    varargout{j_nargout} = cell(njobs,1);
end
%
% case of empty joblist
% 
if njobs == 0,
    return
end
%
if ~isfield(joblist{1},'job'),
    error('joblist{1} must be a structure with a field ''job''');
else
    displaymode = 1 + joblist{1}.job.debugmode;
end
%
flag = NaN(1,njobs);
%
if strcmp(joblist{1}.job.env.remotematfnc,'runmdce'),
    %
    % Remote calculation using mdce_remote
    %
    for ijob = 2:njobs,
        if ~isempty(joblist{ijob}),
            error(['joblist{',num2str(ijob),'} must be an empty cell']);
        end
    end
    %
    flag(:) = -Inf;% failed remote calc. flag
    %
    [job,output] = remotegetbatch(joblist{1}.job,displaymode,1);
    displayrunningjob(job,1,displaymode);
    %
    if isempty(output),% job still running
        flag(:) = 4;
        varargout{1}{1}.job = job;% update job time stamps
    elseif isfield(output,'err'),% job failed
        disp('Remote MDCE run failed.')
        varargout{1}{1}.err = output.err;
    else% job completed
        flag = 10 + output.flag;% add 10 for each remote step
        varargout = output.varargout;
    end    
    %
else 
    %
    % Distributed calculation using remcomputing
    %
    varargout_array = cell(njobs,nargout-1);
    %
    for ijob = 1:njobs,
        if isfield(joblist{ijob},'job'),
            [job,output] = remotegetbatch(joblist{ijob}.job,displaymode,1);
            displayrunningjob(job,1,displaymode);
            %
            if isempty(output),% job still running
                flag(ijob) = 4;
                varargout_array{ijob,1}.job = job;% update job time stamps
            elseif isfield(output,'err'),% job failed
                if displaymode,
                    disp(['Remote calculation failed for job #',num2str(ijob),'/',num2str(njobs)])
                end
                flag(ijob) = -4;
                varargout_array{ijob,1}.err = output.err;
            else% job completed
                flag(ijob) = 3;% scheduler.mode;
                varargout_array(ijob,:) = output.varargout;
            end
        else
            error(['joblist{',num2str(ijob),'} must be a structure with a field ''job''']);
        end
    end
    %
    for j_argout = 1:nargout-1,
        %
        varargout{j_argout} = varargout_array(:,j_argout);
        %
    end
    %
    if all(flag < 4),%no job left running
        for ijob = 1:njobs,
            if exist(joblist{ijob}.job.temppath,'dir')
                try
                    rmdir(joblist{ijob}.job.temppath,'s');
                catch err
                    disp(['WARNING : tmp directory ',joblist{ijob}.job.temppath,' could not be removed for the following reason : ',err.message])
                end
            end
        end
    end
end
    
    


