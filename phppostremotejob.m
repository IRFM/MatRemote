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
function [php_post] = phppostremotejob(remote,job,php_post)
%
if nargin < 3, php_post = {}; end
%
% data transfer from job
%
ij = 1;
%
% WARNING: check that the variable exist in the list of POST variables on the PHP side
%
post_job{ij} = {'batch_dir'};ij = ij + 1;
post_job{ij} = {'timeid'};ij = ij + 1;
post_job{ij} = {'id'};ij = ij + 1;
post_job{ij} = {'pbssearch'};ij = ij + 1;
post_job{ij} = {'condorsearch'};ij = ij + 1;
post_job{ij} = {'slurmsearch'};ij = ij + 1;
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
post_job{ij} = {'matlabfun','env','remotebatch_matlabfun'};ij = ij + 1;
post_job{ij} = {'matlabpath','env','MATLABPATH'};ij = ij + 1;
post_job{ij} = {'remotematfnc','env','remotematfnc'};ij = ij + 1;
post_job{ij} = {'debugmode'};ij = ij + 1;
post_job{ij} = {'condorscript','condor_script'};ij = ij + 1;
post_job{ij} = {'sgescript','sge_script'};ij = ij + 1;
post_job{ij} = {'hostname'};ij = ij + 1;
post_job{ij} = {'remotedatapath'};ij = ij + 1;
%
post_job{ij} = {'testvar','env','TESTVAR'};ij = ij + 1;
post_job{ij} = {'lukeroot','env','luke_root'};ij = ij + 1;
%
% data transfer from remote
%
ij = 1;
%
post_remote{ij} = {'remoteuser'};ij = ij + 1;
post_remote{ij} = {'usermail'};ij = ij + 1;
post_remote{ij} = {'remotehost','host'};ij = ij + 1;
post_remote{ij} = {'shell'};ij = ij + 1;
post_remote{ij} = {'password'};ij = ij + 1;

%
if ~isempty(remote.condor),%condor specific
    %
    post_remote{ij} = {'condorconfig','condor','CONDOR_CONFIG'};ij = ij + 1;
    post_remote{ij} = {'condorpath','condor','PATH'};ij = ij + 1;
    %
end
%
if ~isempty(remote.sge),%sge specific
    %
    nbatchscriptparams = 0;
    ip = 1;
    %
    while 1,
        %
        if isfield(remote.sge,['batchscript_params',int2str(ip)]),
            %
            post_remote{ij} = {['batchscriptparams',int2str(ip)],'sge',['batchscript_params',int2str(ip)]};ij = ij + 1;
            nbatchscriptparams = nbatchscriptparams + 1;
            ip = ip + 1;
            %
        else
            if nbatchscriptparams > 0,
                post_remote{ij} = {'nbatchscriptparams','sge','nbatchscriptparams'};ij = ij + 1;
                remote.sge.nbatchscriptparams = int2str(nbatchscriptparams);%temporary field
            end
            %
            break;
        end
        %
    end
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
                ip = ip + 1;
                if isnumeric(job.(post_job{ii}{1})) || islogical(job.(post_job{ii}{1})),
                    php_post{ip} = num2str(job.(post_job{ii}{1}));%content transfered by php post     
                else
                    php_post{ip} = job.(post_job{ii}{1});%content transfered by php post
                end
            else
                ip = ip + 1;php_post{ip} = '';
            end
        elseif length(post_job{ii}) == 2,
            if isfield(job,post_job{ii}{2}),
                ip = ip + 1;
                if isnumeric(job.(post_job{ii}{2})) || islogical(job.(post_job{ii}{2})),
                    php_post{ip} = num2str(job.(post_job{ii}{2}));%content transfered by php post
                else
                    php_post{ip} = job.(post_job{ii}{2});%content transfered by php post
                end
            else
                ip = ip + 1;php_post{ip} = '';
            end
        elseif length(post_job{ii}) == 3,
            if isfield(job,post_job{ii}{2}) && isfield(job.(post_job{ii}{2}),post_job{ii}{3}),
                ip = ip + 1;
                if isnumeric(job.(post_job{ii}{2}).(post_job{ii}{3})) || islogical(job.(post_job{ii}{2}).(post_job{ii}{3})),
                    php_post{ip} = num2str(job.(post_job{ii}{2}).(post_job{ii}{3}));%content transfered by php post
                else
                    php_post{ip} = job.(post_job{ii}{2}).(post_job{ii}{3});%content transfered by php post                    
                end
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
                ip = ip + 1;
                if isnumeric(remote.(post_remote{ii}{1})) || islogical(remote.(post_remote{ii}{1})),
                    php_post{ip} = num2str(remote.(post_remote{ii}{1}));%content transfered by php post
                else
                    php_post{ip} = remote.(post_remote{ii}{1});%content transfered by php post
                end
            else
                ip = ip + 1;php_post{ip} = '';
            end
        elseif length(post_remote{ii}) == 2,
            if isfield(remote,post_remote{ii}{2}),
                ip = ip + 1;
                if isnumeric(remote.(post_remote{ii}{2})) || islogical(remote.(post_remote{ii}{2})),
                    php_post{ip} = num2str(remote.(post_remote{ii}{2}));%content transfered by php post
                else
                    php_post{ip} = remote.(post_remote{ii}{2});%content transfered by php post
                end     
            else
                ip = ip + 1;php_post{ip} = '';
            end
        elseif length(post_remote{ii}) == 3,
            if isfield(remote.(post_remote{ii}{2}),post_remote{ii}{3}),
                ip = ip + 1;
                if isnumeric(remote.(post_remote{ii}{2}).(post_remote{ii}{3})) || islogical(remote.(post_remote{ii}{2}).(post_remote{ii}{3})),
                    php_post{ip} = num2str(remote.(post_remote{ii}{2}).(post_remote{ii}{3}));%content transfered by php post
                else
                    php_post{ip} = remote.(post_remote{ii}{2}).(post_remote{ii}{3});%content transfered by php post                    
                end
            else
                ip = ip + 1;php_post{ip} = '';
            end
        end
    end
    %    
end


