function [soutput] = matstandardload(job)
%
% This function loads data from the file job.load_id at location job.localdatapath into the structure soutput
%
if exist([job.localdatapath,job.load_id],'file'),
    soutput = load([job.localdatapath,job.load_id]);
else
    soutput.err = ['The file ',[job.localdatapath,job.load_id],' does not exist'];
end