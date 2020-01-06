classdef Measurement < handle
    %MEASUREMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        LIGHTSPEED = 299792458; % m/s
        % range var is about 0.05 m, so due to timing that's about 1.67e-10
 
        var_dij = 1e-12; % around -20 to converge on type 1 only
        %var_dij = 1e-12;
        var_rij = 1.00;   
        var_Rij = 0.30;

%         var_dij = 1e-12; % around -20 to converge on type 1 only
%         %var_dij = 1e-12;
%         var_rij = 1.00;   
%         var_Rij = 0.30;
        % cross terms
        var_dxr = 0;
        var_dxR = 0;
        var_rxR = 0;
    end
    
    properties
        % measurement type
        type = 0;
        % measurement wall time
        walltime = 0;
        % measurement source (i)
        nodei = 0;
        % measurement destination (j)
        nodej = 0;
        % processed measurements
        d_ij = 0;
        r_ij = 0;
        R_ij = 0;
        % processed times
        T_rsp0 = 0;
        T_rsp1 = 0;
        T_rnd0 = 0;
        T_rnd1 = 0;
        % rx quality
        fppwr = 0;
        cirp = 0;
        fploss = 0;
        % measurement filters
        allow_d = false;
        allow_b = false;
        allow_r = false;
        allow_B = false;
        allow_R = false;
        % beaconing raw times
        t_bcn_tx = 0;
        t_bcn_rx = 0;
        t_i = 0;
        t_j = 0;
        % sequence number
        seq = 0;
        % is this a queued message?
        queued = 0;
        t0;
        t1;
        t2;
        t3;
        t4;
        t5;
        attackValue=0;
        attackOffset=0;
    end
    
    methods

        % constructor
        function obj = Measurement( varargin )
            % process raw measurement
            % format: time, dest, src, seq, ts0, ..., ts5, fppwr, cirp, fploss
            
            if nargin >1
                raw =varargin{2};
            obj.type = varargin{1};
            obj.walltime = raw(1);
            obj.nodei = raw(2); % ROS
            obj.nodej = raw(3); % ROS
            obj.seq = raw(4);
            obj.t0 = raw(5);  % i
            obj.t1 = raw(6);  % j
            obj.t2 = raw(7);  % i
            obj.t3 = raw(8);  % j
            obj.t4 = raw(9);  % i
            obj.t5 = raw(10); % j
            obj.t_bcn_tx = obj.t0;
            obj.t_bcn_rx = obj.t1;
            obj.t_j = obj.t5;
            obj.t_i = obj.t4;
            % copy rx quality measurements
            %obj.fppwr = raw(11);
            %obj.cirp = raw(12);
            obj.fploss = raw(11); % ROS
            
            % calculate processed measurements
            obj.d_ij = (obj.t5 - obj.t4);
            %obj.d_ij = (t1 - t0);
            obj.T_rnd0 = obj.t3-obj.t0;
            obj.T_rnd1 = obj.t5-obj.t2;
            obj.T_rsp0 = obj.t2-obj.t1;
            obj.T_rsp1 = obj.t4-obj.t3;
            
            obj.r_ij = (obj.LIGHTSPEED/2)*(obj.T_rnd1 - obj.T_rsp1);
            %obj.R_ij = (obj.LIGHTSPEED/4)*(obj.T_rnd0 - obj.T_rsp1 + obj.T_rnd1 - obj.T_rsp0);
            obj.R_ij = (obj.LIGHTSPEED)*(obj.T_rnd0*obj.T_rnd1 - obj.T_rsp0*obj.T_rsp1)/(obj.T_rnd0 + obj.T_rnd1 + obj.T_rsp0 + obj.T_rsp1);
            %obj.B_ij = ( (t5-t1)/(t4-t0) - 1 );
            end
        end

        % get the vectorized measurements
        function z = vectorize(obj)
            z = [];
            if obj.allow_d
                z = [obj.d_ij];
            end
            if obj.type >= 2
                if obj.allow_r
                    z = [z; obj.r_ij];
                end
            end
            if obj.type >= 3
                if obj.allow_R
                    z = [z; obj.R_ij];
                end
            end
        end
        
        % get the covariance matrix, R
        function R = getCovariance(obj)
            r = [];
            if obj.type == 1 || obj.type == 2 || obj.type == 3
                if obj.allow_d
                    r = [r; obj.var_dij];
                end
            end
            if obj.type == 2 || obj.type == 3
                if obj.allow_r
                    r = [r; obj.var_rij];
                end
            end
            if obj.type == 3
                if obj.allow_R
                    r = [r; obj.var_Rij];
                end
            end
            R = diag(r);
            
            % add cross-terms
            if obj.type == 2
                if obj.allow_r && obj.allow_d
                    R(1,2) = obj.var_dxr;
                    R(2,1) = obj.var_dxr;
                end
            end
            if obj.type == 3
                if obj.allow_d && obj.allow_r
                    R(1,2) = obj.var_dxr;
                    R(2,1) = obj.var_dxr;
                    if obj.allow_R
                        R(1,3) = obj.var_dxR;
                        R(2,3) = obj.var_rxR;
                        R(3,1) = obj.var_dxR;
                        R(3,2) = obj.var_rxR;
                    end
                end
                if obj.allow_d && obj.allow_R
                    R(1,2) = obj.var_dxR;
                    R(2,1) = obj.var_dxR;
                end
                
                if obj.allow_r && obj.allow_R
                    R(1,2) = obj.var_rxR;
                    R(2,1) = obj.var_rxR;
                end
            end
        end
                
        % get measurement type
        function t = getType(obj)
            t = obj.type;
        end
        
        function setType(obj, type)
            obj.type = type;
        end
        
        % get measurement time
        function t = getTime(obj)
            t = obj.walltime;
        end
        
        % get source node
        function id = getSourceId(obj)
            id = obj.nodei;
        end
        
        % get destination id
        function id = getDestId(obj)
            id = obj.nodej;
        end
        
        % measurement type filters
        function allowMeasType_d(obj)
            obj.allow_d = true;
        end
        function allowMeasType_r(obj)
            obj.allow_r = true;
        end
        function allowMeasType_R(obj)
            obj.allow_R = true;
        end
        
        % set measurement covariances
        function setCovar_dij(obj, v)
            obj.var_dij = v;
        end
        
        function setCovar_rij(obj, v)
            obj.var_rij = v;
        end
        
        function setCovar_Rij(obj, v)
            obj.var_Rij = v;
        end
    end
    
end

