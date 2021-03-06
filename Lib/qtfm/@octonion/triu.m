function d = triu(v, k)
% TRIU Extract upper triangular part.
% (Octonion overloading of standard Matlab function.)

% Copyright � 2012 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 2), nargoutchk(0, 1) 

if nargin == 1
    d = overload(mfilename, v);
else
    d = overload(mfilename, v, k);
end

% $Id: triu.m,v 1.2 2013/04/04 17:20:07 sangwine Exp $
