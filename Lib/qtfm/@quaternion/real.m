function p = real(q)
% REAL   Real part of a quaternion.
% (Quaternion overloading of standard Matlab function.)
%
% This function returns the quaternion that is the real part of q.

% Copyright © 2005 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1)

p = overload(mfilename, q);

% $Id: real.m,v 1.7 2013/04/04 17:20:06 sangwine Exp $
