# Numerical Experiments

This directory contains all code required to reproduce the numerical
experiments. First, you need to install Julia, e.g., by downloading
the binaries from the [download page](https://julialang.org/downloads/).
The numerical experiments were performed using Julia v1.11.2.

The experiments are structured in different directories each consisting of
several scripts creating the figures displayed in the article. The following
list describes which script creates which figure(s) or tables and the names
of the resulting .pdf files:

* Figure 1: `basic_plots/bathymetry.jl` &rarr; `bathymetry.pdf`
* Figure 2: `basic_plots/dispersion_relations.jl` &rarr; `dispersion_relations.pdf`
* Figure 3: `soliton_BBM_BBM/convergence_order.jl` &rarr; `soliton_BBM_BBM_convergence_orders.pdf`
* Figures 4, 5: `soliton_BBM_BBM/baseline_vs_relaxation.jl` &rarr; `soliton_BBM_BBM_invariants.pdf`, `soliton_BBM_BBM_errors.pdf`
* Figure 6: `soliton_BBM_BBM/different_stencils.jl` &rarr; `soliton_BBM_BBM_errors_stencils.pdf`
* Figure 7: `manufactured_solution/convergence_order.jl` &rarr; `manufactured_solution_convergence_orders.pdf`
* Figure 8: `manufactured_solution/convergence_order_reflecting.jl` &rarr; `manufactured_solution_convergence_orders_reflecting.pdf`
* Figure 9: `two_waves/baseline_vs_relaxation_BBM_BBM.jl` &rarr; `two_waves_BBM_BBM_invariants.pdf`
* Figure 10: `two_waves/baseline_vs_relaxation_Svaerd_Kalisch.jl` &rarr; `two_waves_Svaerd_Kalisch_invariants.pdf`
* Figure 11: `traveling_wave/traveling_waves.jl` &rarr; `traveling_waves.pdf`
* Figure 12: `dingemans/solution_different_equations.jl` &rarr; `dingemans_solution_time_snapshots.pdf`
* Figure 13: `dingemans/solution_different_order.jl` &rarr; `dingemans_waterheight_at_x_accuracy_order_Svaerd_Kalisch.pdf`
* Figure 14: `dingemans/solution_different_solver_types.jl` &rarr; `dingemans_waterheight_at_x_solver_types.pdf`
* Figures 15, 16: `dingemans/solution_upwind.jl` &rarr; `dingemans_invariants_ec_ed.pdf`, `dingemans_waterheight_at_x_ec_ed.pdf`
* Figure 17: `dingemans/solution_upwind_order_6.jl` &rarr; `dingemans_waterheight_at_x_order_6_upwind.pdf`
* Figure 18: `dingemans/solution_BBM_BBM_order_6.jl` &rarr; `dingemans_waterheight_at_x_order_6_BBM_BBM_upwind.pdf`
* Table 2: `well_balancedness/table_well_balanced_error.jl`

The resulting figures are then saved as .pdf files in a new directory `out`
inside the folder of this `README.md`. The table (Table 2) is printed to the screen as $\LaTeX$ code.

In order to execute a script, you can run the following command in this folder:

```bash
julia path_to/file_name.jl
```

in a terminal. To execute the first script from the list above, e.g.,
execute

```bash
julia basic_plots/bathymetry.jl
```

Alternatively, you can `include` the file from the Julia REPL, but in this case you need to restart Julia
when executing a script in another directory to load the correct environment.
In addition to scripts that save one or more figures or display a table, there are two scripts,
which compute and print the source terms that correspond to the manufactured
solutions used in Figures 7 and 8:

* manufactured solution for the BBM-BBM equations: `manufactured_solution/create_manufactured_solution_BBM_BBM.jl`
* manufactured solution for the Svärd-Kalisch equations: `manufactured_solution/create_manufactured_solution_Svaerd_Kalisch.jl`
