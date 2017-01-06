% Read the MIT Media Lab Place Pulse Dataset and download images.

%homedir = '/mnt/raid/data/vicente/urban_release';
homedir = pwd;

% Data file from the Place Pulse project (MIT Media Lab).
% You need to download this file from
% http://pulse.media.mit.edu/data/
data_file = [homedir '/data/consolidated_data_jsonformatted.json'];
out_dir = [homedir '/data/images'];
image_width = 640; image_height = 420;
if ~exist(out_dir, 'dir'), mkdir(out_dir); end

% Load json file and read data. 
urban = read_place_pulse_urban_data(data_file);

% Now try downloading images from Google Street View.
% size_str = '400x300'; latlong_str = '48.271,14.309';
% pitch = 'NULL'; heading = 'NULL'; fov = 'NULL'
% Get an API key from Google APIs
api_key = 'QaGfyl6Cmb-gO5MPXUepXHL0S3s=';
%api_url = ['http://maps.googleapis.com/maps/api/streetview?' ...
%          'size=%s&location=%s&sensor=false&key=%s' ...
%          '&heading=%s&fov=%s&pitch=%s'];
streetViewPath = 'https://maps.googleapis.com/maps/api/streetview?size=400x300';
streetViewPath = strcat(streetViewPath,'&location=',im.Lat,',',im.Lon);
streetViewPath = strcat(streetViewPath,'&heading=',im.Heading);
streetViewPath = strcat(streetViewPath,'&pitch=',im.Pitch);
streetViewPath = strcat(streetViewPath,'&key=',key);
api_url = [streetViewPath]; 

% Download images from street view.
for i = randperm(length(urban.cities))%1 : length(urban.cities)
    out_filename = sprintf('%s/id_%s_%d_%d.jpg', out_dir, urban.ids{i}, image_width, image_height);
    if ~exist(out_filename, 'file')
        fprintf('Downloading image %d (city = %s)\r', i, urban.cities{i}); 
        size_str = sprintf('%dx%d', image_width, image_height);
        latlong_str = sprintf('%s,%s', urban.latitudes{i}, urban.longitudes{i});
        heading_str = urban.headings{i}; pitch_str = urban.pitches{i};
        fov_str = 'NULL';
        request_url = sprintf(api_url, size_str, latlong_str, api_key, ...
                              heading_str, fov_str, pitch_str);
        imdata = imread(request_url);
        imwrite(imdata, out_filename);
        pause(0.1);
    end
end

% Now present images on a webpage.
view_dir = [homedir '/output/view'];
if ~exist(view_dir, 'dir'), mkdir(view_dir); end
cities = unique(urban.cities);
safety_scores = cellfun(@(x)str2double(x), urban.qs_safer);
for i = 1 : length(cities)    
    c_inds = find(strcmp(cities{i}, urban.cities));
    c_safety_scores = safety_scores(c_inds);
    [sc, s_inds] = sort(c_safety_scores, 'descend');
    
    results_per_page = 50;
    n_pages = ceil(length(c_inds) / results_per_page);
    counter = 1; nav_str = '';
    for ii = 1 : n_pages
        nav_str = sprintf('%s | <a href="p_%s_%d.html">%02d</a>', nav_str, regexprep(lower(cities{i}), ' ', '_'), ii, ii);
    end
    for ii = 1 : n_pages
        f = fopen(sprintf('%s/p_%s_%d.html', view_dir, ...
                          regexprep(lower(cities{i}), ' ', '_'), ii), 'w');
        fprintf(f, '<html><body><h2>%s</h2>%s<table>', cities{i}, nav_str);
        for j = 1 + (ii - 1) * results_per_page : min(length(c_inds), ii * results_per_page)
            if ~isnan(sc(j))
                fprintf(f, '<tr><td>%d</td>', j);
                fprintf(f, '<td><img src="../mit_images_640x420/id_%s_%d_%d.jpg" height="207"/></td>', ...
                            urban.ids{c_inds(s_inds(j))}, image_width, image_height);
                fprintf(f, '<td>%.2f</td></tr>', sc(j));
            end
            counter = counter + 1;
        end
        fprintf(f, '</table>%s</body></html>', nav_str);
        fclose(f);
    end
end



                  
