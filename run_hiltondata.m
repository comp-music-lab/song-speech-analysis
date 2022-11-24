function run_hiltondata
    %%
    datainfoid = 'datainfo_Hilton-pyin';
    duration = Inf;
    typeflag = 1;
    exploratory = false;
    outputdir = './output/Hilton-pyin/';

    analysis_featureES_1(datainfoid, duration, typeflag, exploratory, outputdir);

    %%
    datainfoid = 'datainfo_Hilton-sa';
    duration = Inf;
    typeflag = 1;
    exploratory = false;
    outputdir = './output/Hilton-sa/';

    analysis_featureES_1(datainfoid, duration, typeflag, exploratory, outputdir);
end