function t = transpose(a)
% .'  Transpose.
% (Octonion overloading of standard Matlab function.)

% Copyright © 2011 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1) 

t = overload(mfilename, a);

% $Id: transpose.m,v 1.2 2013/04/04 17:20:08 sangwine Exp $
