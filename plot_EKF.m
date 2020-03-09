%% Clean up console and variables
clc; close all; clear all;
addpath('classes');
addpath('utilities');

%% Load saved SLATS data
load('cache/temp.mat');
node_ids = nm.getNodeIds();
node_names = nm.getNodeNames();

%% Plot Path
handles = [];
t_history = nm.getAllMeasurementTimes();
p_errors = [];
rb = 1;
rb_id = 'ntb-mobile';
rb_idx = nm.getNodeIdx(rb_id);
xyzm_all = [];
xyze_all = [];
errors_all = [];
time_all = [];
downsample = 50;

for i=1:length(t_history);
    if i > length(p_history)
        break;
    end
    
    t = t_history(i);
    [xyz_mocap, lat] = nm.dataparser.getMocapPos( rb, t );
    if lat < 0.050
        xyz_est = p_history{i}(rb_idx,:);
        xyz_err = xyz_mocap - xyz_est;
        xyzm_all = [xyzm_all; xyz_mocap];
        xyze_all = [xyze_all; xyz_est];
        time_all = [time_all; t];
        xyz_err = xyz_mocap - xyz_est;
        errors_all = [errors_all; norm(xyz_err)];
        p_errors = [p_errors; t xyz_err];
    end
end

% a little bit of filtering for plotting
xyze_all(:,1) = medfilt1(xyze_all(:,1), 3);
xyze_all(:,2) = medfilt1(xyze_all(:,2), 3);
xyze_all(:,3) = medfilt1(xyze_all(:,3), 3);

%% Plot
cfigure(35,11);

% ----- path -----
subplot(2,4,[1 2 5 6]);
plot3(xyzm_all(1:downsample:end,1), xyzm_all(1:downsample:end,2), xyzm_all(1:downsample:end,3), 'bo');
hold on;
plot3(xyze_all(1:downsample:end,1), xyze_all(1:downsample:end,2), xyze_all(1:downsample:end,3), 's', 'MarkerFaceColor', [0 0.75 0], 'Color', [0 0.5 0]);

xlabel('X Position (m)');
%ylabel('Y Position (m)');
zlabel('Z Position (m)');
grid on;
leg_str = sprintf('Estimated Position, RMSE: %.3f', sqrt( mean( errors_all ).^2 ) );
set(gca, 'View', [-173.5 12]);
hl = legend('True Position', leg_str);
lpos = get(hl,'Position');
set(hl,'Position', [0.15 0.75 lpos([3 4])]);
xlabpos = get(get(gca,'XLabel'), 'Position');
set(get(gca, 'XLabel'), 'Position', xlabpos + [0 -1.2 0]);

% ----- x y z errors -----
subplot(2,4,[3 4]);
tstart = p_errors(1,1);
plot(p_errors(:,1) - tstart, p_errors(:,2), 's', 'MarkerSize', 3, 'Color', [0 0.5 0]);
hold on;
plot(p_errors(:,1) - tstart, p_errors(:,3), 'bo', 'MarkerSize', 3);
plot(p_errors(:,1) - tstart, p_errors(:,4), 'm^', 'MarkerSize', 3);
plot(p_errors(:,1) - tstart, zeros( size(p_errors(:,1)) ), '--k', 'LineWidth',2);
ylabel('Error (m)');
xlabel('Time (sec)');
grid on;
ylim([-2 2]);
% legends
xstr = sprintf('X (mean %.2fm, RMSE %.2f)', mean(p_errors(:,2)), sqrt( mean( p_errors(:,2).^2 ) ) );
ystr = sprintf('Y (mean %.2fm, RMSE %.2f)', mean(p_errors(:,3)), sqrt( mean( p_errors(:,3).^2 ) ) );
zstr = sprintf('Z (mean %.2fm, RMSE %.2f)', mean(p_errors(:,4)), sqrt( mean( p_errors(:,4).^2 ) ) );
[hleg, hobj, hout, mout] = legend({xstr, ystr, zstr});
set(hobj(5), 'MarkerSize', 8);
set(hobj(7), 'MarkerSize', 8);
set(hobj(9), 'MarkerSize', 8);



% ----- norm error vs. pos -----
subplot(2,4,[7 8]);
ds = 50;
tstart = time_all(1);
% dist from centroid
xyz_static = nm.getTrueStaticPositions();
xyz_centroid = mean(xyz_static(:,2:4));

xyz_dist = sqrt( sum( (xyzm_all - repmat(xyz_centroid, size(xyzm_all,1), 1)).^2, 2) );

[hax, hl1, hl2] = plotyy(time_all(1:ds:end) -tstart, medfilt1(errors_all(1:ds:end),2), time_all(1:ds:end) -tstart, xyz_dist(1:ds:end));
set(hl1,'Marker', 's');
set(hl2,'Marker', 'o');
set(hax(1),'YTick',[0:0.5:2])
set(hax(2),'YTick',[0:1:4])
xlabel('Time (sec)');
ylabel(hax(1), 'Estimate error (m)');
ylabel(hax(2), 'Distance from centroid (m)');
ylim(hax(1), [0 2]);
grid on;


%saveplot('output/ped01_R_path');