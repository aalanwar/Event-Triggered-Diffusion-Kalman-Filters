function updateEllipse(h,x,P,nSigma)
%  UpdateEllipse( handle, [x;y;<z>], P=2x2 or 3x3)
P = P([1 3],[1 3]); % only plot x−z part
x = x([1 3]);
if(~any(diag(P)==0))
    [V,D] = eig(P);
    y = nSigma*[cos(0:0.1:2*pi);sin(0:0.1:2*pi)];
    el = V*sqrtm(D)*y;
    el = [ el el(:,1)]+repmat(x,1,size(el,2)+1);
    % PLOT ON XZ PLANE
    xdata = el(1,:);
    zdata = el(2,:);
    set(h, 'XData', real(xdata), 'ZData', real(zdata));
end