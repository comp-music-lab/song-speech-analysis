function analysis_npvi(datainfofile, outputdir, duration, typeid)
    %%
    switch typeid
        case 1
            typelist = {'song', 'desc'};
            fileid = 'song-desc';
        case 2
            typelist = {'song', 'inst'};
            fileid = 'song-inst';
        case 3
            typelist = {'song', 'recit'};
            fileid = 'song-recit';
    end
    
    %%
    datainfo = readtable(datainfofile);
    datainfo = datainfo(strcmp(datainfo.type, typelist{1}) | strcmp(datainfo.type, typelist{2}), :);

    %%
    N = size(datainfo, 1);
    nPVI = zeros(N, 1);
    for i=1:N
        onsetfilepath = strcat(datainfo.annotationdir{i}, 'onset_', datainfo.dataname{i}, '.csv');
        T = readtable(onsetfilepath, 'ReadVariableNames', false, 'Format', '%f%s');
        t_onset = unique(T.Var1);
        t_onset = t_onset(t_onset <= duration);
        
        breakfilepath = strcat(datainfo.annotationdir{i}, 'break_', datainfo.dataname{i}, '.csv');
        T = readtable(breakfilepath, 'ReadVariableNames', false, 'Format', '%f%s');
        t_break = unique(T.Var1);
        t_break = t_break(t_break <= duration);

        ioi = helper.h_ioi(t_onset, t_break);
        %nPC = 200*abs(diff(ioi)./arrayfun(@(i) ioi(i - 1) + ioi(i), 2:numel(ioi)));
        for j=2:numel(ioi)
            nPVI(i) = nPVI(i) + abs((ioi(j) - ioi(j - 1))/(0.5*(ioi(j) + ioi(j - 1))));
        end
        nPVI(i) = nPVI(i)/(numel(ioi) - 1);
    end
    
    nPVI = nPVI.*100;

    %%
    T = table(nPVI, datainfo.type, datainfo.language, datainfo.groupid,...
        'VariableNames', {'npvi', 'type', 'lang', 'groupid'});

    writetable(T, strcat(outputdir, 'npvi_', num2str(duration, '%d'), 'sec_', fileid, '.csv'));
end