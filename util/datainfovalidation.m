function datainfovalidation
    %%
    %%{
    datainfofile = '../datainfo.csv';
    K = 4;
    datatypelist = {'desc', 'inst', 'recit', 'song'};
    onsetavailable = true;
    %}
    %{
    datainfofile = '../datainfo_pyin-Praat.csv';
    K = 2;
    datatypelist = {'desc', 'song'};
    onsetavailable = true;
    %}
    %{
    datainfofile = '../datainfo_pyin.csv';
    K = 2;
    datatypelist = {'desc', 'song'};
    onsetavailable = false;
    %}

    T = readtable(datainfofile);

    %% validation 0
    assert(isempty(setdiff(unique(T.melodic), {'N', 'Y', 'n/a'})), 'Check melodic');
    assert(isempty(setdiff(unique(T.sex), {'M', 'F'})), 'Check sex');
    assert(isempty(setdiff(unique(T.blinding), {'TRUE', 'FALSE'})), 'Check blinding');

    %%
    groupid = unique(T.groupid);
    for i=1:numel(groupid)
        idx = T.groupid == groupid(i);
        assert(sum(idx) == K, 'Check group id');

        dataname = T.dataname(idx);
        datatype = cellfun(@(s) h_strsplit(s), dataname, 'UniformOutput', false);

        %% validation 1
        assert(isempty(setdiff(datatype, datatypelist)), 'Check dataname datatype');

        %% validation 2
        assert(all(strcmp(datatype, T.type(idx))), 'Check datatype');

        %% validation 3
        if onsetavailable
            onsetfilepath = strcat('.', T.annotationdir(idx), 'onset_', dataname, '.csv');
            assert(all(isfile(onsetfilepath)), 'Check onset file path');
    
            breakfilepath = strcat('.', T.annotationdir(idx), 'break_', dataname, '.csv');
            assert(all(isfile(breakfilepath)), 'Check break file path');
        end

        audiofilepath = strcat(T.audiodir(idx), dataname, '.', T.audioext(idx));
        assert(all(isfile(audiofilepath)),  ['Check audio file path: ', num2str(i), ' - ', T.performer{idx(1)}]);

        melodic = T.melodic(idx);
        f0filepath = strcat('.', T.annotationdir(idx), dataname, '_f0.csv');
        assert(all(isfile(f0filepath(~strcmp(melodic, 'N')))), 'Check f0 file path');

        %% validation 4
        assert(length(unique(T.performer(idx))) == 1, 'Check performer');
        assert(length(unique(T.language(idx))) == 1, 'Check language');
        assert(length(unique(T.sex(idx))) == 1, 'Check sex');
    end

    %% validation 5
    lang = unique(T.language);
    M = readtable('../data/LangColorMap.csv');
    for i=1:numel(lang)
        idx = strcmp(lang{i}, M.lang_filename);
        assert(sum(idx) == 1, 'Check language-color mapping');
        fprintf('%s, %s\n', M.lang_filename{idx}, M.family{idx});
    end
end

function str = h_strsplit(dataname)
    s = strsplit(dataname, '_');
    str = s{end};
end