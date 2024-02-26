# Setup packages
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using DispersiveShallowWater
using Plots
using LaTeXStrings

const OUT = "out/"
ispath(OUT) || mkpath(OUT)

function convergence_plot!(subplot, tspan, example_path)
     accuracy_orders = [2, 4, 6, 8]
     iters = [4, 4, 4, 3]
     initial_Ns = [32, 32, 32, 32]

     all_Ns = minimum(initial_Ns) * 2 .^ (0:(maximum(iters) - 1))

     linewidth = 2
     markersize = 5
     markershapes = [:circle, :star5, :star8, :rtriangle]

     for i in 1:length(accuracy_orders)
          Ns = initial_Ns[i] * 2 .^ (0:(iters[i] - 1))
          _, errormatrix = convergence_test(example_path, iters[i]; N = initial_Ns[i], tspan = tspan,
                                            accuracy_order = accuracy_orders[i], abstol = 1e-14,
                                            reltol = 1e-14)
          # Use sum over all L^2-errors for all variables, i.e. ||η - η_ana||_2 + ||v - v_ana||_2
          l2_err = sum(errormatrix[:l2], dims = 2)
          eocs = log.(l2_err[2:end] ./ l2_err[1:(end - 1)]) ./ log(0.5)
          eoc_mean = round(sum(eocs) / length(eocs), digits = 2)
          plot!(Ns, l2_err, label = "p = $(accuracy_orders[i]), EOC: $eoc_mean",
                markershape = markershapes[i], linewidth = linewidth, markersize = markersize,
                subplot = subplot)
     end
     xticks!(all_Ns, string.(all_Ns))
end

plot(layout = (1, 2), label = :none, xscale = :log2, yscale = :log10, xlabel = "N", ylim = (1e-12, 1e-1),
     ylabel = L"\Vert\eta - \eta_{ana}\Vert_2 + \Vert v - v_{ana}\Vert_2",
     legend = :bottomleft)

const EXAMPLES_DIR_BBM_BBM = joinpath(examples_dir(), "bbm_bbm_variable_bathymetry_1d")
convergence_plot!(1, (0.0, 1.0), joinpath(EXAMPLES_DIR_BBM_BBM, "bbm_bbm_variable_bathymetry_1d_manufactured.jl"))

const EXAMPLES_DIR_SVAERD_KALISCH = joinpath(examples_dir(), "svaerd_kalisch_1d")
convergence_plot!(2, (0.0, 0.01), joinpath(EXAMPLES_DIR_SVAERD_KALISCH, "svaerd_kalisch_1d_manufactured.jl"))

savefig(joinpath(OUT, "manufactured_solution_convergence_orders.pdf"))
