%% Clean up console and variables

for ii=0:10
    
clc; close all; %clear all;
keepvars = {'ii'};
clearvars('-except', keepvars{:});

addpath('classes');
addpath('utilities');

%% Supress warnings
warning('off', 'MATLAB:nearlySingularMatrix');

%% Raw Data Log Folder
logfolder = 'logs/ped04/';
%ped01 --> boot4, 136
%ped01 --> boot4, 145
%% Node/Network configuration
configfile = 'config/nodepositions_nesl_mobile_ped03';

%% Create Network Manager
% NetworkManager(nodeconfig, datafolder, <owr_corrections>, <twr_corrections>) 
nm = NetworkManager(configfile, logfolder, 'config/antennacorrections_mocap', 'config/twrcorrections_mocap', 'config/twrcorrections_mocap' );
node_ids = nm.getNodeIds();
node_names = nm.getNodeNames();

%% Rigid body IDs
nm.setRigidBodyId('ntb-mobile', 1);

%% Black-listed nodes
%nm.blacklistNode('ntb-charlie');

%% Select reference node
nm.setReferenceNode('ntb-alpha');

%% Bootstrap the node positions and clock params before filter starts
% use first second of measurements to bootstrap node states
%nm.skipTime(35);
nm.skipTime(10);
nm.bootstrapNodeStates( 4.0 );
%

%nm.setStaticNodesToTruePosition();

%% Measurement type selection
nm.enableMessageType(nm.MSGTYPE3, true);
nm.enableMessageType(nm.MSGTYPE1, true);
nm.enableMeasurementType(nm.MEASTYPE_d, true);
nm.enableMessageType(nm.MSGTYPE2, true);
nm.enableMeasurementType(nm.MEASTYPE_r, true);

nm.enableMeasurementType(nm.MEASTYPE_R, true);
%nm.setMessageMinInterval(nm.MSGTYPE3, 2.00);
nm.enableSLATS(true);


%% Set some known anchor positions if desired
%known_anchors = {'ntb-alpha', 'ntb-bravo', 'ntb-charlie', 'ntb-delta', 'ntb-hotel', 'ntb-golf', 'ntb-echo', 'ntb-foxtrot'};
known_anchors = {};
for i=1:length(known_anchors)
    aid = known_anchors{i};
    aidx = nm.getNodeIdx( aid );
    nm.nodes{ aidx }.var_p = [0.0; 0.0; 0.0];
end

%% Process Covariances
% Process and Initial noise and state vals are determined by each node object
Q = nm.getProcessVar();
P = nm.getInitialVar();

%% Save as movie
SAVEMOVIE = false;
if SAVEMOVIE
    vidObj = VideoWriter('output/mocap.avi');
    vidObj.FrameRate=20;
    open(vidObj);
end

%% Position Visualization
% get current true and estimated positions
pTruStatic = nm.getTrueStaticPositions();
pEstAll = nm.getTransformedPositions();

fig = cfigure(25,25); grid on; hold on; axis equal;

htruStatic = plot3(pTruStatic(:,2),pTruStatic(:,3),pTruStatic(:,4),'^k','MarkerSize',10, 'MarkerFaceColor', 'k');
hestAll = plot3(pEstAll(:,1),pEstAll(:,2),pEstAll(:,3),'r+');
herrStatic = zeros(nm.getNumStaticNodes(),1);
hvar = zeros(nm.getNumNodes(),1);
varscale = 1.00;
for i=1:nm.getNumNodes()
    nid = node_ids(i);
    % if node is static, plot error line to true position
    if ~nm.nodes{i}.isMobile()
        herrStatic(i) = plot3([pTruStatic(i,2) pEstAll(i,1)],[pTruStatic(i,3) pEstAll(i,2)],[pTruStatic(i,4) pEstAll(i,3)], nm.getPlotStyle(nid), 'Color', nm.getPlotColor(nid));
    end
    % if node is the reference, add text saying so
    if nm.nodes{i}.isReference()
        xyz = nm.nodes{i}.getTruePosition();
        text( xyz(1)-0.50, xyz(2) - 0.30, xyz(3), 'Reference');
    end
    % add text for each node
    if ~nm.nodes{i}.isMobile()
        xyz = nm.nodes{i}.getTruePosition();
        text( xyz(1)-0.50, xyz(2) + 0.50, xyz(3), nm.nodes{i}.getName() );
    end
    
    % get a node's position covariance matrix    
    nidx = (i-1)*5 + 1;
    Pi = P( nidx:(nidx+2), nidx:(nidx+2) ) + 0.01*[1 0 0; 0 0 0; 0 0 1];
    hvar(i) = plotEllipse([pEstAll(i,1); pEstAll(i,2); pEstAll(i,3)], Pi, varscale);
end

% rigid bodies in mocap
rigid_bodies = nm.dataparser.getRigidBodyIds();
hrigidbodies = zeros( length(rigid_bodies),1 );
for i=1:length(rigid_bodies)
    hrigidbodies(i) = plot3(0, 0, 0, 'sb', 'MarkerSize', 10, 'MarkerFaceColor', 'k', 'LineWidth', 2);
end

xlim([-7 7]);
ylim([0 4]);
zlim([-7 7]);
xlabel('X Position (m)', 'FontSize',14);
ylabel('Y Position (m)', 'FontSize',14);
zlabel('Z Position (m)', 'FontSize',14);
htitle = title('NESL Network Localization (t = 0.00s)','FontSize',16);
view(180,0);
%legend(herr, nm.getNodeNames());
drawnow;

%% Replay data and run EKF
% analysis stop time
t_stop = 145;
% state, time, and transformed position history
s_history = [];
p_history = {};
cov_history = [];
pDKAL_history =[];
P_big_history = [];
t_history = [];
timeUpdateFlag_history = [];
DiffFlag_history = [];
MeasFlag_history = [];

nm.network= { [1 2 3 4 5 6 7 8 9],[1 2 3 4 5 6 7 8 9],[1 2 3 4 5 6 7 8 9],[1 2 3 4 5 6 7 8 9],[1 2 3 4 5 6 7 8 9],[1 2 3 4 5 6 7 8  9],[1 2 3 4 5 6 7 8 9],[1 2 3 4 5 6 7 8 9],[1 2 3 4 5 6 7 8 9]};

% last global time update
meas1 = nm.getNextMeasurement();
t_start = meas1.getTime();
t_last = t_start;
k = 0;

nm.setneigh_forall();
nm.init_x_P_forall(nm.getState(),P);

% plotting
plot_delay = 0*0.100; % sec
plot_last = t_start;

tlast_twr = 0;
period_twr = 5.00;

PDESIRED = ii;
MOBILEID = 8;


numofnodes=9;
numofstates=5;
M=numofnodes*numofstates;

%P_big=4*eye(9*M,9*M);
nm.cov_big=blkdiag(nm.nodes{1}.P,nm.nodes{2}.P,nm.nodes{3}.P,nm.nodes{4}.P,nm.nodes{5}.P,nm.nodes{6}.P,nm.nodes{7}.P,nm.nodes{8}.P,nm.nodes{9}.P);
nm.P_big=blkdiag(nm.nodes{1}.P,nm.nodes{2}.P,nm.nodes{3}.P,nm.nodes{4}.P,nm.nodes{5}.P,nm.nodes{6}.P,nm.nodes{7}.P,nm.nodes{8}.P,nm.nodes{9}.P);
avg_trace = PDESIRED +1;
avg_pDKAL = PDESIRED +1;
diffEnable = 1; % enable diffusion
while (t_last - t_start) < t_stop
    k = k + 1;
    
    % get next measurement object
    meas = nm.getNextMeasurement();
    if isempty(meas)
        break;
    end
    walltime = meas.getTime();
    z = meas.vectorize();
    R = meas.getCovariance();  
    
%     if meas.getSourceId() == MOBILEID || meas.getDestId() == MOBILEID 
%         if ~meas.queued
%             savemsgs = savemsgs +1;
%             continue;
%         else
%             sentmsgs = sentmsgs+1;
%         end
%     end
       
    % delta-time uses wallclock (desktop timestamp) for now
    dt_ref = meas.getTime() - t_last;
    t_last = walltime;
    t_history = [t_history; walltime];
    
    % get network state vector
    %s = nm.getState();
    s= nm.getAndFixStateConc();
    % configure process and measurement functions
    f = @(s) nm.processFcn(s, dt_ref);
    h = @(s) nm.measurementFcn(s, meas);
    
    % update state estimate
%     s = nm.getState();
%     [s, P] = ekf(f, s, P, h, z, dt_ref*Q, R);

 


    %  [x, P] = ekf(f,x,P,h,z,Q,R);            % ekf 
 % [x_next,P_next] = dif_ekf(f,x_next,P_next,h,Q,R,[z z z],l,G,c);
 
  
 
 %every node participates with its estimate for position
     nm.setState(nm.getAndFixStateConc());
    

    % update position estimates
    pTruStatic = nm.getTrueStaticPositions();
    pEstAll = nm.getTransformedPositions();
    
    % ----- CONDITIONAL MESSAGING -----
%     mobIdx = nm.getNodeIdx( MOBILEID );
%     stateIdx = (mobIdx-1)*5 + 1;
%     Pi = nm.nodes{mobIdx}.P(stateIdx:(stateIdx+2), stateIdx:(stateIdx+2));
   % P_big=nm.getCovWithXerror(meas,P_big,dt_ref,walltime) ;

  % if avg_trace > PDESIRED
  if avg_pDKAL > PDESIRED
      %    if k > 749
%        k
%    end
        bestNode = -1;
        bestP = 0;
        nm.publishmeas_forneigh(meas,h);
        RunMeasFlag = nm.checkekf_p1_forall( dt_ref,meas);
        %RunMeasFlag = nm.checkekf_p1_forall_fake( dt_ref,meas);
        nm.publisheita_forneigh();
        [RunDiffFlag,RunTimeFlag]= nm.checkekf_p2_forall(f,dt_ref*Q ,diffEnable,dt_ref);
        % send a RIJ measurement to mobile node
        %cov_big=nm.getCov(meas,cov_big,dt_ref) ;
        timeUpdateFlag_history = [timeUpdateFlag_history RunTimeFlag];
        DiffFlag_history = [DiffFlag_history RunDiffFlag];
        MeasFlag_history = [MeasFlag_history RunMeasFlag];
        
        %%%
        cov_big = nm.cov_big;
        P_mobile = cov_big(45*8+1:end,45*8+1:end);
        mobIdx = nm.getNodeIdx( MOBILEID );
        stateIdx = (mobIdx-1)*5 + 1;
        Pi = P_mobile(stateIdx:(stateIdx+2), stateIdx:(stateIdx+2));

        
        
        %if max(max(Pi)) > PDESIRED
        %cov_history = [cov_history; [walltime max(max(Pi))]];
        avg_trace = trace(Pi)/3;
        %avg_trace = max(max(Pi));
        cov_history = [cov_history; [walltime avg_trace]];
        
        %%----------- get p from DKAL
        mobIdx = nm.getNodeIdx( MOBILEID );
        stateIdx = (mobIdx-1)*5 + 1;
        Pi_DKAL = nm.nodes{mobIdx}.P(stateIdx:(stateIdx+2), stateIdx:(stateIdx+2));
        avg_pDKAL = trace(Pi_DKAL)/3
        pDKAL_history = [ pDKAL_history; [walltime avg_pDKAL]];
        %%----------- get p from P_big
        mobIdx = nm.getNodeIdx( MOBILEID );
        stateIdx = (mobIdx-1)*5 + 1;
        P_big= nm.P_big(stateIdx:(stateIdx+2), stateIdx:(stateIdx+2));
        avg_P_big = trace(P_big)/3;        
        P_big_history = [ P_big_history; [walltime avg_P_big]];
%         %%-------------
%         for i=1:nm.getNumNodes()
%             % source ID
%             srcId = nm.nodes{i}.getId();
%             %{
%             % make fake measurement to mobile node
%             m = Measurement( nm.MSGTYPE3, zeros(11,1) );
%             m.type = 3;
%             m.R_ij = 3;
%             m.allowMeasType_R();
%             m.nodei = srcId;
%             m.nodej = MOBILEID;
%             zh = m.vectorize();
%             Rh = m.getCovariance();
%             % fake EKF step
%             hh = @(s) nm.measurementFcn(s, m);
%             [sh, Ph] = ekf(f, s, P, hh, zh, dt_ref*Q, Rh);
%             % how much would P reduce?
%             Pih = Ph(stateIdx:(stateIdx+2), stateIdx:(stateIdx+2));
%             Pred = abs(max(max(Pih)) - max(max(Pi)));
%             if Pred > bestP
%                 bestP = Pred;
%                 bestNode = srcId;
%             end
%             %}
%             
%             % trigger message
%             nm.queueMessage( MOBILEID, srcId, nm.MSGTYPE3 );
%         end
        
        % trigger message
        %fprintf('TRIGGERING MESSAGE FROM %d to %d\n', MOBILEID, bestNode);
        %nm.queueMessage( MOBILEID, bestNode, nm.MSGTYPE3 );
  else
        srcIndex=meas.getSourceId() +1;
        if srcIndex ==11
            srcIndex =9;
        end
        nm.savemsgsM = nm.savemsgsM +length(nm.network{srcIndex});
      
        RunTimeFlag=nm.ekfPartThreeOnlyForAll(dt_ref*Q ,f,dt_ref);
        %RunTimeFlag should be always 1 here
        timeUpdateFlag_history = [timeUpdateFlag_history RunTimeFlag];
        DiffFlag_history = [DiffFlag_history 0];
        MeasFlag_history = [MeasFlag_history 0];
        %cov_big=nm.getCovMobileTimeUpdate(cov_big,dt_ref) ;
        P_mobile = nm.cov_big(45*8+1:end,45*8+1:end);
        mobIdx = nm.getNodeIdx( MOBILEID );
        stateIdx = (mobIdx-1)*5 + 1;
        Pi = P_mobile(stateIdx:(stateIdx+2), stateIdx:(stateIdx+2));
        avg_trace = trace(Pi)/3;
        %avg_trace = max(max(Pi));
        cov_history = [cov_history; [walltime avg_trace]];
        %%----------- get p from DKAL
        mobIdx = nm.getNodeIdx( MOBILEID );
        stateIdx = (mobIdx-1)*5 + 1;
        Pi_DKAL = nm.nodes{mobIdx}.P(stateIdx:(stateIdx+2), stateIdx:(stateIdx+2));
        avg_pDKAL = trace(Pi_DKAL)/3
        pDKAL_history = [ pDKAL_history; [walltime avg_pDKAL]];
        %%-------------
                %%----------- get p from P_big
        mobIdx = nm.getNodeIdx( MOBILEID );
        stateIdx = (mobIdx-1)*5 + 1;
        P_big= nm.P_big(stateIdx:(stateIdx+2), stateIdx:(stateIdx+2));
        avg_P_big = trace(P_big)/3;        
        P_big_history = [ P_big_history; [walltime avg_P_big]];
    end
    
    
           
    % update plots
    set(hestAll,'xdata',pEstAll(:,1),'ydata', pEstAll(:,2),'zdata',pEstAll(:,3));
    for i=1:nm.getNumNodes()
        if ~nm.nodes{i}.isMobile()
            set(herrStatic(i),'xdata',[pTruStatic(i,2) pEstAll(i,1)],'ydata',...
                [pTruStatic(i,3) pEstAll(i,2)],'zdata',[pTruStatic(i,4) pEstAll(i,3)]);
        end
        nidx = (i-1)*5 + 1;
        Pi = nm.nodes{i}.P( nidx:(nidx+2), nidx:(nidx+2) );
        updateEllipse( hvar(i), [pEstAll(i,1); pEstAll(i,2); pEstAll(i,3)], Pi + 0.001*[1 0 0; 0 0 0; 0 0 1], varscale);
        if i == 3
            % Pi
        end
    end    
    
    if walltime - plot_last >= plot_delay
        plot_last = walltime;
        % update rigid bodies
        for i=1:length(rigid_bodies)
            rb = rigid_bodies(i);
            [xyz, latency] = nm.dataparser.getMocapPos(rb, walltime);
            if latency < 0.250
                set(hrigidbodies(i), 'XData', xyz(1), 'YData', xyz(2), 'ZData', xyz(3));
            end
        end
        
        % update plot title
        tstr = sprintf('NESL Network Localization (t = %.2fs)', (t_last - t_start));
        set(htitle, 'String', tstr);
        drawnow;
    end

    % append state estimate & measurement to history
    s_history = [s_history; s'];
    p_history = [p_history; pEstAll];

    %fprintf('t = %.2f / %.2f \n', meas.getTime()-meas1.getTime(), t_stop);
    
    if SAVEMOVIE
        f = getframe(fig);
        writeVideo(vidObj,f);
    end

    %pause();
end

if SAVEMOVIE
    close(vidObj);
end
savemsgsM=nm.savemsgsM;
sentmsgsD=nm.sentmsgsD;
sentmsgsM=nm.sentmsgsM;
% save data
saveName= strcat('cache\ped04All_Th_',num2str(ii));
save(saveName,'savemsgsM','sentmsgsD','sentmsgsM', 'nm', 'k', 's_history', 'p_history', 'cov_history','pDKAL_history','P_big_history' ,'t_history','PDESIRED','t_stop','timeUpdateFlag_history' ,'DiffFlag_history','MeasFlag_history');

end;


