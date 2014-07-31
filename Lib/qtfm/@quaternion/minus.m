function q = minus(l, r)
% -   Minus.
% (Quaternion overloading of standard Matlab function.)

% Copyright © 2005 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(2, 2), nargoutchk(0, 1) 

q = plus(l, -r); % We use uminus to negate the right argument.

% $Id: minus.m,v 1.3 2013/04/04 17:20:07 sangwine Exp $

