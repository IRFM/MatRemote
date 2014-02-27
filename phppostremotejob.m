function [php_post] = phppostremotejob(remote,job,php_post)
%
if nargin < 3, php_post = {}; end
%
% data transfer from job
%
ij = 1;
post_job{ij} = {'batch_dir'};ij = ij + 1;
post_job{ij} = {'timeid'};ij = ij + 1;
post_job{ij} = {'id'};ij = ij + 1;
post_job{ij} = {'pbssearch'};ij = ij + 1;
post_job{ij} = {'condorsearch'};ij = ij + 1;
post_job{ij} = {'xgridsearch'};ij = ij + 1;
post_job{ij} = {'directsearch'};ij = ij + 1;
post_job{ij} = {'sgesearch'};ij = ij + 1;
post_job{ij} = {'nodes'};ij = ij + 1;
post_job{ij} = {'ppn'};ij = ij + 1;
post_job{ij} = {'memory'};ij = ij + 1;
post_job{ij} = {'walltime'};ij = ij + 1;
post_job{ij} = {'ncpus'};ij = ij + 1;
post_job{ij} = {'funcopy'};ij = ij + 1;
post_job{ij} = {'remtimout'};ij = ij + 1;
post_job{ij} = {'rempause'};ij = ij + 1;
post_job{ij} = {'wait'};ij = ij + 1;
post_job{ij} = {'script'};ij = ij + 1;
post_job{ij} = {'savefcn'};ij = ij + 1;
post_job{ij} = {'loadfcn'};ij = ij + 1;
post_job{ij} = {'matlabroot','env','remotebatch_matlabroot'};ij = ij + 1;
post_job{ij} = {'matlabprefdir','env','remotebatch_matlabprefdir'};ij = ij + 1;
post_job{ij} = {'testvar','env','TESTVAR'};ij = ij + 1;
post_job{ij} = {'matlabfun','env','remotebatch_matlabfun'};ij = ij + 1;
post_job{ij} = {'remotepathfnc','env','remotepathfnc'};ij = ij + 1;
post_job{ij} = {'remotematfnc','env','remotematfnc'};ij = ij + 1;
post_job{ij} = {'debugmode'};ij = ij + 1;
post_job{ij} = {'condorscript','condor_script'};ij = ij + 1;
post_job{ij} = {'xgridscript','xgrid_script'};ij = ij + 1;
post_job{ij} = {'sgescript','sge_script'};ij = ij + 1;
post_job{ij} = {'hostname'};ij = ij + 1;
post_job{ij} = {'remotedatapath'};ij = ij + 1;
post_job{ij} = {'mailuser'};ij = ij + 1;
%
% A maximum of 20 extra job parameters (job.params) are passed to the php
%
if isfield(job,'params'),
    %
    nparam = length(job.params);
    %
    if nparams > 20,
        error('Only 20 job extra parameters may be transfered to the php');
    else
        %
        post_job{ij} = {'nparam'};ij = ij + 1;
        job.nparam = int2str(nparam);
        %
        for ip = 1:nparam; 
            %
            post_job{ij} = {['params',int2str(ip)]};ij = ij + 1;
            %
        end
    end
end
%
% data transfer from remote
%
post_remote{1} = {'remoteuser'};
post_remote{2} = {'remotehost','host'};
if ~isempty(remote.condor),
    post_remote{3} = {'condorconfig','condor','CONDOR_CONFIG'};
    post_remote{4} = {'condorpath','condor','PATH'};
end
%
ip = length(php_post);
%
if ~isempty(job),
    %
    for ii = 1:length(post_job),
        ip = ip + 1;php_post{ip} = post_job{ii}{1};%php variable
        %
        if length(post_job{ii}) == 1,
            if isfield(job,post_job{ii}{1}),
                ip = ip + 1;php_post{ip} = num2str(job.(post_job{ii}{1}));%content transfered by php post     
            else
                if ~isempty(strfind(post_job{ii}{1},'params')),
                    iparam = str2num(post_job{ii}{1}(7:end));
                    ip = ip + 1;php_post{ip} = num2str(job.params{iparam});%content transfered by php post     
                else
                    ip = ip + 1;php_post{ip} = '';
                end
            end
        elseif length(post_job{ii}) == 2,
            if isfield(job,post_job{ii}{2}),
                ip = ip + 1;php_post{ip} = num2str(job.(post_job{ii}{2}));%content transfered by php post
            else
                ip = ip + 1;php_post{ip} = '';
            end
        elseif length(post_job{ii}) == 3,
            if isfield(job.(post_job{ii}{2}),post_job{ii}{3}),
                ip = ip + 1;php_post{ip} = num2str(job.(post_job{ii}{2}).(post_job{ii}{3}));%content transfered by php post
            else
                ip = ip + 1;php_post{ip} = '';
            end
        end
    end
end
%
if ~isempty(remote),
    %
    for ii = 1:length(post_remote),
        ip = ip + 1;php_post{ip} = post_remote{ii}{1};%php variable
        %
        if length(post_remote{ii}) == 1,
            if isfield(remote,post_remote{ii}{1}),
                ip = ip + 1;php_post{ip} = num2str(remote.(post_remote{ii}{1}));%content transfered by php post
            else
                ip = ip + 1;php_post{ip} = '';
            end
        elseif length(post_remote{ii}) == 2,
            if isfield(remote,post_remote{ii}{2}),
                ip = ip + 1;php_post{ip} = num2str(remote.(post_remote{ii}{2}));%content transfered by php post
            else
                ip = ip + 1;php_post{ip} = '';
            end
        elseif length(post_remote{ii}) == 3,
            if isfield(remote.(post_remote{ii}{2}),post_remote{ii}{3}),
                ip = ip + 1;php_post{ip} = num2str(remote.(post_remote{ii}{2}).(post_remote{ii}{3}));%content transfered by php post
            else
                ip = ip + 1;php_post{ip} = '';
            end
        end
        end
    end
    %    
end



