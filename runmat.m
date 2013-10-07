function mat_output = runmat(mat_input)
%
varargout = cell(1,mat_input.nargout-1);
%
[varargout{:}] = feval(mat_input.fun,mat_input.args_in{:});
%
mat_output.varargout = varargout;