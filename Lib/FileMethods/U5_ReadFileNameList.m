%Chih-Yuan Yang
%03/07/13
function filenamelist = U5_ReadFileNameList( fn_list )
    fid = fopen(fn_list,'r');
    C = textscan(fid,'%d %s\n');
    fclose(fid);
    filenamelist = C{2};
end

