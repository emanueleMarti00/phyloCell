function h=plotEnvironmentVariables(varargin)
% posisible parameters :
% 'valves','temperatureObj','temperatureStage','temperatureCommand',tempera
% tureRoom','minutes',
% 'legend'
% 
% example :
% plotEnvironmentVAriables('valves','temperatureObj','minutes', 'legend')

global monitorSpy;
global timeLapse;

load(strcat(timeLapse.realPath,timeLapse.filename,'-MonitorLog.mat'));

nplot=0;
valves=0;
tobj=0;
tstage=0;
tcom=0;
troom=0;
minutes=0;
legende=0;
phylo=0;
frame=0;

for k=1:size(varargin,2) 
    
   str=varargin{k};
   if strcmp(str,'valves')
       valves=1;
   end
   if strcmp(str,'temperatureObj')
       tobj=1;
   end
   if strcmp(str,'temperatureStage')
       tstage=1;
   end
   if strcmp(str,'temperatureCommand')
       tcom=1;
   end
    if strcmp(str,'temperatureRoom')
       troom=1;
    end
    if strcmp(str,'minutes')
       minutes=1;
    end
    if strcmp(str,'legend')
       legende=1;
    end
    
    if strcmp(str,'phylo')
        % in case used by phylocell display
       phylo=1;
    end
    
    if isnumeric(str)
        frame=str;
    end
end

temp=logical(tobj+tstage+tcom);
temp=double(temp);

plotSum=valves+temp+troom;

% get data from monitorSpy log file
for i=1:numel(monitorSpy.list)
   
    tstageArr(i)=monitorSpy.list(i).currentTemperature1;
    tobjArr(i)=monitorSpy.list(i).currentTemperature2;
    troomArr(i)=monitorSpy.list(i).alarmTemperature2;
    %temp2b(i)=monitorSpy.list(i).alarmTemperature2;
end


%get data from the seqeuncer variable
sequencer=timeLapse.sequencer;
seqFrame=phy_createSequencerRefArray(sequencer);

tcomArr=[];
for i=1:numel(seqFrame)
    tcomArr(i)=seqFrame(i).temperature;
    valvesArr(i)= seqFrame(i).valves;
end



if minutes
    timeArr=0:timeLapse.interval*3/180:(numel(monitorSpy.list)-1)*timeLapse.interval*3/180;
else
    timeArr=1:1:numel(monitorSpy.list);
end

if numel(tcomArr)~=0
if length(timeArr)>length(tcomArr)
    tcomArr(end+1:length(timeArr))=tcomArr(end);
    valvesArr(end+1:length(timeArr))=valvesArr(end);
end
end


h=figure;
%set(h,'Visible','off');
tplot=0;
i=1;
str='';
cleg=1;

    if valves
       %subplot(plotSum,1,i); 
       plot(timeArr,valvesArr,'Color','r','LineWidth',1.5); hold on;
       
       if phylo
       plot(timeArr(frame),valvesArr(frame),'Marker','o','Color','r','LineWidth',2); hold on;
       set(gca,'FontSize',10);
       ylabel('Valves position');
       
       ax = findobj(h,'Type','axes');
       
       set(ax,'Color','none');
       set(ax,'XColor',[1 1 1]);
       set(ax,'YColor',[1 1 1]);
       set(ax,'LineWidth',1.5);
       ylim([0.95*min(valvesArr) 1.05*max(valvesArr)]);
       else
       set(gca,'FontSize',16);
       ylabel('Valves position');
       end
       i=i+1;
    end
    
    if tobj || tstage || tcom 
        if ~tplot
       subplot(plotSum,1,i); 
       tplot=1;
        end
        if tobj
        plot(timeArr,tobjArr,'Color','b'); hold on;
        set(gca,'FontSize',16);
        str(cleg,:)='Objec';
        cleg=cleg+1;
        end
        if tstage
        plot(timeArr,tstageArr,'COlor','g'); hold on; 
        str(cleg,:)='Stage';
        cleg=cleg+1;
        end
        if tcom
          %  timeArr,tcomArr
          if numel(tcomArr)~=0
        plot(timeArr,tcomArr,'Color','r','LineWidth',1.5); hold on; 
        str(cleg,:)='Comma';
        
         if phylo
       plot(timeArr(frame),tcomArr(frame),'Marker','o','Color','r','LineWidth',2); hold on;
       set(gca,'FontSize',10);
       ylabel('T (�C)');
       
       ax = findobj(h,'Type','axes');
       
       set(ax,'Color','none');
       set(ax,'XColor',[1 1 1]);
       set(ax,'YColor',[1 1 1]);
       set(ax,'LineWidth',1.5);
       ylim([0.95*min(tcomArr) 1.05*max(tcomArr)]);
       else
       set(gca,'FontSize',16);
       ylabel('T (�C)');
         end
        end
        end
       
        if legende
        legend(str);
        end
        
        i=i+1;
       
    end
    
    if troom
       subplot(plotSum,1,i);  plot(timeArr,troomArr); hold on; 
       ylabel('Room temperature (�C)');
       set(gca,'FontSize',16);
    end
    


if minutes
    %if ~phylo
    xlabel('Time (min)');
    %end
else
    %if ~phylo
    xlabel('Time (frames)');
    %end
end

if plotSum==1
   ps=get(gca,'Position');
   ps(4)=ps(4)*0.5;
   set(gca,'Position',ps);
   
end
%legend('off');
%if get(handles.legend,'Value')
%legend(leg);
%end



% subplot(3,1,2); plot(temp1,strcat('-',cell2mat(col(1)))); hold on;
%   plot(temp2,strcat('-',cell2mat(col(2)))); 
%    plot(temp2b,strcat('-',cell2mat(col(3))));
%    legend('Stage Temperature','Objective Temperature','Objective Control');
%     ylabel('Temperature (celsius)'); hold on;
% subplot(3,1,3);    plot(temp1b,strcat('-',cell2mat(col(4))));
%      ylabel('Temperature (celsius)');
% xlabel('Frames');
% %title(' Temperature drift ');
%  legend('Room Temperature');
%  
 %h=gcf;
 %saveas(h,strcat(timeLapse.realPath,timeLapse.filename,'-monitor.fig'));
 %close(h);
 
  if ~phylo
 myExportFig(strcat(timeLapse.realPath,timeLapse.filename,'-environment.pdf'),gcf,'-nobackground');
  end

 
 