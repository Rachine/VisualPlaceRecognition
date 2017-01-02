% Base class for the dataset specification
%
% To make your own dataset (see dbPitts.m for an easy example):
% 1. Inherit from dbBase
% 2. In the constructor, set a short identifier of the dataset in db.name
% 3. Save a matlab structure called dbStruct to <paths.dsetSpecDir>/<db.name>.mat, which contains:
%   - dbImageFns: cell array of database image file names relative to dataset root
%   - qImageFns: cell array of query image file names relative to dataset root
%   - utmDb:  2x <number_of_database_images>, containing (x,y) UTM coordinates for each database image
%   - We are going to keep (x,y) = (lat,lon) for convenience, no conversion
%   done
%   - utmQ:  2x <number_of_query_images>, containing (x,y) UTM coordinates for each query image
%   - posDistThr: distance in meters which defines potential positives
%   - nonTrivPosDistSqThr: squared distance in meters which defines the potential positives used for training
%   - safetyDb: cell array of safety class scores for each database image
%   - wealthDb: cell array of wealth scores for each database image
%   - safetyLabels: cell array of binary labels indicating for each image if the place is safe or not
%   - wealthLabels: cell array of binary labels indicating for each image if the place is wealthy or not
%   - safetyStdScores, wealthStdScores: standardized scores for the regression 
% 4. In the constructor, set db.dbPath and db.qPath specifying the root locations of database and query images, respectively. Presumably, like in dbPitts.m, you want to load these from a configuration file. The variables should be such that [db.dbPath, dbImageFns{i}] and [db.qPath, qImageFns{i}] form the full paths to database/query images.
% 5. Finally: call db.dbLoad(); at the end of the constructor
% 6. Optionally: you can override the methods for some more functionality, e.g. for Tokyo Time Machine we modify the fuction nontrivialPosQ which gets all potential positives for a query that are non-trivial (don't come from the same panorama). For Time Machine data, we also make sure that the nontrivial potential positives are taken at different times than the query panorama (for generalization, c.f. our NetVLAD paper). There was no need for this for the Pittsburgh dataset as the query and the database sets were taken at different times, but for TokyoTM the query set is constructed out of the database set. Furthermore, one can also supplu 'nnSearchPostprocess' which filters search results (used in testCore.m), e.g. it is done for Tokyo 24/7 to follow the standard test procedure for this dataset (i.e. perform very simple non-max suppression)



classdef dbBase < handle
    
    properties
        name
        
        dbPath, dbImageFns, utmDb,
        safetyDb,wealthDb,
        numImages,
        safetyLabels,wealthLabels,
        safetyStdScores, wealthStdScores
        
    end
    
    methods
    
        function dbLoad(db, delta)
            
            % load custom information
            
            paths= localPaths();
            dbFn= sprintf('%s/%s.mat', paths.dsetSpecDir, db.name);
            
            if exist(dbFn, 'file')
                load(dbFn, 'dbStruct');
                for propName= fieldnames(dbStruct)'
                    if ~ismember(propName{1}, {'cp'})
                        db.(propName{1})= dbStruct.(propName{1});
                    end
                end
                clear dbStruct propName;
            else
                error('Download the database file (%s.mat) and set the correct dsetSpecDir in localPaths.m', db.name);
            end
            
            % generate other useful data
            
            db.numImages= length(db.dbImageFns);
            assert( size(db.utmDb, 2) == db.numImages );
            
            db.safetyLabels = db.generateLabels('safety', delta) ;
            db.wealthLabels = db.generateLabels('wealth', delta) ;
            
            db.safetyStdScores = db.generateStdScores('safety') ;
            db.wealthStdScores = db.generateStdScores('wealth') ;
            
            % make paths absolute just in case (e.g. vl_imreadjpeg needs absolute path)
            
            for propName= properties(db)'
                s= db.(propName{1});
                if isstr(s)
                    db.(propName{1})= relja_expandUser(s);
                end
            end
            
        end
        
        function [labels] = generateLabels(db, type, delta)
            % initialization Safety Labels
            labels = zeros(1,db.numImages) ;
            % type must be 'safety' or 'wealth'
            scores = db.(strcat(type, 'Db')) ;
            % searching the scores in the top and bottom delta% 
            sortedScores= sort(scores, 'descend') ;
            deltaRank = floor(delta*db.numImages / 100) ;
            topScores = sortedScores(1:deltaRank) ;
            labels(ismember(scores, topScores)) = 1 ;
            bottomScores = sortedScores((end-deltaRank):end);
            labels(ismember(scores, bottomScores)) = -1 ;
        end
        
        function [stdScores] = generateStdScores(db, type)
            % 'type' must be 'safety' or 'wealth'
            rawScores = db.(strcat(type, 'Db')) ;
            % Returns the standardized scores for regression
            stdScores = zscore(rawScores) ;
        end
    
    end

end

