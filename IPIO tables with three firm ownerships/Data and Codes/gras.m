function X = gras(X0,u,v)
% Info: Generalized RAS 
% Input: benchmark matrix X0, and the row and column sums u and v (column 
% vectors) of a corresponding matrix in the target year 1. Negative
% elements are allowed in the required data (in X0, u, and v).
% Aim: estimate the new matrix X with the row and column sums equal 
% to u and v, respectively, such that it is as close as possible to X0; The
% algorithm follows that from Lenzen, Wood & Gallego (2007).
% Written by Umed Temurshoev, University of Groningen, the Netherlands, September, 2009

[m,n] = size(X0);
N = zeros(m,n);
N(X0<0) = -X0(X0<0);   
P = X0+N;

r = ones(m,1);     %initial guess for r (suggested by J&O, 2003)
pr = P'*r;
nr = N'*invd(r)*ones(m,1);
s1 = invd(2*pr)*(v+sqrt(v.^2+4*pr.*nr));   %first step s
ps = P*s1;
ns = N*invd(s1)*ones(n,1);
r = invd(2*ps)*(u+sqrt(u.^2+4*ps.*ns));    %first step r

pr = P'*r;
nr = N'*invd(r)*ones(m,1);
s2 = invd(2*pr)*(v+sqrt(v.^2+4*pr.*nr));  %second step s                              
dif = s2-s1;
iter = 1                %first iteration
eps = 0.0001;         %tolerance level 0000000000
M = max(abs(dif));
while (M > eps)
    s1 = s2;
    ps = P*s1;
    ns = N*invd(s1)*ones(n,1);
    r = invd(2*ps)*(u+sqrt(u.^2+4*ps.*ns));   %previous step r
    pr = P'*r;
    nr = N'*invd(r)*ones(m,1);
    s2 = invd(2*pr)*(v+sqrt(v.^2+4*pr.*nr));  %current step s
    dif = s2-s1;
    iter = iter+1
    M = max(abs(dif));
end
s = s2;                                        %final step s
ps = P*s;
ns = N*invd(s)*ones(n,1);
r = invd(2*ps)*(u+sqrt(u.^2+4*ps.*ns));        %final step r
X = diag(r)*P*diag(s)-invd(r)*N*invd(s);
return