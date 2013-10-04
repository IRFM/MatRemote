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
    tmpfilestr = [func2str(mdce_input.fun),'_',mdce_input.timeid];
    tmpfilename = [tmpfilestr,'.m'];
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
else
    fun = mdce_input.fun;
end
%
[flag,varargout{:}] = mdce_luke(fun,mdce_input.args_in,mdce_input.arg_index,mdce_input.arg_range,dkecluster);
%
if isfield(mdce_input,'funstr'),
    delete(tmpfilename);
end
%
mdce_output.flag = flag;
mdce_output.varargout = varargout;