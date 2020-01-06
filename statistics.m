clear all
close all
%reporterr = [ PDESIRED,mean(err3d),std(err3d),rms(err3d),mean(p_errors(:,2)), sqrt( mean( p_errors(:,2).^2 ) ),mean(p_errors(:,3)), sqrt( mean( p_errors(:,3).^2 ) ),mean(p_errors(:,4)), sqrt( mean( p_errors(:,4).^2 ) )]
% reportmsg = [PDESIRED,savemsgsM,sentmsgsM,sentmsgsD]
reporterr(1,:) =[0    0.2309    0.1614    0.2817    0.0116    0.1324   -0.0403    0.2105   -0.0009    0.1322];
reportmsg(1,:) =[0           0       32499       32481];

reporterr(2,:) =[1.0000    0.3560    0.2215    0.4193    0.1063    0.2386   -0.0022    0.2441    0.0550    0.2435];
reportmsg(2,:) =[1       27639        4860        4860];
           
reporterr(3,:) = [2.0000    0.4823    0.1734    0.5125    0.1852    0.2522   -0.0921    0.2687    0.1663    0.3561];
reportmsg(3,:) = [2       30798        1701        1701];

reporterr(4,:) =[3.0000    0.9493    0.4941    1.0701    0.1689    0.4207   -0.3201    0.6431    0.2465    0.7447];
reportmsg(4,:) =[ 3       31365        1134        1134];

reporterr(5,:) =[4.0000    1.2431    0.4730    1.3300    0.3973    0.6023   -0.4974    0.8455    0.3384    0.8313];
reportmsg(5,:) =[  4       31770         729         729];

reporterr(6,:) =[5.0000    1.3587    0.4393    1.4280    0.5021    0.5946   -0.2318    1.0493    0.1970    0.7646];
reportmsg(6,:) =[5       31932         567         567];

reporterr(7,:) =[6.0000    1.2497    0.4316    1.3221    0.3989    0.5735   -0.7397    0.8435   -0.0501    0.8411];
reportmsg(7,:) = [6       32013         486         486];

reporterr(8,:) =[7.0000    1.1401    0.3949    1.2066    0.6197    0.7579   -0.5546    0.6021    0.0640    0.7203];
reportmsg(8,:) =[7       32175         324         324];

reporterr(9,:) =[8.0000    1.3458    0.6366    1.4887    0.9601    1.1528   -0.0697    0.5444    0.3318    0.7687];
reportmsg(9,:) =[8       32175         324         324];

reporterr(10,:) =[9.0000    1.9435    0.7300    2.0761    0.9419    1.1991    0.2231    0.9642    0.7268    1.3938];
reportmsg(10,:) =[9       32256         243         243];

reporterr(11,:) =[10.0000    2.5873    1.3756    2.9302    1.8946    2.1725   -0.4507    0.6773    1.0494    1.8459];
reportmsg(11,:) =[ 10       32337         162         162];



plot(reporterr(:,1),reporterr(:,2),'k-*')
hold on
plot(reporterr(:,1),reporterr(:,3),'b-+')
grid on;
%ylabel('');
xlabel('Threshold');
legend('3D-err Mean', '3D-err Std');

figure
plot(reportmsg(:,1),reportmsg(:,2)*2,'k-*')
hold on
plot(reportmsg(:,1),reportmsg(:,3)*2,'b-+')
grid on;
%ylabel('');
xlabel('Threshold');
legend('# of Saved Msg', '# of Sent Msg');
% reporterr(7,:) =[12.0000    2.3074    1.3509    2.6737    1.3957    1.4609    0.1432    1.7195    0.4891    1.4344];
% reportmsg(7,:) =[12       32337         162         162];
% 
% reporterr(8,:) =[14.0000    2.1653    0.8740    2.3349    1.4602    1.5053   -0.4559    0.7179    0.6196    1.6343];
% reportmsg(8,:) =[14       32418          81          81];