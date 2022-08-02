function xsynth = h_clicksynth(x, t_x, clicksound, onset, mono)
    if mono
        xsynth = x;
    else
        if size(x, 2) == 2
            xsynth = x;
        elseif size(x, 2) == 1
            xsynth = [x, zeros(numel(x), 1)];
        end
    end
    
    L_x = numel(x);
    L_c = numel(clicksound);
    
    for i=1:numel(onset)
        [~, idx_st] = min(abs(t_x - onset(i)));
        idx_ed = min(L_x, idx_st + L_c - 1);
        
        if mono
            xsynth(idx_st:idx_ed) = xsynth(idx_st:idx_ed) + clicksound(1:numel(idx_st:idx_ed));
        else
            xsynth(idx_st:idx_ed, 2) = xsynth(idx_st:idx_ed, 2) + clicksound(1:numel(idx_st:idx_ed));
        end
    end
end