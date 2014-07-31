function S = s(o)
% S Scalar part of a full octonion.

% Copyright © 2011 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1)

S = s(o.a);

end
% $Id: s.m,v 1.2 2013/04/04 17:20:07 sangwine Exp $
