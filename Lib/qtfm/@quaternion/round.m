function a = round(q)
% ROUND Round towards nearest integer.
% (Quaternion overloading of standard Matlab function.)

% Copyright © 2006 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1) 

a = overload(mfilename, q);

% $Id: round.m,v 1.5 2013/04/04 17:20:07 sangwine Exp $

