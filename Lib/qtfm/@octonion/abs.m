function a = abs(o)
% ABS Absolute value, or modulus, of an octonion.
% (Octonion overloading of standard Matlab function.)

% Copyright © 2011 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(1, 1), nargoutchk(0, 1) 

a = sqrt(normo(o)); % It might be better to put the code from normo inline
                    % here for speed, eventually.

end

% $Id: abs.m,v 1.2 2013/04/04 17:20:07 sangwine Exp $
