function B = ipermute(A, order)
% IPERMUTE Inverse permute dimensions of N-D array
% (Quaternion overloading of standard Matlab function.)

% Copyright © 2008 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(2, 2), nargoutchk(0, 1)

B = overload(mfilename, A, order);

% $Id: ipermute.m,v 1.4 2013/04/04 17:20:07 sangwine Exp $

