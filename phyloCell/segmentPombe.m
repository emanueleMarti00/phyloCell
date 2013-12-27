function [xx yy imdistance2]=segmentPombe(imdata,param,filtre)
% replace the previous findCellCenter function : about 8 faster !
% find cell centers based on distance to edges.
% display=1 shows the result as a figure;
%display=1;

%imdata=phy_scale(imdata);


display=0;

sizemin=param.cell_diameter/1.5; % minimal distance to edge to be considered, roughly the min cell radius , pixel units
sizemax=param.cell_diameter*2; % maximal distance to edge that is tolerable
%cellcelldistance=15; % drough distance between cells

thresh=0.3:-0.05:0.05; % thresholding applied to generate BW image


%find the right threshold to detect the contour of the colonie
maxe=max(max(imdata));
meane=mean2(imdata);

[counts,x]=imhist(imdata);
count2=filter(ones(1,1),1,counts);
d=diff(count2);
d2=filter(ones(1,1),1,d);

if display
    figure;plot(x(1:end-1),d2);
end

[minv minind]=min(d2);
meanv=mean(d2);
ind=find(d2>meanv+minv);
final_ind=find(ind>minind,1,'first');
x(ind(final_ind));% the value of threshold

imbw=round(double(im2bw(imdata,x(ind(final_ind))+0.05))); %threshold+0.05
if display
    figure;imshow(imbw);
end

imbwstore=imbw;

se = strel('disk',round(param.cell_diameter/2));
imbw=imclose(imbw,se);

imbw=imfill(imbw,'holes');
%figure;imshow(imbw);
%tic;imbw = bwmorph(imbw,'fill');toc

se = strel('disk',3);
imbw=imopen(imbw,se);
imbw=bwareaopen(imbw,round(param.cell_diameter^2*pi/2),4);

C=~imbw;

C=imdilate(C,strel('disk',round(param.cell_diameter/8)));

if display
    figure; imshow(double(C)+imdata);
    % figure; imshow(double(C2)+imdata);
end
%----------------------------------

%C=0;

imbwtot=zeros(size(imdata));
imdistance=zeros(size(imdata));
immeandist=zeros(size(imdata));
imcount=zeros(size(imdata));

imdistance2=zeros(size(imdata));



%img2=imdata+NG;

strc=strel('disk',1);
imc=imerode(imbwstore,strc);

strclose=strel('disk',15);
imc=imclose(imc,strclose);


%figure, imshow(imbwstore,[]);
%figure, imshow(imc,[]);
%return;

%figure, imshow(filtre);

for it=thresh
    
    % imbw=im2bw(imdata,double(meane+it*(maxe-meane))/65536);
    imbw=im2bw(imdata,double(meane+it*(maxe-meane)));
    %imbwNG=im2bw(NG,double(meanNG+it*(maxNG-meanNG)));
    
    
    if nargin==3
    imdist=bwdist(imbw|C|~filtre);   
    else
    imdist=bwdist(imbw|C);
    end
    
    imdistance2=imdistance2+imdist;
    
    
end

imdistance2=imdistance2/numel(thresh);

imdistance2(C)=0;

gaussianfilter = fspecial('gaussian',16,3);
smoothedbd = imfilter(imdistance2,gaussianfilter);

[slopes, determinant] = ic_slopes(smoothedbd);

%figure, imshow(slopes,[0 1]); colormap(jet);
%figure, imshow(determinant,[-0.01 0.01]); colormap(jet);

saddlecandidates = (determinant < -0.01) & (slopes < 0.1) & (imdistance2 > 0) & (imdistance2 < 20);

%figure, imshow(imdistance2/(max(max(imdistance2)))+saddlecandidates,[]);

%if display
%    figure, imshow(imdistance2,[]);
%end

str=strel('disk',12);
temp3=imdilate(saddlecandidates,str);


pix=find(temp3);

% figure, imshow(imbw);
% imbw(pix)=1;
% figure, imshow(imbw);

imdistance2(pix)=3;
imdistance2norm=imdistance2/(max(max(imdistance2)));

if display
figure, imshow(imdistance2norm,[]); colormap(jet);
end

bwdis=im2bw(imdistance2norm,0.4);

B = bwboundaries(bwdis);

nx=64;

xxtemp=[];
yytemp=[];

for i=1:numel(B)
   
  % if i==1
   arr=cell2mat(B(i)); 
   
   t=0:size(arr,1)-1;
   x = arr(:,1);
   y = arr(:,2);
   tt = 0:(size(arr,1)-1)/nx:size(arr,1)-1;
   tt=tt(1:nx);
   
   xxtemp(i,:) = spline(t,x,tt);
   yytemp(i,:) = spline(t,y,tt); 
   
 %     figure, plot(tt,xx(i,:),'Color','b'); 
 %     figure, plot(t,x,'Color','r')
 %  end
  
%  if i==1
%    bound=[xx(i,:) ; yy(i,:)]
%    
%    rectangle_t = fit_rectangle(bound);
%  end
   
end

xx=[];
yy=[];

ncount=1;

for i=1:numel(B)
    area=polyarea(xxtemp(i,:),yytemp(i,:));
    xmin=min(xxtemp(i,:)); xmax=max(xxtemp(i,:));ymin=min(yytemp(i,:)); ymax=max(yytemp(i,:));
    
    if  area>300 && area<8000 && xmin>10 && ymin>10 && ymax< size(bwdis,1)-10 && xmax < size(bwdis,2)-10
   xx(ncount,:)=xxtemp(i,:);
   yy(ncount,:)=yytemp(i,:);
   ncount=ncount+1;
    end
end

%ncount


% xt=rectangle_t.bounding_points(:,1);
% yt=rectangle_t.bounding_points(:,2);
% 
% a= rectangle_t.bounding_points
% b=rectangle_t.equation_of_diagonals
% c=rectangle_t.equation_of_bounding_sides
% d=rectangle_t.centroid

if display
figure, imshow(bwdis); line(yy',xx','lineWidth',1); %line(xt,yt,'Color','b','lineWidth',2);
end



