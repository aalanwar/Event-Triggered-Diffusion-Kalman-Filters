classdef NetworkManager < handle
    %NETWORKMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        LIGHTSPEED = 299792458; % m/s
        PLTSTYLES = {'-o', '-s', '-^', '-x', '-*', '--o', '--s', '--^', '--x', '--*'};
        PLTCOLORS = [
            1 0 0
            0 0 1
            0 0 0
            0.8 0.8 0
            1 0 1
            0 0.7 0.7
            0 1 0
            0.5 0.5 0.5
            0.25 0.25 1
            1 0.25 0.25
            0.25 1 0.25
            ];
        PASS = 1;
        BLOCK = 0;
        MSGTYPE1 = 1;
        MSGTYPE2 = 2;
        MSGTYPE3 = 3;
        MEASTYPE_d = 1;
        MEASTYPE_r = 2;
        MEASTYPE_b = 3;
        MEASTYPE_B = 4;
        MEASTYPE_R = 5;
        MAXMEASUREMENTS = 1e6;
        MEASBLOCKBKOFF = 0.010;
    end
    
    properties
        cov_big;
        P_big;
        % node variables
        nodes = {};
        nodeinfo = {};
        numnodes = 0;
        propdelay2alpha=[];
        % message / data variables
        dataparser = [];
        antennacorrections = [];
        twrcorrections = [];
        owrcorrections = [];
        msgidx = 1;
        measurement_history = {};
        meascnt = 0;
        
        % range bias state
        rangebiases = [];
        var_rangebias = 0.10;  % m/s
        vari_rangebias = 1.0^2; % m
        
        % message filtering (pass=1,block=0)
        filter_type1 = 0;
        filter_type2 = 0;
        filter_type3 = 0;
        filter_meas_d = 0;
        filter_meas_r = 0;
        filter_meas_b = 0;
        filter_meas_B = 0;
        filter_meas_R = 0;
        
        % min period between message types (sec)
        period_type1 = 0;
        period_type2 = 0;
        period_type3 = 0;
        
        % node blacklist
        blacklist = [];
        
        % message queues (src, dest, type)
        measQ = [];
        
        % reference node id
        refNode = [];
        
        % enable SLATS?
        enable_slats = false;
        
        % number of saved messages
        savemsgsM =0;
        %number of sent messages
        sentmsgsM=0;
        sentmsgsD=0;
        %neighbours including myself
        %  network= { [1 2 3 ],[ 1 2 3 4 5],[ 1 2 3 4],[3 4 5],[4 5 6],[5 6 7],[6 7 8],[1 2 3 4 5 6 7 8]};
        % network= { [1 2 3],[ 1 2 3 4 5],[ 1 2 3 4 5],[3 4 5 6],[4 5 6 7],[5 6 7 8],[4 5 6 7 8],[1 2 3 4 5 6 7 8]};
        %network= {[1 2 3 4 5 ],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[2 3 4 5 6 7 8],[ 2 3 4 5 6 7 8],[ 2 3 4 5 6 7 8]};
        %network= { [9 1 2 ],[1 2 3 4 5 6 7 8],[2 3 4],[3 4 5],[4 5 6],[5 6 7],[6 7 8],[7 8 9],[8 9 1]};
        %  network= { [8 1 2 3],[1 2 3 4 5 6 7 8],[1 2 3 4],[2 3 4 5],[3 4 5 6],[4 5 6 7],[4 6 7 8],[6 7 8 1]};
        %fully connected
        network= { [1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[ 1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[ 1 2 3 4 5 6 7 8]};
        
        %rm 2 connection
        %network= { [1 2 3 4 5 6 7],[1 2 3 4 5 6 7 8],[ 1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[2 3 4 5 6 7 8]};
        %network= { [1 2 3 4 5 6 7 8],[1 2 3 5 6 7 8],[ 1 2 3 4 5 6 7],[1 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8]};
        
        %1 neig
        % network= { [1 2],[2 3],[3 4],[4 5],[5 6],[6 7],[7 8],[8 1]};
        
        %2 neig
        %network= { [8 1 2],[1 2 3],[2 3 4],[3 4 5],[4 5 6],[5 6 7],[6 7 8],[7 8 1]};
        
        %3 neig
        %network={[1 3 4 6],[2 4 5 8],[1 3 5 7],[1 2 4 7],[2 3 5 8],[1 6 7 8],[3 4 6 7],[2 5 6 8]};
        
        %4 nei
        %network = {[1 2 5 7 8],[2 3 6 7 1],[3 4 6 8 2],[4 5 6 8 3],[5 6 7 1 4],[6 2 3 4 5],[7 8 1 2 5],[8 1 3 4 7]};
        
        %5 nei
        %network={[1 2 3 5 7 8],[2 3 4 5 8 1],[3 4 6 8 1 2],[4 5 6 7 2 3],[5 6 7 1 2 4],[6 7 8 3 4 5],[7 8 1 4 5 6],[8 1 2 3 6 7]};
        
        %6 nei
        %                 1               2               3               4               5               6               7               8
        %network= { [8 1 2 3 4 5 6],[1 2 3 4 5 6 7],[1 2 3 4 5 7 8],[3 4 6 7 8 1 2],[3 5 6 7 8 1 2],[4 5 6 7 8 1 2],[6 7 8 2 3 4 5],[7 8 1 3 4 5 6]};
        
        %conditional msg
        %network= { [1 2 3 4 5 6 7 8 9],[1 2 3 4 5 6 7 8 9],[1 2 3 4 5 6 7 8 9],[1 2 3 4 5 6 7 8 9],[1 2 3 4 5 6 7 8 9],[1 2 3 4 5 6 7 8  9],[1 2 3 4 5 6 7 8 9],[1 2 3 4 5 6 7 8 9],[1 2 3 4 5 6 7 8 9]};
        %Gps
        %network= { [1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8],[1 2 3 4 5 6 7 8]};
        % mobile
        %network= { [1 2 3 4 5 6 7 8 9],[1 2 3 4 5 6 7 8 9],[3 1 2  4 5 6 7 8 9],[4 1 2 3  5 6 7 8 9],[5 1 2 3 4  6 7 8 9],[6 1 2 3 4 5  7 8 9],[7 1 2 3 4 5 6  8 9],[ 1 2 3 4 5 6 7 8 9],[ 1 2 3 4 5 6 7 8 9]};
        
    end
    
    methods
        % =============================================
        %                  CONSTRUCTOR
        % =============================================
        function obj = NetworkManager(configfile, logfolder, varargin)
            % create dataparser
            obj.dataparser = DataParserROS(configfile, logfolder);
            obj.nodeinfo = obj.dataparser.getNodeInfo();
            % create node objects
            for i=1:length(obj.nodeinfo)
                node_names = obj.nodeinfo{1};
                node_ids = obj.nodeinfo{2};
                node_dynamics = obj.nodeinfo{6};
                for i=1:length(node_ids)
                    name = node_names{i};
                    id = node_ids(i);
                    xyz = [obj.nodeinfo{3}(i); obj.nodeinfo{4}(i); obj.nodeinfo{5}(i)];
                    obj.nodes{i} = Node(id, name);
                    obj.nodes{i}.setTruePosition(xyz);
                    % is this a mobile node?
                    if strcmp(node_dynamics{i}, 'mobile');
                        obj.nodes{i}.setToMobile();
                    end
                end
            end
            obj.numnodes = length(obj.nodeinfo{1});
            
            % load rangefile corrections if they exist % TWR, OWR
            if nargin >= 3
                ant_file = varargin{1};
                obj.antennacorrections = csvread(ant_file);
            end
            if nargin >= 4
                owr_file = varargin{2};
                obj.owrcorrections = csvread(owr_file);
            end
            if nargin >= 5
                twr_file = varargin{3};
                obj.twrcorrections = csvread(twr_file);
            end
            
            % pre-allocate measurement memory
            obj.measurement_history = cell(obj.MAXMEASUREMENTS,1);
            
            % pre-allocate range bias memory
            obj.rangebiases = zeros( obj.getNumNodes(), obj.getNumNodes() );
        end
        
        % =============================================
        %                     SLATS
        % =============================================
        
        % enable SLATS
        function enableSLATS(obj, val)
            obj.enable_slats = val;
        end
        
        
        % =============================================
        %                MESSAGE FILTERING
        % =============================================
        
        % queue a specific message type
        function queueMessage(obj, srcId, dstId, type)
            % add if Q empty
            if isempty(obj.measQ)
                obj.measQ = [obj.measQ; [srcId dstId type]];
                return;
            end
            % otherwise only add if not already queued
            if isempty( find( obj.measQ(:,1) == srcId & obj.measQ(:,2) == dstId & obj.measQ(:,3) == type ) )
                obj.measQ = [obj.measQ; [srcId dstId type]];
            end
        end
        
        % enable / disable specific message types
        function enableMessageType(obj, type, enable)
            switch type
                case obj.MSGTYPE1
                    obj.filter_type1 = enable;
                case obj.MSGTYPE2
                    obj.filter_type2 = enable;
                case obj.MSGTYPE3
                    obj.filter_type3 = enable;
                otherwise
                    error('Message type not recognized');
            end
        end
        
        % downsample specific message types to a given period lower bound
        function setMessageMinInterval(obj, type, interval)
            switch type
                case obj.MSGTYPE1
                    obj.period_type1 = interval;
                case obj.MSGTYPE2
                    obj.period_type2 = interval;
                case obj.MSGTYPE3
                    obj.period_type3 = interval;
                otherwise
                    error('Message type not recognized');
            end
        end
        
        % enable / disable specific message types
        function enableMeasurementType(obj, type, enable)
            switch type
                case obj.MEASTYPE_d
                    obj.filter_meas_d = enable;
                case obj.MEASTYPE_r
                    obj.filter_meas_r = enable;
                case obj.MEASTYPE_b
                    obj.filter_meas_b = enable;
                case obj.MEASTYPE_B
                    obj.filter_meas_B = enable;
                case obj.MEASTYPE_R
                    obj.filter_meas_R = enable;
                otherwise
                    error('Message type not recognized');
            end
        end
        
        % determine whether or not this measurement should be received
        function valid = filterMeasurement(obj, meas)
            srcId = meas.getSourceId();
            dstId = meas.getDestId();
            type = meas.getType();
            tlastSent = obj.nodes{ obj.getNodeIdx(srcId) }.getLastMeasTime( type );
            
            % ignore measurement if src or dst are blacklisted
            if ~isempty( find(obj.blacklist == srcId, 1) ) || ~isempty( find(obj.blacklist == dstId, 1) )
                valid = obj.BLOCK;
                return;
            end
            
            % set allowed measurement types % to know for vectorizing
            if obj.filter_meas_d
                meas.allowMeasType_d();
            end
            if obj.filter_meas_r
                meas.allowMeasType_r();
            end
            if obj.filter_meas_R
                meas.allowMeasType_R();
            end
            
            % next, pass immediately if measurement type has been requested
            if ~isempty( obj.measQ )
                qIdx = find(obj.measQ(:,1) ==  srcId & obj.measQ(:,2) == dstId);
                if ~isempty(qIdx)
                    % force this message to be the right type
                    meas.type = obj.measQ(qIdx,3);
                    meas.queued = 1;
                    % a message of this type has been requested, pass it and remove
                    % from the message queue
                    
                    % block if the range or time is obviously incorrect
                    if meas.r_ij < -1 || meas.r_ij > 20 || meas.R_ij < -1 || meas.R_ij > 20
                        valid = obj.BLOCK;
                        obj.measQ(qIdx,:) = [];
                        return;
                    end
                    valid = obj.PASS;
                    obj.measQ(qIdx,:) = [];
                    return;
                end
            end
            
            % block if no measurements supported
            if ~(obj.filter_meas_d || obj.filter_meas_r || obj.filter_meas_R)
                valid = obj.BLOCK;
                return;
            end
            
            % block if the range or time is obviously incorrect
            if meas.r_ij < -1 || meas.r_ij > 20 || meas.R_ij < -1 || meas.R_ij > 20
                valid = obj.BLOCK;
                return;
            end
            
            
            % pass as a type 3 message if they're allowed and it's been
            % long enough since the last type 3 message
            if obj.filter_type3 == obj.PASS
                
                meas.setType(obj.MSGTYPE3);
                tlastSent = obj.nodes{ obj.getNodeIdx(srcId) }.getLastMeasTime( obj.MSGTYPE3 );
                dt = meas.getTime() - tlastSent;
                if dt >= obj.period_type3 || dt < obj.MEASBLOCKBKOFF
                    valid = obj.PASS;
                    obj.nodes{ obj.getNodeIdx(srcId) }.setLastMeasTime( obj.MSGTYPE3, meas.getTime() );
                    return;
                end
            end
            % otherwise make this a type 2 message and pass it if they're
            % allowed and if it's been long enough since the last type 2.
            if obj.filter_type2 == obj.PASS
                % downgrade this to a type 2 message
                meas.setType(obj.MSGTYPE2);
                tlastSent = obj.nodes{ obj.getNodeIdx(srcId) }.getLastMeasTime( obj.MSGTYPE2 );
                dt = meas.getTime() - tlastSent;
                if dt >= obj.period_type2 || dt < obj.MEASBLOCKBKOFF
                    valid = obj.PASS;
                    obj.nodes{ obj.getNodeIdx(srcId) }.setLastMeasTime( obj.MSGTYPE2, meas.getTime() );
                    return;
                end
            end
            % finally, we can at the very least make this a type 1 message
            % if the other 2 messages are blocked for this time period.
            % Disallow this too, though, if not enough time has elapsed
            % since the last type 1.
            if obj.filter_type1 == obj.PASS
                % downgrade this to a type 1 message
                meas.setType(obj.MSGTYPE1);
                tlastSent = obj.nodes{ obj.getNodeIdx(srcId) }.getLastMeasTime( obj.MSGTYPE1 );
                dt = meas.getTime() - tlastSent;
                if dt >= obj.period_type1 || dt < obj.MEASBLOCKBKOFF
                    valid = obj.PASS;
                    obj.nodes{ obj.getNodeIdx(srcId) }.setLastMeasTime( obj.MSGTYPE1, meas.getTime() );
                    return;
                end
            end
            
            % otherwise, block it
            valid = obj.BLOCK;
        end
        
        % =============================================
        %                  PLOTTING
        % =============================================
        
        % plot styles and colors
        function style = getPlotStyle(obj, nodeId)
            nidx = obj.dataparser.getNodeIdx(nodeId);
            style = obj.PLTSTYLES{nidx};
        end
        function c = getPlotColor(obj, nodeId)
            nidx = obj.dataparser.getNodeIdx(nodeId);
            c = obj.PLTCOLORS(nidx,:);
        end
        
        % get number of nodes
        function n = getNumNodes(obj)
            n = obj.numnodes;
        end
        
        % get number of static nodes
        function n = getNumStaticNodes(obj)
            n = 0;
            for i=1:obj.getNumNodes()
                dynamics = obj.nodeinfo{6}{i};
                if strcmp(dynamics, 'static')
                    n = n + 1;
                end
            end
        end
        
        % get number of mobile nodes
        function n = getNumMobileNodes(obj)
            n = obj.getNumNodes() - obj.getNumStaticNodes();
        end
        
        % =============================================
        %                  NODE INFO
        % =============================================
        
        % get node ascii names
        function n = getNodeNames(obj)
            n = obj.nodeinfo{1};
        end
        
        % get numeric node is: 0, 1, ...
        function id = getNodeIds(obj)
            id = obj.nodeinfo{2};
        end
        
        % get the index of a specific node
        function idx = getNodeIdx(obj, nodeid)
            idx = obj.dataparser.getNodeIdx( nodeid );
        end
        
        % blacklist a certain node (don't use it)
        function blacklistNode(obj, nodeid)
            idx = obj.getNodeIdx( nodeid );
            nodeids = obj.getNodeIds();
            id = nodeids(idx);
            obj.blacklist = [obj.blacklist; id];
        end
        
        % =============================================
        %               STATE ACCESSORS
        % =============================================
        
        % get network state
        function s = getState(obj)
            s = [];
            for i=1:length(obj.nodes)
                s = [s; obj.nodes{i}.getState()];
            end
        end
        
        % get the vectorized range biases
        function sb = getRangeBiasVec(obj)
            sb = [];
            for i=1:obj.getNumNodes()
                for j=(i+1):obj.getNumNodes()
                    sb = [sb; obj.rangebiases(i,j)];
                end
            end
        end
        
        % range bias vector to matrix
        function SB = rangeBiasVec2Mat(obj, sb)
            SB = [];
            idx = 0;
            for i=1:obj.getNumNodes()
                for j=(i+1):obj.getNumNodes()
                    idx = idx + 1;
                    SB(i,j) = sb(idx);
                    SB(j,i) = sb(idx);
                end
            end
        end
        
        % set the vectorized range biases
        function setRangeBiasState(obj, sb)
            obj.rangebiases = obj.rangeBiasVec2Mat(sb);
        end
        
        % set network state
        function setState(obj, s)
            idx = 1;
            for i=1:length(obj.nodes)
                stateSize = length(obj.nodes{i}.getState());
                si = s(idx:(idx+stateSize-1));
                obj.nodes{i}.setState(si);
                idx = idx + stateSize;
            end
            
        end
        
        %every node participate with its state only
        function s=getAndFixStateConc(obj)
            idx = 1;
            s = [];
            for i=1:length(obj.nodes)
                stateSize = length(obj.nodes{i}.getState());
                si = obj.nodes{i}.x(idx:(idx+stateSize-1));
                obj.nodes{i}.setState(si);
                s = [ s ; si];
                idx = idx + stateSize;
            end
            
        end
        % get estimated node positions for only static nodes
        function P = getEstimatedStaticPositions(obj)
            P = [];
            for i=1:length(obj.nodes)
                if ~obj.nodes{i}.isMobile()
                    P = [P; obj.nodes{i}.getId() obj.nodes{i}.getStatePosition()'];
                end
            end
        end
        
        % get estimated node positions for all nodes
        function P = getEstimatedPositions(obj)
            P = [];
            for i=1:length(obj.nodes)
                P = [P; obj.nodes{i}.getStatePosition()'];
            end
        end
        
        % get true node positions
        function P = getTrueStaticPositions(obj)
            P = [];
            for i=1:length(obj.nodes)
                if ~obj.nodes{i}.isMobile()
                    P = [P; obj.nodes{i}.getId() obj.nodes{i}.getTruePosition()'];
                end
            end
        end
        
        % get estimated positions transformed to match true as closely as
        % possible (procrustes)
        function P = getTransformedPositions(obj)
            truStatic = obj.getTrueStaticPositions();
            estStatic = obj.getEstimatedStaticPositions();
            % procrustes ignoring first column (node IDs)
            [~,~,Transform] = procrustes(truStatic(:,2:end), estStatic(:,2:end), 'Scaling', false);
            % transform all points
            estAll = obj.getEstimatedPositions();
            ofst = repmat(Transform.c(1,:), obj.getNumNodes(), 1);
            P = Transform.b*estAll*Transform.T + ofst;
        end
        
        % set reference node (for EKF)
        function setReferenceNode(obj, nodeId)
            nidx = obj.dataparser.getNodeIdx(nodeId);
            obj.nodes{nidx}.setAsReference();
            obj.refNode = obj.nodes{nidx}.getId();
        end
        
        % =============================================
        %               PROCESS & MEASUREMENT
        % =============================================
        
        % get process variance
        function P = getProcessVar(obj)
            p = [];
            for i=1:length(obj.nodes)
                p = [p; obj.nodes{i}.getProcessVar()];
            end
            P = diag(p);
        end
        
        % get initial variance
        function P = getInitialVar(obj)
            p = [];
            for i=1:length(obj.nodes)
                p = [p; obj.nodes{i}.getInitialVar()];
            end
            P = diag(p);
        end
        
        
        % state process function
        function snew = processFcn(obj, s, dt)
            snew = s;
            
            % perform process update over each node separately
            stateSize = 5;
            i = 1;
            for n=1:obj.getNumNodes()
                snew(i+3) = s(i+3) + s(i+4) * 1e-9 * dt;
                i = i + stateSize;
            end
        end
        
        % state measurement function
        function y = measurementFcn(obj, s, meas)
            type = meas.getType();
            
            srcIdx = obj.getNodeIdx(meas.getSourceId());
            dstIdx = obj.getNodeIdx(meas.getDestId());
            
            % find state indices for nodes with index i and j
            stateSize = 5;
            start_i = (srcIdx-1)*stateSize + 1;
            start_j = (dstIdx-1)*stateSize + 1;
            
            % extract the needed state info
            pi = s(start_i:(start_i+2));
            pj = s(start_j:(start_j+2));
            oi = s(start_i+3);
            oj = s(start_j+3);
            bi = s(start_i+4);
            bj = s(start_j+4);
            
            % predicted measurement y
            % format: y = [d_ij; r_ij; B_ij; R_ij];
            y = [];
            
            c = obj.LIGHTSPEED;
            
            % d_ij = range/speed_of_light + offset
            if obj.filter_meas_d
                if obj.enable_slats
                    y = [y; ( sqrt(sum((pj-pi).^2)) + 2.0 )/c + (oj - oi)];
                else
                    y = [y; (oj - oi)];
                end
            end
            
            % type 1 only has offset
            if type == 1
                return;
            end
            
            % r_ij = range + t_error
            if obj.filter_meas_r
                if obj.enable_slats
                    y = [y; sqrt(sum((pj-pi).^2)) + (c*meas.T_rsp1/2)*(bj - bi)*1e-9];
                else
                    y = [y; sqrt(sum((pj-pi).^2))];
                end
            end
            
            % type 2 only has offset and noisy range
            if type == 2
                return;
            end
            
            % R_ij = range + t_error
            if obj.filter_meas_R
                if obj.enable_slats
                    err = c*( 1e-9*(bi-bj)*(meas.T_rnd0*meas.T_rnd1 - meas.T_rsp0*meas.T_rsp1 ))/( (1+ 1e-9*(bi-bj))*meas.T_rnd0 + meas.T_rnd1 + meas.T_rsp0 + (1+ 1e-9*(bi-bj))*meas.T_rsp1 );
                    y = [y; sqrt(sum((pj-pi).^2)) + err ];
                else
                    y = [y; sqrt(sum((pj-pi).^2))];
                end
            end
        end
        
        % request the next (filtered) measurement
        function m = getNextMeasurement(obj)
            while obj.msgidx < obj.dataparser.getNumMeasurements()
                % get new tentative meas
                raw = obj.dataparser.getMeasurement(obj.msgidx);
                meas = Measurement(obj.MSGTYPE3, raw);%calulate dij,rij,Rij
                obj.msgidx = obj.msgidx + 1;
                % check if we should pass this message
                if obj.filterMeasurement(meas) == obj.PASS
                    % ANT corrections
                    if ~isempty(obj.antennacorrections)
                        idx = find(obj.antennacorrections(:,1) == meas.getSourceId() &...
                            obj.owrcorrections(:,2) == meas.getDestId());
                        if ~isempty(idx)
                            meas.d_ij = meas.d_ij + 0*1e-9*obj.antennacorrections(idx, 3);
                        end
                    end
                    % OWR corrections
                    if ~isempty(obj.owrcorrections)
                        idx = find(obj.owrcorrections(:,1) == meas.getSourceId() &...
                            obj.owrcorrections(:,2) == meas.getDestId());
                        if ~isempty(idx)
                            meas.r_ij = meas.r_ij + obj.owrcorrections(idx, 3);
                        end
                    end
                    % TWR corrections
                    if ~isempty(obj.twrcorrections)
                        idx = find(obj.twrcorrections(:,1) == meas.getSourceId() &...
                            obj.twrcorrections(:,2) == meas.getDestId());
                        if ~isempty(idx)
                            meas.R_ij = meas.R_ij + obj.twrcorrections(idx, 3);
                        end
                    end
                    
                    m = meas;
                    
                    % increment and check message count
                    if obj.meascnt > obj.MAXMEASUREMENTS
                        m = [];
                        return;
                    end
                    obj.meascnt = obj.meascnt + 1;
                    obj.measurement_history{obj.meascnt} = m;
                    return;
                end
            end
            % no more measurements
            m = [];
        end
        
        function killLastMeasurement(obj)
            obj.meascnt = obj.meascnt - 1;
        end
        
        % reset measurement index
        function resetMeasurements(obj)
            obj.msgidx = 1;
            obj.measurement_history = cell(obj.MAXMEASUREMENTS,1);
            obj.meascnt = 0;
        end
        
        % =============================================
        %                  BOOTSTRAPPING
        % =============================================
        
        % skip some time
        function skipTime(obj, tskip)
            % enable type 3 messages for this
            type3Enabled = obj.filter_type3;
            typeREnabled = obj.filter_meas_R;
            obj.enableMessageType(obj.MSGTYPE3, true);
            obj.enableMeasurementType(obj.MEASTYPE_R, true);
            
            % get the first measurement
            meas1 = obj.getNextMeasurement();
            t1 = meas1.getTime();
            t_now = t1;
            while t_now - t1 < tskip
                meas = obj.getNextMeasurement();
                if isempty(meas)
                    break;
                end
                t_now = meas.getTime();
            end
            
            % reset the measurement history but not the dp index
            obj.measurement_history = cell(obj.MAXMEASUREMENTS,1);
            obj.meascnt = 0;
            
            % set type 3 filtering to whatever it was before bootstrap
            obj.enableMessageType(obj.MSGTYPE3, type3Enabled);
            obj.enableMeasurementType(obj.MEASTYPE_R, typeREnabled);
        end
        
        % bootstrap node positions using ranges averaged over a duration
        function bootstrapNodeStates(obj, T_boot)
            % enable type 3 messages for this
            type3Enabled = obj.filter_type3;
            typeREnabled = obj.filter_meas_R;
            obj.enableMessageType(obj.MSGTYPE3, true);
            obj.enableMeasurementType(obj.MEASTYPE_R, true);
            
            % get range estimates (distance matrix)
            R_sum = zeros( obj.getNumNodes(), obj.getNumNodes() );
            % get offset estimates
            D_sum = zeros( obj.getNumNodes(), 1 );
            % distance measurement counts
            D_cnt = zeros( obj.getNumNodes(), obj.getNumNodes() );
            % timing measurements
            d_ij_arrays = cell( obj.getNumNodes(), 1 );
            d_ij_times  = cell( obj.getNumNodes(), 1 );
            % get the first measurement
            meas1 = obj.getNextMeasurement();
            t1 = meas1.getTime();
            t_now = t1;
            while t_now - t1 < T_boot
                meas = obj.getNextMeasurement();
                if isempty(meas)
                    break;
                end
                t_now = meas.getTime();
                srcIdx = obj.getNodeIdx( meas.getSourceId() );
                dstIdx = obj.getNodeIdx( meas.getDestId() );
                
                R_sum(srcIdx,dstIdx) = R_sum(srcIdx,dstIdx) + meas.R_ij;
                R_sum(dstIdx,srcIdx) = R_sum(dstIdx,srcIdx) + meas.R_ij;
                D_cnt(srcIdx,dstIdx) = D_cnt(srcIdx,dstIdx) + 1;
                D_cnt(dstIdx,srcIdx) = D_cnt(dstIdx,srcIdx) + 1;
                
                % look for messages from the reference node to bootstrap
                % clock offset and bias
                if ~isempty(obj.refNode) && meas.getSourceId() == obj.refNode
                    % append d_ij and time
                    d_ij_arrays{dstIdx} = [d_ij_arrays{dstIdx} meas.d_ij];
                    d_ij_times{dstIdx} = [d_ij_times{dstIdx} meas.getTime()];
                end
            end
            
            % average range estimates
            D = zeros( obj.getNumNodes(), obj.getNumNodes() );
            W = ones( obj.getNumNodes(), obj.getNumNodes() );
            for i=1:obj.getNumNodes()
                for j=1:obj.getNumNodes()
                    % ignore diagonals
                    if i == j
                        continue;
                    end
                    % assign default or average measurements
                    if D_cnt(i,j) == 0
                        % if we have no measurement, assume it's a bit far
                        % away and give it very low weight
                        D(i,j) = 10;
                        W(i,j) = 0.01;
                    else
                        D(i,j) = R_sum(i,j) / D_cnt(i,j);
                    end
                end
            end
            
            % use MDS to get an estimate of the node positions
            Y = mdscale(D, 3, 'Weights', W);
            
            % assign the estimated positions to each node
            for i=1:obj.getNumNodes()
                obj.nodes{i}.setStatePosition( Y(i,:) );
            end
            
            % perform linear regression over d_ij and time to get estimated
            % clock offset and bias w.r.t. reference node
            for i=1:size(d_ij_arrays,1)
                if length(d_ij_arrays{i}) >= 3
                    % wall time = x
                    x = d_ij_times{i} - d_ij_times{i}(1);
                    % measured d_ij = y
                    y = d_ij_arrays{i};
                    p = polyfit(x, y, 1);
                    est_bias = p(1);
                    est_ofst = polyval(p, x(end));
                    obj.nodes{i}.setStateClockOfst(est_ofst);
                    obj.nodes{i}.setStateClockBias(est_bias*1e9);
                    fprintf('BOOTSTRAP: node %d: offset= %.6f ms, bias = %d ppb\n', obj.nodes{i}.getId(), est_ofst*1e3, est_bias*1e9);
                elseif obj.nodes{i}.getId() ~= obj.refNode
                    fprintf('WARN: No timing bootstrap for %d-->%d (%d measurements)\n', obj.refNode, obj.nodes{i}.getId(), length(d_ij_arrays{i}));
                end
            end
            
            % reset the measurement history but not the dp index
            obj.measurement_history = cell(obj.MAXMEASUREMENTS,1);
            obj.meascnt = 0;
            
            % set type 3 filtering to whatever it was before bootstrap
            obj.enableMessageType(obj.MSGTYPE3, type3Enabled);
            obj.enableMeasurementType(obj.MEASTYPE_R, typeREnabled);
        end
        
        % set all static nodes to their true positions
        function setStaticNodesToTruePosition(obj)
            for i=1:length(obj.nodes)
                if ~obj.nodes{i}.isMobile()
                    obj.nodes{i}.setPositionToTrue();
                end
            end
        end
        
        % =============================================
        %              MEASUREMENT HISTORY
        % =============================================
        
        % get pairwise TWR range measurements
        function r = getMeasurementTWR(obj, srcId, dstId)
            r = [];
            for i=1:obj.meascnt
                meas = obj.measurement_history{i};
                if meas.getSourceId() == srcId && meas.getDestId() == dstId
                    r = [r; meas.R_ij];
                end
            end
        end
        
        % get pairwise OWR range measurements
        function r = getMeasurementOWR(obj, srcId, dstId)
            r = [];
            for i=1:obj.meascnt
                meas = obj.measurement_history{i};
                if meas.getSourceId() == srcId && meas.getDestId() == dstId
                    r = [r; meas.r_ij];
                end
            end
        end
        
        % get pairwise offset measurements
        function [o,t] = getMeasurementOffsets(obj, srcId, dstId)
            o = [];
            for i=1:obj.meascnt
                meas = obj.measurement_history{i};
                if meas.getSourceId() == srcId && meas.getDestId() == dstId
                    o = [o; meas.d_ij];
                end
            end
        end
        
        % get all measurements between two devices
        function m = getMeasurements(obj, srcId, dstId)
            m = [];
            for i=1:obj.meascnt
                meas = obj.measurement_history{i};
                if meas.getSourceId() == srcId && meas.getDestId() == dstId
                    m = [m; meas];
                end
            end
        end
        
        % get pairwise measurement times
        function t = getMeasurementTimes(obj, srcId, dstId)
            t = [];
            for i=1:obj.meascnt
                meas = obj.measurement_history{i};
                if meas.getSourceId() == srcId && meas.getDestId() == dstId
                    t = [t; meas.getTime()];
                end
            end
        end
        
        % get all measurement times
        function t = getAllMeasurementTimes(obj)
            t = zeros(1,obj.meascnt);
            for i=1:obj.meascnt
                meas = obj.measurement_history{i};
                t(i) = meas.getTime();
            end
        end
        
        % get allan deviation between two nodes
        function [ad,tau] = getAllanDev(obj, srcId, dstId, tau)
            % get non-zero aligned data
            data = obj.dataparser.aligned_logs;
            data = data(data(:,2) == srcId & data(:,3) == dstId, :);
            % get tx and rx
            tx = data(:,5);
            rx = data(:,6);
            % tx time (ignore 1st b/c y is diffed)
            x = tx(2:end);
            % rx dFreq in seconds
            y = (diff(rx) ./ diff(tx) - 1);
            [ad,~,~,tau] = allan(struct('freq',y,'time',x),tau,'',0);
        end
        
        % get all time offsets between two nodes
        function [o,t] = getAllOffsets(obj, srcId, dstId)
            data = obj.dataparser.aligned_logs;
            idxs = find(data(:,2) == srcId & data(:,3) == dstId);
            t = data(idxs,1);
            o = data(idxs,10) - data(idxs,9);
        end
        
        % get all time biases between two nodes
        function [b,t] = getAllBiases(obj, srcId, dstId)
            data = obj.dataparser.aligned_logs;
            idxs = find(data(:,2) == srcId & data(:,3) == dstId);
            t = data(idxs,1);
            o = data(idxs,10) - data(idxs,9);
            b = diff(o)./diff(t);
            t = t(2:end);
        end
        
        % =============================================
        %              POSITION ACCESSORS
        % =============================================
        function xyz = getTruePosition(obj, nodeId, tarray)
            xyz = [];
            for i=1:length(tarray)
                t = tarray(i);
                idx = obj.getNodeIdx( nodeId );
                if obj.nodes{idx}.isMobile()
                    rbid = obj.nodes{idx}.getRigidBodyId();
                    p = obj.dataparser.getMocapPos( rbid, t );
                else
                    p = obj.nodes{ idx }.getTruePosition()';
                end
                xyz = [xyz; p];
            end
        end
        
        function setRigidBodyId(obj, nodeId, rbId)
            nodeIdx = obj.getNodeIdx( nodeId );
            obj.nodes{nodeIdx}.setRigidBodyId( rbId );
        end
        
        function setSizebuffer_forall(obj,size_R)
            for i=1:length(obj.nodes)
                obj.nodes{i}.setSizebuffer(size_R);
            end
        end
        
        function init_x_P_forall(obj,x,P)
            for i=1:length(obj.nodes)
                obj.nodes{i}.init_x_P(x,P)
            end
        end
        %init the reduced state size for all
        function init_x_P_forall_red(obj)
            for i=1:length(obj.nodes)
                obj.nodes{i}.init_x_P_red();
            end
        end
        
        function publishmeas_forall(obj,meas,h)
            for i=1:length(obj.nodes)
                obj.nodes{i}.set_meas(meas,h);
            end
        end
        
%         function checkekf_p1_red(obj,size)
%             for i=1:length(obj.nodes)
%                 obj.nodes{i}.checkekf_p1_red(size);
%             end
%         end
        
        function RunMeasFlag= checkekf_p1_forall(obj,dt_ref,meas)
            for i=1:length(obj.nodes)
                obj.nodes{i}.checkekf_p1();
            end
            RunMeasFlag = obj.MeasurementPCovUpdate(dt_ref,meas);
        end

        function RunMeasFlag= checkekf_p1_forallUnconn(obj)
            for i=1:length(obj.nodes)
                obj.nodes{i}.checkekf_p1();
            end
            mobileIndex =9;
            RunMeasFlag = obj.nodes{mobileIndex}.measUpdateFlag;
            obj.nodes{mobileIndex}.measUpdateFlag = 0;
        end
        
        
        function RunMeasFlag= checkekf_p1_forall_fake(obj,dt_ref,meas)
            for i=1:length(obj.nodes)
                obj.nodes{i}.checkekf_p1_fake();
            end
            RunMeasFlag =0;
            %RunMeasFlag = obj.MeasurementPCovUpdate(dt_ref,meas);
        end        
%         function checkukf_p1_forall(obj,M,alpha,bita,kk,delta)
%             for i=1:length(obj.nodes)
%                 obj.nodes{i}.checkukf_p1(M,alpha,bita,kk,delta);
%             end
%         end
        
        function [RunDiffFlag,RunTimeFlag]= checkekf_p2_forall(obj,fstate,Q,diffEnable,dt_ref)
            for i=1:length(obj.nodes)
                obj.nodes{i}.checkekf_p2(fstate,Q,diffEnable);
            end
            RunDiffFlag = obj.DiffusionPCovUpdate();
            RunTimeFlag = obj.TimePCovUpdate(dt_ref);
        end
        
        
        function [RunDiffFlag,RunTimeFlag]= checkekf_p2_forallUnconn(obj,fstate,Q,diffEnable,dt_ref)
            for i=1:length(obj.nodes)
                obj.nodes{i}.checkekf_p2(fstate,Q,diffEnable);
            end
            mobileIndex =9;
             RunDiffFlag =obj.nodes{mobileIndex}.diffUpdateFlag ;
            RunTimeFlag = obj.nodes{mobileIndex}.timeUpdateFlag;
        end
%         function checkukf_p2_forall(obj,fstate,M,alpha,bita,kk,delta )
%             for i=1:length(obj.nodes)
%                 obj.nodes{i}.checkukf_p2(fstate,M,alpha,bita,kk,delta );
%             end
%         end
        
%         function checkekf_p2_forall_red(obj,fstate,dt_ref)
%             for i=1:length(obj.nodes)
%                 Q = getQ_red(obj,i);
%                 obj.nodes{i}.checkekf_p2_red(fstate,dt_ref*Q);
%             end
%         end
        
        function Q=getQ_red(obj,i)
            Q=[];
            for j=sort(obj.network{i})
                Q = [Q; obj.nodes{j}.getProcessVar()];
            end
            Q = diag(Q);
        end
        
        function publisheita_forall(obj)
            for i=1:length(obj.nodes)
                if(obj.nodes{i}.ready_to_ekf_p1 == 1) %eita is ready to publish
                    for j=1:length(obj.nodes)
                        obj.nodes{j}.seteital(i,obj.nodes{i}.eita,obj.nodes{i}.P);
                    end
                end
            end
        end
        
        function reseteita(obj)
            for i=1:length(obj.nodes)
                obj.nodes{i}.reseteital();
            end
        end
        %%%%%%%%%%%%%% network topology
        
        
        %set the neighbours for all
        function setneigh_forall(obj)
            for i=1:length(obj.nodes)
                obj.nodes{i}.setmyneigh(sort(obj.network{i}));
                obj.nodes{i}.setSizebuffer(length(obj.network{i}));
            end
        end
        
        function publishmeas_forneigh(obj,meas,h)
            srcIndex=meas.getSourceId() +1;
            desIndex=meas.getDestId() +1;
            
            %id 10 is number 9
            if srcIndex ==11
                srcIndex =9;
            end
            if desIndex ==11
                desIndex =9;
            end
            
%             %if srcIndex ==1
%             if any(obj.network{1}==srcIndex)
%                 ttt =6;
%             end
            %check if the measuremnt is between neighbours
            % if not just discard it
            if( any(obj.network{srcIndex}==desIndex) )
                for i =obj.network{srcIndex}
                    %send the need msg only to the nei
                    % the meas must be between nei of my nei
                    %if(any(obj.network{i}==srcIndex) && any(obj.network{i}==desIndex))
                    obj.nodes{i}.set_meas(meas,h);
                    if(i ~= srcIndex)% if it is to my self, do not count!
                        obj.sentmsgsM = obj.sentmsgsM +1;
                    end
                    %end
                end
            end
        end
        
        
        function publishmeas_forneigh_red(obj,meas,h)
            srcIndex=meas.getSourceId() +1;
            desIndex=meas.getDestId() +1;
            
            %check if the measuremnt is between neighbours
            % if not just discard it
            if( any(obj.network{srcIndex}==desIndex) )
                for i =obj.network{srcIndex}
                    %send the need msg only to the nei
                    % the meas must be between nei of my nei
                    %if(any(obj.network{i}==srcIndex) && any(obj.network{i}==desIndex))
                    obj.nodes{i}.set_meas(meas,h);
                    %end
                end
            end
        end
        function calcPropDelaytoAlpha(obj)
            for i=1:length(obj.nodes)-1
                obj.propdelay2alpha(i)= norm( obj.nodes{1}.true_p- obj.nodes{i+1}.true_p )/obj.LIGHTSPEED;
            end
        end
        
        function publisheita_forneigh(obj)
            for i=1:length(obj.nodes)
                if(obj.nodes{i}.ready_to_ekf_p1 == 1 && obj.nodes{i}.eitaIsSent ==0) %eita is ready to publish
                    obj.nodes{i}.eitaIsSent =1;
                    for j = sort(obj.network{i})
                        %if(obj.nodes{j}.ready_to_ekf_p1==1)
                        obj.nodes{j}.seteital(i,obj.nodes{i}.eita,obj.nodes{i}.P);
                       
                        if(j ~= i)% if it is to my self, do not count!
                            obj.sentmsgsD = obj.sentmsgsD +1;
                        end
                        %end
                    end
                end
            end
        end
        
        % state process function
        function snew = processFcn_red(obj, s, dt)
            snew = s;
            %srcIndex=meas.getSourceId() +1;
            
            % perform process update over each node separately
            stateSize = 5;
            i = 1;
            for n=size(s)/5
                snew(i+3) = s(i+3) + s(i+4) * 1e-9 * dt;
                i = i + stateSize;
            end
        end
        %   network= { [1 2 3 ],[ 1 2 3 ],[ 1 2 3 4],[3 4 5],[4 5 6],[5 6 7],[6 7 8],[1 2 3 4 5 6 7 8]};
        function y = measurementFcn_red(obj,s,meas,nodeIdx )
            type = meas.getType();
            
            srcIdx = obj.getNodeIdx(meas.getSourceId());
            dstIdx = obj.getNodeIdx(meas.getDestId());
            
            % find state indices for nodes with index i and j
            stateSize = 5;
            start_i = (srcIdx-1)*stateSize + 1;
            start_j = (dstIdx-1)*stateSize + 1;
            
            for i=1:length(obj.nodes)
                %if the node is not in the negh, then take out 5
                if( ~any(i==obj.network{nodeIdx}) && srcIdx >= i  )  %&& i < max(obj.network{srcIdx})
                    start_i = start_i -5;
                end
                if( ~any(i==obj.network{nodeIdx}) && dstIdx >= i ) %&& dstIdx > i
                    start_j = start_j -5;
                end
            end
            
            % extract the needed state info
            pi = s(start_i:(start_i+2));
            pj = s(start_j:(start_j+2));
            oi = s(start_i+3);
            oj = s(start_j+3);
            bi = s(start_i+4);
            bj = s(start_j+4);
            
            % predicted measurement y
            % format: y = [d_ij; r_ij; B_ij; R_ij];
            y = [];
            
            c = obj.LIGHTSPEED;
            
            % d_ij = range/speed_of_light + offset
            if obj.filter_meas_d
                if obj.enable_slats
                    y = [y; ( sqrt(sum((pj-pi).^2)) + 2.0 )/c + (oj - oi)];
                    
                else
                    y = [y; (oj - oi)];
                end
            end
            
            % type 1 only has offset
            if type == 1
                return;
            end
            
            % r_ij = range + t_error
            if obj.filter_meas_r
                if obj.enable_slats
                    y = [y; sqrt(sum((pj-pi).^2)) + (c*meas.T_rsp1/2)*(bj - bi)*1e-9];
                else
                    y = [y; sqrt(sum((pj-pi).^2))];
                end
            end
            
            % type 2 only has offset and noisy range
            if type == 2
                return;
            end
            
            % R_ij = range + t_error
            if obj.filter_meas_R
                if obj.enable_slats
                    err = c*( 1e-9*(bi-bj)*(meas.T_rnd0*meas.T_rnd1 - meas.T_rsp0*meas.T_rsp1 ))/( (1+ 1e-9*(bi-bj))*meas.T_rnd0 + meas.T_rnd1 + meas.T_rsp0 + (1+ 1e-9*(bi-bj))*meas.T_rsp1 );
                    y = [y; sqrt(sum((pj-pi).^2)) + err ];
                else
                    y = [y; sqrt(sum((pj-pi).^2))];
                end
            end
        end
        % get process variance
        function Q = getProcessVar_red(obj)
            Q = [];
            for i=1:length(obj.nodes)
                Q = [Q; obj.nodes{i}.getProcessVar()];
            end
            Q= diag(Q);
        end
        
        % get initial variance
        function P = getInitialVar_red(obj)
            p = [];
            for i=1:length(obj.nodes)
                p = [p; obj.nodes{i}.getInitialVar()];
            end
            P = diag(p);
        end
        
        function sendP(obj)
            P = obj.nodes{9}.P;
            for i =1:8
                P = P + obj.nodes{i}.P;
            end
            obj.nodes{9}.P = P./9;
        end
        
        function calcThreshold(obj,dt_ref)
            numofnodes=9;
            numofstates=5;
            M=numofnodes*numofstates;
            c_diffusion=1/numofnodes *ones(numofnodes,numofnodes);
            C_mat=kron(c_diffusion,eye(M));
            G = 1;
            P_mat = blkdiag(obj.nodes{1}.P,obj.nodes{2}.P,obj.nodes{3}.P,obj.nodes{4}.P,obj.nodes{5}.P,obj.nodes{6}.P,obj.nodes{7}.P,obj.nodes{8}.P,obj.nodes{9}.P);
            P_minus_mat = blkdiag(obj.nodes{1}.P_minus,obj.nodes{2}.P_minus,obj.nodes{3}.P_minus,obj.nodes{4}.P_minus,obj.nodes{5}.P_minus,obj.nodes{6}.P_minus,obj.nodes{7}.P_minus,obj.nodes{8}.P_minus,obj.nodes{9}.P_minus);
            X = [obj.nodes{1}.x,obj.nodes{2}.x,obj.nodes{3}.x,obj.nodes{4}.x,obj.nodes{5}.x,obj.nodes{6}.x,obj.nodes{7}.x,obj.nodes{8}.x,obj.nodes{9}.x];
            fstate= @(X) processFcn(s, dt_ref);
            h = @(X) measurementFcn(s, meas);
            [f, F_bar]= jaccsd(fstate,X);
            L = ones(numofnodes,numofnodes);
            L_latin=kron(L,eye(M));
            A = C_mat' * P_mat * (P_minus_mat)^-1 * kron(eye(length(P_minus_mat)/length(F_bar)),F_bar);
            B = C_mat' * P_mat * (P_minus_mat)^-1 * kron(eye(length(P_minus_mat)/length(F_bar)),G);
            % D = C_mat' * P_mat * L_latin' *
            
        end
        
        
        function P=getCovWithXerror(obj,meas,P_old,dt_ref,walltime)
            %If A is an m × n matrix and B is a p × q matrix,
            %then the Kronecker product A ? B is the mp × nq block matrix
            numofnodes=9;
            numofstates=5;
            M=numofnodes*numofstates;
            c_diffusion=1/numofnodes *ones(numofnodes,numofnodes);
            C_mat=kron(c_diffusion,eye(M));
            G = 1;
            P_mat = blkdiag(obj.nodes{1}.P_i_i,obj.nodes{2}.P_i_i,obj.nodes{3}.P_i_i,obj.nodes{4}.P_i_i,obj.nodes{5}.P_i_i,obj.nodes{6}.P_i_i,obj.nodes{7}.P_i_i,obj.nodes{8}.P_i_i,obj.nodes{9}.P_i_i);
            P_minus_mat = blkdiag(obj.nodes{1}.P_minus,obj.nodes{2}.P_minus,obj.nodes{3}.P_minus,obj.nodes{4}.P_minus,obj.nodes{5}.P_minus,obj.nodes{6}.P_minus,obj.nodes{7}.P_minus,obj.nodes{8}.P_minus,obj.nodes{9}.P_minus);
            
            L = ones(numofnodes,numofnodes);
            L_latin=kron(L,eye(M));
            
            % get the true positions X_true
            rb=1;
            [xyz_mobile, latency] = obj.dataparser.getMocapPos(rb, walltime);
            
            x_true = [];
            for i=1:length(obj.nodes)
                if ~obj.nodes{i}.isMobile()
                    x_true = [x_true;  obj.nodes{i}.getTruePosition(); obj.nodes{1}.state_clkofst; obj.nodes{1}.state_clkbias];
                else
                    x_true = [x_true;  xyz_mobile'; obj.nodes{1}.state_clkofst; obj.nodes{1}.state_clkbias];
                end
            end
            % X = [obj.nodes{1}.x_i_i;obj.nodes{2}.x_i_i;obj.nodes{3}.x_i_i;obj.nodes{4}.x_i_i;obj.nodes{5}.x_i_i;obj.nodes{6}.x_i_i;obj.nodes{7}.x_i_i;obj.nodes{8}.x_i_i;obj.nodes{8}.x_i_i];
            X = [x_true-obj.nodes{1}.x_i_i;x_true-obj.nodes{2}.x_i_i;x_true-obj.nodes{3}.x_i_i;x_true-obj.nodes{4}.x_i_i;x_true-obj.nodes{5}.x_i_i;x_true-obj.nodes{6}.x_i_i;x_true-obj.nodes{7}.x_i_i;x_true-obj.nodes{8}.x_i_i;x_true-obj.nodes{9}.x_i_i];
            fstate= @(X) obj.processExtendedFcn(X, dt_ref);
            [f, F]= obj.jaccsd(fstate,X);
            
            
            for i=1:obj.getNumNodes()
                x=x_true-obj.nodes{i}.x_i_i;
                h = @(x) obj.measurementFcn(x, meas);
                [ h_, H_{i}]= obj.jaccsd(h,x);
            end
            % Convert H_{i} to H_vector
            %H_vector = [ H_{1}', H_{2}', H_{3}', H_{4}', H_{5}', H_{6}', H_{7}', H_{8}', H_{9}' ];
            %H = diag(H_vector);
            H= blkdiag( H_{1}, H_{2}, H_{3}, H_{4}, H_{5}, H_{6}, H_{7}, H_{8}, H_{9});
            
            R_single = meas.getCovariance();
            R= blkdiag(R_single,R_single,R_single,R_single,R_single,R_single,R_single,R_single,R_single);
            A = C_mat' * P_mat * (P_minus_mat)^-1 * kron(eye(length(P_minus_mat)/length(F)),F);
            B = C_mat' * P_mat * (P_minus_mat)^-1 * kron(eye(length(P_minus_mat)/length(F)),G);
            D = C_mat' * P_mat * L_latin' * H' * R^-1;
            onesVec=ones(numofnodes,1);
            Q = obj.getProcessVar();
            P = A*P_old*A' + B* kron(onesVec*onesVec',Q)*B'+D*R*D';
            
        end
        
        function P=getCovStatic(obj,meas,P_old,dt_ref)
            %If A is an m × n matrix and B is a p × q matrix,
            %then the Kronecker product A ? B is the mp × nq block matrix
            numofnodes=8;
            numofstates=5;
            M=numofnodes*numofstates;
            c_diffusion=1/numofnodes *ones(numofnodes,numofnodes);
            C_mat=kron(c_diffusion,eye(M));
            G = 1;
            P_mat = blkdiag(obj.nodes{1}.P_i_i,obj.nodes{2}.P_i_i,obj.nodes{3}.P_i_i,obj.nodes{4}.P_i_i,obj.nodes{5}.P_i_i,obj.nodes{6}.P_i_i,obj.nodes{7}.P_i_i,obj.nodes{8}.P_i_i);
            P_minus_mat = blkdiag(obj.nodes{1}.P_minus,obj.nodes{2}.P_minus,obj.nodes{3}.P_minus,obj.nodes{4}.P_minus,obj.nodes{5}.P_minus,obj.nodes{6}.P_minus,obj.nodes{7}.P_minus,obj.nodes{8}.P_minus);
            
            L = ones(numofnodes,numofnodes);
            L_latin=kron(L,eye(M));
            
            
            X = [obj.nodes{1}.x_i_i;obj.nodes{2}.x_i_i;obj.nodes{3}.x_i_i;obj.nodes{4}.x_i_i;obj.nodes{5}.x_i_i;obj.nodes{6}.x_i_i;obj.nodes{7}.x_i_i;obj.nodes{8}.x_i_i];
            fstate= @(X) obj.processExtendedFcn(X, dt_ref);
            [f, F]= obj.jaccsd(fstate,X);
            
            for i=1:obj.getNumNodes()
                x=obj.nodes{i}.x_i_i;
                h = @(x) obj.measurementFcn(x, meas);
                [ h_, H_{i}]= obj.jaccsd(h,x);
            end
            % Convert H_{i} to H_vector
            %H_vector = [ H_{1}', H_{2}', H_{3}', H_{4}', H_{5}', H_{6}', H_{7}', H_{8}', H_{9}' ];
            %H = diag(H_vector);
            H= blkdiag( H_{1}, H_{2}, H_{3}, H_{4}, H_{5}, H_{6}, H_{7}, H_{8});
            
            R_single = meas.getCovariance();
            R= blkdiag(R_single,R_single,R_single,R_single,R_single,R_single,R_single,R_single);
            A = C_mat' * P_mat * (P_minus_mat)^-1 * kron(eye(length(P_minus_mat)/length(F)),F);
            B = C_mat' * P_mat * (P_minus_mat)^-1 * kron(eye(length(P_minus_mat)/length(F)),G);
            D = C_mat' * P_mat * L_latin' * ctranspose(H) * R^-1;
            onesVec=ones(numofnodes,1);
            Q = obj.getProcessVar();
            P = A*P_old*ctranspose(A) + B* kron(onesVec*ctranspose(onesVec),Q)*ctranspose(B)+D*R*ctranspose(D);
            
        end
        
        function P=getCovStaticTimeUpdate(obj,P_old,dt_ref)
            %If A is an m × n matrix and B is a p × q matrix,
            %then the Kronecker product A ? B is the mp × nq block matrix
            numofnodes=8;
            numofstates=5;
            M=numofnodes*numofstates;
            X = [obj.nodes{1}.x_i_i;obj.nodes{2}.x_i_i;obj.nodes{3}.x_i_i;obj.nodes{4}.x_i_i;obj.nodes{5}.x_i_i;obj.nodes{6}.x_i_i;obj.nodes{7}.x_i_i;obj.nodes{8}.x_i_i];
            fstate= @(X) obj.processExtendedFcn(X, dt_ref);
            [f, F]= obj.jaccsd(fstate,X);
            onesVec=ones(numofnodes,1);
            Q = obj.getProcessVar();
            G=eye(numofnodes*numofstates);
            % FF = kron(eye(numofnodes),F);
            
            
            %GG = kron(onesVec,G);
            GG = kron(onesVec,G);
            P = F*P_old*ctranspose(F) + GG*Q*ctranspose(GG);
            
        end
        
        %        P_mobile=P_old(45*8+1:end,45*8+1:end);
        % MOBILEID = 10;
        %         mobIdx = obj.getNodeIdx( MOBILEID )
        %         stateIdx = (mobIdx-1)*5 + 1
        %         Pi = P_mobile(stateIdx:(stateIdx+2), stateIdx:(stateIdx+2))
        %  avg_trace = trace(Pi)/3
        function P=getCov(obj,meas,P_old,dt_ref)
            %If A is an m × n matrix and B is a p × q matrix,
            %then the Kronecker product A ? B is the mp × nq block matrix
            numofnodes=9;
            numofstates=5;
            M=numofnodes*numofstates;
            c_diffusion=1/numofnodes *ones(numofnodes,numofnodes);
            C_mat=kron(c_diffusion,eye(M));
            G = 1;
            P_mat = blkdiag(obj.nodes{1}.P_i_i,obj.nodes{2}.P_i_i,obj.nodes{3}.P_i_i,obj.nodes{4}.P_i_i,obj.nodes{5}.P_i_i,obj.nodes{6}.P_i_i,obj.nodes{7}.P_i_i,obj.nodes{8}.P_i_i,obj.nodes{9}.P_i_i);
            P_minus_mat = blkdiag(obj.nodes{1}.P_minus,obj.nodes{2}.P_minus,obj.nodes{3}.P_minus,obj.nodes{4}.P_minus,obj.nodes{5}.P_minus,obj.nodes{6}.P_minus,obj.nodes{7}.P_minus,obj.nodes{8}.P_minus,obj.nodes{9}.P_minus);
            
            L = ones(numofnodes,numofnodes);
            L_latin=kron(L,eye(M));
            
            X = [obj.nodes{1}.x_i_i;obj.nodes{2}.x_i_i;obj.nodes{3}.x_i_i;obj.nodes{4}.x_i_i;obj.nodes{5}.x_i_i;obj.nodes{6}.x_i_i;obj.nodes{7}.x_i_i;obj.nodes{8}.x_i_i;obj.nodes{9}.x_i_i];
            fstate= @(X) obj.processExtendedFcn(X, dt_ref);
            [f, F]= obj.jaccsd(fstate,X);
            
            for i=1:obj.getNumNodes()
                x=obj.nodes{i}.x_i_i;
                h = @(x) obj.measurementFcn(x, meas);
                [ h_, H_{i}]= obj.jaccsd(h,x);
            end
            % Convert H_{i} to H_vector
            %H_vector = [ H_{1}', H_{2}', H_{3}', H_{4}', H_{5}', H_{6}', H_{7}', H_{8}', H_{9}' ];
            %H = diag(H_vector);
            H= blkdiag( H_{1}, H_{2}, H_{3}, H_{4}, H_{5}, H_{6}, H_{7}, H_{8}, H_{9});
            
            R_single = meas.getCovariance();
            R= blkdiag(R_single,R_single,R_single,R_single,R_single,R_single,R_single,R_single,R_single);
            A = ctranspose(C_mat) * P_mat * (P_minus_mat)^-1 * kron(eye(length(P_minus_mat)/length(F)),F);
            B = ctranspose(C_mat)  * P_mat * (P_minus_mat)^-1 * kron(eye(length(P_minus_mat)/length(F)),G);
            D = ctranspose(C_mat)  * P_mat * L_latin' * H' * R^-1;
            onesVec=ones(numofnodes,1);
            Q = obj.getProcessVar();
            P = A*P_old*ctranspose(A) + B* kron(onesVec*ctranspose(onesVec),Q)*ctranspose(B)+D*R*ctranspose(D);
            
        end
        
        function P=getCovMobileTimeUpdate(obj,P_old,dt_ref)
            %If A is an m × n matrix and B is a p × q matrix,
            %then the Kronecker product A ? B is the mp × nq block matrix
            numofnodes=9;
            numofstates=5;
            M=numofnodes*numofstates;
            X = [obj.nodes{1}.x_i_i;obj.nodes{2}.x_i_i;obj.nodes{3}.x_i_i;obj.nodes{4}.x_i_i;obj.nodes{5}.x_i_i;obj.nodes{6}.x_i_i;obj.nodes{7}.x_i_i;obj.nodes{8}.x_i_i;obj.nodes{9}.x_i_i];
            fstate= @(X) obj.processExtendedFcn(X, dt_ref);
            [f, F]= obj.jaccsd(fstate,X);
            onesVec=ones(numofnodes,1);
            Q = obj.getProcessVar();
            G=eye(numofnodes*numofstates);
            % FF = kron(eye(numofnodes),F);
            
            
            %GG = kron(onesVec,G);
            GG = kron(onesVec,G);
            P = F*P_old*ctranspose(F) + GG*Q*ctranspose(GG);
            
        end
        
        function P=getCovStaticWithXerror(obj,meas,P_old,dt_ref)
            %If A is an m × n matrix and B is a p × q matrix,
            %then the Kronecker product A ? B is the mp × nq block matrix
            numofnodes=8;
            numofstates=5;
            M=numofnodes*numofstates;
            c_diffusion=1/numofnodes *ones(numofnodes,numofnodes);
            C_mat=kron(c_diffusion,eye(M));
            G = 1;
            P_mat = blkdiag(obj.nodes{1}.P_i_i,obj.nodes{2}.P_i_i,obj.nodes{3}.P_i_i,obj.nodes{4}.P_i_i,obj.nodes{5}.P_i_i,obj.nodes{6}.P_i_i,obj.nodes{7}.P_i_i,obj.nodes{8}.P_i_i);
            P_minus_mat = blkdiag(obj.nodes{1}.P_minus,obj.nodes{2}.P_minus,obj.nodes{3}.P_minus,obj.nodes{4}.P_minus,obj.nodes{5}.P_minus,obj.nodes{6}.P_minus,obj.nodes{7}.P_minus,obj.nodes{8}.P_minus);
            
            L = ones(numofnodes,numofnodes);
            L_latin=kron(L,eye(M));
            
            % get the true positions X_true
            x_true = [];
            for i=1:length(obj.nodes)
                if ~obj.nodes{i}.isMobile()
                    x_true = [x_true;  obj.nodes{i}.getTruePosition(); obj.nodes{1}.state_clkofst; obj.nodes{1}.state_clkbias];
                end
            end
            % X = [obj.nodes{1}.x_i_i;obj.nodes{2}.x_i_i;obj.nodes{3}.x_i_i;obj.nodes{4}.x_i_i;obj.nodes{5}.x_i_i;obj.nodes{6}.x_i_i;obj.nodes{7}.x_i_i;obj.nodes{8}.x_i_i];
            X = [x_true-obj.nodes{1}.x_i_i;x_true-obj.nodes{2}.x_i_i;x_true-obj.nodes{3}.x_i_i;x_true-obj.nodes{4}.x_i_i;x_true-obj.nodes{5}.x_i_i;x_true-obj.nodes{6}.x_i_i;x_true-obj.nodes{7}.x_i_i;x_true-obj.nodes{8}.x_i_i];
            fstate= @(X) obj.processExtendedFcn(X, dt_ref);
            [f, F]= obj.jaccsd(fstate,X);
            
            for i=1:obj.getNumNodes()
                x=obj.nodes{i}.x_i_i;
                h = @(x) obj.measurementFcn(x, meas);
                [ h_, H_{i}]= obj.jaccsd(h,x);
            end
            % Convert H_{i} to H_vector
            %H_vector = [ H_{1}', H_{2}', H_{3}', H_{4}', H_{5}', H_{6}', H_{7}', H_{8}', H_{9}' ];
            %H = diag(H_vector);
            H= blkdiag( H_{1}, H_{2}, H_{3}, H_{4}, H_{5}, H_{6}, H_{7}, H_{8});
            
            R_single = meas.getCovariance();
            R= blkdiag(R_single,R_single,R_single,R_single,R_single,R_single,R_single,R_single);
            A = C_mat' * P_mat * (P_minus_mat)^-1 * kron(eye(length(P_minus_mat)/length(F)),F);
            B = C_mat' * P_mat * (P_minus_mat)^-1 * kron(eye(length(P_minus_mat)/length(F)),G);
            D = C_mat' * P_mat * L_latin' * H' * R^-1;
            onesVec=ones(numofnodes,1);
            Q = obj.getProcessVar();
            P = A*P_old*A' + B* kron(onesVec*onesVec',Q)*B'+D*R*D';
            
        end
        
        
        
        function [z,A]=jaccsd(obj,fun,x)
            % JACCSD Jacobian through complex step differentiation
            % [z J] = jaccsd(f,x)
            % z = f(x)
            % J = f'(x)
            % example :
            % f=@(x)[x(2);x(3);0.05*x(1)*x(2)];
            % [x,A]=jaccsd(f,[1 1 1])
            %
            % x =
            %
            %     1.0000
            %     1.0000
            %     0.0500
            %
            %
            % A =
            %
            %          0    1.0000         0
            %          0         0    1.0000
            %     0.0500    0.0500         0
            z=fun(x);
            n=numel(x);%Number of elements in an array or subscripted array expression.
            m=numel(z);
            A=zeros(m,n);
            h=n*eps;
            for k=1:n
                x1=x;
                x1(k)=x1(k)+h*i;
                A(:,k)=imag(fun(x1))/h;
            end
        end
        
        function snew = processExtendedFcn(obj, s, dt)
            snew = s;
            
            % perform process update over each node separately
            stateSize = 5;
            i = 1;
            for n=1:stateSize:length(s)
                snew(i+3) = s(i+3) + s(i+4) * 1e-9 * dt;
                i = i + stateSize;
            end
        end
        % state measurement function
        function y = measurementFcnExtended(obj, s, meas)
            type = meas.getType();
            
            srcIdx = obj.getNodeIdx(meas.getSourceId());
            dstIdx = obj.getNodeIdx(meas.getDestId());
            
            % find state indices for nodes with index i and j
            stateSize = 5;
            start_i = (srcIdx-1)*stateSize + 1;
            start_j = (dstIdx-1)*stateSize + 1;
            
            % extract the needed state info
            pi = s(start_i:(start_i+2));
            pj = s(start_j:(start_j+2));
            oi = s(start_i+3);
            oj = s(start_j+3);
            bi = s(start_i+4);
            bj = s(start_j+4);
            
            % predicted measurement y
            % format: y = [d_ij; r_ij; B_ij; R_ij];
            y = [];
            
            c = obj.LIGHTSPEED;
            
            % d_ij = range/speed_of_light + offset
            if obj.filter_meas_d
                if obj.enable_slats
                    y = [y; ( sqrt(sum((pj-pi).^2)) + 2.0 )/c + (oj - oi)];
                else
                    y = [y; (oj - oi)];
                end
            end
            
            % type 1 only has offset
            if type == 1
                return;
            end
            
            % r_ij = range + t_error
            if obj.filter_meas_r
                if obj.enable_slats
                    y = [y; sqrt(sum((pj-pi).^2)) + (c*meas.T_rsp1/2)*(bj - bi)*1e-9];
                else
                    y = [y; sqrt(sum((pj-pi).^2))];
                end
            end
            
            % type 2 only has offset and noisy range
            if type == 2
                return;
            end
            
            % R_ij = range + t_error
            if obj.filter_meas_R
                if obj.enable_slats
                    err = c*( 1e-9*(bi-bj)*(meas.T_rnd0*meas.T_rnd1 - meas.T_rsp0*meas.T_rsp1 ))/( (1+ 1e-9*(bi-bj))*meas.T_rnd0 + meas.T_rnd1 + meas.T_rsp0 + (1+ 1e-9*(bi-bj))*meas.T_rsp1 );
                    y = [y; sqrt(sum((pj-pi).^2)) + err ];
                else
                    y = [y; sqrt(sum((pj-pi).^2))];
                end
            end
        end
        
        function RunTimeFlag=ekfPartThreeOnlyForAll(obj,Q,fstate,dt_ref)
            for i=1:length(obj.nodes)
                obj.nodes{i}.ekf_part3_Only(Q,fstate);
            end
            RunTimeFlag=obj.TimePCovUpdate(dt_ref);
        end
          
                       
        function RunTimeFlag=ekfPartThreeOnlyForAllUncon(obj,Q,fstate)
            for i=1:length(obj.nodes)
                obj.nodes{i}.ekf_part3_Only(Q,fstate);
            end
            mobileIndex =9;
            RunTimeFlag=obj.nodes{mobileIndex}.timeUpdateFlag ==1;
            %reset the node flag
            obj.nodes{mobileIndex}.timeUpdateFlag =0;
            
        end
        
        function RunFlag= MeasurementPCovUpdate(obj,dt_ref,meas)
            iamReady=1;
            for i=1:length(obj.nodes)
                if obj.nodes{i}.measUpdateFlag ==0
                    iamReady=0;
                end
            end
            RunFlag = 0;
            if iamReady==1
                RunFlag = 1;
                numofnodes=9;
                numofstates=5;
                M=numofnodes*numofstates;
                G = 1;
                P_mat = blkdiag(obj.nodes{1}.P_i_i,obj.nodes{2}.P_i_i,obj.nodes{3}.P_i_i,obj.nodes{4}.P_i_i,obj.nodes{5}.P_i_i,obj.nodes{6}.P_i_i,obj.nodes{7}.P_i_i,obj.nodes{8}.P_i_i,obj.nodes{9}.P_i_i);
                P_minus_mat = blkdiag(obj.nodes{1}.P_minus,obj.nodes{2}.P_minus,obj.nodes{3}.P_minus,obj.nodes{4}.P_minus,obj.nodes{5}.P_minus,obj.nodes{6}.P_minus,obj.nodes{7}.P_minus,obj.nodes{8}.P_minus,obj.nodes{9}.P_minus);
                
                L = ones(numofnodes,numofnodes);
                L_latin=kron(L,eye(M));
                
                X = [obj.nodes{1}.eita;obj.nodes{2}.eita;obj.nodes{3}.eita;obj.nodes{4}.eita;obj.nodes{5}.eita;obj.nodes{6}.eita;obj.nodes{7}.eita;obj.nodes{8}.eita;obj.nodes{9}.eita];
                fstate= @(X) obj.processExtendedFcn(X, dt_ref);
                [f, F]= obj.jaccsd(fstate,X);
                
                for i=1:obj.getNumNodes()
                    x=obj.nodes{i}.eita;
                    h = @(x) obj.measurementFcn(x, meas);
                    [ h_, H_{i}]= obj.jaccsd(h,x);
                end
                % Convert H_{i} to H_vector
                %H_vector = [ H_{1}', H_{2}', H_{3}', H_{4}', H_{5}', H_{6}', H_{7}', H_{8}', H_{9}' ];
                %H = diag(H_vector);
                H= blkdiag( H_{1}, H_{2}, H_{3}, H_{4}, H_{5}, H_{6}, H_{7}, H_{8}, H_{9});
                
                R_single = meas.getCovariance();
                R= blkdiag(R_single,R_single,R_single,R_single,R_single,R_single,R_single,R_single,R_single);
               
                CovTermOne = P_mat * P_minus_mat^-1 * obj.cov_big * P_minus_mat^-1 *P_mat ;
                CovTermTwo = P_mat  * L_latin' * ctranspose(H) * R ^-1 * H * L_latin * P_mat;
               
                obj.cov_big =  CovTermOne + CovTermTwo;
                
                %%%%%%%%%%%%%%%%%%%
%                 temp = [];
%                 for i=1:obj.getNumNodes()
%                     temp = [ temp ;  ctranspose(H_{i}) * R_single^-1* H_{i}];
%                 end
%                 PTermOne = P_minus_mat ;
%                 PTermTwo =  L_latin' * temp;
%                 obj.P_big = ( PTermOne +PTermTwo )^-1 ;
                obj.P_big = P_mat;
                
                
                for i=1:length(obj.nodes)
                    obj.nodes{i}.measUpdateFlag =0;   
                end
                
            end
        end
        
        function RunFlag=DiffusionPCovUpdate(obj)
            iamReady=1;%assume they are ready
            for i=1:length(obj.nodes)
                if obj.nodes{i}.diffUpdateFlag ==0
                    iamReady=0; % some one is not ready :(
                end
            end
            RunFlag=0;
            if iamReady ==1
                RunFlag=1;
                numofnodes=9;
                numofstates=5;
                M=numofnodes*numofstates;
                c_diffusion=1/numofnodes *ones(numofnodes,numofnodes);
                C_mat=kron(c_diffusion,eye(M));
                %% no change in P_big
                %% update the cov
                obj.cov_big = C_mat'*obj.cov_big*C_mat;
                for i=1:length(obj.nodes)
                    obj.nodes{i}.diffUpdateFlag =0;
                end
            end
        
        end
        
%         %just a fake one
%         function RunFlag=TimePCovUpdateUncon(obj,dt_ref)
%             iamReady=1;%assume they are ready
%             for i=1:length(obj.nodes)
%                 if obj.nodes{i}.timeUpdateFlag ==0
%                     iamReady=0; % some one is not ready :(
%                 end
%             end
%             RunFlag=0;
%             if iamReady ==1
%                 RunFlag=1;
%                 numofnodes=9;
%                 numofstates=5;
%                 M=numofnodes*numofstates;
%                 X = [obj.nodes{1}.x_i_i;obj.nodes{2}.x_i_i;obj.nodes{3}.x_i_i;obj.nodes{4}.x_i_i;obj.nodes{5}.x_i_i;obj.nodes{6}.x_i_i;obj.nodes{7}.x_i_i;obj.nodes{8}.x_i_i;obj.nodes{9}.x_i_i];
%                 fstate= @(X) obj.processExtendedFcn(X, dt_ref);
%                 [f, F]= obj.jaccsd(fstate,X);
%                 onesVec=ones(numofnodes,1);
%                 Q = obj.getProcessVar();
%                 G=eye(numofnodes*numofstates);
%                 % FF = kron(eye(numofnodes),F);
%                    
%                 %GG = kron(onesVec,G);
%                 GG = kron(onesVec,G);
%                 obj.cov_big = F*obj.cov_big * ctranspose(F) + GG*Q*ctranspose(GG);
%                 obj.P_big = F*obj.P_big * ctranspose(F) + GG*Q*ctranspose(GG);
%                 for i=1:length(obj.nodes)
%                     obj.nodes{i}.timeUpdateFlag =0;
%                 end
%             end
%         end
%     end       
        
        function RunFlag=TimePCovUpdate(obj,dt_ref)
            iamReady=1;%assume they are ready
            for i=1:length(obj.nodes)
                if obj.nodes{i}.timeUpdateFlag ==0
                    iamReady=0; % some one is not ready :(
                end
            end
            RunFlag=0;
            if iamReady ==1
                RunFlag=1;
                numofnodes=9;
                numofstates=5;
                M=numofnodes*numofstates;
                X = [obj.nodes{1}.x_i_i;obj.nodes{2}.x_i_i;obj.nodes{3}.x_i_i;obj.nodes{4}.x_i_i;obj.nodes{5}.x_i_i;obj.nodes{6}.x_i_i;obj.nodes{7}.x_i_i;obj.nodes{8}.x_i_i;obj.nodes{9}.x_i_i];
                fstate= @(X) obj.processExtendedFcn(X, dt_ref);
                [f, F]= obj.jaccsd(fstate,X);
                onesVec=ones(numofnodes,1);
                Q = obj.getProcessVar();
                G=eye(numofnodes*numofstates);
                % FF = kron(eye(numofnodes),F);
                   
                %GG = kron(onesVec,G);
                GG = kron(onesVec,G);
                obj.cov_big = F*obj.cov_big * ctranspose(F) + GG*Q*ctranspose(GG);
                obj.P_big = F*obj.P_big * ctranspose(F) + GG*Q*ctranspose(GG);
                for i=1:length(obj.nodes)
                    obj.nodes{i}.timeUpdateFlag =0;
                end
            end
        end
    end
end