function plot_DeltaTcr_results(results, output_dir)
% PLOT_DELTATCR_RESULTS Generates publication-quality parametric figures:
%   - Figure 1: DeltaT_cr vs. a/h (n = 1, e0 = 0.2, Even; UTD, LTD, NTD)
%   - Figure 2: DeltaT_cr vs. n (a/h = 100, e0 = 0.2, Even; UTD, LTD, NTD)
%   - Figure 3: DeltaT_cr vs. e0 (a/h = 100, n = 1, Even; UTD, LTD, NTD)
%   - Figure 4: DeltaT_cr vs. a/h for Different n (e0 = 0.2, Even, UTD)
%   - Figure 5: DeltaT_cr vs. e0 for Different n (a/h = 100, Even, UTD)
%   - Figure 6: DeltaT_cr vs. a/h for Different Porosities (n = 1, Even, UTD)
%   - Figure 8: Categorical Comparison across Configurations (Section J)
%
% Exports each figure in PNG (600 dpi), PDF, and FIG.

    if ~exist('output_dir', 'var') || isempty(output_dir)
        script_dir = fileparts(mfilename('fullpath'));
        project_root = fileparts(script_dir);
        if isempty(project_root), project_root = pwd; end
        output_dir = fullfile(project_root, 'results');
    end
    if ~exist(output_dir, 'dir'), mkdir(output_dir); end

    if isempty(results)
        mat_path = fullfile(output_dir, 'DeltaTcr_parametric_results.mat');
        if exist(mat_path, 'file')
            d = load(mat_path);
            results = d.results;
        else
            error('Results structure or MAT file not found.');
        end
    end

    % Styling constants
    c_utd = [0.00, 0.45, 0.74];  % Deep Blue
    c_ltd = [0.85, 0.33, 0.10];  % Crimson Red
    c_ntd = [0.12, 0.65, 0.28];  % Emerald Green

    c_series = [
        0.00, 0.45, 0.74;  % Blue
        0.85, 0.33, 0.10;  % Orange/Red
        0.47, 0.67, 0.19;  % Green
        0.49, 0.18, 0.56;  % Purple
    ];

    % =========================================================================
    % FIGURE 1: DeltaT_cr vs. a/h (n = 1, e0 = 0.2, Even)
    % =========================================================================
    fig1 = figure('Name', 'Figure 1: DeltaT_cr vs a/h', 'Color', 'w', ...
                  'Units', 'inches', 'Position', [1, 1, 7.5, 5.5]);
    ah_f1 = [10, 20, 30, 40, 60, 80, 100, 120];
    dt_utd_f1 = get_series(results, 'a_over_h', ah_f1, 1.0, 0.2, 'even', 'UTD');
    dt_ltd_f1 = get_series(results, 'a_over_h', ah_f1, 1.0, 0.2, 'even', 'LTD');
    dt_ntd_f1 = get_series(results, 'a_over_h', ah_f1, 1.0, 0.2, 'even', 'NTD');

    hold on;
    plot(ah_f1, dt_utd_f1, 'o-', 'LineWidth', 2.0, 'MarkerSize', 8, 'Color', c_utd, ...
         'MarkerFaceColor', c_utd, 'DisplayName', 'UTD (Uniform)');
    plot(ah_f1, dt_ltd_f1, 's--', 'LineWidth', 2.0, 'MarkerSize', 8, 'Color', c_ltd, ...
         'MarkerFaceColor', c_ltd, 'DisplayName', 'LTD (Linear)');
    plot(ah_f1, dt_ntd_f1, 'd:', 'LineWidth', 2.0, 'MarkerSize', 8, 'Color', c_ntd, ...
         'MarkerFaceColor', c_ntd, 'DisplayName', 'NTD (Nonlinear)');
    hold off;

    grid on; box on;
    set(gca, 'FontSize', 11, 'LineWidth', 1.0, 'GridAlpha', 0.25);
    xlabel('Slenderness ratio $a/h$', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel('$\Delta T_{\mathrm{cr}}$ [$^\circ\mathrm{C}$]', 'Interpreter', 'latex', 'FontSize', 12);
    title('Critical Buckling Temperature vs. a/h (n = 1, e0 = 0.2)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 11, 'Box', 'on');
    save_fig_formats(fig1, output_dir, 'Figure1_DeltaTcr_vs_ah');
    close(fig1);

    % =========================================================================
    % FIGURE 2: DeltaT_cr vs. n (a/h = 100, e0 = 0.2, Even)
    % =========================================================================
    fig2 = figure('Name', 'Figure 2: DeltaT_cr vs n', 'Color', 'w', ...
                  'Units', 'inches', 'Position', [1, 1, 7.5, 5.5]);
    n_f2 = [0, 0.5, 1, 2, 5, 10];
    dt_utd_f2 = get_series(results, 'n', n_f2, 100, 0.2, 'even', 'UTD');
    dt_ltd_f2 = get_series(results, 'n', n_f2, 100, 0.2, 'even', 'LTD');
    dt_ntd_f2 = get_series(results, 'n', n_f2, 100, 0.2, 'even', 'NTD');

    hold on;
    plot(n_f2, dt_utd_f2, 'o-', 'LineWidth', 2.0, 'MarkerSize', 8, 'Color', c_utd, ...
         'MarkerFaceColor', c_utd, 'DisplayName', 'UTD (Uniform)');
    plot(n_f2, dt_ltd_f2, 's--', 'LineWidth', 2.0, 'MarkerSize', 8, 'Color', c_ltd, ...
         'MarkerFaceColor', c_ltd, 'DisplayName', 'LTD (Linear)');
    plot(n_f2, dt_ntd_f2, 'd:', 'LineWidth', 2.0, 'MarkerSize', 8, 'Color', c_ntd, ...
         'MarkerFaceColor', c_ntd, 'DisplayName', 'NTD (Nonlinear)');
    hold off;

    grid on; box on;
    set(gca, 'FontSize', 11, 'LineWidth', 1.0, 'GridAlpha', 0.25);
    xlabel('Power-Law Gradation Index $n$', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel('$\Delta T_{\mathrm{cr}}$ [$^\circ\mathrm{C}$]', 'Interpreter', 'latex', 'FontSize', 12);
    title('Critical Buckling Temperature vs. Index n (a/h = 100, e0 = 0.2)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 11, 'Box', 'on');
    save_fig_formats(fig2, output_dir, 'Figure2_DeltaTcr_vs_n');
    close(fig2);

    % =========================================================================
    % FIGURE 3: DeltaT_cr vs. e0 (a/h = 100, n = 1, Even)
    % =========================================================================
    fig3 = figure('Name', 'Figure 3: DeltaT_cr vs e0', 'Color', 'w', ...
                  'Units', 'inches', 'Position', [1, 1, 7.5, 5.5]);
    e0_f3 = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6];
    dt_utd_f3 = get_series(results, 'e0', e0_f3, 100, 1.0, 'even', 'UTD');
    dt_ltd_f3 = get_series(results, 'e0', e0_f3, 100, 1.0, 'even', 'LTD');
    dt_ntd_f3 = get_series(results, 'e0', e0_f3, 100, 1.0, 'even', 'NTD');

    hold on;
    plot(e0_f3, dt_utd_f3, 'o-', 'LineWidth', 2.0, 'MarkerSize', 8, 'Color', c_utd, ...
         'MarkerFaceColor', c_utd, 'DisplayName', 'UTD (Uniform)');
    plot(e0_f3, dt_ltd_f3, 's--', 'LineWidth', 2.0, 'MarkerSize', 8, 'Color', c_ltd, ...
         'MarkerFaceColor', c_ltd, 'DisplayName', 'LTD (Linear)');
    plot(e0_f3, dt_ntd_f3, 'd:', 'LineWidth', 2.0, 'MarkerSize', 8, 'Color', c_ntd, ...
         'MarkerFaceColor', c_ntd, 'DisplayName', 'NTD (Nonlinear)');
    hold off;

    grid on; box on;
    set(gca, 'FontSize', 11, 'LineWidth', 1.0, 'GridAlpha', 0.25);
    xlabel('Porosity Volume Fraction $e_0$', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel('$\Delta T_{\mathrm{cr}}$ [$^\circ\mathrm{C}$]', 'Interpreter', 'latex', 'FontSize', 12);
    title('Critical Buckling Temperature vs. Porosity e0 (a/h = 100, n = 1)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 11, 'Box', 'on');
    save_fig_formats(fig3, output_dir, 'Figure3_DeltaTcr_vs_e0');
    close(fig3);

    % =========================================================================
    % FIGURE 4: DeltaT_cr vs. a/h for Different n (e0 = 0.2, Even, UTD)
    % =========================================================================
    fig4 = figure('Name', 'Figure 4: DeltaT_cr vs a/h for Different n', 'Color', 'w', ...
                  'Units', 'inches', 'Position', [1, 1, 7.5, 5.5]);
    ah_f4 = [10, 20, 30, 40, 60, 80, 100, 120];
    n_legend_f4 = {'Ceramic (n = 0)', 'Linear (n = 1)', 'Metal-Rich (n = 5)', 'Metal-Dominant (n = 10)'};
    n_vals_f4   = [0, 1, 5, 10];
    markers_f4  = {'o-', 's--', '^-.', 'd:'};

    hold on;
    for i = 1:numel(n_vals_f4)
        dt_val = get_series(results, 'a_over_h', ah_f4, n_vals_f4(i), 0.2, 'even', 'UTD');
        plot(ah_f4, dt_val, markers_f4{i}, 'LineWidth', 2.0, 'MarkerSize', 8, ...
             'Color', c_series(i, :), 'MarkerFaceColor', c_series(i, :), ...
             'DisplayName', n_legend_f4{i});
    end
    hold off;

    grid on; box on;
    set(gca, 'FontSize', 11, 'LineWidth', 1.0, 'GridAlpha', 0.25);
    xlabel('Slenderness ratio $a/h$', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel('$\Delta T_{\mathrm{cr}}$ [$^\circ\mathrm{C}$]', 'Interpreter', 'latex', 'FontSize', 12);
    title('Critical Buckling Temperature vs. a/h for Different n', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 11, 'Box', 'on');
    save_fig_formats(fig4, output_dir, 'Figure4_DeltaTcr_vs_ah_different_n');
    close(fig4);

    % =========================================================================
    % FIGURE 5: DeltaT_cr vs. e0 for Different n (a/h = 100, Even, UTD)
    % =========================================================================
    fig5 = figure('Name', 'Figure 5: DeltaT_cr vs e0 for Different n', 'Color', 'w', ...
                  'Units', 'inches', 'Position', [1, 1, 7.5, 5.5]);
    e0_f5 = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6];
    hold on;
    for i = 1:numel(n_vals_f4)
        dt_val = get_series(results, 'e0', e0_f5, 100, n_vals_f4(i), 'even', 'UTD');
        plot(e0_f5, dt_val, markers_f4{i}, 'LineWidth', 2.0, 'MarkerSize', 8, ...
             'Color', c_series(i, :), 'MarkerFaceColor', c_series(i, :), ...
             'DisplayName', n_legend_f4{i});
    end
    hold off;

    grid on; box on;
    set(gca, 'FontSize', 11, 'LineWidth', 1.0, 'GridAlpha', 0.25);
    xlabel('Porosity Volume Fraction $e_0$', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel('$\Delta T_{\mathrm{cr}}$ [$^\circ\mathrm{C}$]', 'Interpreter', 'latex', 'FontSize', 12);
    title('Critical Buckling Temperature vs. Porosity e0 for Different n', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 11, 'Box', 'on');
    save_fig_formats(fig5, output_dir, 'Figure5_DeltaTcr_vs_e0_different_n');
    close(fig5);

    % =========================================================================
    % FIGURE 6: DeltaT_cr vs. a/h for Different Porosities (n = 1, Even, UTD)
    % =========================================================================
    fig6 = figure('Name', 'Figure 6: DeltaT_cr vs a/h for Different Porosities', 'Color', 'w', ...
                  'Units', 'inches', 'Position', [1, 1, 7.5, 5.5]);
    ah_f6 = [10, 20, 30, 40, 60, 80, 100, 120];
    e0_legend_f6 = {'Solid Plate (e0 = 0)', 'Low Porosity (e0 = 0.2)', 'Med Porosity (e0 = 0.4)', 'High Porosity (e0 = 0.6)'};
    e0_vals_f6   = [0, 0.2, 0.4, 0.6];
    markers_f6   = {'o-', 's--', '^-.', 'd:'};

    hold on;
    for i = 1:numel(e0_vals_f6)
        dt_val = get_series(results, 'a_over_h', ah_f6, 1.0, e0_vals_f6(i), 'even', 'UTD');
        plot(ah_f6, dt_val, markers_f6{i}, 'LineWidth', 2.0, 'MarkerSize', 8, ...
             'Color', c_series(i, :), 'MarkerFaceColor', c_series(i, :), ...
             'DisplayName', e0_legend_f6{i});
    end
    hold off;

    grid on; box on;
    set(gca, 'FontSize', 11, 'LineWidth', 1.0, 'GridAlpha', 0.25);
    xlabel('Slenderness ratio $a/h$', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel('$\Delta T_{\mathrm{cr}}$ [$^\circ\mathrm{C}$]', 'Interpreter', 'latex', 'FontSize', 12);
    title('Critical Buckling Temperature vs. a/h for Different Porosities', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 11, 'Box', 'on');
    save_fig_formats(fig6, output_dir, 'Figure6_DeltaTcr_vs_ah_different_e0');
    close(fig6);

    % =========================================================================
    % FIGURE 8: Categorical Comparison across Configurations (Section J)
    % =========================================================================
    fig8 = figure('Name', 'Figure 8: Comparative Assessment Across Configurations', ...
                  'Color', 'w', 'Units', 'inches', 'Position', [1, 1, 10, 6.0]);

    % Define the 7 test scenarios:
    % 1. Baseline: ah=100, n=1, e0=0.2, even
    % 2. Pure Ceramic: ah=100, n=0, e0=0.2, even
    % 3. Metal-Rich: ah=100, n=5, e0=0.2, even
    % 4. Solid Plate: ah=100, n=1, e0=0, none
    % 5. Uneven Porosity: ah=100, n=1, e0=0.2, uneven
    % 6. SCE Porosity: ah=100, n=1, e0=0.2, sce
    % 7. Thick Plate: ah=20, n=1, e0=0.2, even

    cfg_names = {
        'Baseline (a/h=100, n=1)', ...
        'Pure Ceramic (n=0)', ...
        'Metal-Rich (n=5)', ...
        'Solid Plate (e0=0)', ...
        'Uneven Porosity', ...
        'SCE Porosity', ...
        'Thick Plate (a/h=20)'
    };

    scenarios = [
        struct('ah', 100, 'n', 1.0, 'e0', 0.2, 'por', 'even');
        struct('ah', 100, 'n', 0.0, 'e0', 0.2, 'por', 'even');
        struct('ah', 100, 'n', 5.0, 'e0', 0.2, 'por', 'even');
        struct('ah', 100, 'n', 1.0, 'e0', 0.0, 'por', 'none');
        struct('ah', 100, 'n', 1.0, 'e0', 0.2, 'por', 'uneven');
        struct('ah', 100, 'n', 1.0, 'e0', 0.2, 'por', 'sce');
        struct('ah', 20,  'n', 1.0, 'e0', 0.2, 'por', 'even');
    ];

    num_scenarios = numel(scenarios);
    data_utd = zeros(num_scenarios, 1);
    data_ltd = zeros(num_scenarios, 1);
    data_ntd = zeros(num_scenarios, 1);

    for s_i = 1:num_scenarios
        sc = scenarios(s_i);
        data_utd(s_i) = find_val(results, sc.ah, sc.n, sc.e0, sc.por, 'UTD');
        data_ltd(s_i) = find_val(results, sc.ah, sc.n, sc.e0, sc.por, 'LTD');
        data_ntd(s_i) = find_val(results, sc.ah, sc.n, sc.e0, sc.por, 'NTD');
    end

    bar_data = [data_utd, data_ltd, data_ntd];
    b = bar(bar_data, 'grouped');
    b(1).FaceColor = c_utd;
    b(2).FaceColor = c_ltd;
    b(3).FaceColor = c_ntd;

    grid on; box on;
    set(gca, 'FontSize', 10.5, 'LineWidth', 1.0, 'GridAlpha', 0.25);
    set(gca, 'XTick', 1:num_scenarios, 'XTickLabel', cfg_names);
    xtickangle(20);
    set(gca, 'Position', [0.10, 0.16, 0.86, 0.76]);
    ylabel('$\Delta T_{\mathrm{cr}}$ [$^\circ\mathrm{C}$]', 'Interpreter', 'latex', 'FontSize', 12);
    title('Comparative Assessment of Critical Buckling Temperature Across Configurations', ...
          'FontSize', 13, 'FontWeight', 'bold');
    legend({'UTD (Uniform)', 'LTD (Linear)', 'NTD (Nonlinear)'}, 'Location', 'northwest', 'FontSize', 11, 'Box', 'on');

    % Set log scale or annotations to clearly display both thin and thick plates
    set(gca, 'YScale', 'log');
    ylabel('$\Delta T_{\mathrm{cr}}$ [$^\circ\mathrm{C}$] (Log Scale)', 'Interpreter', 'latex', 'FontSize', 12);

    save_fig_formats(fig8, output_dir, 'Figure8_Comparative_Configurations');
    close(fig8);

    fprintf('All parametric plots (Figures 1-6, 8) generated and exported.\n');
end

% -------------------------------------------------------------------------
% Helper: Extract series of DeltaT_cr across specified parameter
% -------------------------------------------------------------------------
function vals = get_series(results, sweep_param, sweep_vals, fixed_1, fixed_2, por_val, td_val)
    vals = zeros(size(sweep_vals));
    for i = 1:numel(sweep_vals)
        switch sweep_param
            case 'a_over_h'
                vals(i) = find_val(results, sweep_vals(i), fixed_1, fixed_2, por_val, td_val);
            case 'n'
                vals(i) = find_val(results, fixed_1, sweep_vals(i), fixed_2, por_val, td_val);
            case 'e0'
                vals(i) = find_val(results, fixed_1, fixed_2, sweep_vals(i), por_val, td_val);
        end
    end
end

% -------------------------------------------------------------------------
% Helper: Look up specific case in results struct array
% -------------------------------------------------------------------------
function val = find_val(results, ah, n, e0, por, td)
    match = false;
    val = NaN;
    for i = 1:numel(results)
        r = results(i);
        if abs(r.a_over_h - ah) < 1e-4 && ...
           abs(r.n - n) < 1e-4 && ...
           abs(r.e0 - e0) < 1e-4 && ...
           (strcmpi(r.porosity_type, por) || (e0 == 0 && (strcmpi(r.porosity_type, 'none') || strcmpi(r.porosity_type, 'even')))) && ...
           strcmpi(r.thermal_distribution, td)
            val = r.DeltaT_cr;
            match = true;
            break;
        end
    end
    if ~match
        error('Result not found for case: ah=%.1f, n=%.1f, e0=%.1f, por=%s, td=%s', ...
            ah, n, e0, por, td);
    end
end

% -------------------------------------------------------------------------
% Helper: Save figure in 3 formats (PNG 600dpi, PDF, FIG)
% -------------------------------------------------------------------------
function save_fig_formats(fig, output_dir, base_name)
    png_file = fullfile(output_dir, [base_name, '.png']);
    pdf_file = fullfile(output_dir, [base_name, '.pdf']);
    fig_file = fullfile(output_dir, [base_name, '.fig']);

    print(fig, png_file, '-dpng', '-r600');
    try
        exportgraphics(fig, pdf_file, 'ContentType', 'vector');
    catch
        print(fig, pdf_file, '-dpdf');
    end
    savefig(fig, fig_file);
    fprintf('Saved: %s (.png, .pdf, .fig)\n', base_name);
end
