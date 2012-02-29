function [flag,varargout] = parcomputing(fun,args_in,arg_index,arg_range,scheduler)
% LUKE - Parallel computing of the loop
%
%   parfor computing of the loop
%
%   INPUT:
%
%       - fun_handle: function handle
%       - args_in: input arguments list of the function {1,nargin}
%       - arg_index: index in the argument list args_in which must be changed [1,1]
%       - arg_range: list of values for the input argument arg_index [1,nrange]
%           => nrange = length(arg_range) = number of iterations 
%       - scheduler: scheduler information
%
%   OUTPUT:
%
%       - flag: status of the computation : scheduler.mode (OK with parcomputing) or -2 (failed) [1,nrange]
%       - varargout: output arguments list of the function {1,nargout-1}.
%           => Each element is a list of size {nrange,1}
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
nargout_in = nargout - 1;
nrange = length(arg_range);
varargout_array = cell(1,nrange);
flag = scheduler.mode*ones(1,nrange);
configuration = findResource('scheduler','configuration',scheduler.configuration);
scheduler.clustersize = min([scheduler.clustersize,configuration.ClusterSize]);
%
%try
    matlabpool('open',scheduler.configuration,scheduler.clustersize);
%catch
%    info_dke_yp(2,['WARNING: calculations are performed on a single processor since the job scheduler is not available (MatLab version too old, limited number of licenses, dkepath inconsistently set...) for ',func2str(fun),'.m (mode 1).']);
%end
%
parfor j_range = 1:nrange,
    %
    args_loc = args_in;
    args_loc{arg_index} = arg_range{j_range};
    varargout_loc = cell(1,nargout_in);
    try
        [varargout_loc{:}] = feval(fun,args_loc{:});
    catch me_seq
        disp(['Error executing the iteration ',int2str(j_range),'/',int2str(nrange),'.']);
        disp(['===> Error : ',getReport(me_seq)]);
        flag(j_range) = -2;
    end
    varargout_array{j_range} = varargout_loc;
    %
end
%
varargout = cell(1,nargout_in);
%
%[varargout{:}] = deal(cell(N_range,1)); keep this line as an example of use of the function deal
%
parfor j_argout = 1:nargout_in,
    %
    varargout{j_argout} = cell(nrange,1);
    for j_range = 1:nrange,
        varargout{j_argout}{j_range} = varargout_array{j_range}{j_argout};
    end
    %
end
%
matlabpool close force
%
      