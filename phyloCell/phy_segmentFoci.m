%segment budneck function
function [budneck]=phy_segmentFoci(img,parametres)

imgor=img;
%img=phy_scale(img);% scale image (O 1)

budneck=phy_Object;%initialize
%==========================================================================
%find mask of budnecks by tresh hold and watershed

display=1;

if display
figure; subplot(3,3,1); imshow(img,[]); hold on; 
end

img = medfilt2(img,[4 4]);% filtre median

if display
subplot(3,3,2); imshow(img,[]); hold on; 
end

%substract background
warning off all
background = imopen(img,strel('disk',parametres{4,2}));
warning on all
I2 = imsubtract(img,background);

if display
subplot(3,3,3); imshow(I2,[]); hold on; 
end

%figure, imshow(I2,[]);

cells_mean=mean2(I2);
cells_stdv=std2(I2);
cells_max=max(max(I2));

if cells_max==0
   errordlg('Image to be segmented is not displayed !');
   return;
end

filterlevel=parametres{5,2}/double(cells_max);
%return;

%xbin=0:0.01:1;
%figure, hist(I2(:),xbin);

med=median(I2(:));

%first level of threshold

% level1 =parametres{5,2};
% 
% %+parametres{5,2}
% %+cells_stdv %graythresh(I2);
% if level1>=1
%     level1=0.999;
% end
% if level1<=0
%     level1=0.001;
% end

I2=phy_scale(I2);% scale image (O 1)
img=phy_scale(imgor);
bw_bud=im2bw(I2,filterlevel);

if display
subplot(3,3,4); imshow(bw_bud,[]); hold on; 
end
%figure; imshow(bw_bud);

%second level of threshold
% level2 = graythresh(I2(bw_bud))+parametres{5,2};
% if level2>=1
%     level2=0.999;
% end
% if level2<=0
%     level2=0.001;
% end
% bw_bud=im2bw(I2,level2);

if display
subplot(3,3,5); imshow(bw_bud,[]); hold on;
end

%low=bw_bud;
%figure; imshow(bw_bud);

%third level of threshold
% level3 = graythresh(I2(bw_bud))+parametres{5,2};
% if level3>=1
%     level3=0.999;
% end
% if level3<=0
%     level3=0.001;
% end
% bw_bud=im2bw(I2,level3);

%if display
%subplot(3,3,6); imshow(bw_bud,[]); hold on; 
%end

%high=bw_bud;

%figure; imshow(bw_bud);

%level2,level3

%if level 2 small, the budnecks are very large
% if level2<(level3)/2 %if level 2 <half of level 2
%     level2 = level3/1.5; % level 2 proportional to level 3
%     bw_bud=im2bw(I2,level2);
%     low=bw_bud;
%     disp('level 2 low');
% end

if display
subplot(3,3,6); imshow(bw_bud,[]); hold on; 
end

%bw_bud=low;

% figure; imshow(bw_bud);
%if level 2 is low then threshold to a level very high
%level3,med

% if level3<5*med
%     bw_bud=im2bw(I2,8*med);
%     high=bw_bud;
%     bw_bud=im2bw(I2,6*med);
%     low=bw_bud;
%     'high'
% end

%thresh by hysterisis (level 2 and level 3)
%figure, imshow(low,[]); figure, imshow(high,[]);
%
%bw_bud=phy_hysteresis(low,high);

%figure; imshow(bw_bud);

if display
subplot(3,3,7); imshow(bw_bud,[]); hold on; 
end

cells_mean=mean2(img(bw_bud));
cells_stdv=std2(img(bw_bud));

%dilate les budnecks
%se = strel('disk',1);
%bw_bud=imdilate(bw_bud,se);

%if display
%subplot(3,3,8); imshow(bw_bud,[]); hold on; 
%end
%figure; imshow(bw_bud);

%exit the function if no budnecks detected
if ~any(bw_bud)
    return
end

%mask the real image with new found budnecks
bud=bw_bud.*img;

%find the regional max in the budnecks
%check their distance
regmax=imregionalmax(bud);
[x y]=find(regmax);
xwat=[];
ywat=[];
for l=1:length(x);
    x2(1)=x(1);
    y2(1)=y(1);
    d=[];
    a=[x(l) y(l)];
    for j=1:length(x2)
        b=[x2(j) y2(j)];
        d(j) = sum((a-b).^2).^0.5;
    end
    [mind ind_mind]=min(d);
    if (mind>parametres{4,2})
        
        x2=[x2;x(l)];
        y2=[y2;y(l)];%keep only the regionals max of the points with distance greater than the parameter
        if (mind<100*parametres{4,2})% use watershade only for the budnecks that are close than 3 * diam
            xwat=[xwat;x2(ind_mind),x(l)];
            ywat=[ywat;y2(ind_mind),y(l)];
        end
    end
end

%figure, imshow(img,[]); hold on; plot(ywat,xwat,'r+');
ind=sub2ind(size(img),xwat,ywat);

%ind=[];


if isempty(ind)
    L=bw_bud;
    
else %watershed
    %prepare for watershed imersion
    D=-img;
    D(~bw_bud)=-2;%-Inf
    D(ind)=-2;%-Inf
    
    %watershed imersion
    L = phy_watershed(D);
    
    %mask with the initial mask (watershed only neded for the budnecks separation)
    L=L.*bw_bud;
    

end


if display
subplot(3,3,8); imshow(L,[]); hold on; 
end

%remove the regions smaller than the typical area

%L = bwareaopen(L,round(parametres{4,2}^2/4),4);


if display
subplot(3,3,9); imshow(L,[]); hold on; 
end

%--------------------------------------------------------------------------

%L=bw_bud; % for mitochondria detection (no watershed)

[B,L] = bwboundaries(L,4,'noholes');%hyst

k=1;
for cc = 1:length(B)
    
    % obtain (X,Y) boundary coordinates corresponding to label 'k'
    boundary = B{cc};
    pix=find(L==cc);
    
    %numel(pix)
    
    if numel(pix)>10
    %calcul mean ,mode, min,max, intensity budneck
   % 'ok'
   
    if min(boundary(:,2))>10 && max(min(boundary(:,2)))<size(img,2)-10 && min(boundary(:,1))>10 && max(min(boundary(:,1)))<size(img,1)-10
    budneck(k).Mean=mean(img(pix));
    budneck(k).Median=median(img(pix));
    budneck(k).Min=min(img(pix));
    budneck(k).Max=max(img(pix));
    budneck(k).Nrpoints=length(pix); %number of point (aire)
    budneck(k).Mean_cell=cells_mean;
    budneck(k).fluoMean(2)=mean(imgor(pix));
    
    [r c]=ind2sub(size(img),pix); %transform from linear indice to matricial indice
    budneck(k).x=boundary(:,2);  %x contur
    budneck(k).y=boundary(:,1);   % y contur
    budneck(k).ox=mean(c); %x center
    budneck(k).oy=mean(r);  %y center
    budneck(k).n=k;
    
    k=k+1;
    end
    end
end
