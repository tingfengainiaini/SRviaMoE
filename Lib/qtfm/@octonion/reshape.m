function a = reshape(q, varargin)
% RESHAPE Change size.
% (Octonion overloading of standard Matlab function.)

% Copyright © 2013 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

nargoutchk(0, 1)

a = overload(mfilename, q, varargin{:});

% $Id: reshape.m,v 1.1 2013/05/23 14:15:14 sangwine Exp $
