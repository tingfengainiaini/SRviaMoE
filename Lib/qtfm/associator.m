function d = associator(a, b, c)
% ASSOCIATOR Computes the associator of the three parameters.

% Reference:
%
% Richard D. Schafer, 'An Introduction to Non-Associative Algebras',
% Academic Press, 1966. Page 13.

% Copyright © 2013 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(3, 3), nargoutchk(0, 1)

d = (a * b) * c - a * (b * c);

if isa(c, 'quaternion') || isa(c, 'octonion')
    d = vector(d); % The result is pure by definition.
end

end

% $Id: associator.m,v 1.2 2013/04/03 16:18:11 sangwine Exp $
