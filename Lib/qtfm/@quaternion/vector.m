function p = vector(q)
% VECTOR   Quaternion vector part. Synonym of V.

% Copyright © 2005, 2010 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1)

p = q; p.w = []; % Copy and then set the scalar part to empty.

% $Id: vector.m,v 1.6 2013/04/04 17:20:07 sangwine Exp $
