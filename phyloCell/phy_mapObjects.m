%mapping objects
%objecti=objects of actual image
%objecti_1= objects of image i-1
%objecti_2=objects of image i-2
%output : objectOut=object i with the right numbers
function objectOut=phy_mapObjects(distanceParameter,objecti,objecti_1,objecti_2)

persistent lastObjNumber;

objectOut=objecti;

x=[];
y=[];
x1=[];
y1=[];
x2=[];
y2=[];
indexi=[];   %the objects  non deleted in the image i
indexi_1=[];
indexi_2=[];
if nargin==2 % first image objects map
    lastObjNumber=0; % the total nmber of marquers
    for k = 1:length(objecti)
        if ~isempty(objectOut(k).x)
            if objectOut(k).n~=0  %check if already mapped
                lastObjNumber=max(objectOut(k).n,lastObjNumber); % lastObjNumber is the maximum label of the marquers
            else
                lastObjNumber=lastObjNumber+1;  % if not mapped each new object will have a new label
                objectOut(k).n=lastObjNumber;
            end
        end
    end
    
    
elseif nargin>=3 % if mapping bewtwen image i and image i-1
    
    for l=1:size(objecti,2)
        if objecti(l).ox~=0
         
           % a=objecti(l)
            x(end+1)=objecti(l).ox;   %make mapping betwen 2 set of points (the object centres) (x,y)image i
            y(end+1)=objecti(l).oy;
            indexi(end+1)=l;
        end
    end
    
    for m=1:size(objecti_1,2)
        if objecti_1(m).ox~=0
            x1(end+1)=objecti_1(m).ox; %make mapping betwen 2 set of points (the object centres) (x1,y1)image i-1
            y1(end+1)=objecti_1(m).oy;
            indexi_1(end+1)=m;
        end
        if (nargin>=4) % if 3 arguments (from 3 images)
           % m,length(objecti_2)
           if length(objecti_2)>=m
            if objecti_2(m).ox~=0
                x2(end+1)=objecti_2(m).ox;    %make mapping betwen 2 set of points (the object centres) (x2,y2)image i-2
                y2(end+1)=objecti_2(m).oy;
                indexi_2(end+1)=m;
            end
           end
        end
    end
    
    if (nargin>=2) && isempty(x)
        return
    end
    if (nargin>=3) && isempty(x1)
        return
    end
    if (nargin>=4) && isempty(x2)
        return
    end
    
   % x1,x
    
    if min([size(x1,2),size(x,2)])<3 %when they are fewer than 3 points not using the initialisation
        %[R0,T0,iclosest_1,dist_1,Error0]=phy_icp([x1; y1],[x; y],10,2,[3,min([size(x1,2),size(x,2)])],1,0);
       % 'easy'
        [iclosest_1,dist_1]=phy_icp2([x1; y1],[x;y]);
        %function [TR, TT, iclosest,distance,ERROR] = phy_icp(model,data,max_iter,min_iter,fitting,thres,init_flag,tes_flag,refpnt)
    else
        % phy_icp(model,data,max_iter,min_iter,fitting,thres,init_flag,tes_flag)
        %[R0,T0,iclosest_1,dist_1,Error0]=phy_icp([x1; y1],[x; y],10,2,[3,min([size(x1,2),size(x,2)])],1,1);
        
        %the final 1/0 do or not an initialisation by translation (the same median)
        %iclosest_1 is the index of the closest point in image i-1
        %dist_1 is the distance after icp to the closest point in image i-1
       % 'tough'
        [R0,T0,iclosest0,dist0,Error0]=phy_icp([x1; y1],[x; y],10,2,[3,min([size(x1,2),size(x,2)])],0.01,0);
        [R1,T1,iclosest1,dist1,Error1]=phy_icp([x1; y1],[x; y],10,2,[3,min([size(x1,2),size(x,2)])],0.01,1);

        
        if Error0<=Error1   %compare the 2 errors (with/without initialisation) and chose the smalest one
            iclosest_1=iclosest0;   %iclosest_1 is the index of the closest point in image i-1
            dist_1=dist0;    %dist_1 is the distance after icp to the closest point in image i-1
        else
            iclosest_1=iclosest1;   %iclosest_1 is the index of the closest point in image i-1
            dist_1=dist1;   %dist_1 is the distance after icp to the closest point in image i-1
        end
        
        
    end
    
    dist_min=dist_1;    % if tey are not 3 images in imput, the distance to the closest point is the final distance dist_min
    for i=1:length(x)
        n(i)=objecti_1(indexi_1(iclosest_1(i))).n;  % n is an array of labels of best matchimg point in image i-1
    end;
    
    
    if (nargin>=4) % if mapping with image i-1 and i-2
        if min([size(x2,2),size(x,2)])<3 %when they are fewer than 3 points not using the initialisation
            %[R0,T0,iclosest_2,dist_2,Error0]=phy_icp([x2; y2],[x; y],10,2,[3,min([size(x2,2),size(x,2)])],1,0);
            [iclosest_2,dist_2]=phy_icp2([x2; y2],[x;y]);
        else
            % [R,T,iclosest,distance,ERROR] =
            % phy_icp(model,data,max_iter,min_iter,fitting,thres,init_flag,tes_flag)
            %[R0,T0,iclosest_2,dist_2,Error0]=phy_icp([x2; y2],[x; y],10,2,[3,min([size(x2,2),size(x,2)])],1,1);
            
            %the final argument 1/0 do or not an initialisation by translation (the same median)
            %iclosest_2 is the index of the closest point in image i-2
            %dist_2 is the distance after icp to the closest point in image i-2
            %[x2; y2],[x; y]
            [R0,T0,iclosest0,dist0,Error0]=phy_icp([x2; y2],[x; y],10,2,[3,min([size(x2,2),size(x,2)])],0.01,0);
            [R1,T1,iclosest1,dist1,Error1]=phy_icp([x2; y2],[x; y],10,2,[3,min([size(x2,2),size(x,2)])],0.01,1);
            %the final 1/0 do or not an initialisation by translation (the same median)
            
            if Error0<=Error1
                iclosest_2=iclosest0;   %iclosest_2 is the index of the closest point in image i-2
                dist_2=dist0;   %dist_2 is the distance after icp to the closest point in image i-2
            else
                iclosest_2=iclosest1;   %iclosest_2 is the index of the closest point in image i-2
                dist_2=dist1;    %dist_2 is the distance after icp to the closest point in image i-2
            end
            
        end
        
        for i=1:length(x)        %keep the index and the distance of the minimum distance betwen image i-1 and i-2
            if dist_1(i)<dist_2(i)  %distance to the closest point is the final distance dist_min (= dist from i-1 or i-2)
                dist_min(i)=dist_1(i);
                n(i)=objecti_1(indexi_1(iclosest_1(i))).n;
            else
                dist_min(i)=dist_2(i);
                n(i)=objecti_2(indexi_2(iclosest_2(i))).n;
            end
        end
    end
    
    n_final=zeros(1,length(x)); %final labeling
    for i=1:length(x)
        a=find(n==n(i));    %if 2 or more point asociated with the same pevious point
        %keep only the one with minimum distance
        [mini indi]=min(dist_min(a));
        if dist_min(a(indi))<distanceParameter*1.5; %parameter; if the distance smalar than the parameter then the final label
            n_final(a(indi))=n(a(indi));
        end
    end
    
    for i=1:length(x)
        if n_final(i)~=0
            objectOut(indexi(i)).n=n_final(i);
        else
            lastObjNumber=lastObjNumber+1;  %if no label (distance to big/ new point..) , a new label will be given
            objectOut(indexi(i)).n=lastObjNumber;
        end
    end
    
end


end