function [R, F1, PRC, RCL, OS] = ft_rvalue(t_onset_ref, t_onset_est, thresh)
    %%
    if nargin < 3
        thresh = 0.02;
    end

    %%
    N_hit = 0;
    N_ref = numel(t_onset_ref);
    
    for j=1:N_ref
        boundary_l = t_onset_ref(j) - thresh;
        boundary_r = t_onset_ref(j) + thresh;

        if j > 1
            preboundary_r = t_onset_ref(j - 1) + thresh;
            
            if boundary_l < preboundary_r
                boundary_l = boundary_l + (preboundary_r - boundary_l)/2;
            end
        end

        if j < N_ref
            postboundary_l = t_onset_ref(j + 1) - thresh;
            
            if postboundary_l < boundary_r
                boundary_r = boundary_r - (boundary_r - postboundary_l)/2;
            end
        end

        flag = boundary_l <= t_onset_est & t_onset_est < boundary_r;
        if sum(flag) > 0
            N_hit = N_hit + 1;
        end
    end

    %%
    N_est = numel(t_onset_est);
    
    PRC = N_hit/N_est;
    RCL = N_hit/N_ref;
    F1 = (2*PRC*RCL)/(PRC + RCL);

    OS = RCL/PRC - 1;
    r1 = sqrt((1 - RCL)^2 + OS^2);
    r2 = (-OS + RCL - 1)/sqrt(2);
    R = 1 - (abs(r1) + abs(r2))/2;
end

%{
figure(1);
stem([boundary_l, t_onset_ref(j), boundary_r], [1, 1, 1]);
hold on;
stem([t_onset_ref(j - 1), preboundary_r], [1, 1]);
stem([postboundary_l, t_onset_ref(j + 1)], [1, 1]);
hold off;
%}