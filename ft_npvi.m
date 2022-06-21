function nPVI = ft_npvi(t_onset, t_break)
    [ioi, ~, t_st, t_ed, ~] = helper.h_ioi(t_onset, t_break);
    
    nPVI = 0;
    N = numel(ioi);
    m = 0;
    
    for i=2:N
        if t_st(i) == t_ed(i - 1)
            nPVI = nPVI + abs(ioi(i - 1) - ioi(i))/(ioi(i - 1) + ioi(i));
            m = m + 1;
        end
    end
    
    nPVI = nPVI*(200/m);
end