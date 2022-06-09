function T = pairing_20220517
    %%
    listing = dir('./data/Stage 1 RR Audio/');
    filelist = arrayfun(@(l) l.name, listing, 'UniformOutput', false);
    audiolist = filelist(contains(filelist, '.wav'));
    datalist = cellfun(@(af) af(1:end - 4), audiolist, 'UniformOutput', false);
    
    %%
    participant = {'Yuto', 'Patrick', 'Dhwani', 'Shafagh'};
    performer = {'Yuto', 'John', 'Parimal', 'Shafagh'};
    Map_annotdata = containers.Map(participant, performer);

    %%
    originaldir = {};
    annotatordir = {};
    dataname = {};
    datatype = {};
    original = {};
    annotator = {};

    datadir = './data/Stage 1 RR Round 1/';
    h_split = @(X) X{end};

    for i=1:numel(participant)
        original_i = participant{i};
        variation = setdiff(participant, original_i);
        finalonsetdir = strcat(datadir, original_i, '/');

        for j=1:numel(variation)
            annotatordir_j = strcat(datadir, variation{j}, '/');
            dataname_j = datalist(contains(datalist, Map_annotdata(original_i)));
            datatype_j = cellfun(@(d) h_split(strsplit(d, '_')), dataname_j, 'UniformOutput', false);
            
            annotatordir = [annotatordir; repmat({annotatordir_j}, [numel(dataname_j), 1])];
            originaldir = [originaldir; repmat({finalonsetdir}, [numel(dataname_j), 1])];
            dataname = [dataname; dataname_j];
            original = [original; repmat({original_i}, [numel(dataname_j), 1])];
            datatype = [datatype; datatype_j];
            annotator = [annotator; repmat(variation(j), [numel(dataname_j), 1])];
        end
    end

    T = table(originaldir(:), annotatordir(:), dataname(:), datatype(:), original(:), annotator(:),...
        'VariableNames', {'originaldir', 'annotatordir', 'dataname', 'datatype', 'original', 'annotator'});
end