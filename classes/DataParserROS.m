classdef DataParserROS < handle
    %DATAPARSER parse tcp data logs from NTB nodes
    %   obj = DataParser( config_file, log_folder )
    
    
    properties
        fpath = '';
        raw_logs = {};
        nodeinfo = {};
        timinglogs = [];
        mocaplogs = [];
        
        % for speed, map of id to idx and name to idx
        id2idx = zeros(1,128);
        name2idx = containers.Map('KeyType', 'char', 'ValueType', 'int32');
    end
    
    methods
        % Constructor
        function obj = DataParserROS( config, fpath )
            
            % open and parse config data
            fid = fopen(config);
            obj.nodeinfo = textscan(fid, '%s %f %f %f %f %s', 'Delimiter', ',');
            fclose(fid);
            
            % load hash tables for speed
            for i=1:length( obj.nodeinfo{1} )
                name = obj.nodeinfo{1}{i};
                id = obj.nodeinfo{2}(i);
                obj.id2idx(id+1) = i;
                obj.name2idx(name) = i;
            end
            
            % initialize log cell arrays
            obj.timinglogs = cell(1,length(obj.nodeinfo{1}));
            
            % read NTB timing measurements
            obj.fpath = fpath;
            d = importdata([obj.fpath '/ntbtiming.csv']);
            if size(d,1) < 0
                error('NTB log file empty');
            end
            
            % convert timestamps to seconds
            d(:,5) = d(:,5) / 63.8976 / 1e9;
            d(:,6) = d(:,6) / 63.8976 / 1e9;
            d(:,7) = d(:,7) / 63.8976 / 1e9;
            d(:,8) = d(:,8) / 63.8976 / 1e9;
            d(:,9) = d(:,9) / 63.8976 / 1e9;
            d(:,10) = d(:,10) / 63.8976 / 1e9;

            % check to make sure we have info on each node
            unique_ids = unique([d(:,2); d(:,3)]);
            for i=1:length(unique_ids)
                id = unique_ids(i);
                idxs = find(obj.nodeinfo{2} == id);
                if isempty(idxs)
                    warning('No config found for node ID: %d\n', id);
                    % remove data associated with this ID
                    toremove = find(d(:,2) == id | d(:,3) == id);
                    d(toremove,:) = [];
                end
            end
            
            obj.timinglogs = d;
            
            % load the OptiTrack mocap data
            obj.mocaplogs = importdata([obj.fpath '/mocap.csv' ]);
            if isempty(obj.mocaplogs)
                error('No mocap data in log file');
            end
        end
        
        % convert hostname to id
        function id = hostnameToId(obj, name)
            idx = find(strcmp(obj.nodeinfo{1}, name));
            id = obj.nodeinfo{2}(idx);
        end
        
        % convert id to hostname
        function name = idToHostname(obj, id)
            hostidx = find(obj.nodeinfo{2} == id);
            name = obj.nodeinfo{1}(hostidx);
        end
                
        % get node index from alpha or numeric ID
        function idx = getNodeIdx(obj, node)
            if isnumeric(node)
                idx = obj.id2idx( node+1 );
            else
                idx = obj.name2idx( node );
            end
        end
       
        % get the node info
        function info = getNodeInfo(obj)
            info = obj.nodeinfo;
        end
        
        % get the node position x,y,z
        function xyz = getNodePos(obj, id)
            idx = obj.getNodeIdx(id);
            xyz = [obj.nodeinfo{3}(idx) obj.nodeinfo{4}(idx) obj.nodeinfo{5}(idx)];
        end
        
        % number of aligned measurements
        function n = getNumMeasurements(obj)
            n = size(obj.timinglogs,1);
        end
        
        % get a specific measurement
        function meas = getMeasurement(obj, idx)
            meas = obj.timinglogs(idx,:);
        end
        
        % get number of pairwise messages
        function msgs = getPairwiseMessages(obj)
            N = length(obj.raw_logs);
            msgs = zeros(N, N);
            for i=1:N
                for j=1:N
                    % sent from i to j, received AT j
                    log = obj.raw_logs{j};
                    idxs = find(log(:,3) == (i-1));
                    msgs(i,j) = length(idxs);
                end
            end
        end
        
        % get rigid body ids
        function ids = getRigidBodyIds(obj)
            ids = unique(obj.mocaplogs(:,2));
        end
        
        % get closest mocap estimate to time for rigid body
        function [xyz, latency] = getMocapPos(obj, rb, time)
            idxs = obj.mocaplogs(:,2) == rb;
            [t, c] = min(abs(obj.mocaplogs(idxs,1)-time));
            xyz = obj.mocaplogs(c(1),3:5);
            latency = t(1);
        end
            
        % deprecated ... don't use
        function t = getTotalTime(obj)
            t = obj.timinglogs(end,1) - obj.timinglogs(1,1);
        end
        
       
    end
    
end











































