function t = ctranspose(a)
% '   Octonion conjugate transpose.
% (Octonion overloading of standard Matlab function.)

% Copyright � 2012 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1) 

t = conj(transpose(a));

% $Id: ctranspose.m,v 1.2 2013/04/04 17:20:07 sangwine Exp $
