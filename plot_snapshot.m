%%
% This file to generate a snapshot (figure 6) in the paper

%% Clean up console and variables
clc; close all; clear all;
addpath('classes');
addpath('utilities');

%% Load saved SLATS data
load('cache\ped01_20sec_skip46_Th_4.mat');

close all;
node_ids = nm.getNodeIds();
node_names = nm.getNodeNames();

%% Plot Position Convergence
%%{
cfigure(12,10);
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

    [xyz_mocap, lat] = nm.dataparser.getMocapPos( rb, t );
    %if lat < 0.050
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
   % end
end
%%MSE = mean(xyz_err.^2)
%%RMSE = sqrt(mean(xyz_err.^2))
ax1=subplot(3,1,1);
tstart = p_errors(1,1);

plot(p_errors(:,1) - tstart, err3d,'--gs','MarkerSize',2,'LineWidth',1,...
    'MarkerEdgeColor',[0,0.7,0.9],'MarkerFaceColor','red');
set(gca,'fontweight','bold','FontSize',14,'FontName','Arial');
xlabel('Time (sec)','fontweight','bold','FontSize',14,'FontName','Arial');
ylabel('3D Localization error (m)','fontweight','bold','FontSize',9,'FontName','Arial');

grid on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax2=subplot(3,1,2);
%plot(pDKAL_Good(:,1) - pDKAL_Good(1,1), pDKAL_Good(:,2), 'LineWidth',2);
plot(pDKAL_Good(:,1) - pDKAL_Good(1,1), pDKAL_Good(:,2),'--gs','MarkerSize',2,'LineWidth',1,...
    'MarkerEdgeColor',[0,0.7,0.9],'MarkerFaceColor','red');
hold on;
plot([0, pDKAL_Good(end,1)-pDKAL_Good(1,1)], [PDESIRED PDESIRED], '--k', 'LineWidth',2);
xlim([0 t_stop]);
ylim([0 6.8]);
grid on;

set(gca,'fontweight','bold','FontSize',14,'FontName','Arial');

xlabel('Time (sec)','fontweight','bold','FontSize',14,'FontName','Arial');

lgd=legend( {'Trace','$\pi_{\max}$'},'Interpreter','Latex');
lgd.FontSize = 10;
lgd.FontWeight = 'normal';
disp(sprintf('PDESIRED= %s',PDESIRED))
disp(sprintf('mean_err3d= %s', mean(err3d)))
disp(sprintf('var_err3d= %s',var(err3d)))


ax3=subplot(3,1,3);
tstart = p_errors(1,1);


plot(p_errors(:,1) - tstart,MeasFlagGood,'--gs','MarkerSize',4,'LineWidth',1,...
    'MarkerEdgeColor','black','MarkerFaceColor','red');
ylim([-0.5 1.5]);
grid on;
set(gca,'fontweight','bold','FontSize',14,'FontName','Arial','ytick',[0 1]);
xlabel('Time (sec)','fontweight','bold','FontSize',14,'FontName','Arial');
ylabel('Meas. Flag','fontweight','bold','FontSize',14,'FontName','Arial');
time = p_errors(:,1) - tstart;
time_slots = time(find(MeasFlagGood==1))';
%ylim([-1 2]);
% legends



savemsgsM
sentmsgsM
sentmsgsD
 reporterr = [ PDESIRED,mean(err3d),std(err3d),rms(err3d),mean(p_errors(:,2)), sqrt( mean( p_errors(:,2).^2 ) ),mean(p_errors(:,3)), sqrt( mean( p_errors(:,3).^2 ) ),mean(p_errors(:,4)), sqrt( mean( p_errors(:,4).^2 ) )]
 reportmsg = [PDESIRED,savemsgsM,sentmsgsM,sentmsgsD]
 %disp(sprintf('report= %s',report))
%saveplot('output/ped01_conditional');