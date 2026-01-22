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
function [err,job,varargout] = matremote_jd(arg1,args_in,remote,job)
%
% This is a generic matlab function exectuting the function fun with
% arguments args_in remotely according to profile remote
%
% remote can be a remote structure or a string of the form : 
%
%   - remoteprofile : remote profile 'remoteprofile' with default remote user and default remote scheduler
%       ex : 'CRPP_PPB110'
%   - remoteuser:remoteprofile : remote profile 'remoteprofile' with remote user 'remoteuser' and default remote scheduler
%       ex : 'decker:CRPP_PPB110'
%   - remoteuser:remoteprofile:scheduler : remote profile 'remoteprofile' with remote user 'remoteuser' and remote scheduler 'scheduler'
%       ex : 'decker:CRPP_PPB110:slurm'
%
% Note : this function can be used with a wait loop (job.remtimeout or remote.remtimeout > 0)
%                 or return the job for later check (job.remtimeout or remote.remtimeout == 0)
%
% Use : 
%   - [err,job,varargout] = matremote_jd(fun,args_in,remote,[job])
%       -> run the function [varargout] = fun(args_in) remotely 
%          according to remote profile 'remote' and optionnal job parameters 'job'
% 
%   - [err,job,varargout] = matremote_jd(job)
%       -> check the status of the job 'job' and return the result if completed
%
varargout = cell(1,nargout-2);%test
%
err = '';
%
if nargin == 1,% check the status of the job 'job' and return the result if completed
    %
    [job,output] = remotegetbatch(arg1,[],1);% arg1=job;
    displayrunningjob(job);
    %
elseif nargin > 2 && ~isempty(remote),% new batch job 
    %
    if nargin < 4,
        job = matstandardjob_jd('runmat');
    end
    %
    if ~isfield(job,'funcopy'),
        job.funcopy = true;
    end
    %
    mat_input.fun = arg1;% arg1=fun;
    mat_input.args_in = args_in;
    mat_input.nargout = nargout-1;
    %
    if ischar(remote),
        %
        isep = strfind(remote,':');
        %
        if isempty(isep),
            remoteuser = NaN;
            remoteprofile = remote;
            scheduler = NaN;
        elseif length(isep) == 1,
            remoteuser = remote(1:isep-1);
            remoteprofile = remote(isep+1:end);
            scheduler = NaN;
        elseif length(isep) == 2,
            remoteuser = remote(1:isep(1)-1);
            remoteprofile = remote(isep(1)+1:isep(2)-1);
            scheduler = remote(isep(2)+1:end);            
        else
            error('Could not determine remote profile')
        end
        %
        [remoteprofiles,profilestr] = load_remoteprofiles_jd(remoteprofile,true,false,scheduler,remoteuser,false,false);
        %
        if length(profilestr) ~= 1,
            error('Could not determine remote profile')
        else
            disp(profilestr{1})
        end
        remote = remoteprofiles;
    end
    %
    job = remoterunbatch(remote,job,mat_input);
    %
    if ~isfield(job,'err'),% no error occured in the remote job start,
        if isfield(job,'remtimout') && job.remtimout == 0,% return and check later
            output = '';
        else
            [job,output] = remotegetbatch(job,[],0);% wait for result
            displayrunningjob(job);
        end
    else
        output.err = job.err;
    end
    %
elseif nargin == 2 || (nargin > 2 && isempty(remote)),
    %
    % direct calculation
    %
    job = '';
    %
    try 
        [varargout{:}] = feval(arg1,args_in{:});% arg1=fun;
        output.varargout = varargout;
    catch lsterr
        output.err = disperr_jd(lsterr);
    end
else
    error('Wrong number of inputs calling matremote_jd')
end
%
if isfield(output,'err'),
    disp('Remote calculation failed.')
    if isempty(output.err),
        err = 'unknown error';
    else        
        err = output.err;
    end
elseif isfield(output,'varargout'),
    varargout = output.varargout;
end

