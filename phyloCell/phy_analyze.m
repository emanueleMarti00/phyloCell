function phy_analyze(incells)
global segmentation

%( remove cells that are present only for less than 4 frames ? )

% identify cells at bottom of cavities for all the times

cellindex=[];
for i=1:length(segmentation.cells1(:,1))
    if segmentation.discardImage(i)==0
    cells=segmentation.cells1(i,:);
    y=[segmentation.cells1(i,:).oy];
    n=[segmentation.cells1(i,:).n];
    pix=n~=0;
    [y ind]=sort(y(pix));
    n=n(pix);
    
    if segmentation.orientation==1 % cavity pointing up
        cellindex=[cellindex n(ind(1))];
    else
        cellindex=[cellindex n(ind(end))];
    end
    end
end


cellid=unique(cellindex);

deb=[];
fin=[];
id=[];

cc=1;
for i=cellid
    pix=cellindex==i;
    
    if nargin
    %if ~numel(find(incells==i))
    %    continue
    %end
    if cc>incells
        break
    end
    end
    
    [bw n]=bwlabel(pix);
    
    for j=1:n
        pix2=bw==j;
        id=[id i];
        deb=[deb find(pix2,1,'first')];
        fin=[fin find(pix2,1,'last')];
    end
    cc=cc+1;
end


h=figure;
col=[0.3 0.3 0.3; 1 0 0; 1 0 0.5];

N=[segmentation.tcells1.N];

cc=1;
ytick=[];
cc2=1;

col2=colormap(jet(256));

col3=colormap(hsv(256));

for i=id
    
    rec=[];
    ind=find(i==cellid);
    startY=20*ind;
    
    tcellsind=find(N==i);
    
    if isempty(ytick) || startY>ytick(end)
        ytick=[ytick startY];
        yticklabel{cc2}=['Cell ' num2str(tcellsind)];
        cc2=cc2+1;
        
        
        rec(1,1)=segmentation.tcells1(tcellsind).detectionFrame;
        rec(1,2)=segmentation.tcells1(tcellsind).lastFrame;
        
        %rec(2,1)=segmentation.tcells1(tcellsind).lastFrame;
        % rec(2,2)=segmentation.tcells1(tcellsind).lastFrame;
        
        cindex=1;
        % plot beginning and end of cell life
        Traj(rec,'Color',col,'colorindex',cindex,'tag',['Cell :' num2str(tcellsind) ' - Int :' num2str(rec(1,1)) '-' num2str(rec(1,2))],h,'width',5,'startX',0,'startY',startY,'sepColor',[0.1 0.1 0.1],'sepwidth',0,'gradientwidth',0);
        
        % plot cell size and distance from cavity
        cindex=ones(1,length(segmentation.tcells1(tcellsind).Obj));
        
        cindex2=ones(1,length(segmentation.tcells1(tcellsind).Obj));
        miny=1;
        maxy=1000;
        
        for j=1:length(segmentation.tcells1(tcellsind).Obj)
            
            rec(j,1)=segmentation.tcells1(tcellsind).Obj(j).image;
            rec(j,2)=segmentation.tcells1(tcellsind).Obj(j).image+1;
            
            ar=segmentation.tcells1(tcellsind).Obj(j).area;
            yr=segmentation.tcells1(tcellsind).Obj(j).oy;
            
            
            warning off all
            t=uint8(round(255*(ar-200)/(10000))); % size
            s=uint8(round(255*((yr-miny)/(maxy-miny)))); % distance from extremum
            warning on all;
            cindex(j)=max(1,t);
            cindex2(j)=max(1,s);
            
        end
        
        Traj(rec,'Color',col2,'colorindex',cindex,'tag',['Cell :' num2str(tcellsind)],h,'width',5,'startX',0,'startY',startY-5,'sepColor',[0.1 0.1 0.1],'sepwidth',0,'gradientwidth',0);
        Traj(rec,'Color',col3,'colorindex',cindex2,'tag',['Cell :' num2str(tcellsind)],h,'width',5,'startX',0,'startY',startY+5,'sepColor',[0.1 0.1 0.1],'sepwidth',0,'gradientwidth',0);
    end
        
       rec=[];
        
        rec(1,1)=deb(cc);
        rec(1,2)=fin(cc);
        
        if rec(1,2)==rec(1,1)
           rec(1,2)=rec(1,2)+1;
        end
        
        cindex=2;
        % plot
        
        Traj(rec,'Color',col,'colorindex',cindex,'tag',['Cell :' num2str(tcellsind) ' - Int :' num2str(rec(1,1)) '-' num2str(rec(1,2))],h,'width',5,'startX',0,'startY',startY,'sepColor',[0.1 0.1 0.1],'sepwidth',0,'gradientwidth',0);
        
        cc=cc+1;
    end
    
    set(gca,'YTick',ytick);
    set(gca,'YTickLabel',yticklabel,'FontSize',16,'Color',[0.8 0.8 0.8]);
    
    
    axis tight;
    
    
    % note frame and cell number
    % compute cell motion right before and after (erratic motion)
    % compute variation in cell volume
    
    %case 1 : cell dissappears (dead) - lastFrame ?
    
    %case 2 :  mis segmentation/ tracking --> needs manual fixing
    
    %case 3 : cells leaves the cavity
    
    
    % merge trajectories ???
    
