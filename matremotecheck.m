function [res,txt] = matremotecheck(remote,job,mask)
%
% This function checks whether an instance with standard expression 'mask'
% can be found in the remote directory 'job.remotedatapath,job.batch_dir'
%
% If so, the timestamp (mtime) of the file is returned.
%
remotecmd = ['ls ',job.remotedatapath,job.batch_dir];
%
[res,txt] = matremotecmd(remote,job,remotecmd);
%
if ~res,
    itxt = strfind(txt,mask);
    if isempty(itxt),
        res = 1;
        txt = ['Expression ''',mask,''' not found in filelist under remote directory ''',job.remotedatapath,job.batch_dir,''''];
    else
        %
        if length(itxt) > 1,
            disp(' ')
            disp(['WARNING : There are more than one instances of expression ''',mask,''' in filelist under remote directory ''',job.remotedatapath,job.batch_dir,''''])
            disp( 'WARNING : First instance selected.')
            disp(' ')
            itxt = itxt(1);
        end
        %
        filename = txt(itxt+(0:min([find(double(txt(itxt:end)) == 32 | double(txt(itxt:end)) == 10)-1,length(txt)+1-itxt])-1));
        %
        remotecommand_path_python2 = 'which python2';
        %
        [res_remotepath_python2,remotepath_python2] = matremotecmd(remote,job,remotecommand_path_python2);
        %
        if res_remotepath_python2 == 1 %check local
            %
            [res_remotepath_python2,remotepath_python2] = unix(remotecommand_path_python2);
            %
        end
        %
        if isempty(remotepath_python2) || res_remotepath_python2 == 1
            %
            disp('ERROR : path to python2 is unknown on the remote computer. This problem must be fixed.');
            return;
            %
        else
            %
            remotepath_python2 = deblank(remotepath_python2);
            remotecmd = [remotepath_python2,' -c "import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))" %Y%m%d%H%M%S ',job.remotedatapath,job.batch_dir,filename];
            [res,txt] = matremotecmd(remote,job,remotecmd);%Command not compatible with python3
            %
        end
        %
    end
end
