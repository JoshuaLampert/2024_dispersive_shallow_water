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

linewidth = 2
linestyles = [:dash, :dot]

g = 9.81
D = 2.0
c = 5 / 2 * sqrt(g * D)
xmin = -35.0
xmax = 35.0
tspan = (0.0, 50 * (xmax - xmin) / c)
N = 512
accuracy_order = 8

# baseline
trixi_include(joinpath(EXAMPLES_DIR_BBMBBM, "bbm_bbm_1d_basic.jl"),
              gravity_constant = g, D = D, coordinates_min = xmin,
              coordinates_max = xmax, tspan = tspan, N = N,
              accuracy_order = accuracy_order)
p1 = plot(analysis_callback, title = "", label_extension = "baseline",
          linestyles = [:solid :dash :dot],
          linewidth = linewidth, layout = 2, subplot = 1)
p2 = plot(analysis_callback, title = "", what = (:errors,),
          label_extension = "baseline", linestyle = linestyles[1],
          linewidth = linewidth, xscale = :log10, yscale = :log10,
          start_from = 2, # exclude first entry since it is 0, which is a problem for the loglog plot
          ylabel = L"\Vert\eta - \eta_{ana}\Vert_2 + \Vert v - v_{ana}\Vert_2",
          exclude = [:conservation_error], xlim = (0.1, 100.0), legend = :topleft)
p3 = plot(semi => sol, label = "baseline", plot_initial = true, plot_bathymetry = false,
          linestyle = linestyles[1], linewidth = linewidth, plot_title = "", title = "",
          ylims = [(-8, 3) (-1, 40)])
x = DispersiveShallowWater.grid(semi)
q = sol.u[end]
plot!(p3, x, q.x[1], inset = (1, bbox(0.11, 0.6, 0.35, 0.32)), subplot = 3,
      xlim = (-20, -10),
      ylim = (-0.05, 0.05), legend = nothing, linewidth = linewidth,
      linestyle = linestyles[1],
      color = 2,
      tickfontsize = 5, yticks = [0.04, 0.0, -0.04], xticks = [-20, -15, -10],
      plot_initial = true, plot_bathymetry = false, framestyle = :box)
q_exact = DispersiveShallowWater.compute_coefficients(initial_condition, tspan[2], semi)
plot!(p3, x, q_exact.x[1], subplot = 3, legend = nothing, linewidth = linewidth,
      linestyle = :solid, color = 1)

# relaxation
trixi_include(joinpath(EXAMPLES_DIR_BBMBBM, "bbm_bbm_1d_relaxation.jl"),
              gravity_constant = g, D = D, coordinates_min = xmin,
              coordinates_max = xmax, tspan = tspan, N = N,
              accuracy_order = accuracy_order)
plot!(p1, analysis_callback, title = "", label_extension = "relaxation",
      linestyles = [:solid :dash :dot],
      linewidth = linewidth, subplot = 2)
plot!(p2, analysis_callback, title = "", what = (:errors,),
      label_extension = "relaxation", linestyle = linestyles[2], linewidth = linewidth,
      ylabel = L"\Vert\eta - \eta_{ana}\Vert_2 + \Vert v - v_{ana}\Vert_2",
      start_from = 2, # exclude first entry since it is 0, which is a problem for the loglog plot
      exclude = [:conservation_error])
plot!(p3, semi => sol, plot_bathymetry = false, label = "relaxation",
      linestyle = linestyles[2],
      linewidth = linewidth, plot_title = "", title = "", color = 3)
x = DispersiveShallowWater.grid(semi)
q = sol.u[end]
plot!(p3, x, q.x[1], subplot = 3, legend = nothing, linewidth = linewidth,
      linestyle = linestyles[2], color = 3)

# Plot box
plot!(p3, [-20, -10], [-0.1, -0.1], color = :black, label = :none)
plot!(p3, [-20, -10], [0.1, 0.1], color = :black, label = :none)
plot!(p3, [-20, -20], [-0.1, 0.1], color = :black, label = :none)
plot!(p3, [-10, -10], [-0.1, 0.1], color = :black, label = :none)

# Plot connecting lines
plot!(p3, [-20, -29], [-0.1, -3.6], color = :black, label = :none)
plot!(p3, [-10, -3.15], [-0.1, -3.6], color = :black, label = :none)

plot!(p1, size = (600, 300), legend = :right, subplot = 2)
savefig(p1, joinpath(OUT, "soliton_BBM_BBM_invariants.pdf"))

plot!(p2, size = (600, 250), bottom_margin = 3 * Plots.mm)
savefig(p2, joinpath(OUT, "soliton_BBM_BBM_errors.pdf"))

savefig(p3, joinpath(OUT, "soliton_BBM_BBM_solution.pdf"))
