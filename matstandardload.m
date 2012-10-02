function [soutput] = matstandardload(job)
%
% This function loads data from the file job.load_id at location job.localdatapath into the structure soutput
%
soutput = load([job.localdatapath,job.load_id]);