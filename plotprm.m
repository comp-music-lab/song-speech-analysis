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
    pprm.langmarkermap = containers.Map({'English', 'Japanese', 'Spanish', 'Korean', 'Mandarin', 'Greek'}, {'o', 'x', '+', 's', 'd', 'v'});
    pprm.xangle = 50;
end