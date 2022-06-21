function ioiratioist = ft_ioiratiodist(t_onset, t_break)
    [~, ioiratio, ~, ~, ~] = helper.h_ioi(t_onset, t_break);
    
    ioiratioist = abs(ioiratio - 0.5);
end