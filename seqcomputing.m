function [results] = seqcomputing(fun,args_in,arg_index,arg_range,nargout_in)
%LUKE - Sequential computing of the loop in case of failure of the Distributed Computing Environment
%
%   Sequential computing of the loop in case of failure of the Distributed Computing Environment
%
%   INPUT:
%
%       - fun: function handle
%       - args_in: input arguments list of the function
%       - arg_index: index in the argument list args_in which must be changed
%       - arg_range: list of values to be calculated for the input argument arg_index, length(arg_range) = number of times a calculation must be performed
%       - nargout_in: number of output arguments in the parent function
%
%   OUTPUT:
%
%       - results: output arguments list of the function
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
for j_range = 1:length(arg_range),
    %
    outcmd = '';
    %
    for j_nargout = 1:nargout_in,
        %
        if j_nargout == 1,
            outcmd = '[';
        end
        %
        outcmd = [outcmd,'arg_out{',int2str(j_nargout),',',int2str(j_range),'}'];
        %
        if j_nargout == nargout_in,
            outcmd = [outcmd,'] = '];
        else
            outcmd = [outcmd,','];
        end
    end
    %
    cmd = [outcmd,'feval(fun,args_in{:});'];   
    %
    args_in{arg_index} = arg_range{j_range};
    %
    eval(cmd);
end
%
results = cell(1,nargout_in);
%
for j_nargout = 1:nargout_in,
    results{j_nargout} = reshape(arg_out(j_nargout,:),length(arg_range),1);
end
