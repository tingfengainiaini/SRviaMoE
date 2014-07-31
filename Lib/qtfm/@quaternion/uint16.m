function d = uint16(~)
% UINT16 Convert to unsigned 16-bit integer (obsolete).
% (Quaternion overloading of standard Matlab function.)

% Copyright © 2006 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

error(['Conversion to uint16 from quaternion is not possible. ',...
       'Try cast(q, ''uint16'')'])

% Note: this function was replaced from version 0.9 with the convert
% function, because it is incorrect to provide a conversion function
% that returns a quaternion result.

% $Id: uint16.m,v 1.5 2013/04/04 16:54:28 sangwine Exp $
