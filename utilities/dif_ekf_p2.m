function [x]=dif_ekf_p2(eital,c)


%-- Diffusion update

x =0;
for i =1:length(c)
    x = x+eital(:,i)*c(i) ;
end

end

