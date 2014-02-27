function [php_post] = phppostremotejob(remote,job,php_post)
%
if nargin < 3, php_post = {}; end
%
post_job{1} = {'batch_dir'};
post_job{2} = {'timeid'};
post_job{3} = {'id'};
post_job{4} = {'pbssearch'};
post_job{5} = {'condorsearch'};
post_job{6} = {'xgridsearch'};
post_job{7} = {'directsearch'};
post_job{8} = {'sgesearch'};
post_job{8} = {'nodes'};
post_job{9} = {'ppn'};
post_job{10} = {'memory'};
post_job{11} = {'walltime'};
post_job{12} = {'ncpus'};
post_job{13} = {'funcopy'};
post_job{14} = {'remtimout'};
post_job{15} = {'rempause'};
post_job{16} = {'wait'};
post_job{17} = {'script'};
post_job{18} = {'savefcn'};
post_job{19} = {'loadfcn'};
post_job{20} = {'matlabroot','env','remotebatch_matlabroot'};
post_job{21} = {'matlabprefdir','env','remotebatch_matlabprefdir'};
post_job{22} = {'testvar','env','TESTVAR'};
post_job{23} = {'matlabfun','env','remotebatch_matlabfun'};
post_job{24} = {'remotepathfnc','env','remotepathfnc'};
post_job{25} = {'remotematfnc','env','remotematfnc'};
post_job{26} = {'debugmode'};
post_job{27} = {'condorscript','condor_script'};
post_job{28} = {'xgridscript','xgrid_script'};
post_job{29} = {'sgescript','sge_script'};
post_job{30} = {'hostname'};
post_job{31} = {'remotedatapath'};
%
post_remote{1} = {'remoteuser'};
post_remote{2} = {'remotehost','host'};
post_remote{3} = {'condorconfig','condor','CONDOR_CONFIG'};
post_remote{4} = {'condorpath','condor','PATH'};
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



