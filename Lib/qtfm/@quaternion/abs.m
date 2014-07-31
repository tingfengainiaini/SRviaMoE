function a = abs(q)
% ABS Absolute value, or modulus, of a quaternion.
% (Quaternion overloading of standard Matlab function.)

% Copyright © 2005 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1) 

% Because abs is so heavily used, the code here is inline. It is copied
% from the function normq, based on the former private function modsquared.

if isempty(q.w)
    a = sqrt(         q.x.^2 + q.y.^2 + q.z.^2);
else
    a = sqrt(q.w.^2 + q.x.^2 + q.y.^2 + q.z.^2);
end

end

% $Id: abs.m,v 1.4 2013/04/04 17:20:07 sangwine Exp $
