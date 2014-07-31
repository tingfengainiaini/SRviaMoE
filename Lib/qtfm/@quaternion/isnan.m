function tf = isnan(A)
% ISNAN  True for Not-a-Number.
% (Quaternion overloading of standard Matlab function.)

% Copyright © 2005, 2010 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1)

if isempty(A.w)
    tf = isnan(A.x) | isnan(A.y) | isnan(A.z);
else
    tf = isnan(A.w) | isnan(vee(A));
end

% $Id: isnan.m,v 1.7 2013/04/04 17:20:07 sangwine Exp $
