function [php_post] = phppostremotejob(remote,job,php_post)
%
post_job{1} = {'batch_dir'};
post_job{2} = {'timeid'};
post_job{3} = {'id'};
post_job{4} = {'pbssearch'};
post_job{5} = {'condorsearch'};
post_job{6} = {'xgridsearch'};
post_job{7} = {'directsearch'};
post_job{8} = {'sgesearch'};
%
post_remote{1} = {'remoteuser'};
post_remote{2} = {'remotehost','host'};
post_remote{3} = {'remotedatapath'};
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
                ip = ip + 1;php_post{ip} = '';
            end
        else
            if isfield(job,post_job{ii}{2}),
                ip = ip + 1;php_post{ip} = num2str(job.(post_job{ii}{2}));%content transfered by php post
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
        else
            if isfield(remote,post_remote{ii}{2}),
                ip = ip + 1;php_post{ip} = num2str(remote.(post_remote{ii}{2}));%content transfered by php post
            else
                ip = ip + 1;php_post{ip} = '';
            end
        end
    end
    %    
end



