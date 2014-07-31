function a = reshape(q, varargin)
% RESHAPE Change size.
% (Quaternion overloading of standard Matlab function.)

% Copyright © 2008 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

nargoutchk(0, 1)

a = overload(mfilename, q, varargin{:});

% $Id: reshape.m,v 1.6 2013/04/04 17:20:07 sangwine Exp $

