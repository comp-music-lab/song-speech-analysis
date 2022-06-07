function jsd_h = jsd(X, Y)
    %%
    k = 5;
    
    H_X = klnn(X, k);
    H_Y = klnn(Y, k);
    H_M = klnn([X; Y], k);

    jsd_h = H_M - 0.5*(H_X + H_Y);
end