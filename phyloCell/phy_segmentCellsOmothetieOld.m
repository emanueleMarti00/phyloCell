%segmentation funtion of cells by omothetie
function cell=phy_segmentCellsOmothetieOld(imdata,param,display)

imdata=phy_scale(imdata);



% cell_radius=round(param.cell_diameter/2.0);
% [listx listy distance imdistance]=phy_findCellCenters(imdata,display,cell_radius);
% 
% imdistance=phy_scale(imdistance);
% 
% moreOutput.maxAxis=10*ones(size(listx));
% moreOutput.minAxis=10*ones(size(listx));
% moreOutput.orientation=zeros(size(listx));
% cells=phy_createCellsComplex(listx,listy,moreOutput);
% 
% nx=cells.nx;
% for i=1:cells.n
%     x(i,:)=cells.x((i-1)*(nx+1)+1:(i)*(nx+1));
%     y(i,:)=cells.y((i-1)*(nx+1)+1:(i)*(nx+1));
% end
% 
% x=x(:,1:nx);
% y=y(:,1:nx);

[y x imdistance]=segmentPombe(imdata);

imdistance=phy_scale(imdistance);

[FX,FY] = gradient(double(imdata));


grad2=sqrt(FX.*FX+FY.*FY);
grad2=phy_scale(grad2);


maxeint=1*double(max(max(imdata))); %0.5
mineint=1*double(min(min(imdata)));%1.2

imdata=double(imadjust(imdata,[mineint maxeint]));

xtemp=x;
ytemp=y;


display=0;

if display
    %figure, imshow(grad2);
    %figure; imshow(imdata);
    %figure; imshow(imdistance); colormap(jet);
    figure; imshow(imdata,[]);
    
    
    h=line(xtemp',ytemp','Color','g');
    xnewfit=[]; ynewfit=[];
    h2= line(xnewfit',ynewfit','Color','m');
end

%bre=ones(length(xtemp(:,1)),1);

it=50; % iteration number
scale=0.03; % default 0.07

overlap=zeros(size(xtemp));

if numel(xtemp)~=0
    
for i=1:it;
    if display
        delete(h); delete(h2);
    end
    mx=mean(xtemp,2);
    my=mean(ytemp,2);
    
    mx=repmat(mx,1,size(xtemp,2));
    my=repmat(my,1,size(xtemp,2));
    
    ind = sub2ind(size(imdata),round(ytemp),round(xtemp));
    
    meanind=sub2ind(size(imdata),round(my),round(mx));
    
    im=imdata(ind);
    sc=imdistance(ind);
    gr=grad2(ind);
    
   % sca=1+max(0,(sc-im-gr+imdata(meanind)+2*grad2(meanind))/5);%+imdata(meanind)
   % andrei s version of scaling factor
 
%     if i>0.3*double(it)
%    scamaxi=1-(double(i)-0.3*double(it))/((1-0.3)*double(it));
%    alpha=1-0.8*(double(i)-0.3*double(it))/((1-0.3)*double(it));
%    else
   alpha=1;    
   scamaxi=1;
%    end
   
    sca=1+4*sc.*scamaxi.*(scale-alpha*gr.*gr); %4
    
    xtempold=xtemp;
    ytempold=ytemp;
    
    xtemp=(sca).*(xtemp-mx)+mx;
    ytemp=(sca).*(ytemp-my)+my;
    
    %[xnewfit ynewfit ang2]=fitEllipse2(xtemp,ytemp);
    
   % figure, plot(xtemp',ytemp');
    
    [xnewfit ynewfit ang2]=fitPombe(xtemp,ytemp);

    if i<0.9*double(it)
        [xtemp ytemp]=restorePoly(xtemp,ytemp,xnewfit,ynewfit,0.1); % last argument is the restoration coefficient default : 0.2-0.4
    end
    
    
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
        pause(0.1);
        %return;
    end
    
end
end

if display
    delete(h2);
end

xf=xtemp;
yf=ytemp;
nc=0;
for i=1:size(xf,1)
    
    if polyarea(xf(i,:),yf(i,:))>500 && polyarea(xf(i,:),yf(i,:))<12000  %area cutoff
        nc=nc+1;
    cell(nc)=phy_Object(i,xf(i,:),yf(i,:));
    cell(nc).ox=mean(xf(i,:));
    cell(nc).oy=mean(yf(i,:));

    end
end

if nc==0
   cell=phy_Object(0,[],[]); 
end



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

