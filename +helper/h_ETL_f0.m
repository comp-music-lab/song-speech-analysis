function D = h_ETL_f0(dataname, f0dir)
    %%
    D = cell(numel(dataname), 1);
    reffreq = 440;

    %%
    for i=1:numel(dataname)
        f0info = readtable(strcat(f0dir, dataname{i}, '_f0.csv'));
        f0_i = f0info.voice_1(f0info.voice_1 ~= 0);
        D{i} = 1200.*log2(f0_i./reffreq);
    end
end