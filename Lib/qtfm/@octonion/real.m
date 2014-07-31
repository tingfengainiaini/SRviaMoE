function p = real(o)
% REAL   Real part of an octonion.
% (Octonion overloading of standard Matlab function.)
%
% This function returns the octonion that is the real part of o.

% Copyright © 2011 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1)

p = overload(mfilename, o);

% $Id: real.m,v 1.2 2013/04/04 17:20:08 sangwine Exp $
