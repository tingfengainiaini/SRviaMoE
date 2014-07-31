function d = scalar_product(a, b)
% SCALAR_PRODUCT  Octonion scalar product.
% The scalar (dot) product of two octonions is the sum of the products of
% the eight components of the two octonions.

% Copyright � 2012 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

narginchk(2, 2), nargoutchk(0, 1)

if ~isa(a, 'octonion') || ~isa(b, 'octonion')
    error('Scalar product is not defined for an octonion and a non-octonion.')
end

d = scalar_product(a.a, b.a) + scalar_product(a.b, b.b);

% This function will work only for arrays of the same size (same limitation
% as the quaternion function which is called twice on the previous line).

% $Id: scalar_product.m,v 1.2 2013/04/04 17:20:08 sangwine Exp $

end
