function ioiratiodist = ft_ioirationndist(t_onset, t_break)
    [~, ioiratio, ~, ~, ~] = helper.h_ioi(t_onset, t_break);
    ioiratio = ioiratio(:);
    
    X = sort(ioiratio);
    ioiratiodist = conv(diff(X), [0.5; 0.5]);

    %{
    NS = createns(ioiratio, 'NSMethod', 'exhaustive');
    [~, D] = knnsearch(NS, ioiratio, 'K', 2);

    ioiratiodist = D(:, end);
    %}
end

%{
a = 0;
b = 1;

support_x = linspace(a + 1e-12, b - 1e-12, 1024);
X = ioiratio;

support_y = norminv((support_x - a)./(b - a), 0, 1);
Y = norminv((X - a)./(b - a), 0, 1);
h = kdebandwidth_lp(Y);
    
density_y = arrayfun(@(Y_i) normpdf(support_y, Y_i, h), Y, 'UniformOutput', false);
density_y = mean(cat(1, density_y{:}), 1);
density = density_y .* 1./normpdf(norminv((support_x - a)./(b - a), 0, 1), 0, 1) .* (1/(b - a));

figure;
plot(support_x, density);
hold on;
scatter(ioiratio, zeros(numel(ioiratio), 1));
hold off;
%}