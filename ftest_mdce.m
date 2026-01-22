% 
% /////////////////////////////////////////
%
% Software name : MatRemote, part of LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function [a,b] = ftest_mdce(c,d,force_error)
%
if c == 5 && force_error >= 1,
    if force_error >= 2 || (~strcmp(getenv('HOSTNAME'),'p-cephee15.cluster') && ~strcmp(getenv('HOSTNAME'),'p-cephee16.cluster'))%batch run
        error('error forced inside ftest')
    end
end
%
pause(10)
%
a = c+d;
b = c-d;
%
