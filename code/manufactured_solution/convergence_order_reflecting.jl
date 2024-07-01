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
example_path = joinpath(EXAMPLES_DIR, "bbm_bbm_variable_bathymetry_1d_manufactured_reflecting.jl")

accuracy_orders = [2, 4, 6]
Ns = [[33, 65, 129, 257], [33, 65, 129, 257], [33, 65, 129, 257]]

all_Ns = unique(reduce(vcat, Ns))

linewidth = 2
markersize = 5
markershapes = [:circle, :star5, :star8, :rtriangle]

plot(layout = (1, 2), label = :none, xscale = :log2, yscale = :log10, xlabel = "N",
     legend = :bottomleft)
xticks!(all_Ns, string.(all_Ns))
ylims!((1e-6, 1e-1), subplot = 1)
ylims!((1e-10, 1e-1), subplot = 2)

for i in 1:length(accuracy_orders)
     _, errormatrix = convergence_test(example_path, Ns[i]; tspan = (0.0, 1.0),
                                       accuracy_order = accuracy_orders[i], abstol = 1e-14,
                                       reltol = 1e-14)
     l2_err = errormatrix[:l2]
     eocs_eta = log.(l2_err[2:end, 1] ./ l2_err[1:(end - 1), 1]) ./ log.(Ns[i][1:(end - 1)] ./ Ns[i][2:end])
     eocs_v = log.(l2_err[2:end, 2] ./ l2_err[1:(end - 1), 2]) ./ log.(Ns[i][1:(end - 1)] ./ Ns[i][2:end])
     eoc_mean_eta = round(sum(eocs_eta) / length(eocs_eta), digits = 2)
     eoc_mean_v = round(sum(eocs_v) / length(eocs_v), digits = 2)
     plot!(Ns[i], l2_err[:, 1], label = "p = $(accuracy_orders[i]), EOC: $eoc_mean_eta",
           markershape = markershapes[i], linewidth = linewidth, markersize = markersize,
           subplot = 1, ylabel = L"\Vert\eta - \eta_{ana}\Vert_2")
     plot!(Ns[i], l2_err[:, 2], label = "p = $(accuracy_orders[i]), EOC: $eoc_mean_v",
           markershape = markershapes[i], linewidth = linewidth, markersize = markersize,
           subplot = 2, ylabel = L"\Vert v - v_{ana}\Vert_2")
end

savefig(joinpath(OUT, "manufactured_solution_convergence_orders_reflecting.pdf"))
