function [results, mesh_conv] = run_parametric_DeltaTcr_study(force_recompute)
% RUN_PARAMETRIC_DELTATCR_STUDY
% Executes systematic parametric studies for FGM thermal buckling FEA:
%   - a/h in [10, 20, 30, 40, 60, 80, 100, 120]
%   - n in [0, 0.5, 1, 2, 5, 10]
%   - e0 in [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6]
%   - porosity_type in {'even', 'uneven', 'sce', 'none'}
%   - thermal_distribution in {'UTD', 'LTD', 'NTD'}
%
% Caches all results to MAT and exports to CSV.
% Reuses completed cases unless force_recompute == true.

    if ~exist('force_recompute', 'var') || isempty(force_recompute)
        force_recompute = false;
    end

    % Determine paths
    script_dir   = fileparts(mfilename('fullpath'));  % website/post_processing/
    project_root = fileparts(script_dir);             % website/
    if isempty(project_root)
        project_root = pwd;
    end
    addpath(project_root);

    % Add math_model/ to path so core FEA solver functions are available
    math_model_dir = fullfile(fileparts(project_root), 'math_model');
    if exist(math_model_dir, 'dir')
        addpath(math_model_dir);
    end

    results_dir = fullfile(project_root, 'results');
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
    end

    mat_filepath = fullfile(results_dir, 'DeltaTcr_parametric_results.mat');
    csv_filepath = fullfile(results_dir, 'DeltaTcr_parametric_results.csv');

    % Material properties: Al / Alumina (Javaheri & Eslami 2002)
    mat.E_m     = 70e9;       mat.E_c     = 380e9;      % Pa
    mat.nu      = 0.3;
    mat.alpha_m = 23e-6;      mat.alpha_c = 7.4e-6;     % 1/K
    mat.K_m     = 204.0;      mat.K_c     = 10.4;       % W/m-K

    default_mesh = 8;
    a_len = 1.0;
    b_len = 1.0;

    % Load existing cache if present
    cache = containers.Map();
    results = [];
    mesh_conv = [];

    if exist(mat_filepath, 'file') && ~force_recompute
        fprintf('Loading existing cache from: %s\n', mat_filepath);
        cached_data = load(mat_filepath);
        if isfield(cached_data, 'results')
            results = cached_data.results;
            for i = 1:numel(results)
                key = make_case_key(results(i).a_over_h, results(i).n, results(i).e0, ...
                                    results(i).porosity_type, results(i).thermal_distribution, ...
                                    results(i).mesh);
                cache(key) = results(i);
            end
        end
        if isfield(cached_data, 'mesh_conv')
            mesh_conv = cached_data.mesh_conv;
        end
    end

    % Define all parameter grids
    ah_list_fig1 = [10, 20, 30, 40, 60, 80, 100, 120];
    n_list_fig2  = [0, 0.5, 1, 2, 5, 10];
    e0_list_fig3 = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6];
    n_list_fig4  = [0, 1, 5, 10];
    e0_list_fig6 = [0, 0.2, 0.4, 0.6];
    td_all       = {'UTD', 'LTD', 'NTD'};

    % Queue of cases to evaluate
    case_queue = [];

    % Figure 1 cases: a/h vs TD (n=1, e0=0.2, even)
    for ah = ah_list_fig1
        for td = td_all
            case_queue = [case_queue; struct('ah', ah, 'n', 1.0, 'e0', 0.2, 'por', 'even', 'td', td{1}, 'm', default_mesh)]; %#ok<AGROW>
        end
    end

    % Figure 2 cases: n vs TD (ah=100, e0=0.2, even)
    for n_val = n_list_fig2
        for td = td_all
            case_queue = [case_queue; struct('ah', 100, 'n', n_val, 'e0', 0.2, 'por', 'even', 'td', td{1}, 'm', default_mesh)]; %#ok<AGROW>
        end
    end

    % Figure 3 cases: e0 vs TD (ah=100, n=1, even)
    for e0_val = e0_list_fig3
        for td = td_all
            case_queue = [case_queue; struct('ah', 100, 'n', 1.0, 'e0', e0_val, 'por', 'even', 'td', td{1}, 'm', default_mesh)]; %#ok<AGROW>
        end
    end

    % Figure 4 cases: a/h vs n (e0=0.2, even, UTD)
    for ah = ah_list_fig1
        for n_val = n_list_fig4
            case_queue = [case_queue; struct('ah', ah, 'n', n_val, 'e0', 0.2, 'por', 'even', 'td', 'UTD', 'm', default_mesh)]; %#ok<AGROW>
        end
    end

    % Figure 5 cases: e0 vs n (ah=100, even, UTD)
    for e0_val = e0_list_fig3
        for n_val = n_list_fig4
            case_queue = [case_queue; struct('ah', 100, 'n', n_val, 'e0', e0_val, 'por', 'even', 'td', 'UTD', 'm', default_mesh)]; %#ok<AGROW>
        end
    end

    % Figure 6 cases: a/h vs e0 (n=1, even, UTD)
    for ah = ah_list_fig1
        for e0_val = e0_list_fig6
            case_queue = [case_queue; struct('ah', ah, 'n', 1.0, 'e0', e0_val, 'por', 'even', 'td', 'UTD', 'm', default_mesh)]; %#ok<AGROW>
        end
    end

    % Figure 8 (Comparative Configurations across UTD, LTD, NTD)
    % 1. Baseline: ah=100, n=1, e0=0.2, even (already queued)
    % 2. Pure Ceramic: ah=100, n=0, e0=0.2, even (already queued)
    % 3. Metal-Rich: ah=100, n=5, e0=0.2, even (already queued)
    % 4. Solid Plate: ah=100, n=1, e0=0, none
    for td = td_all
        case_queue = [case_queue; struct('ah', 100, 'n', 1.0, 'e0', 0.0, 'por', 'none', 'td', td{1}, 'm', default_mesh)]; %#ok<AGROW>
    end
    % 5. Uneven Porosity: ah=100, n=1, e0=0.2, uneven
    for td = td_all
        case_queue = [case_queue; struct('ah', 100, 'n', 1.0, 'e0', 0.2, 'por', 'uneven', 'td', td{1}, 'm', default_mesh)]; %#ok<AGROW>
    end
    % 6. SCE Porosity: ah=100, n=1, e0=0.2, sce
    for td = td_all
        case_queue = [case_queue; struct('ah', 100, 'n', 1.0, 'e0', 0.2, 'por', 'sce', 'td', td{1}, 'm', default_mesh)]; %#ok<AGROW>
    end
    % 7. Thick Plate: ah=20, n=1, e0=0.2, even (already queued)

    % Deduplicate case queue
    unique_keys = containers.Map();
    unique_queue = [];
    for i = 1:numel(case_queue)
        c = case_queue(i);
        k_str = make_case_key(c.ah, c.n, c.e0, c.por, c.td, c.m);
        if ~isKey(unique_keys, k_str)
            unique_keys(k_str) = true;
            unique_queue = [unique_queue; c]; %#ok<AGROW>
        end
    end

    total_cases = numel(unique_queue);
    fprintf('Total unique parametric cases to solve/verify: %d\n', total_cases);

    num_computed = 0;
    num_cached = 0;

    for idx = 1:total_cases
        c = unique_queue(idx);
        k_str = make_case_key(c.ah, c.n, c.e0, c.por, c.td, c.m);

        if isKey(cache, k_str) && ~force_recompute
            num_cached = num_cached + 1;
            continue;
        end

        % Execute FEA calculation
        h = a_len / c.ah;
        if ismember(upper(c.td), {'LTD', 'NTD', 'LTT', 'NTT'})
            Tm = 5.0;  % Javaheri (2002) bottom metal reference temperature (deg C)
        else
            Tm = 0.0;
        end

        DeltaT_cr = run_thermal_buckling_case(a_len, b_len, h, c.n, mat, 'SSSS', c.td, Tm, c.m, c.por, c.e0);

        % Recover lambda_cr eigenvalue
        if Tm == 0
            lambda_cr = DeltaT_cr;
        else
            phi_slope = compute_thermal_resultants(mat, h, c.n, c.td, c.por, c.e0);
            phi_const = compute_thermal_resultants(mat, h, c.n, 'UTD', c.por, c.e0);
            lambda_cr = DeltaT_cr + Tm * (phi_const / phi_slope);
        end

        res_item.a_over_h = c.ah;
        res_item.n = c.n;
        res_item.e0 = c.e0;
        res_item.porosity_type = c.por;
        res_item.thermal_distribution = upper(c.td);
        res_item.k = c.n;
        res_item.lambda_cr = lambda_cr;
        res_item.DeltaT_cr = DeltaT_cr;
        res_item.mesh = c.m;
        res_item.mode_number = 1;

        cache(k_str) = res_item;
        num_computed = num_computed + 1;

        if mod(num_computed, 10) == 0 || num_computed == total_cases
            fprintf('  Solved %d new cases (Cached: %d / %d)\n', num_computed, num_cached, total_cases);
        end
    end

    fprintf('Parametric cases ready: %d solved newly, %d loaded from cache.\n', num_computed, num_cached);

    % Mesh Convergence Study on Baseline Case
    % Baseline: a/h = 100, n = 1.0, e0 = 0.2, even, UTD
    mesh_list = [4, 6, 8, 10, 12];
    mesh_conv = [];
    fprintf('Executing mesh convergence study on baseline (ah=100, n=1, e0=0.2, even, UTD)...\n');
    for m_val = mesh_list
        h = a_len / 100;
        dt_conv = run_thermal_buckling_case(a_len, b_len, h, 1.0, mat, 'SSSS', 'UTD', 0, m_val, 'even', 0.2);
        conv_item.mesh = m_val;
        conv_item.dofs = (2 * m_val + 1)^2 * 5; % Q8 5-DOF grid DOFs approximation
        conv_item.DeltaT_cr = dt_conv;
        mesh_conv = [mesh_conv; conv_item]; %#ok<AGROW>
    end

    % Convert cache to struct array
    all_keys = keys(cache);
    if isempty(all_keys)
        results = [];
    else
        first_item = cache(all_keys{1});
        results = repmat(first_item, numel(all_keys), 1);
        for i = 1:numel(all_keys)
            results(i) = cache(all_keys{i});
        end
    end

    % Save MAT and CSV files
    save(mat_filepath, 'results', 'mesh_conv');
    fprintf('Saved MAT file: %s\n', mat_filepath);

    % Export CSV
    tbl = struct2table(results);
    % Reorder table columns nicely
    col_order = {'a_over_h', 'n', 'e0', 'porosity_type', 'thermal_distribution', 'k', 'lambda_cr', 'DeltaT_cr', 'mesh', 'mode_number'};
    tbl = tbl(:, col_order);
    writetable(tbl, csv_filepath);
    fprintf('Saved CSV file: %s\n', csv_filepath);
end

function k_str = make_case_key(ah, n, e0, por, td, m)
    k_str = sprintf('ah_%.2f_n_%.2f_e0_%.2f_por_%s_td_%s_m_%d', ...
        ah, n, e0, lower(char(por)), upper(char(td)), m);
end
