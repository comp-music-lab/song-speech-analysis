function t_seg = h_phraseseg(t_onset, t_break)
    %%
    if isempty(t_break)
        t_seg = [];
        return
    end

    %%
    t_seg = zeros(numel(t_break), 2);
    t_seg(:, 2) = t_break;
    
    t_break_pre = -Inf;
    for i=1:numel(t_break)
        t_seg(i, 1) = t_onset(find(t_break_pre < t_onset & t_onset < t_break(i), 1, 'first'));
        t_break_pre = t_seg(i, 2);
    end
end