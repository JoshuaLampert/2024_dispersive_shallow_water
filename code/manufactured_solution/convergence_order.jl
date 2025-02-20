# Setup packages
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using DispersiveShallowWater
using Plots
using LaTeXStrings

const EXAMPLES_DIR = "elixirs"
const OUT = "out/"
ispath(OUT) || mkpath(OUT)

function convergence_plot!(p, subplot, tspan, example_path)
     accuracy_orders = [2, 4, 6, 8]
     iters = [4, 4, 4, 3]
     initial_Ns = [32, 32, 32, 32]

     all_Ns = minimum(initial_Ns) * 2 .^ (0:(maximum(iters) - 1))

     linewidth = 2
     markersize = 5
     markershapes = [:circle, :star5, :star8, :rtriangle]
     # for the Svärd-Kalisch equations with accuracy_order = 2 and N = 256 we need more than 100_000 iterations
     maxiters = 200_000

     for i in 1:length(accuracy_orders)
          Ns = initial_Ns[i] * 2 .^ (0:(iters[i] - 1))
          _, errormatrix = convergence_test(example_path, iters[i]; N = initial_Ns[i], tspan = tspan,
                                            accuracy_order = accuracy_orders[i], abstol = 1e-14,
                                            reltol = 1e-14, maxiters = maxiters)
          # Use sum over all L^2-errors for all variables, i.e. ||η - η_ana||_2 + ||v - v_ana||_2
          l2_err = sum(errormatrix[:l2], dims = 2)
          eocs = log.(l2_err[2:end] ./ l2_err[1:(end - 1)]) ./ log(0.5)
          eoc_mean = round(sum(eocs) / length(eocs), digits = 2)
          plot!(p, Ns, l2_err, label = "p = $(accuracy_orders[i]), EOC: $eoc_mean",
                markershape = markershapes[i], linewidth = linewidth, markersize = markersize,
                subplot = subplot)
     end
     xticks!(p, all_Ns, string.(all_Ns))
end

p = plot(layout = (1, 2), label = :none, xscale = :log2, yscale = :log10, xlabel = "N", ylim = (1e-12, 1e-1),
         ylabel = L"\Vert\eta - \eta_{ana}\Vert_2 + \Vert v - v_{ana}\Vert_2",
         legend = :bottomleft)

convergence_plot!(p, 1, (0.0, 1.0), joinpath(EXAMPLES_DIR, "bbm_bbm_variable_bathymetry_1d_manufactured.jl"))

convergence_plot!(p, 2, (0.0, 0.01), joinpath(EXAMPLES_DIR, "svaerd_kalisch_1d_manufactured.jl"))

plot!(p, size = (600, 300))
savefig(p, joinpath(OUT, "manufactured_solution_convergence_orders.pdf"))
