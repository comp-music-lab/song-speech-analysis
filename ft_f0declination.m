function coef = ft_f0declination(t_onset, t_break, f0, t_f0)
    if isempty(t_onset)
        coef = NaN;
        return
    end
    
    reffreq = 440;
    f0 = 1200.*log2(f0./reffreq);

    if isempty(t_break)
        [~, idx_st] = min(abs(t_f0 - t_onset(1)));
        idx_ed = numel(f0);
        f0_i = f0(idx_st:idx_ed);
        t_f0_i = t_f0(idx_st:idx_ed);

        idx = ~isinf(f0_i);
        f0_idx = f0_i(idx);
        t_f0_idx = t_f0_i(idx);

        %R = [ones(numel(t_f0_idx), 1), t_f0_idx(:)]\f0_idx(:);
        mdl = fitlm(t_f0_idx(:), f0_idx(:), 'RobustOpts', 'huber');
        R = mdl.Coefficients.Estimate;
        coef = sign(R(2));
        %coef = R(2);
    else
        [~, idx_st] = min(abs(t_f0 - t_onset(1)));
        [~, idx_ed] = min(abs(t_f0 - t_break(1)));
        f0_i = f0(idx_st:idx_ed);
        t_f0_i = t_f0(idx_st:idx_ed);

        idx = ~isinf(f0_i);
        f0_idx = f0_i(idx);
        t_f0_idx = t_f0_i(idx);

        %R = [ones(numel(t_f0_idx), 1), t_f0_idx(:)]\f0_idx(:);
        mdl = fitlm(t_f0_idx(:), f0_idx(:), 'RobustOpts', 'huber');
        R = mdl.Coefficients.Estimate;
        coef = sign(R(2));
        %coef = R(2);

        %{
        figure;
        scatter(t_f0_i, f0_i, 'Marker', '.');
        hold on
        plot(t_f0_i, R(1) + R(2).*t_f0_i, '-.m');
        hold off
        %}
        
        for i=2:numel(t_break)
            idx = find(t_onset > t_break(i - 1), 1, 'first');

            [~, idx_st] = min(abs(t_f0 - t_onset(idx)));
            [~, idx_ed] = min(abs(t_f0 - t_break(i)));
            f0_i = f0(idx_st:idx_ed);
            t_f0_i = t_f0(idx_st:idx_ed);

            idx = ~isinf(f0_i);
            f0_idx = f0_i(idx);
            t_f0_idx = t_f0_i(idx);

            %R = [ones(numel(t_f0_idx), 1), t_f0_idx(:)]\f0_idx(:);
            mdl = fitlm(t_f0_idx(:), f0_idx(:), 'RobustOpts', 'huber');
            R = mdl.Coefficients.Estimate;
            coef(end + 1) = sign(R(2));
            %coef(end + 1) = R(2);

            %{
            figure;
            scatter(t_f0_i, f0_i, 'Marker', '.');
            hold on
            plot(t_f0_i, R(1) + R(2).*t_f0_i, '-.m');
            hold off
            %}
        end
    end
end