function [a,b] = ftest_mdce(c,d,force_error)
%
if c == 5 && force_error >= 1,
    if force_error >= 2 || (~strcmp(getenv('HOSTNAME'),'p-cephee15.cluster') && ~strcmp(getenv('HOSTNAME'),'p-cephee16.cluster'))%batch run
        error('error forced inside ftest')
    end
end
%
a = c+d;
b = c-d;
%
