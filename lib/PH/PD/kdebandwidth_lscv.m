function h_opt = kdebandwidth_lscv(X)
    %%
    kernelfun = @(u) 1/sqrt(2*pi) .* exp(-0.5.*u.^2);
    
    %%
    D = (X - X');
    h_max = std(X);
    h_ini = h_max * rand;
    objfun = @(h) lossfun(D, h, kernelfun);
    h_opt = fminunc(objfun, h_ini, optimoptions(@fminunc, 'OptimalityTolerance', 1e-8, 'Display', 'off'));
end

function L = lossfun(D, h, kernelfun)
    %%
    n = size(D, 1);

    %%
    D_m = D./(sqrt(2)*h);

    f_sq = sum(kernelfun(D_m), 'all');
    f_sq = f_sq/(sqrt(2)*h*n^2);
    
    %%
    D_m = D./h;

    f_cv = sum(kernelfun(D_m), 'all');
    f_cv = f_cv - n*kernelfun(0);
    f_cv = f_cv * 2/(h*n*(n - 1));

    %%
    L = f_sq - f_cv;
end

%{
addpath(strcat(userpath, '/lib2/Rcall/'));
Rlib = 'ks';
Rpath = 'C:\Program Files\R\R-4.0.2\bin\R.exe';
Rclear();
Rinit(Rlib, Rpath);

mu = -0.45;
sgm = 1.34;
n = [64, 137];
support = linspace(-9, 28, 1024);
f = n(1)/sum(n).*normpdf(support, mu, sgm) + n(2)/sum(n).*gampdf(support, 3.13, 2.11);

X = [normrnd(mu, sgm, [n(1), 1]); gamrnd(3.13, 2.11, [n(2), 1])];

[h_opt, h, L] = kdebandwidth_lscv(X);
q = kde(support, X, h_opt);

figure(1);
clf; cla;
subplot(2, 1, 1);
plot(support, f);
hold on;
plot(support, q, '-.m');
hold off;
%subplot(2, 1, 2);
%scatter(h, L, 'Marker', '.');

Rpush('X', X(:));
Rrun('h_cv <- hlscv(X, deriv.order=0, bw.ucv=TRUE)');
h_R = Rpull('h_cv');

disp([h_opt, h_R]);
%}

%{
mu_1 = normrnd(0, 2);
mu_2 = normrnd(0, 2);
sgm_1 = gamrnd(1, 1);
sgm_2 = gamrnd(1, 1);

support = linspace(-20, 20, randi(1024, 1) + 512);
dx = support(2) - support(1);

f = normpdf(support, mu_1, sgm_1);
g = normpdf(support, mu_2, sgm_2);
fg = fftshift(ifft(fft(f).*fft(g))) .* dx;

q = normpdf(support, mu_1 + mu_2, sqrt(sgm_1^2 + sgm_2^2));

figure(1);
subplot(2, 1, 1);
plot(support, fg); hold on; plot(support, q, '-.m'); hold off;
subplot(2, 1, 2);
plot(support, fg - q);
%}