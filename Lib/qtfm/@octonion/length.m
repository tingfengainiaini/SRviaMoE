function n = length(o)
% LENGTH   Length of vector.
% (Octonion overloading of standard Matlab function.)

% Copyright © 2011 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1)

n = length(o.a); % This calls the quaternion length function.

% $Id: length.m,v 1.2 2013/04/04 17:20:07 sangwine Exp $
