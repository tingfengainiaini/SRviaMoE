function tf = ispure(o)
% ISPURE   Tests whether an octonion is pure.
% tf = ispure(o) returns 1 if o has no scalar part, 0 otherwise. Note that
% if o has a scalar part which is zero, ispure(o) returns 1. Also,
% ispure(o) returns 1 if o is an empty octonion, since it has no scalar
% part.

% Copyright � 2011 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1)

tf = ispure(o.a);
assert(~ispure(o.b)); % This is unconditional because the second quaternion
                      % component must always be a full quaternion.
% $Id: ispure.m,v 1.2 2013/04/04 17:20:07 sangwine Exp $
