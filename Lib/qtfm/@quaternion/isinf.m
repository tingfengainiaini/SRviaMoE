function tf = isinf(A)
% ISINF  True for infinite elements.  
% (Quaternion overloading of standard Matlab function.)

% Copyright © 2005, 2010 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1)

if isempty(A.w)
    tf = isinf(A.x) | isinf(A.y) | isinf(A.z);
else
    tf = isinf(A.w) | isinf(vee(A));
end

% $Id: isinf.m,v 1.7 2013/04/04 17:20:07 sangwine Exp $
