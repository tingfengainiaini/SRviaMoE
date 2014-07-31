function x = s(q)
% S(Q) Scalar part of a full quaternion.

% Copyright � 2005, 2010 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

% narginchk(1, 1), nargoutchk(0, 1)

x = q.w;

% $Id: s.m,v 1.6 2013/04/04 17:20:07 sangwine Exp $
