classdef dbBoston < dbBase
    
    methods
    
        function db= dbBoston()
            db.name= sprintf('Boston');
            
            paths= localPaths();
            dbRoot= paths.dsetRootBoston;
            db.dbPath= [dbRoot];
%             db.qPath= [dbRoot, 'query/'];
            
            db.dbLoad();
        end
        
        function [ids, ds]= nnSearchPostprocess(db, searcher, iQuery, nTop)
            % perform non-max suppression like in Torii et al. CVPR 2015
            [ids, ds]= searcher(iQuery, nTop*12); % 12 cutouts per panorama
            [~, uniqInd, ~]= unique( floor((ids-1)/12) ,'stable');
            uniqInd= uniqInd(1:min(end,nTop));
            ids= ids(uniqInd);
            ds= ds(uniqInd);
        end
        
    end
    
end

