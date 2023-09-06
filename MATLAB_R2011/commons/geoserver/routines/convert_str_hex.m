function str_converted = convert_str_hex(str)
% encode a string to a url encoded version. This is particulary useful to encode
% parts of a geoserver CQL filter

str = strrep((str) ,'>'  , '%3E');
str = strrep((str) ,'='  , '%3D');
str = strrep((str) ,'<'  , '%3C');
str = strrep((str) ,':'  , '%3A');
str = strrep((str) ,' '  , '%20');
str = strrep((str) ,','  , '%2C');

str_converted = str;

end