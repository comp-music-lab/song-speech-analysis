function result = oq_threshcurve(t_onset_ref, t_onset_est, thresh, annotator, language, datatype)
    %%
    J = numel(thresh);

    R = zeros(J, 1);
    F1 = zeros(J, 1);
    PRC = zeros(J, 1);
    RCL = zeros(J, 1);
    OS = zeros(J, 1);
    
    %%
    for j=1:J
        [R(j), F1(j), PRC(j), RCL(j), OS(j)] = ft_rvalue(t_onset_ref, t_onset_est, thresh(j));
    end
    
    %%
    result = table(...
        F1, R, PRC, RCL, OS, thresh, repmat(annotator, [J, 1]), repmat(language, [J, 1]), repmat(datatype, [J, 1]),...
        'VariableNames', {'F1', 'Rval', 'PRC', 'RCL', 'OS', 'thresh', 'annotator', 'language', 'type'}...
        );
end