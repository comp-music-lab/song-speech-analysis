function pprm = plotprm()
    pprm.titlefontsize = 24;
    pprm.labelfontsize = 20;
    pprm.legendfontsize = 16;
    pprm.tickfontsize = 18;
    pprm.linewidth = 2;
    pprm.colorcode = {...
        [0 0.4470 0.7410], ...
        [0.8500 0.3250 0.0980], ...
        [0.9290 0.6940 0.1250], ...
        [0.4940 0.1840 0.5560]
        };
    pprm.typemarkermap = containers.Map({'song', 'recit', 'desc', 'inst'}, {'o', '^', 'd', 's'});
    pprm.langmarkermap = containers.Map({'English', 'Japanese', 'Spanish', 'Korean', 'Mandarin', 'Greek', 'Yoruba', 'Farsi', 'Marathi'},...
        {'o', 'x', '+', 's', 'd', 'v', '*', '^', 'p'});
    pprm.langcolormap = containers.Map({'English', 'Japanese', 'Spanish', 'Korean', 'Mandarin', 'Greek', 'Yoruba', 'Farsi', 'Marathi'},...
        {[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250], [0.4940 0.1840 0.5560], [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330],...
        [0.6350 0.0780 0.1840], [0.8 0.1 0.7], [0.2 0.2 0.9]});
    pprm.xangle = 50;
end