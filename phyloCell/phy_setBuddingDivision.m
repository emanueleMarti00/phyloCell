function phy_setBuddingDivision()
global segmentation;

% once cell parentage is determined, this function determines bud and
% division timings

displayImage=segmentation.realImage;
budchannel=3;

phy_progressbar;

% firstMCells

firstMCell=segmentation.pedigree.firstMCell;
firstCells=segmentation.pedigree.firstCells;
minDivisionTime=segmentation.pedigree.minDivisionTime;

exclude=firstMCell;

tcells=segmentation.tcells1;
cells=segmentation.cells1;

% sort tcells according to appearance timing;

order=[];
for i=1:numel(tcells)
    order(i)= tcells(i).detectionFrame;
end

[narr o]=sort(order);


% assign daughters to their mothers

phy_progressbar;
pause(0.1);

%list=zeros(length(tcells),size(cells,1),10);


for j=segmentation.pedigree.start:segmentation.pedigree.end
    
    phy_progressbar(double((j-segmentation.pedigree.start+1)/(-segmentation.pedigree.start+segmentation.pedigree.end)));
    
    img=uint16(phy_loadTimeLapseImage(segmentation.position,j,budchannel,'non retreat'));
    warning off all;
    img=imresize(img,segmentation.sizeImageMax);
    warning on all;
    
    budnecks=segmentation.budnecks(j,:);
    budn=[budnecks.n];
    
    
    intensity=zeros(1,length(budnecks));
    
    for l=1:length(budnecks)
        if budnecks(l).n~=0
            bw_cell = poly2mask(budnecks(l).x,budnecks(l).y,size(img,1),size(img,2));
            intensity(budnecks(l).n)=mean(img(bw_cell));
            
            %img(bw_cell)=1000;
        end
    end
    
    
    % figure, imshow(img,[]);
    %return;
    
    for k=1:numel(tcells)
        
        i=o(k);
        
        %  if i<4
        %     continue
        % end
        %   if i>4
        %     continue
        %   end
        
        if tcells(i).N~=0
            
            jk=j-tcells(i).detectionFrame+1;
            
            if jk<=0 || jk>length(tcells(i).Obj)
                continue
            end
            
            %  i,jk
            
            tcells1=tcells(i).Obj(jk);
            
            score=zeros(1,length(budnecks));
            
            %rule 1 : find all possible budnecks in the neighborhood at
            %cell; apply weight based on overlap
            
            [candidates weight]=findBudNecks(budnecks,tcells1);
            
            score(candidates)=10*weight;
            
            if numel(candidates)>1
                fprintf(['cell :' num2str(i) ': frame : ' num2str(j) ' :' num2str(candidates) ' found \n']);
            end
            
            % rule 2 : for recently appeared cells, identified bud neck
            % based on on link with mother
            
            candidates2=[];
            if jk<minDivisionTime-3 && numel(candidates)>0 % todo : iterate until bud neck is gone
                
                % todo : make a list of budnecks available at each frame
                % and assign it to cells, so that prioritites are given to
                % particular cells
                
                % bud neck point of view : 
                %at each frame, found all bud neck potential owners
                % if bud neck links mother and daughter , easy
                % if bud neck has only one owner, easy
                % if bud neck has several owners, then see if other
                % potential owners
                % already had  a budneck
                % this way identify the owner of all the observed budnecks
                % at each frame
                
                motherCell=tcells(i).mother;
                
                if motherCell~=0
                    
                    cells1=segmentation.cells1(j,:);
                    a=[cells1.n];
                    pix=find(a==motherCell);
                    mother=segmentation.cells1(j,pix);
                    
                    % i,j,motherCell,candidates
                    
                    candidates2=scoreBudNeck(mother,candidates,tcells1,budnecks,displayImage);
                    
                    % pause;
                    score(candidates2)=score(candidates2)+20;  
                end
            end
            
            if mean(score)~=0
                %if numel(candidates)
                
                [mx ix]=max(score);
                pix=find(budn==ix);
                
                
                % if i==6 && j<64
                %   'ok'
                %  j,candidates,candidates2,score
                %score,pix
                % end
                
                tcells(i).Obj(jk).budneck.n=pix;
                %tcells(i).Obj(jk).budneck.x=budnecks(pix).x;
                %tcells(i).Obj(jk).budneck.y=budnecks(pix).y;
                %tcells(i).Obj(jk).budneck.area=budnecks(candidates).area;
                tcells(i).Obj(jk).budneck.intensity=intensity(pix);
                
                if jk<minDivisionTime-3 && numel(candidates)>0
                    motherCell=tcells(i).mother;
                    
                    if motherCell~=0
                        if numel(candidates2)~=0
                            
                            tcells(motherCell).Obj(jk).budneck.n=pix;
                            tcells(motherCell).Obj(jk).budneck.intensity=intensity(pix);
                           % i,jk,a= tcells(motherCell).Obj(jk).budneck.n
                        end
                    end
                end
                
            else
                tcells(i).Obj(jk).budneck=[];
            end
            
            %                 if numel(pix)==0
            %                     fprintf(['cell ' num2str(i) ': no mother cell found \n']);
            %                 end
            %                 if numel(pix)>1
            %                     fprintf(['cell ' num2str(i) ': ambiguity : ' num2str(pix) '\n']);
            %                 end
            
            
        end
    end
end

phy_progressbar(1);
pause(0.1);

%out=checkBadTimings(tcells,minDivisionTime);


function [out weight]=findBudNecks(budnecks,cells1)
% identify budnecks in the vicinity of the target cell based on cell
% contours overlap


scale=1.1;

xc=scale*(cells1.x-mean(cells1.x))+mean(cells1.x);
yc=scale*(cells1.y-mean(cells1.y))+mean(cells1.y);

%figure, plot(xc,yc,'Color','r'); hold on;

out=[]; weight=[];

for i=1:length(budnecks)
    if budnecks(i).n~=0
        x=budnecks(i).x;
        y=budnecks(i).y;
        %   plot(x,y,'Color','b');
        
        t=inpolygon(x,y,xc,yc);
        if mean(t)>0.1
            out=[out budnecks(i).n] ;
            weight=[weight mean(t)];
        end
    end
end


function out=scoreBudNeck(mother,candidates,targetCell,budnecks,displayImage)

masks=(zeros(size(displayImage(:,:,1))));

% build mask with budneck label
for k=1:length(candidates)
    j=candidates(k);
    
    if budnecks(j).n~=0
        
        bw_cell = poly2mask(budnecks(j).x,budnecks(j).y,size(displayImage,1),size(displayImage,2));
        
        masks(bw_cell)=budnecks(j).n;
    end
end

out=[];

% identify budneck at the interface between target and candidates


theta=atan2(mother.oy-targetCell.oy,mother.ox-targetCell.ox);

if abs(theta)<pi/4 || abs(theta)>3*pi/4
    xc=[targetCell.ox-3 targetCell.ox+3 mother.ox+3  mother.ox+3 targetCell.ox-3];
    yc=[targetCell.oy-3 targetCell.oy+3 mother.oy+3  mother.oy-3 targetCell.oy-3];
else
    xc=[targetCell.ox-3 targetCell.ox+3 mother.ox+3  mother.ox-3 targetCell.ox-3];
    yc=[targetCell.oy-3 targetCell.oy-3 mother.oy+3  mother.oy+3 targetCell.oy-3];
end

ar=polyarea(xc,yc);

if ar<10
    %ar,theta
    figure, imshow(masks,[]); line(xc,yc);
end

bw_target = poly2mask(xc,yc,size(displayImage,1),size(displayImage,2));
pix=masks(bw_target);

% figure, imshow(masks,[]); line(xc,yc);
nc=max(candidates);

[nr_pix,nr_cell] = hist(pix,0:nc);
nr_pix=nr_pix(2:end);
[mx ix]=max(nr_pix);

%if targetCell.n==13
%mx,ix
%end

if mx>1
    out=ix;
end

function out=scoreTimings(tcells,candidates3,fr,minDivisionTime)

out=[];
for i=candidates3
    budTimes=tcells(i).budTimes;
    
    if numel(budTimes)~=0
        lastBud=budTimes(end);
    else
        lastBud=tcells(i).detectionFrame;
    end
    
    if fr-lastBud>minDivisionTime
        out=[out i];
    end
    
end

function out=checkBadTimings(tcells,minDivisionTime)


for i=1:numel(tcells)
    timings=tcells(i).budTimes;
    if numel(timings)>1
        delta=timings(2:end)-timings(1:end-1);
        pix=find(delta<minDivisionTime);
        for j=1:numel(pix)
            fprintf(['cell ' num2str(i) ': incoherent bud timing at frame : ' num2str(tcells(i).budTimes(pix+1)) ' with daughter: ' num2str(tcells(i).daughterList(pix+1)) '\n']);
        end
    end
end
out=1;


