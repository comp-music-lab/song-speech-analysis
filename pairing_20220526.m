function T = pairing_20220526
    %%
    listing = dir('./data/Stage 1 RR Audio/');
    filelist = arrayfun(@(l) l.name, listing, 'UniformOutput', false);
    audiolist = filelist(contains(filelist, '.wav'));
    datalist = cellfun(@(af) af(1:end - 4), audiolist, 'UniformOutput', false);
    
    langmap = containers.Map({'Yuto', 'John', 'Parimal', 'Shafagh', 'Florence'},...
        {'Japanese', 'English', 'Marathi', 'Farsi', 'Yoruba'});

    originallist = {'Yuto', 'Dhwani', 'Shafagh', 'Patrick'};
    originaldirlist = strcat('./data/Stage 1 RR Round 2/', originallist, '/');
    annotatorlist = {'Patrick', 'Patrick', 'Shafagh', 'Shafagh', 'Mertens2004', 'Patrick'};
    annotatordirlist = {'./data/Stage 1 RR Round 1/Patrick/', './data/Stage 1 RR Round 2/Patrick/',...
        './data/Stage 1 RR Round 1/Shafagh/', './data/Stage 1 RR Round 2/Shafagh/', './data/Stage 1 RR Praat/',...
        './data/Stage 1 RR IRR/Patrick/'};

    %%
    originaldir = {};
    annotatordir = {};
    dataname = {};
    datatype = {};
    original = {};
    annotator = {};
    annotround = {};
    lang = {};
    
    for i=1:numel(annotatordirlist)
        annotround_i = '-';

        idx = contains(annotatordirlist{i}, 'Round 1');
        if sum(idx) > 0
            annotround_i = 'R1';
        end
        
        idx = contains(annotatordirlist{i}, 'Round 2');
        if sum(idx) > 0
            annotround_i = 'R2';
        end

        idx = contains(annotatordirlist{i}, 'IRR');
        if sum(idx) > 0
            annotround_i = 'IRR';
        end
        
        if strcmp(annotround_i, 'IRR')
            [datalist_white, lang_i] = h_whitelist(strcat(annotatorlist{i}, '/'), datalist, langmap);

            for k=1:numel(datalist_white)
                originaldir(end + 1) = originaldirlist(j);
                annotatordir(end + 1) = annotatordirlist(i);
                dataname(end + 1) = datalist_white(k);

                s = strsplit(datalist_white{k}, '_');
                datatype(end + 1) = s(end);
                original(end + 1) = originallist(j);
                annotator(end + 1) = annotatorlist(i);
                annotround(end + 1) = {annotround_i};
                lang(end + 1) = {lang_i};
            end
        else
            for j=1:numel(originaldirlist)
                if ~strcmp(originallist{j}, annotatorlist{i})
                    [datalist_white, lang_j] = h_whitelist(originaldirlist{j}, datalist, langmap);
        
                    for k=1:numel(datalist_white)
                        originaldir(end + 1) = originaldirlist(j);
                        annotatordir(end + 1) = annotatordirlist(i);
                        dataname(end + 1) = datalist_white(k);
        
                        s = strsplit(datalist_white{k}, '_');
                        datatype(end + 1) = s(end);
                        original(end + 1) = originallist(j);
                        annotator(end + 1) = annotatorlist(i);
                        annotround(end + 1) = {annotround_i};
                        lang(end + 1) = {lang_j};
                    end
                end
            end
        end
    end

    T = table(originaldir(:), annotatordir(:), dataname(:), datatype(:), original(:), annotator(:), annotround(:), lang(:),...
        'VariableNames', {'originaldir', 'annotatordir', 'dataname', 'datatype', 'original', 'annotator', 'annotround', 'language'});
end

function [datalist_white, lang] = h_whitelist(originaldir, datalist, langmap)
    s = strsplit(originaldir, '/');
    s = s{end - 1};

    switch s
        case 'Yuto'
            idx = contains(datalist, 'Yuto');
            lang = langmap('Yuto');
        case 'Dhwani'
            idx = contains(datalist, 'Parimal');
            lang = langmap('Parimal');
        case 'Shafagh'
            idx = contains(datalist, 'Shafagh');
            lang = langmap('Shafagh');
        case 'Patrick'
            idx = contains(datalist, 'McBride');
            lang = langmap('John');
    end

    datalist_white = datalist(idx);
end