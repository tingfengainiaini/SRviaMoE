function c = commutator(a, b)
% COMMUTATOR Computes the commutator of the two parameters.

% Copyright © 2013 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(2, 2), nargoutchk(0, 1)

c = a * b - b * a;

if isa(c, 'quaternion') || isa(c, 'octonion')
    c = vector(c); % The result is pure by definition.
end

end

% $Id: commutator.m,v 1.2 2013/04/03 16:18:11 sangwine Exp $
