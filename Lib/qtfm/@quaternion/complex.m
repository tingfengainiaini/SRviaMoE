function q = complex(a,b)
% COMPLEX Construct a complex quaternion from real quaternions.
% (Quaternion overloading of standard Matlab function.)

% Copyright © 2006 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(2, 2), nargoutchk(0, 1) 

if ~isreal(a) || ~isreal(b)
    error('Arguments must be real.')
end

q = a + b .* complex(0,1);

% Implementation note: we use complex(0,1) and not i, because
% it is possible to create a variable named i which hides the
% built-in Matlab function of the same name.

% $Id: complex.m,v 1.5 2013/04/04 17:20:07 sangwine Exp $
