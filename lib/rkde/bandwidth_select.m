%Written by JooSeuk Kim(2011/07/12)
function h_opt = bandwidth_select(x, b_type, sigma)
%h_opt: optimal bandwidth
%x: n by d vector
%b_type: bandwidth type: 1 -> lscv, 2 -> lkcv, 3 -> jakkola heuristic
%sigma: bandwidth array

if nargin < 2
    b_type = 1;
end

if nargin < 3
    sigma = logspace(-2,1);
end
l = length(sigma);

[n,d] = size(x);

% construct matrix of squared distances
X = zeros(n,n);
for i = 1:d
    X = X + (ones(n,1)*x(:,i)' - x(:,i)*ones(1,n)).^2;
end

if b_type == 1
    %least squares cross validation
    Jmin = inf;
    for i = 1:l
        h = sigma(i);
        K1 = (4*pi*h^2)^(-d/2)*exp(-X/(4*h^2));
        K2 = (2*pi*h^2)^(-d/2)*(exp(-X/(2*h^2))-eye(n,n));
        J = sum(sum(K1))/(n^2) - 2/(n*(n-1))*sum(sum(K2));
        if J < Jmin
            h_opt = h;
            Jmin = J;
        end
    end
elseif b_type == 2
    %log-likelyhood cross validation
    Jmax = -inf;
    for i = 1:l
        h = sigma(i);
        K = (2*pi*h^2)^(-d/2)*(exp(-X/(2*h^2))-eye(n,n));
        J = 1/n*sum(log(sum(K)/(n-1)));
        if J > Jmax
            h_opt = h;
            Jmax = J;
        end
    end
elseif b_type == 3
    %Jakkola hueristics
    %include only distinct data points
    index = (X == 0);
    X(index) = inf;
    Y = min(X);
    h_opt = sqrt(median(Y));
end