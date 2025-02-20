# Setup packages
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using DispersiveShallowWater
using Plots
using LaTeXStrings

const OUT = "out/"
ispath(OUT) || mkpath(OUT)
const EXAMPLES_DIR_BBMBBM = joinpath(examples_dir(), "bbm_bbm_1d")

tspan = (0.0, 10.0)
accuracy_orders = [2, 4, 6, 8]
iters = [4, 4, 4, 3]
initial_Ns = [128, 128, 128, 128]

all_Ns = minimum(initial_Ns) * 2 .^ (0:(maximum(iters) - 1))

linewidth = 2
markersize = 5
markershapes = [:circle, :star5, :star8, :rtriangle]
plot(label = :none, xscale = :log2, yscale = :log10, xlabel = "N", ylim = (1e-5, 1e2),
     ylabel = L"\Vert\eta - \eta_{ana}\Vert_2 + \Vert v - v_{ana}\Vert_2",
     legend = :bottomleft, layout = 2)

# left subplot: baseline
for i in 1:length(accuracy_orders)
    Ns = initial_Ns[i] * 2 .^ (0:(iters[i] - 1))
    _, errormatrix = convergence_test(joinpath(EXAMPLES_DIR_BBMBBM,
                                               "bbm_bbm_1d_basic.jl"),
                                      iters[i]; N = initial_Ns[i], tspan = tspan,
                                      accuracy_order = accuracy_orders[i], abstol = 1e-14,
                                      reltol = 1e-14)
    # Use sum over all L^2-errors for all variables, i.e. ||η - η_ana||_2 + ||v - v_ana||_2
    l2_err = sum(errormatrix[:l2], dims = 2)
    eocs = log.(l2_err[2:end] ./ l2_err[1:(end - 1)]) ./ log(0.5)
    eoc_mean = round(sum(eocs) / length(eocs), digits = 2)
    plot!(Ns, l2_err, label = "p = $(accuracy_orders[i]), EOC: $eoc_mean",
          markershape = markershapes[i], linewidth = linewidth, markersize = markersize,
          subplot = 1)
end

# right subplot: relaxation
for i in 1:length(accuracy_orders)
    Ns = initial_Ns[i] * 2 .^ (0:(iters[i] - 1))
    _, errormatrix = convergence_test(joinpath(EXAMPLES_DIR_BBMBBM,
                                               "bbm_bbm_1d_relaxation.jl"),
                                      iters[i]; N = initial_Ns[i], tspan = tspan,
                                      accuracy_order = accuracy_orders[i], abstol = 1e-14,
                                      reltol = 1e-14)
    # Use sum over all L^2-errors for all variables, i.e. ||η - η_ana||_2 + ||v - v_ana||_2
    l2_err = sum(errormatrix[:l2], dims = 2)
    eocs = log.(l2_err[2:end] ./ l2_err[1:(end - 1)]) ./ log(0.5)
    eoc_mean = round(sum(eocs) / length(eocs), digits = 2)
    plot!(Ns, l2_err, label = "p = $(accuracy_orders[i]), EOC: $eoc_mean",
          markershape = markershapes[i], linewidth = linewidth, markersize = markersize,
          subplot = 2)
end
xticks!(all_Ns, string.(all_Ns))
plot!(size = (600, 300))
savefig(joinpath(OUT, "soliton_BBM_BBM_convergence_orders.pdf"))
