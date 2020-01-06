function [x]=dif_ekf_p2(eital,c)
% diffusion Kalman
%   Detailed explanation goes here
% [ h H_cap]= jaccsd(hmeas,x);
% Rl=H_cap*P*transpose(H_cap)+Rl;
% sum=0;
% for i=1:l
%   sum = sum + transpose(H_cap)*(Rl^-1)*H_cap;
% end
% %sum = sum + P^-1;
% %P_next=sum^-1;
% 
% sum =  P+P*sum*P;
% P_next=sum;
% 
% 
% %-- eita
% sum=0;
% for i=1:l
%   sum = sum + transpose(H_cap)*Rl^-1*( yl(:,i) - h);
% end
% eita = P_next*sum + x;

%-- Diffusion update

x =0;
for i =1:length(c)
    x = x+eital(:,i)*c(i) ;
end
% %-- Time update --%
% [f F_bar]= jaccsd(fstate,x);
% u = f - F_bar*x;
% x_next = F_bar*x + u;
% P_next = F_bar*P*transpose(F_bar) + G*Q*transpose(G);
end


function [z,A]=jaccsd(fun,x)
% JACCSD Jacobian through complex step differentiation
% [z J] = jaccsd(f,x) 
% z = f(x)
% J = f'(x)
% example :
% f=@(x)[x(2);x(3);0.05*x(1)*x(2)];
% [x,A]=jaccsd(f,[1 1 1])
% 
% x =
% 
%     1.0000
%     1.0000
%     0.0500
% 
% 
% A =
% 
%          0    1.0000         0
%          0         0    1.0000
%     0.0500    0.0500         0
z=fun(x);
n=numel(x);%Number of elements in an array or subscripted array expression.
m=numel(z);
A=zeros(m,n);
h=n*eps;
for k=1:n
    x1=x;
    x1(k)=x1(k)+h*i;
    A(:,k)=imag(fun(x1))/h;
end
end