# Numerical Experiments

This directory contains all code required to reproduce the numerical
experiments. First, you need to install Julia, e.g., by downloading
the binaries from the [download page](https://julialang.org/downloads/).
The numerical experiments were performed using Julia v1.10.1.

The experiments are structured in different directories each consisting of
several scripts creating the figures displayed in the article. The following
list describes which script creates which figure(s) and the names of the resulting
.pdf files:

* Figure 1: `basic_plots/bathymetry.jl` -> `bathymetry.pdf`
* Figure 2: `basic_plots/dispersion_relations.jl` -> `dispersion_relations.pdf`
* Figure 3: `basic_plots/dispersion_relations_long.jl` -> `dispersion_relations_long.pdf`
* Figure 4: `soliton_BBM_BBM/convergence_order.jl` -> `soliton_BBM_BBM_convergence_orders.pdf`
* Figures 5, 6, 7: `soliton_BBM_BBM/baseline_vs_relaxation.jl` -> `soliton_BBM_BBM_solution.pdf`, `soliton_BBM_BBM_invariants.pdf`, `soliton_BBM_BBM_errors.pdf`
* Figure 8: `soliton_BBM_BBM/different_stencils.jl` -> `soliton_BBM_BBM_errors_stencils.pdf`
* Figure 9: `manufactured_solution/convergence_order.jl` -> `manufactured_solution_convergence_order.pdf`
* Figure 10: `traveling_wave/solution_k_0_8.jl` -> `traveling_wave_0.8_set2.pdf`
* Figure 11: `traveling_wave/solution_k_5.jl` -> `traveling_wave_5_set2.pdf`
* Figure 12: `traveling_wave/solution_k_15.jl` -> `traveling_wave_15_sets2_and_3.pdf`
* Figure 13: `dingemans/solution_different_equations.jl` -> `dingemans_solution_time_snapshots.pdf`
* Figure 14: `dingemans/solution_different_order.jl` -> `dingemans_waterheight_at_x_accuracy_order_Svaerd_Kalisch.pdf`
* Figure 15: `dingemans/solution_different_solver_types.jl` -> `dingemans_waterheight_at_x_solver_types.pdf`
* Figures 16, 17: `dingemans/solution_upwind.jl` -> `dingemans_invariants_ec_ed.pdf`, `dingemans_waterheight_at_x_ec_ed.pdf`
* Figure 18: `solution_upwind_order_6.jl` -> `dingemans_waterheight_at_x_order_6_upwind.pdf`
* Figure 19: `solution_BBM_BBM_order_6.jl` -> `dingemans_waterheight_at_x_order_6_BBM_BBM.pdf`

The resulting figures are then saved as .pdf files in a new directory `out`
inside the folder of this `README.md`.

In order to execute a script, start Julia in this folder and execute

```julia
julia> include("path_to/file_name.jl")
```

in the Julia REPL. To execute the first script from the list above, e.g.,
execute

```julia
julia> include("basic_plots/bathymetry.jl")
```

In addition to scripts that save one or more figures, there are two scripts,
which compute and print the source terms that correspond to the manufactured
solutions used in Figure 9:

* manufactured solution for the BBM-BBM equations: `manufactured_solution/create_manufactured_solution_BBM_BBM.jl`
* manufactured solution for the Svärd-Kalisch equations: `manufactured_solution/create_manufactured_solution_Svaerd_Kalisch.jl`
