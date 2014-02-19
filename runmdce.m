function mdce_output = runmdce(mdce_input)
%
dkecluster = mdce_clustermode(mdce_input.dkecluster.scheduler);% remote dkecluster
%
varargout = cell(1,mdce_input.nargout-1);
narg_range = length(mdce_input.arg_range);
%
for j_nargout = 1:nargout-1,
    varargout{j_nargout} = cell(narg_range,1);
end
%
[flag,varargout{:}] = mdce_run(mdce_input.fun,mdce_input.args_in,mdce_input.arg_index,mdce_input.arg_range,dkecluster);
%
mdce_output.flag = flag;
mdce_output.varargout = varargout;