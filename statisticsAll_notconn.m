clear all
close all
%there is a bug here in caluclating the savemsgM, i forgot the following if
%stm
% % else %<dsired 
% %     % the src will send to all his nighbours except him self
% %     if( any(nm.network{srcIndex}==desIndex) )
% %         nm.savemsgsM = nm.savemsgsM +length(nm.network{srcIndex}) -1;
% %     end
% the right to have saveMsgsM + sentmsgM = constant
% I tired that an it is right check
% "cache2ndRun\notcon\test',num2str(PDESIRED)"
% so what i will do i will negelec the savemsgM coloumn
%reporterr = [ PDESIRED,mean(err3d),std(err3d),rms(err3d),mean(p_errors(:,2)), sqrt( mean( p_errors(:,2).^2 ) ),mean(p_errors(:,3)), sqrt( mean( p_errors(:,3).^2 ) ),mean(p_errors(:,4)), sqrt( mean( p_errors(:,4).^2 ) )]
% reportmsg = [PDESIRED,savemsgsM,sentmsgsM,sentmsgsD]
%filepath = 'cache\fourneig\reports\Report_fo_ped0';
filepath = 'cache2ndRun\reports\Report_notcon_ped0';
ID = 1;
load(strcat(filepath,num2str(ID)));
% reportmsg = [PDESIRED,savemsgsM,sentmsgsM,sentmsgsD,savedD]
%fix the bug
TotolmsgM= reportmsg_aggregated(1,3);
% savedM = TotalM - sentM
reportmsg_aggregated(:,2)= TotolmsgM - reportmsg_aggregated(:,3);
% now we are trying to estimate the savemsgD
% the percentage of M and D is almost fixed
% let's use that
avgDoverM  =mean(reportmsg_aggregated(:,4) ./ reportmsg_aggregated(:,3));
%now we have the saveM let's get saveD
savemsgsD = ceil(avgDoverM .* reportmsg_aggregated(:,2));
%add fifth colu to saveD
reportmsg_aggregated(:,5)= savemsgsD;
%now back to normal operations
% reportmsg = [PDESIRED,savemsgsM,sentmsgsM,sentmsgsD,savedD]
reporterr_ped01= reporterr_aggregated;
reportmsg_ped01= reportmsg_aggregated;
% prepare percentage!
% threshold , saved , sent
reportmsg_perc_ped01 = [ [0:10]',zeros(11,1),zeros(11,1)];
totalNumMsg_vec1 = reportmsg_ped01(:,2) + reportmsg_ped01(:,3)+reportmsg_ped01(:,4)+reportmsg_ped01(:,5); 
% perc = saved /total , sent/total;
reportmsg_perc_ped01(:,2:3) =[ (reportmsg_ped01(:,2)+reportmsg_ped01(:,5))./totalNumMsg_vec1, (reportmsg_ped01(:,3)+reportmsg_ped01(:,4))./totalNumMsg_vec1];


ID = 2;
load(strcat(filepath,num2str(ID)));
% reportmsg = [PDESIRED,savemsgsM,sentmsgsM,sentmsgsD,savedD]
%fix the bug
TotolmsgM= reportmsg_aggregated(1,3);
% savedM = TotalM - sentM
reportmsg_aggregated(:,2)= TotolmsgM - reportmsg_aggregated(:,3);
% now we are trying to estimate the savemsgD
% the percentage of M and D is almost fixed
% let's use that
avgDoverM  =mean(reportmsg_aggregated(:,4) ./ reportmsg_aggregated(:,3));
%now we have the saveM let's get saveD
savemsgsD = ceil(avgDoverM .* reportmsg_aggregated(:,2));
%add fifth colu to saveD
reportmsg_aggregated(:,5)= savemsgsD;
%now back to normal operations
% reportmsg = [PDESIRED,savemsgsM,sentmsgsM,sentmsgsD,savedD]
reporterr_ped02= reporterr_aggregated;
reportmsg_ped02= reportmsg_aggregated;
% prepare percentage!
% threshold , saved , sent
reportmsg_perc_ped02 = [ [0:10]',zeros(11,1),zeros(11,1)];
totalNumMsg_vec2 = reportmsg_ped02(:,2) + reportmsg_ped02(:,3)+reportmsg_ped02(:,4)+reportmsg_ped02(:,5); 
% perc = saved /total , sent/total;
reportmsg_perc_ped02(:,2:3) =[ (reportmsg_ped02(:,2)+reportmsg_ped02(:,5))./totalNumMsg_vec2, (reportmsg_ped02(:,3)+reportmsg_ped02(:,4))./totalNumMsg_vec2];



ID = 3;
load(strcat(filepath,num2str(ID)));
% reportmsg = [PDESIRED,savemsgsM,sentmsgsM,sentmsgsD,savedD]
%fix the bug
TotolmsgM= reportmsg_aggregated(1,3);
% savedM = TotalM - sentM
reportmsg_aggregated(:,2)= TotolmsgM - reportmsg_aggregated(:,3);
% now we are trying to estimate the savemsgD
% the percentage of M and D is almost fixed
% let's use that
avgDoverM  =mean(reportmsg_aggregated(:,4) ./ reportmsg_aggregated(:,3));
%now we have the saveM let's get saveD
savemsgsD = ceil(avgDoverM .* reportmsg_aggregated(:,2));
%add fifth colu to saveD
reportmsg_aggregated(:,5)= savemsgsD;
%now back to normal operations
% reportmsg = [PDESIRED,savemsgsM,sentmsgsM,sentmsgsD,savedD]
reporterr_ped03= reporterr_aggregated;
reportmsg_ped03= reportmsg_aggregated;
% prepare percentage!
% threshold , saved , sent
reportmsg_perc_ped03 = [ [0:10]',zeros(11,1),zeros(11,1)];
totalNumMsg_vec3 = reportmsg_ped03(:,2) + reportmsg_ped03(:,3)+reportmsg_ped03(:,4)+reportmsg_ped03(:,5); 
% perc = saved /total , sent/total;
reportmsg_perc_ped03(:,2:3) =[ (reportmsg_ped03(:,2)+reportmsg_ped03(:,5))./totalNumMsg_vec3, (reportmsg_ped03(:,3)+reportmsg_ped03(:,4))./totalNumMsg_vec3];


ID = 4;
load(strcat(filepath,num2str(ID)));
% reportmsg = [PDESIRED,savemsgsM,sentmsgsM,sentmsgsD,savedD]
%fix the bug
TotolmsgM= reportmsg_aggregated(1,3);
% savedM = TotalM - sentM
reportmsg_aggregated(:,2)= TotolmsgM - reportmsg_aggregated(:,3);
% now we are trying to estimate the savemsgD
% the percentage of M and D is almost fixed
% let's use that
avgDoverM  =mean(reportmsg_aggregated(:,4) ./ reportmsg_aggregated(:,3));
%now we have the saveM let's get saveD
savemsgsD = ceil(avgDoverM .* reportmsg_aggregated(:,2));
%add fifth colu to saveD
reportmsg_aggregated(:,5)= savemsgsD;
%now back to normal operations
% reportmsg = [PDESIRED,savemsgsM,sentmsgsM,sentmsgsD,savedD]
reporterr_ped04= reporterr_aggregated;
reportmsg_ped04= reportmsg_aggregated;
% prepare percentage!
% threshold , saved , sent
reportmsg_perc_ped04 = [ [0:10]',zeros(11,1),zeros(11,1)];
totalNumMsg_vec4 = reportmsg_ped04(:,2) + reportmsg_ped04(:,3)+reportmsg_ped04(:,4)+reportmsg_ped04(:,5); 
% perc = saved /total , sent/total;
reportmsg_perc_ped04(:,2:3) =[ (reportmsg_ped04(:,2)+reportmsg_ped04(:,5))./totalNumMsg_vec4, (reportmsg_ped04(:,3)+reportmsg_ped04(:,4))./totalNumMsg_vec4];



reporterr = ( 0.5/10 *reporterr_ped01 +  0.5/10 *reporterr_ped02 + 2/10*reporterr_ped03 + 7/10*reporterr_ped04);
%reporterr =  10/10 *reporterr_ped02;
%reportmsg = (reportmsg_perc_ped01 + reportmsg_perc_ped02 +reportmsg_perc_ped03 +reportmsg_perc_ped04)/4;
%reportmsg = reportmsg_perc_ped04;
reportmsg = ( 0.5/10 *reportmsg_perc_ped01 +  0.5/10 *reportmsg_perc_ped02 + 2/10*reportmsg_perc_ped03 +7/10*reportmsg_perc_ped04);
%totalNumMsg = mean(totalNumMsg1 + totalNumMsg2 +totalNumMsg3 +totalNumMsg4
%reporterr = (reporterr_ped01 + reporterr_ped02  )/2;
%reportmsg = (reportmsg_ped01 + reportmsg_ped02  )/2;
% plot(reporterr_ped01(:,1),reporterr(:,2),'k-*')
% hold on
% plot(reporterr_ped01(:,1),reporterr(:,3),'b-+')
% grid on;
% %ylabel('');
% xlabel('Threshold');
% legend('3D-err Mean', '3D-err Std');

figure
x = reporterr_ped01(:,1);
y = reporterr(:,2); 
err = reporterr(:,3);
errorbar(x,y,err,'-s','MarkerSize',8,'LineWidth',2,...
    'MarkerEdgeColor','black','MarkerFaceColor','red')
grid on;
xlim([-.5 10.5])
ylim([0 5])
set(gca,'fontweight','bold','FontSize',14,'FontName','Arial');
%xlabel({'\textbf{Threshold} \boldmath{$\pi_{\max}$}'},'interpreter','latex','fontweight','bold','FontSize',14,'FontName','Arial');
xlabel({'\boldmath{$\pi_{\max}$}'},'interpreter','latex','fontweight','bold','FontSize',14,'FontName','Arial');
ylabel('3D Localization error (m)','fontweight','bold','FontSize',14,'FontName','Arial');
%legend('3D-err Mean', '3D-err Std');

figure
plot(reportmsg(:,1),reportmsg(:,2),'-s','MarkerSize',8,'LineWidth',2,...
    'MarkerEdgeColor','black','MarkerFaceColor','red')
%hold on
%plot(reportmsg(:,1),reportmsg(:,3),'b-+')
grid on;
%ylabel('');
xlabel x, ylabel y, zlabel z;
set(gca, 'YTickMode','manual')
set(gca,'fontweight','bold','FontSize',14,'FontName','Arial');

set(gca, 'YTickLabel',num2str(100.*get(gca,'YTick')','%g%%'))
xlabel({'\boldmath{$\pi_{\max}$}'},'Interpreter','Latex','fontweight','bold','FontSize',14,'FontName','Arial');
ylabel('Percentage of message saving','fontweight','bold','FontSize',14,'FontName','Arial');

figure

plot(reporterr(:,2),reportmsg(:,2),'-s','MarkerSize',8,'LineWidth',2,...
    'MarkerEdgeColor','black','MarkerFaceColor','red')
%hold on
%plot(reportmsg(:,1),reportmsg(:,3),'b-+')
grid on;
%ylabel('');
xlabel x, ylabel y, zlabel z;
set(gca, 'YTickMode','manual')
set(gca,'fontweight','bold','FontSize',14,'FontName','Arial');

set(gca, 'YTickLabel',num2str(100.*get(gca,'YTick')','%g%%'))
xlabel('3D Localization error (m)','fontweight','bold','FontSize',14,'FontName','Arial');
ylabel('Percentage of message saving','fontweight','bold','FontSize',14,'FontName','Arial');

original_amount = reporterr(1,1) + reporterr(1,2);% error +std at threshold 0
new_amount =  reporterr(2,1) + reporterr(2,2); % error +std at threshold 1
PERCENT_INCREASE=(new_amount - original_amount)/original_amount

% % Convert y-axis values to percentage values by multiplication
%      a=[cellstr(num2str(get(gca,'ytick')'*100))]; 
% % Create a vector of '%' signs
%      pct = char(ones(size(a,1),1)*'%'); 
% % Append the '%' signs after the percentage values
%      new_yticks = [char(a),pct];
% % 'Reflect the changes on the plot
%      set(gca,'yticklabel',new_yticks) 
