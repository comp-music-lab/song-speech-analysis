function [A, tau, dof] = pb_effectsize(x, y)
    %%
    n_x = length(x);
    n_y = length(y);
    
    c_1 = 0;
    c_2 = 0;
    
    for i=1:n_x
        c_1 = c_1 + numel(find(x(i) > y));
        c_2 = c_2 + 0.5 * numel(find(x(i) == y));
    end
    
    A = (c_1 + c_2)/(n_x * n_y);

    %%
    x = x(:);
    y = y(:);
    
    R_ik = tiedrank([x; y]);
    R_ikx = tiedrank(x);
    R_iky = tiedrank(y);
    R_ix = mean(R_ik(1:n_x));
    R_iy = mean(R_ik((n_x + 1):end));
    S_xsq = 1/(n_x - 1) * sum((R_ik(1:n_x) - R_ikx - R_ix + (n_x + 1)/2).^2);
    S_ysq = 1/(n_y - 1) * sum((R_ik((n_x + 1):end) - R_iky - R_iy + (n_y + 1)/2).^2);
    
    if n_x == 1
        S_xsq = 0;
    end
    if n_y == 1
        S_ysq = 0;
    end

    tau = 1/(n_x*n_y)*sqrt(n_x*S_xsq + n_y*S_ysq);

    dof = (S_xsq/n_y + S_ysq/n_x)^2/((S_xsq/n_y)^2/(n_x - 1) + (S_ysq/n_x)^2/(n_y - 1));
end

% p = 1/n_x*(R_iy - (n_y + 1)/2);

%{
mu_x = 42.14;
sgm_x = 16.07;

mu_y = 16.30;
sgm_y = 8.34;

n = 83 + 306;
br = 0.02:0.02:0.98;

M = 1000;
A = zeros(M, 1);
A_m = zeros(length(br), 1);

for j=1:length(br)
    n_x = round(br(j) * n);
    n_y = n - n_x;

    parfor m=1:M
        x = normrnd(mu_x, sgm_x, [n_x 1]);
        y = normrnd(mu_y, sgm_y, [n_y 1]);

        A(m) = lib.pb_effectsize(x, y);
    end

    A_m(j) = mean(A);
end

figure(1);
plot(br, A_m);
ylim([0 1]);
%}

%{
mu_x = 2;
mu_y = 0;

sgm_y = 1;
sgm_x = [1 2 4 8 16].*sgm_y;

br = 0.01:0.01:0.99;

N = 2000;
M = 2000;

A = zeros(length(br), length(sgm_x));
A_m = zeros(M, 1);

for i=1:length(sgm_x)
    sgm_xi = sgm_x(i);
    
    for j=1:length(br)
        n_x = round(br(j) * N);
        n_y = N - n_x;
        
        parfor m=1:M
            x = normrnd(mu_x, sgm_xi, [n_x 1]);
            y = normrnd(mu_y, sgm_y, [n_y 1]);

            A_m(m) = lib.pb_effectsize(x, y);
        end

        A(j, i) = mean(A_m);
    end
end

figure(1);
plot(br, A);
xlim([-0.05 1.05]); ylim([0.49 1.01]);
%}

%{
mu_x = 1;
mu_y = 0;
sgm_x = 1;
sgm_y = 1;

N = 500;

x = normrnd(mu_x, sgm_x, [N 1]);
y = normrnd(mu_y, sgm_y, [N 1]);
A = lib.pb_effectsize(x, y);

y = normrnd(mu_x, sgm_x, [N 1]);
x = normrnd(mu_y, sgm_y, [N 1]);
B = lib.pb_effectsize(x, y);

disp([A B]);
%}

%{
al = 0.05;
mu_1 = 1.2;
mu_2 = 0.7;
sgm = 1.8;
d = (mu_1 - mu_2)/sgm;
rho = normcdf(d/sqrt(2));

n_1 = 128;
n_2 = 128;

M = 4096;
CI = zeros(M, 2);

d_0 = 0;
dlt = 0.4;
rho_ul = normcdf([d_0 - dlt, d_0 + dlt]./sqrt(2));
C = (0.5 - rho_ul(1) + rho_ul(2) - 0.5);
equivalencehit = zeros(M, 1);

for m=1:M
    X = normrnd(mu_1, sgm, [n_1, 1]);
    Y = normrnd(mu_2, sgm, [n_2, 1]);
    [rho_m, tau, dof] = pb_effectsize(X, Y);
    u = tinv(1 - al, dof);
    CI(m, :) = [rho_m - tau*u, rho_m + tau*u];

    C_mw = sqrt(ncx2inv(al, 1, C^2/(2*tau)^2));
    equivalencehit(m) = abs(rho_m - 0.5 - (rho_ul(2) - rho_ul(1))/2)/tau < C_mw;
end

falsepositive = sum(rho < CI(:, 1) | CI(:, 2) < rho)/M;
disp(falsepositive);

disp(sum(equivalencehit)/M);

figure(1);
for m=1:M
    plot([m, m], CI(m, :), 'Color', 'k');
    hold on
end
plot([1, M], rho_ul(1).*[1, 1], '-.m');
plot([1, M], rho_ul(2).*[1, 1], '-.m');
plot([1, M], [rho, rho], 'Color', 'g');
hold off
%}