function modes = persistencemode(X, x, f, h, al, B)
    if nargin < 5
        al = 0.95;
    end
    if nargin < 6
        B = 256;
    end
    
    f = f(:);

    %%
    birthdeath = persistencediagram(f);

    %%
    N = numel(X);
    t = zeros(B, 1);
    
    fw = waitbar(0, 'Please wait...');
    for b=1:B
        waitbar(b/B, fw, 'Please wait...');

        X_b = datasample(X, N);
        f_b = kde(x, X_b, h);
        f_b = f_b(:);

        birthdeath_b = persistencediagram(f_b);
        t(b) = bottleneckdist(birthdeath, birthdeath_b);
    end
    close(fw);

    t = sort(t);
    t_al = 2*t(round(al*B));
    
    %%
    idx = abs(birthdeath(:, 2) - birthdeath(:, 1)) > t_al;
    modes = [birthdeath(idx, 1), birthdeath(idx, 3)];
end

function birthdeath = persistencediagram(f)
    [pks, locs, ~, p] = findpeaks(f, 'SortStr', 'descend');
    idx = p > 1e-10;
    birthdeath = [pks(idx), pks(idx) - p(idx), locs(idx)];
end

%{
figure;
scatter(X(:, 1), X(:, 2));
hold on
scatter(Y(:, 1), Y(:, 2));
xl = xlim();
plot(xl, xl, ':k');
hold off
%}

%{
figure;
scatter(birthdeath(:, 2), birthdeath(:, 1));
hold on
plot([0, max(birthdeath(:, 2))], [0, max(birthdeath(:, 2))], '-.m');
plot([0, max(birthdeath(:, 2))], [0, max(birthdeath(:, 2))] + sqrt(2)*t_al/2, '-.k');
plot([0, max(birthdeath(:, 2))], [0, max(birthdeath(:, 2))] + sqrt(2)*t_al, '-.b');
%}

%{
figure;
scatter(X(:, 1), X(:, 2));
hold on
scatter(Y(:, 1), Y(:, 2));
xl = xlim();
plot(xl, xl, '-.m');
plot(xl, xl + sqrt(2)*dlt, '-.k');
plot(xl, xl + sqrt(2)*2*dlt, '-.b');
%}

%{
figure;
for i=1:size(X, 1)
    plot([X(i, 1), Z(i, 1)], [X(i, 2), Z(i, 2)], 'k');
    hold on
end
plot([0, max(X(:, 1))], [0, max(X(:, 1))], '-.m');
hold off
%}

%{
figure;
plot(f);
hold on;
for j=1:size(birthdeath, 1)
    plot(birthdeath(j, 3).*[1, 1], birthdeath(j, 1:2), '-.m');
    text(birthdeath(j, 3), birthdeath(j, 1), num2str(j));
end
hold off

figure;
scatter(birthdeath(:, 2), birthdeath(:, 1));
hold on;
plot([0, max(birthdeath(:, 2))], [0, max(birthdeath(:, 2))], '-.m');
hold off;
%}