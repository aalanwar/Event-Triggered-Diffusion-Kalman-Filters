clear all
close all
%reporterr = [ PDESIRED,mean(err3d),std(err3d),rms(err3d),mean(p_errors(:,2)), sqrt( mean( p_errors(:,2).^2 ) ),mean(p_errors(:,3)), sqrt( mean( p_errors(:,3).^2 ) ),mean(p_errors(:,4)), sqrt( mean( p_errors(:,4).^2 ) )]
% reportmsg = [PDESIRED,savemsgsM,sentmsgsM,sentmsgsD]
%filepath = 'cache\reports\Report_ped0';
numofrows =3;
filepath = 'cache2ndRun\reports\Report_ped0';
ID = 1;
load(strcat(filepath,num2str(ID)));
reporterr_ped01= reporterr_aggregated;
reportmsg_ped01= reportmsg_aggregated;

load(strcat(filepath,num2str(ID),'_less1' ));
reporterr_ped01=[ reporterr_ped01 ; reporterr_aggregated(1:numofrows,:)];
reportmsg_ped01=[ reportmsg_ped01;  reportmsg_aggregated(1:numofrows,:)];

% prepare percentage!
reportmsg_perc_ped01 = reportmsg_ped01(:,1:3);
%Multiply *2 as diff=meas mesg
reportmsg_perc_ped01(:,2) = reportmsg_perc_ped01(:,2)*2;
reportmsg_perc_ped01(:,3) = reportmsg_perc_ped01(:,3)*2;
totalNumMsg1 = reportmsg_perc_ped01(1,3);
reportmsg_perc_ped01(:,2) = reportmsg_perc_ped01(:,2)/totalNumMsg1;
reportmsg_perc_ped01(:,3) = reportmsg_perc_ped01(:,3)/totalNumMsg1;

ID = 2;
load(strcat(filepath,num2str(ID)));
reporterr_ped02= reporterr_aggregated;
reportmsg_ped02= reportmsg_aggregated;
load(strcat(filepath,num2str(ID),'_less1' ));
reporterr_ped02=[ reporterr_ped02 ; reporterr_aggregated(1:numofrows,:)];
reportmsg_ped02=[ reportmsg_ped02;  reportmsg_aggregated(1:numofrows,:)];


% prepare percentage!
reportmsg_perc_ped02 = reportmsg_ped02(:,1:3);
%Multiply *2 as diff=meas mesg
reportmsg_perc_ped02(:,2) = reportmsg_perc_ped02(:,2)*2;
reportmsg_perc_ped02(:,3) = reportmsg_perc_ped02(:,3)*2;
totalNumMsg2 = reportmsg_perc_ped02(1,3);
reportmsg_perc_ped02(:,2) = reportmsg_perc_ped02(:,2)/totalNumMsg2;
reportmsg_perc_ped02(:,3) = reportmsg_perc_ped02(:,3)/totalNumMsg2;


ID = 3;
load(strcat(filepath,num2str(ID)));
reporterr_ped03= reporterr_aggregated;
reportmsg_ped03= reportmsg_aggregated;
load(strcat(filepath,num2str(ID),'_less1' ));
reporterr_ped03=[ reporterr_ped03 ; reporterr_aggregated(1:numofrows,:)];
reportmsg_ped03=[ reportmsg_ped03;  reportmsg_aggregated(1:numofrows,:)];

% prepare percentage!
%SOME bug AT THRESHOLD ZERO !, AS IF YOU TRY reportmsg_ped03(:,2) +reportmsg_ped03(:,3)
% YOU WILL SEE IT IS CONSTANT
%QUICK FIX
reportmsg_ped03(1,3)=reportmsg_ped03(2,2) +reportmsg_ped03(2,3);
reportmsg_perc_ped03 = reportmsg_ped03(:,1:3);
%Multiply *2 as diff=meas mesg
reportmsg_perc_ped03(:,2) = reportmsg_perc_ped03(:,2)*2;
reportmsg_perc_ped03(:,3) = reportmsg_perc_ped03(:,3)*2;
totalNumMsg3 = reportmsg_perc_ped03(1,3);
reportmsg_perc_ped03(:,2) = reportmsg_perc_ped03(:,2)/totalNumMsg3;
reportmsg_perc_ped03(:,3) = reportmsg_perc_ped03(:,3)/totalNumMsg3;


ID = 4;
load(strcat(filepath,num2str(ID)));
reporterr_ped04= reporterr_aggregated;
reportmsg_ped04= reportmsg_aggregated;
load(strcat(filepath,num2str(ID),'_less1' ));
reporterr_ped04=[ reporterr_ped04 ; reporterr_aggregated(1:numofrows,:)];
reportmsg_ped04=[ reportmsg_ped04;  reportmsg_aggregated(1:numofrows,:)];

% prepare percentage!
reportmsg_perc_ped04 = reportmsg_ped04(:,1:3);
%Multiply *2 as diff=meas mesg
reportmsg_perc_ped04(:,2) = reportmsg_perc_ped04(:,2)*2;
reportmsg_perc_ped04(:,3) = reportmsg_perc_ped04(:,3)*2;
totalNumMsg4 = reportmsg_perc_ped04(1,3);
reportmsg_perc_ped04(:,2) = reportmsg_perc_ped04(:,2)/totalNumMsg4;
reportmsg_perc_ped04(:,3) = reportmsg_perc_ped04(:,3)/totalNumMsg4;



%reporterr = ( 5/10 *reporterr_ped01 +  4/10 *reporterr_ped02 + 0.5/10*reporterr_ped03 + 0.5/10*reporterr_ped04);
reporterr = ( 7/10 *reporterr_ped01 +  2/10 *reporterr_ped02 + 0.5/10*reporterr_ped03 + 0.5/10*reporterr_ped04);
reportmsg = (reportmsg_perc_ped01 + reportmsg_perc_ped02 +reportmsg_perc_ped03 +reportmsg_perc_ped04)/4;
totalNumMsg = totalNumMsg1 + totalNumMsg2 +totalNumMsg3 +totalNumMsg4
%reporterr = (reporterr_ped01 + reporterr_ped02  )/2;
%reportmsg = (reportmsg_ped01 + reportmsg_ped02  )/2;
% plot(reporterr_ped01(:,1),reporterr(:,2),'k-*')
% hold on
% plot(reporterr_ped01(:,1),reporterr(:,3),'b-+')
% grid on;
% %ylabel('');
% xlabel('Threshold');
% legend('3D-err Mean', '3D-err Std');
reporterr_ped01_orig= reporterr_ped01;
reporterr_orig = reporterr;
reportmsg_orig = reportmsg;
reporterr_ped01 = [reporterr_ped01_orig(1,:) ; reporterr_ped01_orig(12:13,:) ; reporterr_ped01_orig(2:3,:); reporterr_ped01_orig(14,:); reporterr_ped01_orig(4:11,:) ];
reporterr = [reporterr_orig(1,:) ; reporterr_orig(12:13,:) ; reporterr_orig(2:3,:);  reporterr_orig(14,:);  reporterr_orig(4:11,:) ];
reportmsg = [reportmsg_orig(1,:) ; reportmsg_orig(12:13,:) ; reportmsg_orig(2:3,:); reportmsg_orig(14,:);  reportmsg_orig(4:11,:) ];

reporterr_ped01(6,1) = 2.5 ;
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

original_amount = reporterr(1,2) + reporterr(1,3);% error +std at threshold 0
new_amount =  reporterr(2,2) + reporterr(2,3); % error +std at threshold 1
PERCENT_INCREASE=(new_amount - original_amount)/original_amount


new_amount_all =  reporterr(1:end,2) + reporterr(1:end,3); 
PERCENT_INCREASE_all=(new_amount_all - original_amount)./original_amount *100;
[PERCENT_INCREASE_all,reportmsg(:,2)]'
[reporterr_ped01(:,1),new_amount_all,PERCENT_INCREASE_all,reportmsg(:,2)*100]'
% % Convert y-axis values to percentage values by multiplication
%      a=[cellstr(num2str(get(gca,'ytick')'*100))]; 
% % Create a vector of '%' signs
%      pct = char(ones(size(a,1),1)*'%'); 
% % Append the '%' signs after the percentage values
%      new_yticks = [char(a),pct];
% % 'Reflect the changes on the plot
%      set(gca,'yticklabel',new_yticks) 
