%%
%This file loops over all the generated mat files for the chosen 
%log (logname) and generates single report with all the results for the
%specific log. Remember that we have four logs (ped01-ped02-ped03-ped04)
%%

% Clean up console and variables
clc; close all; clear all;
addpath('classes');
addpath('utilities');

connected = 0;
if connected ==1
 connectionStatus='conn';
else
 connectionStatus='notconn';  
end
%% Load saved SLATS data
index =1;
logname = 'ped01';
for jj= 0:10
 
     
%keep the following variable
keepvars = {'jj','reporterr_aggregated','reportmsg_aggregated','index','logname','connectionStatus'};
clearvars('-except', keepvars{:});
FileName= strcat('cache\',connectionStatus,'\',logname,'_th_',num2str(jj),'.mat'  );
load(FileName);

node_ids = nm.getNodeIds();
node_names = nm.getNodeNames();

%% Plot Position Convergence
%%{
handles = [];
p_errors = [];
rb = 1;
rb_id = 'ntb-mobile';
rb_idx = nm.getNodeIdx(rb_id);
xyzm_all = [];
xyze_all = [];
err3d = [];
mse3d =[];
tstart = t_history(1);
MeasFlagGood =[];
timeUpdateFlagGood = [];

pDKAL_Good=double.empty(0,2);
for i=1:length(t_history);
    if i > length(p_history)
        break;
    end
    
    t = t_history(i);
    %if t - tstart > 60
    %    break;
    %end
    [xyz_mocap, lat] = nm.dataparser.getMocapPos( rb, t );
    if lat < 0.050
        xyz_est = p_history{i}(rb_idx,:);
        xyz_err = xyz_mocap - xyz_est;
        xyzm_all = [xyzm_all; xyz_mocap];
        xyze_all = [xyze_all; xyz_est];
        p_errors = [p_errors; t xyz_err];
        err3d = [err3d; norm(xyz_err)];
        mse3d = [ mse3d;  mse(xyz_err)];
        pDKAL_Good =  [pDKAL_Good ; [pDKAL_history(i,1) pDKAL_history(i,2) ]];
        MeasFlagGood =[MeasFlagGood MeasFlag_history(i)];
        timeUpdateFlagGood = [timeUpdateFlagGood timeUpdateFlag_history(i)];
    end
end

disp(sprintf('PDESIRED= %s',PDESIRED))
disp(sprintf('mean_err3d= %s', mean(err3d)))
disp(sprintf('var_err3d= %s',var(err3d)))


savemsgsM
sentmsgsM
sentmsgsD
 reporterr = [ PDESIRED,mean(err3d),std(err3d),rms(err3d),mean(p_errors(:,2)), sqrt( mean( p_errors(:,2).^2 ) ),mean(p_errors(:,3)), sqrt( mean( p_errors(:,3).^2 ) ),mean(p_errors(:,4)), sqrt( mean( p_errors(:,4).^2 ) )]
 reportmsg = [PDESIRED,savemsgsM,sentmsgsM,sentmsgsD]
 reporterr_aggregated(index,:) = reporterr;
 reportmsg_aggregated(index,:) = reportmsg;
 index = index +1;
end
saveName= strcat('cache\reports\Report_',connectionStatus,'_',logname);
save(saveName,'reporterr_aggregated','reportmsg_aggregated');
