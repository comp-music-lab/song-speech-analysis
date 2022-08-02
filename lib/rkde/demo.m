%Written by JooSeuk Kim(2011/07/12)
clear all 
close all

d = 1; %
n0 = 200; %# of nominal sample size
n1 = 20; %# of outliers

%generate training data with mixture of Gaussian 0.4*N(3, 1) + 0.6*N(8,1)
nc1 = binornd(n0, 0.4);
x1 = [randn(nc1, 1)+3; randn(n0-nc1, 1)+8];

%generate outliers with unifrom from -5 to 15
x0 = 20*rand(n1, 1)-5;

n = n0 + n1;
x = [x1; x0];

%b_type: bandwidth type: 1 -> lscv, 2 -> lkcv, 3 -> jakkola heuristic,
b_type = 1;
h = bandwidth_select(x, b_type);

%weights for KDE
w_kde = ones(n,1)/n;

%weights for RKDE
type = 2; %Hampel loss
[w_hm a b c] = robkde(x, h, type);


y = (-5:0.01:15)';
m = length(y);

%display density estimates
figure;

%true density
f = 0.4*normpdf(y, 3, 1) + 0.6*normpdf(y, 8, 1);

Y = (ones(m, 1)*x' - y*ones(1, n)).^2;
pd = gauss_kern(Y, h, d);
f_kde = pd*w_kde;
f_hm = pd*w_hm;

plot(y, f, 'k-')
hold on
plot(y, f_kde, ':b');
plot(y, f_hm, 'r-.');

stem(x1, 0.005*ones(1,length(x1)), 'bo', 'markersize', 6);
stem(x0, 0.005*ones(1,length(x0)), 'rx', 'markersize', 6);

legend('true', 'KDE', 'RKDE(Hampel)', 'nominal sample', 'outliers');
axis([-5 15 0 0.35])

%display influence function
figure;
x_prime = [-3;2;7;12];
l = length(x_prime);

alpha_kde = [-1/n*ones(n, 1); ones(1, 1)];
alpha_hm = IF(w_hm, x, x_prime, h, 2, a, b, c);

for i = 1:l
    subplot(2,2,i)
    x_extend = [x; x_prime(i)];
    Z = (ones(m, 1)*x_extend' - y*ones(1, n+1)).^2;
    pd2 = gauss_kern(Z, h, d);
    IF_KDE = pd2*alpha_kde;
    IF_HM = pd2*alpha_hm(:,i);
    plot(y, IF_KDE, 'b');
    hold on
    plot(y, IF_HM, 'r-.');
    stem(x_prime(i), 0.005, 'bo', 'markersize', 6);
    legend('KDE', 'RKDE(Hampel)', 'x`');
end