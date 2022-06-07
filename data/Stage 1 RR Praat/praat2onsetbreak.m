function praat2onsetbreak
    %%
    listing = dir('../Stage 1 RR Audio/');
    filelist = arrayfun(@(l) l.name, listing, 'UniformOutput', false);
    audiolist = filelist(contains(filelist, '.wav'));
    datalist = cellfun(@(af) af(1:end - 4), audiolist, 'UniformOutput', false);

    %%
    for i=1:numel(datalist)
        T = readtable(strcat(datalist{i}, '_data.txt'));
        t_onset = T.nucl_t1;
        
        writematrix(t_onset, strcat('./onset_', datalist{i}, '.csv'));
        writematrix([], strcat('./break_', datalist{i}, '.csv'));
    end
end