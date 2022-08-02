%Written by JooSeuk Kim(2011/07/12)

function alpha = IF(w, x, y, h, type, a, b, c)
%alpha: weights for influence function
%w: weights for RKDE
%x: training data
%y: corresponds to x'
%h: bandwidth
%type: type of loss function, 1-> Huber, 2-> Hampel
%a, b, c: parameters

[n, d] = size(x);
[m, d] = size(y);
% construct matrix of squared distances
X = zeros(n, n);
Y = zeros(m, n);

for i = 1:d
    X = X + (ones(n,1)*x(:,i)' - x(:,i)*ones(1,n)).^2;
end

for i = 1:d
    Y = Y + (ones(m,1)*x(:,i)' - y(:,i)*ones(1,n)).^2;
end

K = gauss_kern(X,h,d);
Ky = gauss_kern(Y, h, d);
k0 = gauss_kern(0,h,d);

norm2mu = w'*K*w;
r = real(sqrt(diag(K) + norm2mu - 2*K*w));
ry = real(sqrt(k0 + norm2mu - 2*Ky*w));

gamma = sum((h_psi(r, type, a, b, c)./r));
% idx = isnan(c);
% c(idx) = 1;
% c = sum(c);

g = (r.*psi_prime(r, type, a, b, c)-h_psi(r, type, a, b, c))./(r.^3);
% idx = isnan(g);
% g(idx) = 0;

A = ones(n,1)*w' - eye(n, n);
B = A'*diag(g)*A;
C = gamma*eye(n,n) + B*K;

z = (h_psi(ry, type, a, b, c)./ry)*n;
uy = z/gamma;
D = -w*z' - B*Ky'*diag(uy);
u = C\D;
alpha = [u; uy'];