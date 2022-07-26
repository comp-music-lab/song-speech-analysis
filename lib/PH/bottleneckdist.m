function D = bottleneckdist(PD_A, PD_B)
    %%
    if size(PD_A, 1) == 1
        [~, idx] = min(vecnorm(bsxfun(@minus, PD_A, PD_B), Inf, 2));
        I = 1:size(PD_B, 1);
        D_A = vecnorm(PD_A - PD_B(idx, :), Inf);
        D_B = 0.5.*(PD_B(I ~= idx, 2) - PD_B(I ~= idx, 1));
        D = max([D_A; D_B]);
    elseif size(PD_B, 1) == 1
        [~, idx] = min(vecnorm(bsxfun(@minus, PD_A, PD_B), Inf, 2));
        I = 1:size(PD_A, 1);
        D_A = vecnorm(PD_A(idx, :) - PD_B, Inf);
        D_B = 0.5.*(PD_A(I ~= idx, 2) - PD_A(I ~= idx, 1));
        D = max([D_A; D_B]);
    else
        PD_A_py = py.numpy.array(PD_A);
        PD_B_py = py.numpy.array(PD_B);
        D = py.gudhi.bottleneck_distance(PD_A_py, PD_B_py, 0.0);
    end
end