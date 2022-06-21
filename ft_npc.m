function nPC = ft_npc(t_onset, t_break)
    [ioi, ~, t_st, t_ed, ~] = helper.h_ioi(t_onset, t_break);
    
    nPC = [];
    N = numel(ioi);
    
    for i=2:N
        if t_st(i) == t_ed(i - 1)
            nPC(end + 1) = abs(ioi(i - 1) - ioi(i))/(ioi(i - 1) + ioi(i));
        end
    end
end