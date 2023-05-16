function util_checkPESonset
    dirinfo = dir('../data/Stage 2 Annotation (10second-onset-PES)/');

    for i=1:length(dirinfo)
        if contains(dirinfo(i).name, '.csv')
            T = readtable(strcat(dirinfo(i).folder, filesep, dirinfo(i).name), 'ReadVariableNames', false, 'Format', '%f%s');
            t_onset_PES = T.Var1;
            t_onset_PES = t_onset_PES(t_onset_PES <= 10.1);

            T = readtable(strcat('../data/Stage 2 Annotation/', dirinfo(i).name), 'ReadVariableNames', false, 'Format', '%f%s');
            t_onset = T.Var1;
            t_onset = t_onset(t_onset <= 10.1);

            fprintf('%s %d/%d\n', dirinfo(i).name, numel(t_onset_PES), numel(t_onset));
            assert(numel(t_onset_PES) == numel(t_onset), 'Check onset annotation');
        end
    end
end