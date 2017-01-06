function [urban] = read_mit_urban_data(data_file)

% {"QS Upperclass": "4.31", "Error in QS Upperclass": "0.47", ...
%  "Lon": "14.309", "File_Location": "/images/id_1867_400_300.jpg", ...
%  "Pitch": "NULL", "Error in QS Unique": "0.23", "Heading": "NULL", ...
%  "City": "Linz", "QS Unique": "3.39", "QS Safer": "4.31", ...
%  "Lat": "48.271", "ID": "1867", "Error in QS Safer": "0.53"}

f = fopen(data_file);
str = fscanf(f, '%c', inf);

urban.qs_safer = regexp(str, '"QS Safer": "[^"]*"', 'match');
urban.qs_safer = cellfun(@(x){x(length('"QS Safer": "') + 1: end - 1)}, urban.qs_safer);
urban.qs_safer_error = regexp(str, '"Error in QS Safer": "[^"]*"', 'match');
urban.qs_safer_error = cellfun(@(x){x(length('"Error in QS Safer": "') + 1: end - 1)}, urban.qs_safer_error);

urban.qs_unique = regexp(str, '"QS Unique": "[^"]*"', 'match');
urban.qs_unique = cellfun(@(x){x(length('"QS Unique": "') + 1: end - 1)}, urban.qs_unique);

urban.qs_upperclass = regexp(str, '"QS Upperclass": "[^"]*"', 'match');
urban.qs_upperclass = cellfun(@(x){x(length('"QS Upperclass": "') + 1: end - 1)}, urban.qs_upperclass);

urban.latitudes = regexp(str, '"Lat": "[\-0-9\.]+"', 'match');
urban.latitudes = cellfun(@(x){x(length('"Lat": "') + 1: end - 1)}, urban.latitudes);

urban.longitudes = regexp(str, '"Lon": "[\-0-9\.]+"', 'match');
urban.longitudes = cellfun(@(x){x(length('"Lon": "') + 1: end - 1)}, urban.longitudes);

urban.pitches = regexp(str, '"Pitch": "[^"]*"', 'match');
urban.pitches = cellfun(@(x){x(length('"Pitch": "') + 1: end - 1)}, urban.pitches);

urban.headings = regexp(str, '"Heading": "[^"]*"', 'match');
urban.headings = cellfun(@(x){x(length('"Heading": "') + 1: end - 1)}, urban.headings);

urban.cities = regexp(str, '"City": "[^"]*"', 'match');
urban.cities = cellfun(@(x){x(length('"City": "') + 1: end - 1)}, urban.cities);

urban.ids = regexp(str, '"ID": "[^"]*"', 'match');
urban.ids = cellfun(@(x){x(length('"ID": "') + 1: end - 1)}, urban.ids);

end