function [] = phy_cut_bud_mother(hObject, eventdata, handles)
%Camille Paoletti - 11/2013

%cut a segmented cell in bud + mother with the help of 2 intersection
%points in input

global segmentation

if isempty(segmentation.selectedObj)
    
    errordlg('First select a cell');
    
else
    
    x=segmentation.selectedObj.x;
    y=segmentation.selectedObj.y;
    x=repmat(x,2,1);
    y=repmat(y,2,1);
    
    [xc,yc] = getpts(handles.axes1);
    xc=repmat(xc,1,length(x));
    yc=repmat(yc,1,length(x));
    
    
    dist=(x-xc).^2+(y-yc).^2;
    
    [~,ind]=min(dist,[],2);
    
    x=segmentation.selectedObj.x;
    y=segmentation.selectedObj.y;
    
    indMin=min(ind);
    indMax=max(ind);
    
    if indMax-indMin<26
        xb=horzcat(x(indMin:indMax),x(indMin));
        yb=horzcat(y(indMin:indMax),y(indMin));
        xm=horzcat(x(1:indMin),x(indMax:end));
        ym=horzcat(y(1:indMin),y(indMax:end));
    else
        xm=horzcat(x(indMin:indMax),x(indMin));
        ym=horzcat(y(indMin:indMax),y(indMin));
        xb=horzcat(x(1:indMin),x(indMax:end));
        yb=horzcat(y(1:indMin),y(indMax:end));
    end
    
    [xm,ym]=phy_changePointNumber(xm,ym,50);
    [xb,yb]=phy_changePointNumber(xb,yb,50);
    
    
    %actualisation du contour de la m�re
    segmentation.selectedObj.x=xm;
    segmentation.selectedObj.y=ym;
    segmentation.selectedObj.ox=mean(xm);
    segmentation.selectedObj.oy=mean(ym);
    segmentation.selectedObj.area=polyarea(xm,ym);
    set(segmentation.selectedObj.hcontour,'xData',xm);
    set(segmentation.selectedObj.hcontour,'yData',ym);
    set(segmentation.selectedObj.htext,'position',[mean(xm),mean(ym)]);
    %set(segmentation.selectedObj.htext,'visible','on');
    %set(segmentation.selectedObj.hcontour,'visible','on');
    
    pos=segmentation.frame1;
    
    %actualisation du contour du bud
    bud=phy_Object;
    a=[segmentation.cells1.n];
    bud.n=max(a)+1;
    bud.x=xb;
    bud.y=yb;
    bud.area=polyarea(xb,yb);
    bud.ox=mean(xb);
    bud.oy=mean(yb);
    bud.image=pos;
    
    
    
    segmentation.cells1(pos,end+1)=bud;
    segmentation.frameChanged(pos)=1;
    
    warning off all;
    phy_change_Disp1('refresh',handles);
    warning on all;
end








end

