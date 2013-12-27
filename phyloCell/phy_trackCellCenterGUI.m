function phy_trackCellCenterGUI(varargin)
% Plays a matlab movie
%
% USAGE:
%   playmovie(m,fps,n,option)
%
% EXAMPLES:
%   playmovie('C:\MATLAB6p5\work\animation.mat')
%   playmovie(mov,2,1,'slider')
%   playmovie(mov,1,'fullscreen','slider')
%
% DESCRIPTION:
%   Plays the movie frames movieframes
%   n times at frmprsc frames per second
%   The default values for n and frmprsc
%   are 1 and 2 frames per second
%   movieframes can also be a filename of
%   a .mat file containing the
%   movie frames
%   The name of the variable does
%   not matter as long as there
%   is only one variable
%
% NOTES:
%   if option is equal to 'slider'
%   a slider is placed at the bottom
%   of the figure which allows
%   for sections to be played
%   if option is equal to 'fullscreen'
%   the movie frames are displayed in
%   a full screen type mode, otherwise
%   frames are displayed in true size
%   When using the fullscreen mode
%   and the movie ends, press any key
%   to close the figure
%
%   More than one option can be used at
%   the same time
%   
%   
%Copy-Left, Alejandro Sanchez

error(nargchk(1,5,nargin))

%---------- Initialize Values ----------
global movieframes frmprsc hslider himage hfig control hrecord
frmprsc = [];
n = [];

%----- Get Movie Frames if .mat file specified ------
if ischar(varargin{1})
    try
        load(varargin{1});
    catch
        error(['Unable to open in-file: ',varargin{1}])
    end %try
    if isempty(movieframes)
        a = who;
        ind = strcmp(a,'varargin') + strcmp(a,'frmprsc') ...
            + strcmp(a,'n') + strcmp(a,'hslider') + strcmp(a,'himage');
        ind = find(ind==1);
        a(ind) = [];
        if length(a) > 1
            error([varargin{1},' must only contain one variable'])
        end %if
        eval(['movieframes = ',a{1},';']);
    end %if 
end %if

%----------- Defaults -----------------
sliderposition = [0.25, 0.01, 0.5, 0.03];
buttonposition = [0.8, 0.01, 0.07, 0.03];
slider = 0;
fullscreen = 0;

for k=1:length(varargin)
    if iscell(varargin{k})
        Mt = varargin{k};
        sz = size(varargin{k});
        dim = find(max(sz)==sz);
        n = length(Mt{1});
        movieframes = zeros(n,1);
        for c=1:n
            movieframes(c).cdata = cat(dim,Mt{1}(c).cdata,...
                Mt{2}(c).cdata);
            movieframes(c).colormap = [];
        end
    elseif isstruct(varargin{k})
        movieframes = varargin{k};
    elseif ischar(varargin{k}) && k>1
        if strcmpi(varargin{k}(1:4),'slid')
            slider = 1;
        elseif strcmpi(varargin{k}(1:4),'full')
            fullscreen = 1;
        else
            warning('Invalid Option')
        end %if
    elseif isnumeric(varargin{k}) && isempty(frmprsc)
        frmprsc = varargin{k};        
    elseif isnumeric(varargin{k}) && isempty(n)
        n = varargin{k};
    end %if
end %for

if isempty(frmprsc)
    frmprsc = 2;
end
if isempty(n)
    n = 1;
end

N = length(movieframes);

if N==1 & slider==1
    warning('Cannot display only one image with slider')
    slider = 0;
end

%----- Set Image Processing Toolbox preference ---
iptsetpref('ImshowBorder','tight')
%iptsetpref('ImshowTruesize','auto')

if fullscreen
    set(gcf,'Units','Normalized','Position',[0,0.0293,1.0,0.8945]) %adhoc
    set(gca,'Units','Normalized','Position',[0, 0, 1, 1])
else
%    iptsetpref('ImviewInitialMagnification',100)
end


hfig=figure;

        himage = imshow(movieframes(1).cdata,...
            movieframes(1).colormap);
        set(himage,'EraseMode','None')
        
        set(hfig,'WindowButtonMotionFcn',@figure1_WindowButtonMotionFcn);
        set(hfig,'WindowButtonDownFcn',@figure1_WindowButtonDownFcn);
        set(hfig,'WindowKeyPressFcn',@arrows);
        
        hslider = uicontrol('Style','Slider','Units','Normalized',...
        'Position',sliderposition,'Min',1,'Max',N,'Value',1,...
        'SliderStep',[1/(N-1), 5/(N-1)],'BusyAction','cancel',...
        'TooltipString','Click on slider to move through movie',...
        'Callback', @setslider);
    set(gcf,'Toolbar','figure')
    
        hforw=uicontrol('Style','pushbutton','Units', 'Normalized','Position',[0 0 0.1 0.1],'String','Forward','Callback',@forward);
        hback=uicontrol('Style','pushbutton','Units', 'Normalized','Position',[0.12 0 0.1 0.1],'String','Backward','Callback',@backward);
        hstop=uicontrol('Style','pushbutton','Units', 'Normalized','Position',[0.8 0 0.1 0.1],'String','Stop','Callback',@stopmovie);
        
        hrecord=uicontrol('Style','pushbutton','Units', 'Normalized','Position',[0.9 0 0.1 0.1],'String','Not Recording','Callback',@recordTraj);
        
        control.currentFrame=1;
        control.dir='forward';
        control.playing=0;
        control.lastFrame=N;
        control.record=0;
        control.traj=[];
        control.traj.x=zeros(1,N);
        control.traj.y=zeros(1,N);
      
    function setslider(hObject,eventdata,handle)
     global movieframes frmprsc hslider himage control
      ind = fix(get(hslider,'Value'));
      set(himage,'Cdata',movieframes(ind).cdata);
      control.currentFrame=ind;
      
       

    function arrows(hObject,eventdata,handle)
       global movieframes frmprsc hslider himage hfig control
       
       k=control.currentFrame;
       
        if strcmp(eventdata.Key,'leftarrow')
            if k>1
            displ(k-1)
            end
        end
     
        if strcmp(eventdata.Key,'rightarrow')
            if k<control.lastFrame
            displ(k+1)
            end
        end
        
        if strcmp(eventdata.Key,'f')
            control.dir='forward';
            playm();
        end
        
        if strcmp(eventdata.Key,'b')
            control.dir='backward';
            playm();
        end
        
         
    
    function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)    
   global hfig control
    figure(hfig);
    cp = get(gca,'CurrentPoint');
    control.cp=cp;
    
    function figure1_WindowButtonDownFcn(hObject, eventdata, handles)    
   global control
   k=control.currentFrame;
   
   control.traj.x(k) = control.cp(1,1);
   control.traj.y(k) = control.cp(1,2);
            
   if isfield(control,'hline')
            if ishandle(control.hline)
                delete(control.hline);
            end
   end
          
   control.hline=line(control.traj.x(k),  control.traj.y(k) , 'Marker','o','MarkerSize',10);
   
   if strcmp(control.dir,'forward')
   displ(k+1)
   else
   displ(k-1)    
   end



 function forward(hObject, eventdata, handles)
    global movieframes frmprsc hslider himage hfig control
    
    control.dir='forward';
    control.playing=0;
    playm()
     
 function backward(hObject, eventdata, handles)
     global movieframes frmprsc hslider himage hfig control
   
    control.dir='backward';
    control.playing=0;
    playm()
    
  function stopmovie(hObject, eventdata, handles)
     global movieframes frmprsc hslider himage hfig control
   
    control.playing=0;
    
 function playm()
     global movieframes frmprsc hslider himage hfig control
    
    if control.playing==0
    control.playing=1;
    else
    control.playing=0;  
    return;
    end
    
    N = length(movieframes);
    
     pause(1/frmprsc);
     
     st=control.currentFrame;
     
     if strcmp(control.dir,'forward')
     en=N;
     arr=st:N;
     else
     en=1;
     arr=fliplr(1:st);
     end

     
     cont=1;
     
        for k = arr
            displ(k);
            pause(1/frmprsc)
            
            if control.playing==0
               break; 
            end
        end %for    
     
     control.playing=0;
     
function displ(k)
global movieframes frmprsc hslider himage hfig control    
            set(himage,'Cdata',movieframes(k).cdata)
            set(hslider,'Value',k);
            control.currentFrame=k;

            
            if isfield(control,'hline')
            if ishandle(control.hline)
                delete(control.hline);
            end
            end
            
            if control.traj.x(k)~=0
            control.hline=line(control.traj.x(k),  control.traj.y(k) , 'Marker','o','MarkerSize',10);
            end

            
          
            
           
function recordTraj(hObject, eventdata, handles)
 global movieframes frmprsc hslider himage hfig control hrecord
 
 if control.record==0
     control.record=1;
     set(hrecord,'String','Recording');
    
     
     if isfield(control,'hline')
         if ishandle(control.hline)
             delete(control.hline);
         end
     end
 else
     control.record=0;
     set(hrecord,'String','Not recording');
     %cla;
     
     if isfield(control,'hline')
         if ishandle(control.hline)
             delete(control.hline);
         end
     end
     
     pix=find(control.traj.x~=0);
     control.hline=line(control.traj.x(pix),control.traj.y(pix));
 end
    
        

            
        