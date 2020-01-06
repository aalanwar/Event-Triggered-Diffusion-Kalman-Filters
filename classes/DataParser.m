classdef DataParser < handle
    %DATAPARSER parse tcp data logs from NTB nodes
    %   obj = DataParser( config_file, log_folder )
    
    
    properties
        fpath = '';
        raw_logs = {};
        nodeinfo = {};
        aligned_logs = [];
    end
    
    methods
        % Constructor
        function obj = DataParser( config, fpath )
            
            % open and parse config data
            fid = fopen(config);
            obj.nodeinfo = textscan(fid, '%s %f %f %f %f %s', 'Delimiter', ',');
            fclose(fid);
            
            % initialize log cell arrays
            obj.raw_logs = cell(1,length(obj.nodeinfo{1}));
            obj.aligned_logs = cell(1,length(obj.nodeinfo{1}));
            
            % read files in folder path
            [pathstr,~,~] = fileparts(fpath);
            obj.fpath = pathstr;
            % find all files
            all_files = dir(obj.fpath);
            for i=1:length(all_files)
                f = all_files(i);
                % ignore structural files
                if strcmp(f.name,'.') || strcmp(f.name,'..')
                    continue
                end
                
                % load file for given host
                d = importdata([obj.fpath '/' f.name]);
                if size(d,1) > 0
                    % if this node isn't in the config, throw an error
                    if isempty( find(strcmp(f.name, obj.nodeinfo{1})) )
                        error(['Log file without configuration: ' f.name]);
                    end
                    
                    % format = time, dest, Src, Seq, ts1, ..., ts6, fppwr, cirp, fploss
                    
                    %{
                    % find unique sources of comm. with this node
                    sources = unique(d(:,3));
                    
                    % correct for overflows on local and remote clocks for
                    % all sources
                    for i=1:length(sources)
                        s = sources(i);
                        idxs = find(d(:,3) == s);
                        
                        % correct sequence number
                        d(idxs,4) = d(idxs,4) + cumsum([0; diff(d(idxs,4))<0]) .* 2^8;
                        
                        % correct remote clock times (ts1,4,5)
                        d(idxs,5) = d(idxs,5) + cumsum([0; diff(d(idxs,5))<0]) .* 2^40;
                        d(idxs,8) = d(idxs,8) + cumsum([0; diff(d(idxs,8))<0]) .* 2^40;
                        d(idxs,9) = d(idxs,9) + cumsum([0; diff(d(idxs,9))<0]) .* 2^40;
                        
                        % correct local clock times (ts2,3,6)
                        d(idxs,6) = d(idxs,6) + cumsum([0; diff(d(idxs,6))<0]) .* 2^40;
                        d(idxs,7) = d(idxs,7) + cumsum([0; diff(d(idxs,7))<0]) .* 2^40;
                        d(idxs,10) = d(idxs,10) + cumsum([0; diff(d(idxs,10))<0]) .* 2^40;
                    end
                    %}
                    
                    % convert timestamps to seconds
                    d(:,5) = d(:,5) / 63.8976 / 1e9;
                    d(:,6) = d(:,6) / 63.8976 / 1e9;
                    d(:,7) = d(:,7) / 63.8976 / 1e9;
                    d(:,8) = d(:,8) / 63.8976 / 1e9;
                    d(:,9) = d(:,9) / 63.8976 / 1e9;
                    d(:,10) = d(:,10) / 63.8976 / 1e9;
                    
                    % find the right index from the nodeinfo config
                    nidx = find(strcmp(obj.nodeinfo{1}, f.name));
                    
                    % assign to raw logs
                    obj.raw_logs{nidx} = d;
                end
            end
            
            % aggregate all data by time in aligned logs
            temp = [];
            for i=1:length(obj.raw_logs)
                temp = [temp; obj.raw_logs{i}];
            end
            obj.aligned_logs = sortrows(temp);
            
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
                hostname = obj.idToHostname(node);
                idx = find(strcmp(obj.nodeinfo{1}, hostname));
            else
                idx = find(strcmp(obj.nodeinfo{1}, node));
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
            n = size(obj.aligned_logs,1);
        end
        
        % get a specific measurement
        function meas = getMeasurement(obj, idx)
            meas = obj.aligned_logs(idx,:);
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
        
        function t = getTotalTime(obj)
            t = obj.aligned_logs(end,1) - obj.aligned_logs(1,1);
        end
        
       
    end
    
end











































