function b = full(q)
% FULL  Convert sparse matrix to full matrix.
% (Octonion overloading of standard Matlab function.)

% Copyright © 2013 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1)

b = overload(mfilename, q);

% $Id: full.m,v 1.2 2013/04/04 17:20:07 sangwine Exp $
