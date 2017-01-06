function dbStruct=buildDatasetSpec(dataset_folder,jsonPath,city)
% Function to build dataset according to spec from NetVlad
% Command to run for NY for instance: 
% buildDatasetSpec(strcat(pwd,'/datasets/datasets'),strcat(pwd,'/Data/consolidated_data_jsonformatted.json'),'NY')
    dat=loadjson([jsonPath]); 
    num_images = size(dat,2);
    dbStruct = struct('dbImageFns',[],'utmDb',[], ...
        'numImages',[],'safetyDb',[],'wealthDb',[]);
    num_city = 0;
    if strcmp(city,'NY')
        city = 'New York City';
    end
    for index = 1:num_images
        image = dat(index);
        im = image{1};
        if strcmp(im.City, city) && ~strcmp(im.QS_0x20_Safer, '#VALUE!') && ~strcmp(im.QS_0x20_Upperclass,'#VALUE!')
            num_city = num_city +1;
        end
    end
    dbStruct.numImages = num_city;
    dbStruct.dbImageFns = cell(num_city,1);
    dbStruct.utmDb = zeros(2,num_city);
    dbStruct.safetyDb = zeros(1,num_city);
    dbStruct.wealthDb = zeros(1,num_city);
    indice = 0;
    for index = 1:num_images
        image = dat(index);
        im = image{1};
        if strcmp(im.City, city) && ~strcmp(im.QS_0x20_Safer, '#VALUE!') && ~strcmp(im.QS_0x20_Upperclass,'#VALUE!')
            indice = indice + 1;
            dbStruct.dbImageFns{indice} = im.File_Location;
            dbStruct.utmDb(:,indice) = sscanf([im.Lat,im.Lon],'%f');
            dbStruct.safetyDb(indice) =  sscanf(im.QS_0x20_Safer,'%f');
            dbStruct.wealthDb(indice) =  sscanf(im.QS_0x20_Upperclass,'%f');
        end
    end
    if strcmp(city,'New York City')
        city = 'NY';
    end
    save(strcat(dataset_folder,'/',city,'.mat'),'dbStruct');
end
