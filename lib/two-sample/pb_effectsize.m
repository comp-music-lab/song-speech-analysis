function A = pb_effectsize(x, y)
    n_x = length(x);
    n_y = length(y);
    
    c_1 = 0;
    c_2 = 0;
    
    for i=1:n_x
        c_1 = c_1 + numel(find(x(i) > y));
        c_2 = c_2 + 0.5 * numel(find(x(i) == y));
    end
    
    A = (c_1 + c_2)/(n_x * n_y);
end

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