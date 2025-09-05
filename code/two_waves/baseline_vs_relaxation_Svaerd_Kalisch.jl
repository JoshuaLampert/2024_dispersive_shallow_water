import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using DispersiveShallowWater
using Plots

const OUT = "out/"
ispath(OUT) || mkpath(OUT)
const EXAMPLES_DIR = joinpath(@__DIR__, "elixirs")

linewidth = 2
linestyles = [:dash, :dot]

g = 9.81
xmin = -1.0
xmax = 1.0
tspan = (0.0, 1.0)
N = 512
accuracy_order = 8

# baseline
trixi_include(joinpath(EXAMPLES_DIR, "svaerd_kalisch_1d_two_waves_reflecting.jl"),
              gravity_constant = g, coordinates_min = xmin,
              coordinates_max = xmax, tspan = tspan, N = N,
              accuracy_order = accuracy_order)
plot(analysis_callback, title = "", label_extension = "baseline",
     linestyle = :solid, seriescolors = 1,
     linewidth = linewidth, layout = 2, subplot = 1, exclude = (:entropy, :entropy_modified))
plot!(analysis_callback, title = "", label_extension = "baseline",
     linestyle = :solid, seriescolors = 1,
     linewidth = linewidth, layout = 2, subplot = 2, exclude = (:waterheight_total, :entropy))

# relaxation
trixi_include(joinpath(EXAMPLES_DIR, "svaerd_kalisch_1d_two_waves_reflecting_relaxation.jl"),
              gravity_constant = g, coordinates_min = xmin,
              coordinates_max = xmax, tspan = tspan, N = N,
              accuracy_order = accuracy_order)
plot!(analysis_callback, title = "", label_extension = "relaxation",
      linestyle = :dot, seriescolor = 2,
      linewidth = linewidth, subplot = 1, exclude = (:entropy, :entropy_modified))
plot!(analysis_callback, title = "", label_extension = "relaxation",
      linestyle = :dot, seriescolor = 2,
      linewidth = linewidth, layout = 2, subplot = 2, exclude = (:waterheight_total, :entropy))

plot!(size = (600, 250), bottom_margin = 3 * Plots.mm)
savefig(joinpath(OUT, "two_waves_Svaerd_Kalisch_invariants.pdf"))
