%% Clean up console and variables
clc; close all; clear all;
addpath('classes');
addpath('utilities');

%% Load saved SLATS data
load('cache/slatsGps_ped04.mat');
node_ids = nm.getNodeIds();
node_names = nm.getNodeNames();

%% Plot Position Convergence
%%{
cfigure(15,7);
handles = [];
t_history = nm.getAllMeasurementTimes();
p_errors = [];
rb = 1;
rb_id = 'ntb-mobile';
rb_idx = nm.getNodeIdx(rb_id);
xyzm_all = [];
err3d = [];
tstart = t_history(1);

for i=1:size(gps_history,1);

    t = gps_history(i,1);
    [xyz_mocap, lat] = nm.dataparser.getMocapPos( rb, t );
    
    if lat < 0.50
        xyz_est = gps_history(i,2:end);
        xyz_err = xyz_mocap - xyz_est;
        xyzm_all = [xyzm_all; xyz_mocap];
        p_errors = [p_errors; t xyz_err];
        err3d = [err3d; norm(xyz_err([1,3]))];
    end
end

tstart = p_errors(1,1);
plot(p_errors(:,1) - tstart, p_errors(:,2), 's', 'MarkerSize', 3, 'Color', [0 0.5 0]);
hold on;
plot(p_errors(:,1) - tstart, p_errors(:,3), 'bo', 'MarkerSize', 3);
plot(p_errors(:,1) - tstart, p_errors(:,4), 'm^', 'MarkerSize', 3);
plot(p_errors(:,1) - tstart, zeros( size(p_errors(:,1)) ), '--k', 'LineWidth',2);
ylabel('Error (m)');
xlabel('Time (sec)');
grid on;
ylim([-5 5]);
% legends
xstr = sprintf('X (mean %.2fm, RMSE %.2f)', mean(p_errors(:,2)), sqrt( mean( p_errors(2:end,2).^2 ) ) );
ystr = sprintf('Y (mean %.2fm, RMSE %.2f)', mean(p_errors(:,3)), sqrt( mean( p_errors(2:end,3).^2 ) ) );
zstr = sprintf('Z (mean %.2fm, RMSE %.2f)', mean(p_errors(:,4)), sqrt( mean( p_errors(2:end,4).^2 ) ) );
[hleg, hobj, hout, mout] = legend({xstr, ystr, zstr});
set(hobj(5), 'MarkerSize', 8);
set(hobj(7), 'MarkerSize', 8);
set(hobj(9), 'MarkerSize', 8);
%set(hobj(4), 'MarkerSize', 8);
%set(hobj(6), 'MarkerSize', 8);
set(gca,'YTick', [-5 -4 -3 -2 -1 0 1 2 3 4 5]);

fprintf('RMSE: %.3f\n', sqrt( mean( err3d.^2 ) ));

saveplot('output/ped03_gps_R_200_');
return;
%%}
