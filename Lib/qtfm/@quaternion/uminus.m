function u = uminus(a)
% -  Unary minus.
% (Quaternion overloading of standard Matlab function.)

% Copyright © 2005, 2010 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1) 

u = a;
if ~isempty(u.w)
    u.w = -u.w;
end
u.x = -u.x;
u.y = -u.y;
u.z = -u.z;

% $Id: uminus.m,v 1.7 2013/04/04 17:20:07 sangwine Exp $
