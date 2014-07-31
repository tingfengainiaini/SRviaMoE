function tf = ispure(q)
% ISPURE   Tests whether a quaternion is pure.
% tf = ispure(q) returns 1 if q has no scalar part, 0 otherwise. Note that
% if q has a scalar part which is zero, ispure(q) returns 1. Also,
% ispure(q) returns 1 if q is an empty quaternion, since it has no scalar
% part.

% Copyright © 2005, 2010 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1)

tf = isempty(q.w);

% $Id: ispure.m,v 1.5 2013/04/04 17:20:07 sangwine Exp $

