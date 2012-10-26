function [err,varargout] = matremote_luke_jd(fun,args_in,remote)
%
% This is a generic matlab function exectuting the function fun with
% arguments args_in remotely
%
varargout = cell(1,nargout-1);
%
err = '';
%
if isfield(remote,'debugmode'),
    debugmode = remote.debugmode;
else
    debugmode = 0;
end
%
job.env.luke_root = remote.luke_root;% luke path environment
job.env.remotematfnc = 'runmat';
%
job.script = [job.env.luke_root,filesep,'Tools/matlablukebatch.sh'];
%
job.savefcn = 'matstandardsave';%'runlukesave';%
job.loadfcn = 'matstandardload';%'runlukeload';%
job.localdatapath = '';
if isfield(remote,'remotedatapath') && ~isempty(remote.remotedatapath),
    job.remotedatapath = remote.remotedatapath;
else
    job.remotedatapath = '';
end
%
job.wait = 0;% (0) return hand (1) wait for result
job.nodes = 1;%number of nodes required
job.nproc = 2;%number of cores required
job.walltime = [];% time required (integers - in hours) - leave empty if no requirement
%
if isfield(remote,'memory'),
    job.memory = remote.memory;% requested memory specified in dkeparam
end
%
job.debugmode = debugmode;
%
mat_input.fun = fun;
mat_input.args_in = args_in;
mat_input.nargout = nargout;
%
job = remoterunbatch(remote,job,mat_input,debugmode);
%
if ~isfield(job,'err'),% no error occured in the remote job start,
    output = remotegetbatch(remote,job,debugmode,0);
else
    output.err = job.err;
end
%
if isempty(output),
    if debugmode,
        disp('Timeout reached. Calculation started locally if enforced.')
    end
    err = 'timout';
elseif isfield(output,'err'),
    if debugmode,
        disp('Remote calculation failed. Calculation started locally if enforced.')
    end
    err = output.err;
else
    varargout = output.varargout;
end

