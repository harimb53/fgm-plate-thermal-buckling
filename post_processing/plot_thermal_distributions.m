function fig = plot_thermal_distributions(output_dir)
% PLOT_THERMAL_DISTRIBUTIONS Generates Figure 7 comparing thermal fields:
%   (a) Uniform Temperature Distribution (UTD)
%   (b) Linear Temperature Distribution (LTD)
%   (c) Nonlinear Conduction Distribution (NTD) across various k
%   (d) Through-Thickness Thermal Gradient dT/dz for UTD, LTD, NTD
%
% Implements the exact heat conduction series formulation from Javaheri & Eslami (2002).
% Exports to PNG (600 dpi), PDF, and FIG.

    if ~exist('output_dir', 'var') || isempty(output_dir)
        script_dir = fileparts(mfilename('fullpath'));
        project_root = fileparts(script_dir);
        if isempty(project_root), project_root = pwd; end
        output_dir = fullfile(project_root, 'results');
    end
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end

    % Material properties: Al / Alumina
    mat.K_m = 204.0;  % W/m-K (Metal - bottom, z = -h/2)
    mat.K_c = 10.4;   % W/m-K (Ceramic - top, z = +h/2)
    gamma = (mat.K_c - mat.K_m) / mat.K_m;

    % Thickness coordinate
    zh = linspace(-0.5, 0.5, 201);
    eta = zh + 0.5; % normalized 0 to 1

    % Setup Figure
    fig = figure('Name', 'Figure 7: Thermal Distribution Comparison', ...
                 'Color', 'w', 'Units', 'inches', 'Position', [1, 1, 10, 8.5]);

    % Define consistent color palette
    c_blue   = [0.00, 0.45, 0.74];
    c_red    = [0.85, 0.33, 0.10];
    k_vals   = [0.2, 0.5, 1.0, 2.0, 5.0, 10.0];
    colors_k = [
        0.49, 0.18, 0.56; % Purple (k=0.2)
        0.93, 0.69, 0.13; % Yellow-Orange (k=0.5)
        0.47, 0.67, 0.19; % Green (k=1)
        0.30, 0.75, 0.93; % Cyan (k=2)
        0.64, 0.08, 0.18; % Maroon (k=5)
        0.10, 0.10, 0.10  % Black (k=10)
    ];

    % -------------------------------------------------------------
    % (a) UTD Profile
    % -------------------------------------------------------------
    subplot(2, 2, 1);
    plot(ones(size(zh)), zh, 'LineWidth', 2.2, 'Color', c_blue);
    grid on; box on;
    set(gca, 'FontSize', 11, 'LineWidth', 1.0, 'GridAlpha', 0.25);
    xlabel('Normalized Temperature Rise $\Delta T(z)/\Delta T$', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel('Normalized Thickness $z/h$', 'Interpreter', 'latex', 'FontSize', 11);
    title('(a) Uniform Temperature Distribution (UTD)', 'FontWeight', 'bold', 'FontSize', 12);
    xlim([0, 1.2]); ylim([-0.5, 0.5]);
    text(0.55, 0.0, '$\Delta T(z) = \mathrm{constant}$', 'Interpreter', 'latex', ...
        'FontSize', 11, 'Color', c_blue, 'BackgroundColor', 'w', 'Margin', 2);

    % -------------------------------------------------------------
    % (b) LTD Profile
    % -------------------------------------------------------------
    subplot(2, 2, 2);
    plot(eta, zh, 'LineWidth', 2.2, 'Color', c_red);
    grid on; box on;
    set(gca, 'FontSize', 11, 'LineWidth', 1.0, 'GridAlpha', 0.25);
    xlabel('Normalized Temperature Rise $\Delta T(z)/\Delta T$', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel('Normalized Thickness $z/h$', 'Interpreter', 'latex', 'FontSize', 11);
    title('(b) Linear Temperature Distribution (LTD)', 'FontWeight', 'bold', 'FontSize', 12);
    xlim([0, 1.05]); ylim([-0.5, 0.5]);
    text(0.35, -0.15, '$\Delta T(z) = \left(\frac{z}{h} + \frac{1}{2}\right) \Delta T$', ...
        'Interpreter', 'latex', 'FontSize', 11, 'Color', c_red, 'BackgroundColor', 'w', 'Margin', 2);

    % -------------------------------------------------------------
    % (c) NTD Profile (Nonlinear 1D steady-state conduction)
    % -------------------------------------------------------------
    subplot(2, 2, 3);
    hold on;
    p_vec = (0:5)';
    legend_entries_c = cell(numel(k_vals), 1);
    for idx = 1:numel(k_vals)
        k = k_vals(idx);
        c_p = ((-gamma).^p_vec) ./ (p_vec * k + 1);
        C = sum(c_p);

        % Series calculation for each eta point
        T_ntd = zeros(size(eta));
        for i_eta = 1:numel(eta)
            T_ntd(i_eta) = sum(c_p .* (eta(i_eta) .^ (p_vec * k + 1))) / C;
        end
        plot(T_ntd, zh, 'LineWidth', 1.8, 'Color', colors_k(idx, :));
        legend_entries_c{idx} = sprintf('k = %.1f', k);
    end
    grid on; box on;
    set(gca, 'FontSize', 11, 'LineWidth', 1.0, 'GridAlpha', 0.25);
    xlabel('Normalized Temperature Rise $\Delta T(z)/\Delta T$', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel('Normalized Thickness $z/h$', 'Interpreter', 'latex', 'FontSize', 11);
    title('(c) Nonlinear Conduction Profile (NTD)', 'FontWeight', 'bold', 'FontSize', 12);
    xlim([0, 1.05]); ylim([-0.5, 0.5]);
    legend(legend_entries_c, 'Location', 'southeast', 'FontSize', 9, 'Box', 'on');

    % -------------------------------------------------------------
    % (d) Through-Thickness Thermal Gradient dT/dz
    % -------------------------------------------------------------
    subplot(2, 2, 4);
    hold on;

    % UTD gradient = 0
    plot(zeros(size(zh)), zh, '--', 'LineWidth', 2.0, 'Color', c_blue, 'DisplayName', 'UTD (dT/dz = 0)');

    % LTD gradient = 1 (normalized by DeltaT/h)
    plot(ones(size(zh)), zh, '-.', 'LineWidth', 2.0, 'Color', c_red, 'DisplayName', 'LTD (Normalized = 1)');

    % NTD gradient: d(DeltaT)/dz * (h / DeltaT) = (1/C) * sum((-gamma)^p * eta^(pk))
    ntd_grad_k = [0.5, 1.0, 2.0, 5.0];
    grad_colors = [0.93, 0.69, 0.13; 0.47, 0.67, 0.19; 0.30, 0.75, 0.93; 0.64, 0.08, 0.18];
    for idx = 1:numel(ntd_grad_k)
        k = ntd_grad_k(idx);
        c_p = ((-gamma).^p_vec) ./ (p_vec * k + 1);
        C = sum(c_p);

        dT_dz_norm = zeros(size(eta));
        for i_eta = 1:numel(eta)
            % Derivative of sum(c_p * eta^(pk+1)) with respect to eta
            % c_p * (pk + 1) = (-gamma)^p
            dT_dz_norm(i_eta) = sum(((-gamma).^p_vec) .* (eta(i_eta) .^ (p_vec * k))) / C;
        end
        plot(dT_dz_norm, zh, 'LineWidth', 1.8, 'Color', grad_colors(idx, :), ...
             'DisplayName', sprintf('NTD (k = %.1f)', k));
    end

    grid on; box on;
    set(gca, 'FontSize', 11, 'LineWidth', 1.0, 'GridAlpha', 0.25);
    xlabel('Normalized Thermal Gradient $\frac{h}{\Delta T}\frac{\mathrm{d}T}{\mathrm{d}z}$', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel('Normalized Thickness $z/h$', 'Interpreter', 'latex', 'FontSize', 11);
    title('(d) Through-Thickness Thermal Gradient dT/dz', 'FontWeight', 'bold', 'FontSize', 12);
    xlim([-0.2, 5.5]); ylim([-0.5, 0.5]);
    legend('Location', 'northeast', 'FontSize', 8.5, 'Box', 'on');

    % Tight layout adjustment
    sgtitle('Figure 7: Comparison of Thermal Loading Profiles and Gradients (Al/Alumina)', ...
            'FontSize', 14, 'FontWeight', 'bold');

    % Export to 3 formats: PNG 600 dpi, PDF, FIG
    png_file = fullfile(output_dir, 'Figure7_Thermal_Distributions.png');
    pdf_file = fullfile(output_dir, 'Figure7_Thermal_Distributions.pdf');
    fig_file = fullfile(output_dir, 'Figure7_Thermal_Distributions.fig');

    print(fig, png_file, '-dpng', '-r600');
    try
        exportgraphics(fig, pdf_file, 'ContentType', 'vector');
    catch
        print(fig, pdf_file, '-dpdf');
    end
    savefig(fig, fig_file);

    fprintf('Exported Figure 7:\n  %s\n  %s\n  %s\n', png_file, pdf_file, fig_file);
end
