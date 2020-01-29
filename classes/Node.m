classdef Node < handle
    
    properties
        id = 0;
        name = '';
        
        % true state variables
        true_p = [0;0;0];
        mobile = false;
        %% ------------
        measUpdateFlag=0;
        diffUpdateFlag=0;
        timeUpdateFlag=0;
        readyTochangeCovFlag=0;
        % corresponding rigid body id, if needed
        rigidbody_id = [];
        

%         
         state_p = [0;0;0];
         state_clkofst = 0;
         state_clkbias = 0;
%         

        % --- process variances --- Q
        % by default a node is static with no var on position
        var_p = [0; 0; 0];%[0.0; 0.0; 0.0];
        var_co = 10e-12; % was 1e-15
        % clock bias experimentally drifts as much as +/- 2.0 ns / sec
        var_cb = 1.00; %
        
        % --- initial variances --- initial P
        % initial position variance, dependent on area size
        vari_p = [5; 5; 5];
        vari_cb = 1;
        % clock offset is uniform [0,17] roughly, or 24 var
        vari_co = 1e-3;


        % initial bias could be as high as +/- 2ppm - +/- 2ppm = +/-4ppm (uniform)
        
                % message transmission times
        tlast_type1 = 0;
        tlast_type2 = 0;
        tlast_type3 = 0;
        
        % reference node
        is_reference = false;
        R;
        yl={};
        Rl={};
        hl={};
        measts={};
        eita={};
        x;
        x_i_i;%after the diffusion step
        P;
        P_minus;
        P_i_i;
        eital;
        nodeIndex;
        Pl;

        c=[0.1;0.3;0.1;0.3;0.1;0.1];
        P_next;
        x_next;
        G=1;
        Rx ;
        ready_to_ekf_p1 =0;
        ready_to_ekf_p2 =0;
        eitaIsSent=0;
        state_ready =0;
        fill_index=1;
        eita_index=1;
        size_R;
        myneigh=[];
        ekf_p1_done =0;
        ekf_p2_done =0;
        ukf_p1_done =0;   
        X_min;
    end
    
    methods
        % Constructor
        function obj = Node(id, name)
            obj.id = id;
            obj.name = name;
        end
        
        % make this a mobile node
        function setToMobile(obj)
            obj.mobile = true;
           obj.var_p = [1; 1; 1];
        end
        
        % make this a static node
        function setToStatic(obj)
            obj.mobile = false;
        end
        
        % assign a rigid body id
        function setRigidBodyId(obj, rb)
            obj.rigidbody_id = rb;
        end
        
        % get rigid body id
        function rb = getRigidBodyId(obj)
            rb = obj.rigidbody_id;
        end
        
        % fix static location to true location
        function setPositionToTrue(obj)
            obj.state_p = obj.true_p;
            obj.vari_p = [0; 0; 0];
        end
        
        % is this node mobile?
        function m = isMobile(obj)
            m = obj.mobile;
        end
        
        % set true position
        function setTruePosition(obj, pos)
            if ~iscolumn(pos)
                pos = pos';
            end
            obj.true_p = pos;
        end
        
        % set the time a measurement of a given type was last sent
        function setLastMeasTime(obj, type, time)
            switch type
                case 1
                    obj.tlast_type1 = time;
                case 2
                    obj.tlast_type2 = time;
                case 3
                    obj.tlast_type3 = time;
                otherwise
                    error('Unrecognized measurement type');
            end
        end
        
        % get the time a measurement of a given type was last sent
        function t = getLastMeasTime(obj, type)
            switch type
                case 1
                    t = obj.tlast_type1;
                case 2
                    t = obj.tlast_type2;
                case 3
                    t = obj.tlast_type3;
                otherwise
                    error('Unrecognized measurement type');
            end
        end
        
        % get true position
        function p = getTruePosition(obj)
            p = obj.true_p;
        end
        
        % set the estimated state position
        function setStatePosition(obj, pos)
            if ~iscolumn(pos)
                pos = pos';
            end
            obj.state_p = pos;
        end
        
        % set the clock offset
        function setStateClockOfst(obj, ofst)
            obj.state_clkofst = ofst;
        end
        
        % set the clock bias
        function setStateClockBias(obj, bias)
            obj.state_clkbias = bias;
        end
        
        % get the estimated state position
        function p = getStatePosition(obj)
            p = obj.state_p;
        end
        
        % get the node id
        function id = getId(obj)
            id = obj.id;
        end
        
        % get the node name (string)
        function name = getName(obj)
            name = obj.name;
        end
        
        % get the state vector
        function s = getState(obj)
            s = [obj.state_p; obj.state_clkofst; obj.state_clkbias];
        end
        
        % set the state vector
        function setState(obj, si)
            obj.state_p = si(1:3);
            obj.state_clkofst = si(4);
            obj.state_clkbias = si(5);
        end
        
        % get the process variance vector
        function q = getProcessVar(obj)
            q = [obj.var_p; obj.var_co; obj.var_cb];
        end
        
        % get the initial variance vector
        function q = getInitialVar(obj)
            q = [obj.vari_p; obj.vari_co; obj.vari_cb];
        end
        
        % set this as the reference node
        function setAsReference(obj)
            obj.state_clkofst = 0;
            obj.state_clkbias = 0 ;
            obj.vari_p = [1e-14; 1e-14; 1e-14 ];
            obj.var_co = 1e-14 ;
            obj.vari_co = 1e-14 ;
            obj.var_cb = 1e-14 ;
            obj.vari_cb = 1e-14 ;
            obj.is_reference = true;
            
        end
        
        % is this node a reference
        function val = isReference(obj)
            val = obj.is_reference;
        end
        
        % set covariances
        function setPositionCovar(obj, v)
            obj.var_p = [v; v; v];
        end
        
        function setOffsetCovar(obj, v)
            obj.var_co = v;
        end
        
        function setBiasCovar(obj, v)
            obj.var_cb = v;
        end
        
        function setSizebuffer(obj, size_R )
            obj.size_R = size_R;
            obj.Rx = zeros(1,obj.size_R);
        end
        
        %% amr code
        function set_meas(obj,meas,h)
            
            destID = meas.getDestId();


            obj.yl{obj.fill_index} = meas.vectorize();
            obj.Rl{obj.fill_index} = meas.getCovariance();


            obj.hl{obj.fill_index} = h;
            obj.Rx(obj.fill_index) = 1; %available y's and Rl


            obj.fill_index = obj.fill_index +1;
            for i =1:length(obj.Rx)
                if( obj.Rx(i) ==0 )
                    break; %not ready yet
                end

                if(i == length(obj.Rx))
                    obj.ready_to_ekf_p1 =1;
                end
            end
        end
  
     

        
        function checkekf_p1(obj)
            obj.P_minus = obj.P;
            if(obj.ready_to_ekf_p1 == 1 && obj.ekf_p1_done ==0)
                obj.efk_part1();
                obj.ekf_p1_done=1;
                obj.measUpdateFlag=1;
            end
        end
        
        function checkekf_p1_fake(obj)
            obj.P_minus = obj.P;
            if(obj.ready_to_ekf_p1 == 1 && obj.ekf_p1_done ==0)
                obj.efk_part1_fake();
                obj.ekf_p1_done=1;
                obj.measUpdateFlag=1;
            end
        end        
        
        function init_x_P(obj,x,P)
           obj.x=x;
           obj.x_i_i=x;
           obj.eita=x;
           obj.P=P;
           obj.P_minus=P;
           obj.P_i_i=P;
        end
        
            
        function checkekf_p2(obj,fstate,Q,diffEnable)
            if(obj.ready_to_ekf_p2 == 1 )
                obj.efk_part2(fstate,Q,diffEnable);
                obj.diffUpdateFlag = 1;
                obj.reseteital();
                %obj.ekf_p2_done =1;
            end
             ekf_part3(obj,Q,fstate);
        end

        function checkukf_p2(obj,fstate,M,alpha,bita,kk,delta)
            if(obj.ready_to_ekf_p2 == 1)
                obj.ufk_part2(fstate,M,alpha,bita,kk,delta);
            end
        end


        

      
        function seteital(obj,index,eita,P_neig)
            if obj.id ==1
                obj.nodeIndex;
            end
          if (~any(obj.nodeIndex == index))
            obj.nodeIndex(obj.eita_index)=index;
            obj.eital{obj.eita_index}= eita;
            obj.Pl{obj.eita_index}= P_neig;

            obj.eita_index = obj.eita_index +1;
          end
          if obj.eita_index > length(obj.myneigh)
              obj.ready_to_ekf_p2 =1;
              %efk_part2(obj,Q,fstate)
          end
        end


        
        function reseteital(obj)
            obj.eital={};
            obj.Pl={};
            obj.yl={};
            obj.Rl={};
            obj.Rx=zeros(1,obj.size_R);
            obj.ready_to_ekf_p1 =0;
            obj.ready_to_ekf_p2 =0;
            obj.fill_index =1;
            obj.hl ={};
            obj.eita_index = 1;
            obj.ekf_p1_done =0;
            obj.ekf_p2_done =0;
            obj.nodeIndex=[];
            obj.eitaIsSent =0;
        end
        
        function efk_part1(obj)
            if obj.id ==10
                obj.nodeIndex;
            end 
            [obj.eita,obj.P]=dif_ekf_p1(obj.x,obj.P,obj.hl,obj.Rl,obj.yl);
           obj.P_i_i= obj.P;
        end
        

       function efk_part2(obj,fstate,Q,diffEnable)
           
           if(diffEnable)
               obj.x=0;
               %   obj.P=0;
               for i =1:length(obj.c)
                   obj.x = obj.x+ obj.eital{i}*obj.c(i) ;
                   %      obj.P = obj.P+ obj.Pl{i}*obj.c(i) ;
               end
               
               % ekf_part3(obj,Q,fstate);
           else
               %rm diff
               obj.x= obj.eital{1};
              
           end
           
       end
        
        function ufk_part2(obj,fstate,M,alpha,bita,kk,delta)
            obj.x=0;
            for i =1:length(obj.c)
                obj.x = obj.x+ obj.eital{i}*obj.c(i) ;
            end
            ukf_part3(obj,fstate,M,alpha,bita,kk,delta);
        end
        
        function ekf_part3(obj,Q,fstate)
            obj.timeUpdateFlag = 1;
            obj.readyTochangeCovFlag =1;
            obj.x_i_i = obj.x;
            obj.P_i_i = obj.P;
            [obj.P,obj.x]=dif_ekf_p3(fstate ,obj.P,Q,obj.G,obj.x);
            obj.state_ready =1;
           %if obj.id == 1
               obj.x(4) = 0;
               obj.x(5) = 0;
           %end
           % obj.reseteital();
        end

        function ekf_part3_Only(obj,Q,fstate)
            obj.timeUpdateFlag = 1;
            obj.x_i_i = obj.x;
            obj.P_i_i = obj.P;
            obj.P_minus = obj.P;

            [obj.P,obj.x]=dif_ekf_p3(fstate ,obj.P,Q,obj.G,obj.x);
            obj.state_ready =1;
           %if obj.id == 1
               obj.x(4) = 0;
               obj.x(5) = 0;
           %end
           % obj.reseteital();
        end
     
        %%%% network topology 
        function setmyneigh(obj,neigh)
            obj.myneigh=neigh;
            obj.c = zeros(1,length(neigh));
            for i = 1:length(neigh)
               obj.c(i)=1/length(neigh);
            end
        end

        


    end
end

