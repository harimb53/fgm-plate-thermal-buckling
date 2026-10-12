# FGM Plate Thermal Buckling — Website & Results

Standalone interactive visualization website + pre-computed parametric results
for the FGM Plate Thermal Buckling FEA study (Javaheri & Eslami, 2002).

## Structure

```
website/
├── index.html                     <- STANDALONE interactive website (open directly in browser)
├── fgm_viz_reference.json         <- Reference lookup data (used internally by HTML)
├── results/                       <- Pre-computed parametric study outputs
│   ├── Figure1_DeltaTcr_vs_ah.*   <- Figures 1-8 in PNG, PDF, FIG
│   ├── ...
│   ├── DeltaTcr_parametric_results.csv   <- Full dataset (tabular)
│   ├── DeltaTcr_parametric_results.mat   <- Full dataset (MATLAB)
│   └── validation_report.txt      <- Benchmark validation summary
└── post_processing/               <- MATLAB scripts to regenerate results
    ├── generate_all_DeltaTcr_figures.m   <- Master script: runs everything
    ├── run_parametric_DeltaTcr_study.m   <- Parametric FEA sweep
    ├── plot_DeltaTcr_results.m            <- Plot figures 1-6, 8
    └── plot_thermal_distributions.m       <- Plot figure 7
```

## Using the Website (No Installation Needed)

Simply open `index.html` in any modern browser:
- All data is embedded inline - no server required
- Works completely offline
- No dependencies on MATLAB or any other software

## GitHub Pages

This repository is ready to publish directly from the `main` branch root:

1. Open the repository's **Settings > Pages**.
2. Under **Build and deployment**, choose **Deploy from a branch**.
3. Select the `main` branch and `/ (root)` folder, then save.

GitHub will publish the site at `https://<username>.github.io/<repository>/`.

## Regenerating Results (Requires MATLAB + math_model/)

If you want to recompute the parametric study:

```matlab
% From MATLAB, navigate to the post_processing folder
cd path/to/website/post_processing

% Run the master script (auto-adds math_model/ to path)
generate_all_DeltaTcr_figures
```

NOTE: math_model/ must be at the same level as website/ (i.e., ../math_model/).
The scripts automatically add math_model/ to the MATLAB path.

## Reference

Javaheri, R., & Eslami, M. R. (2002). Thermal buckling of functionally graded plates
based on higher order theory. Journal of Thermal Stresses, 25(7), 603-625.
