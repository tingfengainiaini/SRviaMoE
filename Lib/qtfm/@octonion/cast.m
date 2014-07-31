function b = cast(q, newclass)
% CAST  Cast quaternion variable to different data type.
% (Octonion overloading of standard Matlab function.)

% Copyright © 2011 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(2, 2), nargoutchk(0, 1)

if ~ischar(newclass)
    error('Second parameter must be a string.')
end

b = overload(mfilename, q, newclass);

% $Id: cast.m,v 1.2 2013/04/04 17:20:07 sangwine Exp $
