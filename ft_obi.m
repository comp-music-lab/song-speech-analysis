function obi = ft_obi(t_onset, t_break)
    if isempty(t_break)
        obi = [];
    else
        obi = t_break(1) - t_onset(1);
        
        for i=2:numel(t_break)
            idx = find(t_onset > t_break(i - 1), 1, 'first');
            obi(end + 1) = t_break(i) - t_onset(idx);
        end
    end
end