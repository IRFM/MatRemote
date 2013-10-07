function mdce_output = runmdce(mdce_input)
%
dkepath = load_structures_yp('dkepath','','');
%
dkecluster = clustermode_luke(mdce_input.dkecluster.param,mdce_input.dkecluster.fun,dkepath,mdce_input.dkecluster.schedulertype,0);% remote dkecluster
%
varargout = cell(1,mdce_input.nargout-1);
narg_range = length(mdce_input.arg_range);
%
for j_nargout = 1:nargout-1,
    varargout{j_nargout} = cell(narg_range,1);
end
%
%
%
if isfield(mdce_input,'funstr'),% function string was passed on to worker
    %
    if ~ischar(mdce_input.fun),
        tmpfilestr = [func2str(mdce_input.fun),'_',mdce_input.timeid];
    else
        tmpfilestr = [mdce_input.fun,'_',mdce_input.timeid];
    end
    %
    tmpfilename = [mdce_input.datapath,tmpfilestr,'.m'];
    %
    diary(tmpfilename);
    %
    disp(mdce_input.funstr);
    %
    diary off
    %
    fun = tmpfilestr;
    %
    niwait = 100;% maximum waiting time in s
    %
    for iwait = 1:niwait,
        if exist(tmpfilename,'file') == 2,
            break
        end
        pause(1);
    end
    %
    %addpath(mdce_input.datapath);
    %
else
    fun = mdce_input.fun;
end
%
wd = pwd;
%
cd(mdce_input.datapath);
%
[flag,varargout{:}] = mdce_luke(fun,mdce_input.args_in,mdce_input.arg_index,mdce_input.arg_range,dkecluster);
%
cd(wd);
%
if isfield(mdce_input,'funstr'),
    delete(tmpfilename);
end
%
mdce_output.flag = flag;
mdce_output.varargout = varargout;