%Written by JooSeuk Kim(2011/07/12)

function [w a b c] = robkde(x, h, type)
%w: weights for RKDE
%a,b,c: paramters
%x: n by d data matrix
%h: bandwidth
%type: type of loss function, 1-> Huber, 2-> Hampel

if nargin < 3
    type = 2;
end

[n, d] = size(x);

% construct kernel matrix(Gaussian kernel with bandwidth h)
X = zeros(n,n);
for i = 1:d
    X = X + (ones(n,1)*x(:,i)' - x(:,i)*ones(1,n)).^2;
end
K = gauss_kern(X,h,d);
%find median absolute deviation
[a b c]= parameter_select(K, type);

% initial weights
w = ones(n,1)/n;
tol = 10^-8;

norm2mu = w'*K*w;
normdiff = real(sqrt(diag(K) + norm2mu - 2*K*w));

J = rho(normdiff, type, a, b, c);

while (1)             
    J_old = J;
    w = h_psi(normdiff, type, a, b, c)./normdiff;
    w = w/sum(w);
    
    norm2mu = w'*K*w;
    normdiff = real(sqrt(diag(K) + norm2mu - 2*K*w)); 
    
    J = rho(normdiff, type, a, b, c);        
    if abs(J - J_old) < J_old*tol
        break;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [a b c] = parameter_select(K, type)
%
% K: kernel matrix
%

%first find median
[n n] = size(K);
% initial weights
w = ones(n,1)/n;
tol = 10^-7;

norm2mu = w'*K*w;
normdiff = real(sqrt(diag(K) + norm2mu - 2*K*w));
%rho = abs(x)
J = sum(normdiff)/n;

while (1)             
    J_old = J;
    w = 1./normdiff;
    w = w/sum(w);
    
    norm2mu = w'*K*w;
    normdiff = real(sqrt(diag(K) + norm2mu - 2*K*w)); 
    
    J = sum(normdiff)/n;        
    if abs(J - J_old) < J_old*tol
        break;
    end

    if isnan(J)
        normdiff = normdiff_pre;
        break
    end

    normdiff_pre = normdiff;
end

sort_norm = sort(normdiff, 'descend');

if type == 1
    a = sort_norm(floor(n/2));    
    b = 0;
    c = 0;
elseif type == 2
    a = sort_norm(floor(n/2));
    b = sort_norm(floor(n/20));
    c = max(normdiff);
end
