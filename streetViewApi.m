function [dat] = streetViewApi(key,folder,jsonPath,city)
    dat=loadjson(['data' filesep jsonPath]);
    num_images = size(dat,2);
    for index = 1:num_images
        image = dat(index);
        im = image{1};
        if strcmp(im.City, city)
            streetViewPath = 'https://maps.googleapis.com/maps/api/streetview?size=400x300';
            streetViewPath = strcat(streetViewPath,'&location=',im.Lat,',',im.Lon);
            streetViewPath = strcat(streetViewPath,'&heading=',im.Heading);
            streetViewPath = strcat(streetViewPath,'&pitch=',im.Pitch);
            streetViewPath = strcat(streetViewPath,'&key=',key);
            street_im = imread(streetViewPath,'jpg');
            imwrite(street_im,strcat(folder,im.File_Location),'jpg');
        end
    end
end
