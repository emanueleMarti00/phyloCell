function [listx2 listy2 distance imdistance2 C]=phy_findCellCenters(imdata,display,cellcelldistance,filtre,masque)
global segmentation
% replace the previous findCellCenter function : about 8 faster !
% find cell centers based on distance to edges.
% display=1 shows the result as a figure;
%display=1;

imsave=imdata;

%h=fspecial('disk',round(cellcelldistance/1.5));

h=fspecial('disk',5);

imdata = filter2(h,imdata);

arrfil=[0.0 0.8]; % saturation parameter

if isfield(segmentation.parametres,'BF')
    if segmentation.parametres.BF==1
    arrfil=[0. 0.6];
    end
end
imdata=imadjust(imdata,arrfil,[]); % 0 0.8
%figure, imshow(imdata,[]);

imdata=phy_scale(imdata);

sizemin=cellcelldistance/2; %1.5 minimal distance to edge to be considered, roughly the min cell radius , pixel units
sizemax=cellcelldistance*3; % maximal distance to edge that is tolerable
%cellcelldistance=15; % drough distance between cells

thresh=0.5:-0.05:0.05; % thresholding applied to generate BW image

%find the right threshold to detect the contour of the colonie
maxe=max(max(imdata));
meane=mean2(imdata);

if nargin==5
C=masque;

if display
    figure; imshow(double(C)+imdata);
    pause(0.3);
    close;
%    figure; imshow(imbwgr+imdata);
end

else
C=findClusterContours(imdata,cellcelldistance,display);
end

%----------------------------------
%return;
%C=0;

imbwtot=zeros(size(imdata));
imdistance=zeros(size(imdata));
immeandist=zeros(size(imdata));
imcount=zeros(size(imdata));

imdistance2=zeros(size(imdata));
imdata=phy_scale(imsave);

%
if nargin==5
%D=imerode(C,strel('disk',5));
%imdata(D)=0;
end
%figure, imshow(imdata,[]);
%

%img2=imdata+NG;

for it=thresh
    
    % imbw=im2bw(imdata,double(meane+it*(maxe-meane))/65536);
    imbw=im2bw(imdata,double(meane+it*(maxe-meane)));
    %imbwNG=im2bw(NG,double(meanNG+it*(maxNG-meanNG)));
   % figure, imshow(imbw,[]);
    
    if nargin==4
    imdist=bwdist(imbw|C|~filtre);   
    else
      % figure, imshow(imbw|C);
    %imdist=bwdist(imbw);
    imdist=bwdist(imbw|C);
    end
    
    imdistance2=imdistance2+imdist;
    
end

imdistance2=imdistance2/numel(thresh);

%figure, imshow(20*C+imdistance2,[]);

imdistance2(C)=0;

C=imbw;
%figure, imshow(imdistance2,[]);

pix=phy_localMaximum(imdistance2,cellcelldistance);

temp2=zeros(size(imdata));
temp2(pix)=1;

%figure, imshow(temp2,[])

se = strel('disk',1);
%temp3 = imdilate(imdistance2,se);
temp3=imdilate(temp2,se);

temp3=bwlabel(temp3);

%figure, imshow(temp3+imdata);

s  = regionprops(temp3, imdistance2, 'Centroid','MeanIntensity');
centroids = cat(1, s.Centroid);
meanInt=cat(1,s.MeanIntensity);

listx2=[];
listy2=[];
distance=[];
%distance2=uint8([]);

borderthr=20;

for i=1:length(centroids(:,1))
    
    x=centroids(i,1);
    y=centroids(i,2);
    
    dist=imdistance2(round(y),round(x));
    %dist2=meanInt(i);
    
    if dist<sizemin
        continue;
    end
    
    if dist>sizemax
        continue;
    end
    
    if x<borderthr
        continue;
    end
    
    if y<borderthr
        continue;
    end
    
    if y>size(imdata,1)-borderthr
        continue;
    end
    
    if x>size(imdata,2)-borderthr
        continue;
    end
    
    distance=[distance double(dist) ];
    % distance2=[distance2 uint8(round(dist2))];
    listx2=[listx2 x];
    listy2=[listy2 y];
end

%distance
if nargin>=2
    if display==0
        %   figure, imshow(temp3,[]); hold on ;
        %   line(listx2,listy2,'Marker','o','LineStyle','none');
        
       % figure, imshow(imdistance2,[]);
        
        figure, imshow(imdata,[]);
       
        hold on; line(listx2,listy2,'Marker','o','LineStyle','none','Color','r');
        for i=1:numel(listx2)
            text(listx2(i),listy2(i)-2,num2str(round(distance(i))),'Color','r');
        end
        
        pause(0.5);
        %pause;
        figure;
        close;
    end
end


function C=findClusterContours(imdata,cellcelldistance,display)


[counts,x]=imhist(imdata);
%figure, plot(counts);
count2=filter(ones(1,1),1,counts);

%figure, plot(count2);
d=diff(count2);
d2=filter(ones(1,1),1,d);

if display
   % figure;plot(x(1:end-1),d2);
end

[minv minind]=min(d2);
meanv=mean(d2);
ind=find(d2>meanv+minv);
final_ind=find(ind>minind,1,'first');
%x(ind(final_ind))
% the value of threshold

imbw=round(double(im2bw(imdata,x(ind(final_ind))+0.06))); %threshold+0.05

if display
    figure;imshow(imbw);
    pause(0.3);
    close;
end

%se = strel('disk',round(cellcelldistance/2));
%imbw=imclose(imbw,se);

imbw=imdilate(imbw,strel('disk',round(cellcelldistance/2))); %/8

%figure;imshow(imbw);

imbw=imfill(imbw);

%figure;imshow(imbw);

D=~imbw;
[L nL]=bwlabel(D);

for i=1:nL
tbw=L==i;

if sum(sum(tbw))<cellcelldistance^2*pi
   imbw(tbw)=1; 
end
end

%figure;imshow(imbw);

%%tic;imbw = bwmorph(imbw,'fill');toc

%se = strel('disk',3);
%imbw=imopen(imbw,se);
%imbw=bwareaopen(imbw,round(cellcelldistance^2*pi/2),4);


%figure;imshow(imbw);

C=~imbw;

%%D=C;

C=imdilate(C,strel('disk',round(cellcelldistance/2))); %/2 for cavity /1 otherwise


%[FX,FY] = gradient(double(imdata));

%grad2=sqrt(FX.*FX+FY.*FY);
%grad2=phy_scale(grad2);

%imbwgr=round(double(im2bw(grad2,0.15)));



%pix=find(D);
%D=C;
%D(pix)=0;
%figure, imshow(D,[]);

if display
    figure; imshow(double(C)+imdata);
    pause(0.3);
    close;
%    figure; imshow(imbwgr+imdata);
end
