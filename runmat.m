function mat_output = runmat(mat_input)
%
varargout = cell(1,mat_input.nargout-1);
%
if isfield(mat_input,'funstr'),% function string was passed on to worker
    %
    tmpfilestr = [func2str(mat_input.fun),'_',mat_input.timeid];
    tmpfilename = [tmpfilestr,'.m'];
    %
    diary(tmpfilename);
    %
    disp(mat_input.funstr);
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
    fun = mat_input.fun;
end
%
[varargout{:}] = feval(fun,mat_input.args_in{:});
%
mat_output.varargout = varargout;
%
if isfield(mat_input,'funstr'),
    delete(tmpfilename);
end