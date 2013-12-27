function phy_plotMitochondria(incells,channel,mine,maxe)
global segmentation

cc=1;
ytick=[];
yticklabel={''};
cellwidth=200;

%col=colormap(jet(256));

col2=0:1:255;
col2=col2';
col2=col2/255;

col=zeros(256,3);

if channel==3
col(:,1)=col2;
end

if channel==2
    col(:,2)=col2;
end

if channel==1
col=colormap(jet(256));
end

%indexsel=[11 38 52]

%indexsel=indextim;

h=figure;

mother=incells;

cc=1;

%segmentation

    tcells=segmentation.tcells1(mother);
    tdiv = sort(tcells.divisionTimes);% segList(i).s.tcells1(segList(i).line).lastFrame]);
    tdiv=[tcells.detectionFrame tdiv tcells.lastFrame];
    %i
    %tdiv=tdiv/6; %conversion in minutes
    
    %rec(1,1)= tdiv(1);
    %rec(1,2)= tdiv(2); %y(l);
    %cindex(1)=1;
    rec=[];
    
    cdiv=1;
    csum=0;
    for l=1:length(tcells.Obj)-1
        rec(l,1)= tcells.Obj(l).image;
        rec(l,2)= tcells.Obj(l+1).image; %y(l);
        
        if length(tcells.Obj(l).fluoNuclMean)>=channel
         fluo=tcells.Obj(l).fluoNuclMean(channel);
         %fluo=tcells.Obj(l).Mean(1);
         %fluo=tcells.Obj(l).fluoNuclMean(channel)*tcells.Obj(l).Mean(2);
        else
         fluo=0;   
        end
        
        warning off all
        temp=min(255,max(1,uint8(255*(fluo-mine)/(maxe-mine))));
        warning on all
        
        cindex(l)=temp;
        
        
        
        if channel==1
           % temp
           %class(temp)
          csum=csum+double(temp);
          
          if cdiv==10
             cdiv=0;
             
             %a=csum/10
             cindex(l-9:l)=uint8(round(csum/10));
             csum=0;
          end
          
          cdiv=cdiv+1;  
        end
        
    end
    
   % yticklabel{cc}=[mother];
   % startY=310*(cc-1); %(6*cellwidth)*(cc-1);
   % ytick=[ytick startY];
    shift=-rec(1,1);
    startY=0;
    % shift=0;
    
    % rec
    
    Traj(rec,'Color',col,'colorindex',cindex,'tag',num2str(mother),h,'width',cellwidth,'startX',shift,'startY',startY,'sepColor',[0. 0. 0.],'sepwidth',0,'gradientWidth',100,'topColor',[0 0 0]);
 


dau=segmentation.tcells1(mother).daughterList;
[frames ix]=sort([segmentation.tcells1(segmentation.tcells1(mother).daughterList).detectionFrame]);

dau=dau(ix);


for i=1:length(dau)
    tcells=segmentation.tcells1(dau(i));
    det=tcells.detectionFrame+shift;
    
    rec=[]; cindex=[];
    
    cc=1; su=0;
    
    
   
    
   for l=1:min(12,length(tcells.Obj))
        rec(l,1)= tcells.Obj(l).image;
        rec(l,2)= rec(l,1)+1; %y(l);

        if length(tcells.Obj(l).fluoNuclMean)>=channel
       %  fluo=tcells.Obj(l).fluoNuclMean(channel);
         
         fluo=tcells.Obj(l).fluoNuclMean(channel);
        % fluo=tcells.Obj(l).Mean(1);
       %  fluo=tcells.Obj(l).fluoNuclMean(channel)*tcells.Obj(l).Mean(2);
         
        else
         fluo=0;   
        end
        
        warning off all
        temp=min(255,max(1,uint8(255*(fluo-mine)/(maxe-mine))));
        warning on all
        
        cindex(l)=temp;
        su=su+double(temp);
        cc=cc+1;
   end
    
   
   
   
   if channel==1
      rec=[]; cindex=[];
       
      rec(1,1)= tcells.Obj(1).image;
      rec(1,2)= tcells.Obj(l).image;
      cindex=uint8(round(double(su/l)));
   end
    
   % yticklabel{cc}=[dau(i)];
    startY=700*(mod(i,2)-0.5); %(6*cellwidth)*(cc-1);
    sline=startY+150*sign(startY);
    eline=sign(startY)*150;
    %ytick=[ytick startY];
   % shift=0;
    % shift=0;
    
    % rec
    
    
    Traj(rec,'Color',col,'colorindex',cindex,'tag',num2str(dau(i)),h,'width',cellwidth,'startX',shift,'startY',startY,'sepColor',[0. 0. 0.],'sepwidth',0,'gradientWidth',100,'topColor',[0 0 0]);
    line([det det],[eline sline],'Color','k','LineWidth',2);
    line([det det],[-150 150],'Color','w','LineWidth',2);
    cc=cc+1;
end

xlabel('time (hours) ','FontSize',24);

%[ytick ix]=sort(ytick);
%yticklabel=yticklabel(ix);
%
axis tight
set(h,'Color',[1 1 1],'Position',[100 100 1200 500]);

set(gca,'YTick',[],'XTick',[0 120 240 360 480 600],'XTickLabel',{'0' '20' '40' '60' '80' '100'},'FontSize',24,'Color',[1 1 1]);

hc=colorbar;
colormap(hc,col);
set(hc,'YTick',[0 0.5 1],'YTickLabel',{num2str(mine) num2str(round((mine+maxe)/2)) num2str(maxe)},'FontSize',24);



set(gcf,'Position',[0 8000 1200 200]);


