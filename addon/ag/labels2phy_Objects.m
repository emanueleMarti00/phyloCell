function phy_Objects = labels2phy_Objects(labels,im)

  minSize=100;
  maxSize=15000;
  
    [contours L Na ae]= bwboundaries(labels > 0);
    
    n = length(contours);
    
    phy_Objects = phy_Object();
    
    a=regionprops(L,im,'MeanIntensity');
    ine=[a.MeanIntensity];
    p=isfinite(ine);
    ine2=ine(p);
    meani=mean(ine2);
    sti=std(ine2);
    cc=1;
    
    for i = 1:n
        
        contour = contours{i};
        
        area=polyarea(contour(:, 2), contour(:, 1));
        
   
        
        if area> minSize && area < maxSize && ine(i)<meani+1*sti
        % cc,area 
        phy_Objects(cc) = phy_Object(cc, contour(:, 2), contour(:, 1));
        phy_Objects(cc).ox = mean(contour(:, 2));
        phy_Objects(cc).oy = mean(contour(:, 1));
        cc=cc+1;
        continue
        end
        
       % if area> minSize && area < 2000 && ine(i)<meani+3*sti
            
       % phy_Objects(i) = phy_Object(cc, contour(:, 2), contour(:, 1));
       % phy_Objects(i).ox = mean(contour(:, 2));
       % phy_Objects(i).oy = mean(contour(:, 1));
       % cc=cc+1;
       % continue
       % end
    end
end


function labelsout=filterCells(labels,minSize,maxSize,im)

a=regionprops(labels,im,'Area','MeanIntensity');

labelsout=zeros(size(labels));

cc=1;


for i=1:length(a)
    

    if a(i).Area<minSize
   
        continue
    end
    if a(i).Area>maxSize

        continue
    end
    
  %  z=sum(sum(labels==i))
    labelsout=labelsout+cc*(labels==i);
    
    meanint(cc)=a(i).MeanIntensity;
    
    cc=cc+1;
end

figure, imshow(labelsout,[])

st=std(meanint);
me=mean(meanint);

for i=1:length(a)
    
  %   pix=find(labels==i);
     
  % if meanint(i)>st+me
       %labels(pix)=0;
        continue 
  % end
    
end

end