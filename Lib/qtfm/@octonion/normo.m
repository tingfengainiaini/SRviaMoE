function a = normo(o)
% NORMO Norm of an octonion, the sum of the squares of the components.

% Copyright © 2011 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1) 

a = normq(o.a) + normq(o.b);

% $Id: normo.m,v 1.2 2013/04/04 17:20:08 sangwine Exp $
