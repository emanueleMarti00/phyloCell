function  segmentation=phy_createProcessingVariable(segmentation)


segmentation.processing.features={'cells1';'budnecks';'foci'; 'nucleus';'mito'};

segmentation.processing.process={'segment - Ball inflation'; ...
         'segment - Watershed'; ...
         'segment - Homothetic inflation';...
         'segment - Motion Based Segmentation'; ...
         'segment - Bud neck fluorescence';...
         'segment - Foci fluorescence';...
         'segment - Mitochondria fluorescence';...
         'map     - Iterative Closest Point';...
         'map     - Size-distance optimization';
         'map     - Size-Distance Cavity'; ...
         'segment - Watershed AG'; ...
         'map - Map AG 1'; ...
         'map - Map AG 2'; ...
         'segment - Watershed GC'; ...
         'segment - Nucleus fluorescence'; ...
         'segment - Watershed GC BF'};
     

%segmentation.processing.selectedFeature=1;
%segmentation.processing.selectedProcess=[1 1 1 1 1];

segmentation.processing.parameters={};

segmentation.processing.parameters{1}={'Channel',1;...
                                       'Min Cell Size', 500; ...
                                       'Max Cell Size', 10000};
segmentation.processing.parameters{2}={'Channel',1;...
                                       'Brightfield --> 1 Phase COntrast --> 0',0;...
                                       'Ellipse shape control',50;...
                                       'Typical cell diameter (pixels)',40;...
                                       'Min Cell Size', 500; ...
                                       'Max Cell Size', 10000};
segmentation.processing.parameters{3}={'Channel',1;...
                                       'Typical cell diameter (pixels)',40;...
                                       'Min Cell Size', 500; ...
                                       'Max Cell Size', 10000; ...
                                       'Cell Type (Cerevisiae -> 0 ; Pombe -> 1', 0;...
                                       'Iteration Number', 70;...
                                       'Shape Restore Coef', 0.6;...
                                       'Inflation Strength', 0.04;...
                                       'Convergence Speed', 4;...
                                       'Track Single Cells (no->0 yes-> 1)', 0;...
                                       'Stengthen gradient (no->0 yes-> 1)', 0;...
                                       'Display Segmentation Steps (no->0 yes-> 1)', 0;};
                                   
segmentation.processing.parameters{4}={'Channel',1;...
                                       'Min Cell Size', 500; ...
                                       'Max Cell Size', 10000};
                                   
segmentation.processing.parameters{5}={'Channel',2;...
                                       'Min Cell Size', 20; ...
                                       'Max Cell Size', 1000; ...
                                       'Typical object size (pixels)',10; ...
                                       'Detection Sensitivity (-1 -> +1)', 0};

segmentation.processing.parameters{6}={'Channel',2;...
                                       'Min Cell Size', 1; ...
                                       'Max Cell Size', 1000; ...
                                       'Typical object size (pixels)',10; ...
                                       'Threshold level', 1.2; ...
                                       'Cells ID', 0};  
                                  
segmentation.processing.parameters{7}={'Channel',2;...
                                       'Min Cell Size', 20; ...
                                       'Max Cell Size', 1000; ...
                                       'Typical object size (pixels)',10; ...
                                       'Threshold level', 100}; 
                                   
segmentation.processing.parameters{8}={'Mapping persistence (frames)', 1;...
                                       'Typical cell diameter (pixels)', 40};
                                   
segmentation.processing.parameters{9}={'Mapping persistence (frames)', 1; ...
                                       'Max displacement allowed', 40; ...
                                       'Allow cell shrink',1; ...
                                       'Weight distance', 1; 
                                       'Weight size', 0; ...
                                       'Filter position', 0;}; 
                                   
segmentation.processing.parameters{10}={'Mapping persistence (frames)', 1};


segmentation.processing.parameters{11}={'Channel', 1; ...
                                        'Algorithm', 5; ...
                                        'Cavity mask', 'Stress_and_cell_cycle_31_1_mask.png'};

segmentation.processing.parameters{12}={'areaWeight', 0.2; ...
                                        'xWeight', 0.2; ...
                                        'yWeight', 0.6; ...
                                        'costThreshold', 0.004; ...
                                        'minimumAreaVariation', -0.5; ...
                                        'maximumAreavariation', 14; ...
                                        'Cavity mask', 'Stress_and_cell_cycle_31_1_mask.png'};

segmentation.processing.parameters{13}={'areaWeight', 0.2; ...
                                        'xWeight', 0.15; ...
                                        'yWeight', 0.55; ...
                                        'costThreshold', 0.004; ...
                                        'Cavity mask', 'Stress_and_cell_cycle_31_1_mask.png'};
                                    
segmentation.processing.parameters{14}={'Channel',1;...
                                       'Min Cell Size', 10; ...
                                       'Max Cell Size', 20000; ...
                                       'Typical object size (pixels)',50; ...
                                       'Threshold', 0.25; ...
                                       'Find cell cluster', 0; ...
                                       'Display steps', 0;};
                                      % 'Contour Threshold', 0.3;};
                                      
segmentation.processing.parameters{15}={'Channel',2;...
                                       'Min Cell Size', 20; ...
                                       'Max Cell Size', 4000; ...
                                       'Threshold level', 60};  
                                   
 segmentation.processing.parameters{16}={'Channel',1;...
                                       'Min Cell Size', 10; ...
                                       'Max Cell Size', 20000; ...
                                       'Typical object size (pixels)',50; ...
                                       'Threshold', 0.25; ...
                                       'Find cell cluster', 0; ...
                                       'Display steps', 0;};
                                      % 'Contour Threshold', 0.3;};
                                      
                                   
segmentation.processing.parameters= repmat(segmentation.processing.parameters,[5 1]);

segmentation.processing.selectedProcess=ones(1,length(segmentation.processing.features));
segmentation.processing.selectedFeature=1;