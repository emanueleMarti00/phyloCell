%segmentation funtion of cells by omothetie
function cell=phy_segmentCellsOmothetie(imdata,param,cropp,masque)
global segmentation;

imsave=imdata;


% imdata=imsave;
%     stlarge=strel('disk',15);
%     imdata=max(max(imdata))-imdata+1;
%     imdata=imopen(imdata,stlarge);
%     imdata=max(max(imdata))-imdata+1;
  %  figure, imshow(imdata,[]);
 

imdata=phy_scale(imdata);

if isfield(param,'BF')
    if param.BF==1 % bright field segmentation
        imdata=1-imdata;
    end
end

display=param{12,2};


    
    cell_radius=round(param{2,2}/2.0);
    
    
          %  figure, imshow(imdata,[]);
        if nargin==4

        [listx listy distance imdistance fieldmask]=phy_findCellCenters(imdata,display,cell_radius,1,masque);
        else
        [listx listy distance imdistance fieldmask]=phy_findCellCenters(imdata,display,cell_radius);    
        end
        
        %return;

    
    if display
        figure,imshow(imdistance,[]);
        pause(0.5);
        close;
    end
    
  %   figure,imshow(imdistance,[]);
    
    imdistance=phy_scale(imdistance);
    
    %[accum, circen, cirrad] = CircularHough_Grd(imsave, [10 45], 8,35,1);
    %listx=circen(:,1);
    %listy=circen(:,2);
    
    %listx, listy, distance
    
    %pix=find(distance<1*cell_radius); % 1.1 small cells
    %distance(pix)=10;
    
    moreOutput.maxAxis=0.8.*distance.*ones(size(listx));
    moreOutput.minAxis=0.8.*distance.*ones(size(listx));
    moreOutput.orientation=zeros(size(listx));
    
    %figure, imshow(imdata,[]);
    
    
%     imdata=imsave;
%     stlarge=strel('disk',15);
%     imdata=max(max(imdata))-imdata+1;
%     imdata=imopen(imdata,stlarge);
%     imdata=max(max(imdata))-imdata+1;
%   %  figure, imshow(imdata,[]);
%     imsave=imdata;

    
    imdata=imadjust(imsave,segmentation.colorData(segmentation.channels(1),[4 5]),[]);
    imdata=phy_scale(imdata);
    %figure, imshow(imdata,[]);
    
    cells=phy_createCellsComplex(listx,listy,moreOutput);
    
    nx=cells.nx;
    for i=1:cells.n
        x(i,:)=cells.x((i-1)*(nx+1)+1:(i)*(nx+1));
        y(i,:)=cells.y((i-1)*(nx+1)+1:(i)*(nx+1));
    end
    
    x=x(:,1:nx);
    y=y(:,1:nx);
    
    x(x<1)=1;
    y(y<1)=1;
    x(x>size(imdata,2))=size(imdata,2);
    y(y>size(imdata,1))=size(imdata,1);
    
    %figure, line(x',y');
    


%figure; imshow(imdistance,[]);

%h=fspecial('disk',2);
%imdata = filter2(h,imdata);

[FX,FY] = gradient(double(imdata));

grad2=sqrt(FX.*FX+FY.*FY);
grad2=phy_scale(grad2);


if param{11,2} % strenghthen gradient on the edges
    % increase gradient on cluster edges
fieldmask2=imdilate(fieldmask,strel('disk',round(cell_radius))); %/8
%figure, imshow(fieldmask2,[]); title('2');
%figure, imshow(fieldmask,[]); title('1');
pix=find(fieldmask);
fieldmask2(pix)=0;
pix=find(fieldmask2);
%figure, imshow(fieldmask2,[]);

%te=grad2(pix);
pix2=find(grad2<0.3 & grad2>0.1);
pix3=intersect(pix,pix2);

%grad2(pix3)=0.3;
grad2(pix)=1.5*grad2(pix);

grad2(1:30,1:end)=1.5*grad2(1:30,1:end);
grad2(end-30:end,1:end)=1.5*grad2(end-30:end,1:end);

grad2(1:end,1:30)=1.5*grad2(1:end,1:30);
grad2(1:end,end-30:end)=1.5*grad2(1:end,end-30:end);

end

%h=fspecial('disk',5);
%grad2 = filter2(h,grad2);


%figure, imshow(grad2,[]);


maxeint=1*double(max(max(imdata))); %0.5
mineint=1*double(min(min(imdata)));%1.2

imdata=double(imadjust(imdata,[mineint maxeint]));

xtemp=x;
ytemp=y;

if display
    % figure; imshow(imdistance,[]);
    hdisplay=figure, imshow(grad2,[]);
    
    h=line(xtemp',ytemp','Color','g');
    line(listx',listy','Color','g','LineStyle','none','Marker','+');
    %line(listxold',listyold','Color','b','LineStyle','none','Marker','+');
    
    xnewfit=[]; ynewfit=[];
    h2= line(xnewfit',ynewfit','Color','m');
    %pause(0.5);
    %close;
 %   pause;
   % return;
end
%bre=ones(length(xtemp(:,1)),1);

%it=50; % iteration number
%scale=0.03; % default 0.07

it=param{6,2};
scale=param{8,2};

overlap=zeros(size(xtemp));

cellsize=zeros(size(xtemp,1),it);

%figure, imshow(imdata,[]);

if numel(xtemp)~=0
    
    for i=1:it
        if display
            delete(h); delete(h2);
        end
        mx=mean(xtemp,2);
        my=mean(ytemp,2);
        
        mx=repmat(mx,1,size(xtemp,2));
        my=repmat(my,1,size(xtemp,2));
        
        ind = sub2ind(size(imdata),round(ytemp),round(xtemp));
        
        %meanind=sub2ind(size(imdata),round(my),round(mx));
        
        im=imdata(ind);
        
        if i==1;
            im0=im;
        end
        
        %im=im-im0;
        
        %sc=imdistance(ind);
        gr=grad2(ind);
        
         if i==1
            grold=gr;
        end
        
     
        % sca=1+max(0,(sc-im-gr+imdata(meanind)+2*grad2(meanind))/5);%+imdata(meanind)
        % andrei s version of scaling factor
        
        %     if i>0.3*double(it)
        %    scamaxi=1-(double(i)-0.3*double(it))/((1-0.3)*double(it));
        %    alpha=1-0.8*(double(i)-0.3*double(it))/((1-0.3)*double(it));
        %    else
        alpha=1;
        
        %smallfactor=max(0.7,min(1,(polyarea(xtemp',ytemp')/(pi*cell_radius^2).^1))); % adjust speed to cell size
        %smallfactor=repmat(smallfactor',[1 size(xtemp,2)]);
        
       % smallfactor=1;
        
       % gr=gr./smallfactor;
        
        
       % scamaxi=1;%./smallfactor;
       
        restoredown=param{7,2};
        
       % scdown=0.99;
        
        %tes=param{9,2}
        %class(tes)
        
        speed=param{9,2};
        
%         if i>scdown*it
%            scamaxi=1-1*(i-scdown*it)/((1-scdown)*it);
%            restoredown=1*param{7,2}*(1-0.7*(i-scdown*it)/((1-scdown)*it));
%            speed=param{9,2}*(1-1*(i-scdown*it)/((1-scdown)*it));
%            
%         end
        
        
        %sc
        %    end
       % sca=1+speed.*(scale-alpha*gr.*gr)./(1+20*gr.*gr); %4
        
        sca=1+0.2.*(0.3-1*im-0.1*gr);
       
       %sca=1+6*(0.05+20*(gr-grold))./(1+200.*gr); %.*(0.05-(im-im0)))./(1+100.*gr);
       
        pixq=find(sca>1.05);
        sca(pixq)=1.05;
        
        pixq=find(sca<0.95);
        sca(pixq)=0.95;
       
       grold=gr;
        
        xtempold=xtemp;
        ytempold=ytemp;
        
        xtemp=(sca).*(xtemp-mx)+mx;
        ytemp=(sca).*(ytemp-my)+my;
        
        
       % if strcmp(param.homo.type,'Cerevisiae')
            [xnewfit ynewfit ang2]=fitEllipse2(xtemp,ytemp);
            [xtemp ytemp]=restorePoly(xtemp,ytemp,xnewfit,ynewfit,restoredown); % last argument is the restoration coefficient default : 0.2-0.4
       % else
        %    [xnewfit ynewfit ang2]=fitPombe(xtemp,ytemp);
        %    if i<0.9*double(it)
         %       [xtemp ytemp]=restorePoly(xtemp,ytemp,xnewfit,ynewfit,restoredown); % last argument is the restoration coefficient default : 0.2-0.4
        %    end
        %end
        
        
        
        % figure, plot(xtemp',ytemp');
        % if i<0.9*double(it)
        
        % end
        
        % freeze scaling in case of cell-cell overlaping
        overlap=zeros(size(xtemp));
        
        for j=1:numel(xtemp(:,1))
            inpoly=inpolygon(xtemp,ytemp,xtemp(j,:),ytemp(j,:));
            inpoly(j,:)=inpoly(j,:)-1;
            overlap=overlap+inpoly;
        end
        overlap= logical(overlap);
        
        xtemp(overlap==1)=xtempold(overlap==1);
        ytemp(overlap==1)=ytempold(overlap==1);
        
        
        % prevent contour from going outside of the image
        xtemp(xtemp<1)=1;
        ytemp(ytemp<1)=1;
        xtemp(xtemp>size(imdata,2))=size(imdata,2);
        ytemp(ytemp>size(imdata,1))=size(imdata,1);
        
        
        if display
            h=line(xtemp',ytemp','Color','g'); h2= line(xnewfit',ynewfit','Color','m');
            pause(0.001);
           % pause;
            %return;
        end
        
        %cellsize(:,i)=polyarea(xtemp',ytemp');
        
    end
end

deltasize=diff(cellsize');

if display
    delete(h2);
    delete(hdisplay);
    
   % figure, plot(cellsize');
   % figure, plot(deltasize);
end

xf=xtemp;
yf=ytemp;

nc=0;

celltemp=phy_Object(0,[],[]);

% deltasize=deltasize';
% %size(deltasize),size(cellsize)
% deltasize=mean(deltasize(:,round(0.6*it):round(0.7*it)),2)./cellsize(:,it);
% 
% check=checkCellOutCluster(xtemp,ytemp,imdata,fieldmask);
% 
 for i=1:size(xf,1)
     if polyarea(xf(i,:),yf(i,:))>param{3,2} && polyarea(xf(i,:),yf(i,:))<param{4,2}  %area cutoff
%         
%         if  deltasize(i)< 0.015 % convergence cutoff : cells that did not converge are discarded (probably mis segmentation)
%           %%%%%%%%%%%%  if check(i)==1 % check that cell is not outside of the cell cluster
             nc=nc+1;
             celltemp(nc)=phy_Object(i,xf(i,:),yf(i,:));
             celltemp(nc).ox=mean(xf(i,:));
             celltemp(nc).oy=mean(yf(i,:));
%           %%%%%%%%%%%%  end
%         end
     end
 end


cell=celltemp;
%figure, plot(cellsize');
%figure, plot(deltasize);


%if nc==0
%  cell=phy_Object(0,[],[]);
%end

function chec=checkCellOutCluster(xtemp,ytemp,imdata,fieldmask)

mask=zeros(size(imdata));
warning off all;
chec=ones(1,size(xtemp(:,1)));
edg=zeros(1,size(xtemp(:,1)));
warning on all

fieldmask=~fieldmask;

%figure, imshow(fieldmask);

cellsize=round(1.5*sqrt(round(mean(polyarea(xtemp',ytemp')))/pi));
st=strel('disk',cellsize);

fieldmaskerode=imerode(fieldmask,st);
%figure, imshow(fieldmaskerode);

fieldmask(fieldmaskerode)=0;
%figure, imshow(fieldmask);

for i=1:length(xtemp(:,1))
    bw=poly2mask(xtemp(i,:),ytemp(i,:),size(imdata,1),size(imdata,2));
   mask(bw)=i;
   intr=bw & fieldmask;
   if numel(find(intr))~=0
      edg(i)=1;
   end
   
   %line(xtemp(i,:),ytemp(i,:)); hold on;
end

%figure, imshow(mask,[]);

stat=regionprops(mask,imdata,'MeanIntensity');

a=[stat.MeanIntensity];
meanClustInt=mean(a);

pix=find(a>2*meanClustInt);
pix2=find(edg);
pix3=intersect(pix,pix2);

chec(pix3)=0;

function [xnew ynew]=restorePoly(x,y,xfit,yfit,a)


difx=x-xfit;
dify=y-yfit;

xnew=x-a*difx;
ynew=y-a*dify;


function [xnewarr ynewarr angleout]=fitEllipse2(xarr,yarr)

xnewarr=[];
ynewarr=[];

%figure; line(xarr',yarr','Color','g');

for i=1:numel(xarr(:,1))
    
    x=xarr(i,:);
    y=yarr(i,:);
    
    e = phy_fitEllipse(x,y);
    
    
    
    area=polyarea(x,y);
    
    if numel(e.a)==0
        figure,line(x,y);
    end
    
    fact=sqrt(area/(pi*e.a*e.b));
    
    xm=e.X0_in;
    ym=e.Y0_in;
    
    %e.phi
    
    %angle=-e.phi*2*pi/360;
    angle=-e.phi;
    
    angleout(i)=angle;
    
    nx=length(x);
    x=zeros(nx,1);
    y=zeros(nx,1);
    
    iv=(1:1:nx)*2*pi/nx;
    
    x=fact*e.a*cos(iv);
    y=fact*e.b*sin(iv);
    
    
    M=[ cos(angle) -sin(angle) ; sin(angle) cos(angle)];
    
    vec=[x ; y];
    
    newvec = M*vec;
    
    x=newvec(1,:); %+min(x)-1;
    y=newvec(2,:); %+min(y)-1;
    
    
    xnew=x+xm;
    ynew=y+ym;
    
    xold=xarr(i,1);
    yold=yarr(i,1);
    
    [dist mine]=min(sqrt((xnew-xold).^2+(ynew-yold).^2));
    
    xnew=circshift(xnew,[1 -mine+1]);
    ynew=circshift(ynew,[1 -mine+1]);
    
    [dist mine]=min(sqrt((xnew-xold).^2+(ynew-yold).^2));
    
    xnewarr(i,:)=xnew;
    ynewarr(i,:)=ynew;
    
    
    
end

function [xnewarr ynewarr angleout]=fitPombe(xarr,yarr)

xnewarr=[];
ynewarr=[];

%figure; line(xarr',yarr','Color','g');

%xa=[];
%xb=[];

for i=1:numel(xarr(:,1))
    
    x=xarr(i,:);
    y=yarr(i,:);
    % i
    e = phy_fitEllipse(x,y);
    
    area=polyarea(x,y);
    
    fact=sqrt(area/(pi*e.a*e.b));
    
    xm=e.X0_in;
    ym=e.Y0_in;
    
    %e.phi
    
    %angle=-e.phi*2*pi/360;
    angle=-e.phi;
    
    if e.a<e.b
        temp=e.a;
        e.a=e.b;
        e.b=temp;
        angle=pi/2+angle;
    end
    
    angleout(i)=angle;
    
    nx=length(x);
    x=zeros(nx,1);
    y=zeros(nx,1);
    
    iv=(1:1:nx)*2*pi/nx;
    
    nc=nx/4;
    %da=e.b;
    %e.b=e.a; e.a=da;
    
    for j=1:nc
        x1(j)= -(e.a-e.b)*j/nc+(e.a-e.b)/2;
        y1(j)= e.b;
    end
    
    for j=1:nc
        iv=j*pi/nc;
        x2(j)= -e.b*sin(iv)-(e.a-e.b)/2;
        y2(j)= e.b*cos(iv);
    end
    
    for j=1:nc
        x3(j)= (e.a-e.b)*j/nc-(e.a-e.b)/2;
        y3(j)= -e.b;
    end
    
    for j=1:nc
        iv=j*pi/nc;
        x4(j)=  e.b*sin(iv)+(e.a-e.b)/2;
        y4(j)= -e.b*cos(iv);
    end
    
    % fact=fact*0.8;
    x=[x1 x2 x3 x4]; x=1.4*x*fact;
    y=[y1 y2 y3 y4]; y=0.9*y*fact;
    
    
    %x=fact*e.b*cos(iv)+(e.a-e.b)/2;
    %y=fact*e.b*sin(iv);
    
    
    %figure, plot(x,y); return;
    
    
    M=[ cos(angle) -sin(angle) ; sin(angle) cos(angle)];
    
    vec=[x ; y];
    
    newvec = M*vec;
    
    x=newvec(1,:); %+min(x)-1;
    y=newvec(2,:); %+min(y)-1;
    
    
    xnew=x+xm;
    ynew=y+ym;
    
    xold=xarr(i,1);
    yold=yarr(i,1);
    
    [dist mine]=min(sqrt((xnew-xold).^2+(ynew-yold).^2));
    
    xnew=circshift(xnew,[1 -mine+1]);
    ynew=circshift(ynew,[1 -mine+1]);
    
    [dist mine]=min(sqrt((xnew-xold).^2+(ynew-yold).^2));
    
    xnewarr(i,:)=xnew;
    ynewarr(i,:)=ynew;
    
    
    
end

%figure, plot(xa,xb);

