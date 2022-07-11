function rad_al = ft_dctioiratio(t_onset, t_break)
    [~, ioiratio, ~, ~, ~] = helper.h_ioi(t_onset, t_break);
    
    a = 0;
    b = 1;
    al = 0.95;
    
    %%
    support_x = linspace(a + 1e-8, b - 1e-8, 512);
    support_y = norminv((support_x - a)./(b - a), 0, 1);
    
    X = ioiratio;
    Y = norminv((X - a)./(b - a), 0, 1);
    h = kdebandwidth_lp(Y);
    
    density_y = arrayfun(@(Y_i) normpdf(support_y, Y_i, h), Y, 'UniformOutput', false);
    density_y = mean(cat(1, density_y{:}), 1);
    density = density_y .* 1./normpdf(norminv((support_x - a)./(b - a), 0, 1), 0, 1) .* (1/(b - a));
    
    C = trapz(support_x, density);
    fprintf('Check: %e\n', C);
    
    %%
    P = dct(density).^2;
    rad_al = find(cumsum(P)./sum(P) > al, 1, 'first') .* (2*pi/numel(P));
end

%{
[pks_m, locs_m, ~, prmns_m] = findpeaks(density);
[pks_s, locs_s] = findpeaks(-density);
pks_s = -pks_s;

[~, idx] = sort(pks_s, 'desc');
pks_s = pks_s(idx);
locs_s = locs_s(idx);

C = zeros(numel(pks_s), 6);
for i=1:numel(pks_s)
    idx_l = find(locs_m < locs_s(i), 1, 'last');
    idx_r = find(locs_s(i) < locs_m, 1, 'first');
    C(i, :) = [pks_s(i), pks_m(idx_l), pks_m(idx_r), locs_s(i), locs_m(idx_l), locs_m(idx_r)];
end

%}