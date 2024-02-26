# Setup packages
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using DispersiveShallowWater
using Plots

const EXAMPLES_DIR = joinpath(@__DIR__, "elixirs")
const OUT = "out/"
ispath(OUT) || mkpath(OUT)

linewidth = 3
fontsize = 16
linestyles = [:solid, :dash, :dot]

N = 512
steps = [101, 201, 301, 501]
xlims_zoom = [(-25, 15), (0, 40), (5, 45), (-100, -60)]
ylim_zoom = (0.75, 0.85)

plot(layout = (2, 2), ylim = (-0.05, 0.86), size = (1200, 800),
     titlefontsize = fontsize)

trixi_include(joinpath(EXAMPLES_DIR, "svaerd_kalisch_1d_dingemans.jl"); N = N)
for (i, step) in enumerate(steps)
    plot!(semi => sol, step = step, conversion = waterheight_total,
          label = "Svärd-Kalisch (set 2)", subplot = i, plot_bathymetry = true,
          plot_title = "", linewidth = linewidth, legend = :none,
          guidefontsize = fontsize, tickfontsize = fontsize,
          linestyle = linestyles[1])
    plot!(semi => sol, step = step, inset = (i, bbox(0.1, 0.2, 0.6, 0.5)),
          conversion = waterheight_total, linewidth = linewidth, legend = :none,
          framestyle = :box, xlim = xlims_zoom[i], ylim = ylim_zoom,
          subplot = length(steps) + i, plot_title = "", title = "", xguide = "",
          yguide = "", color = 1, linestyle = linestyles[1])
end

trixi_include(joinpath(EXAMPLES_DIR, "bbm_bbm_variable_bathymetry_1d_dingemans.jl"); N = N)
# BBM-BBM equations need to be translated vertically
shifted_waterheight(q, equations) = waterheight_total(q, equations) + 0.8
DispersiveShallowWater.varnames(shifted_waterheight, equations) = ("η",)
for (i, step) in enumerate(steps)
    plot!(semi => sol, step = step, conversion = shifted_waterheight, label = "BBM-BBM",
          subplot = i, plot_title = "", linewidth = linewidth, plot_bathymetry = false, legend = :none,
          guidefontsize = fontsize, tickfontsize = fontsize, color = 2, linestyle = linestyles[2])
    plot!(semi => sol, step = step,
          conversion = shifted_waterheight, linewidth = linewidth, legend = :none,
          framestyle = :box, xlim = xlims_zoom[i], ylim = ylim_zoom,
          subplot = length(steps) + i, plot_title = "", title = "", xguide = "",
          yguide = "", color = 2, linestyle = linestyles[2])
end

trixi_include(joinpath(EXAMPLES_DIR, "elixir_shallowwater_1d_dingemans.jl"))
for (i, step) in enumerate(steps)
    pd = PlotData1D(sol.u[step], semi)
    plot!(pd["H"], label = "Shallow water", subplot = i,
          title = "t = $(round(sol.t[step], digits = 2))", plot_title = "",
          linewidth = linewidth, legend = :none, guidefontsize = fontsize,
          tickfontsize = fontsize, color = 3, linestyle = linestyles[3])
    plot!(pd["H"], linewidth = linewidth, legend = :none,
          framestyle = :box, xlim = xlims_zoom[i], ylim = ylim_zoom,
          subplot = length(steps) + i, plot_title = "", title = "", xguide = "",
          yguide = "", color = 3, linestyle = linestyles[3])
end

x_values = [3.04, 9.44, 20.04, 26.04, 30.44, 37.04]
for i in 1:length(steps)
      vline!(x_values, subplot = i, color = :grey, linewidth = linewidth,
             linestyle = :dash, label = :none)
end

# have one legend for all subplots
plot!(subplot = 3, legend_column = 2, bottom_margin = 22 * Plots.mm,
      legend = (0.7, -0.34), legendfontsize = 12)
plot!(left_margin = 5 * Plots.mm)

# plot boxes
for i in 1:length(steps)
    plot!([xlims_zoom[i][1], xlims_zoom[i][2]], [ylim_zoom[1], ylim_zoom[1]],
          color = :black, label = :none, subplot = i, linewidth = 2)
    plot!([xlims_zoom[i][1], xlims_zoom[i][2]], [ylim_zoom[2], ylim_zoom[2]],
          color = :black, label = :none, subplot = i, linewidth = 2)
    plot!([xlims_zoom[i][1], xlims_zoom[i][1]], [ylim_zoom[1], ylim_zoom[2]],
          color = :black, label = :none, subplot = i, linewidth = 2)
    plot!([xlims_zoom[i][2], xlims_zoom[i][2]], [ylim_zoom[1], ylim_zoom[2]],
          color = :black, label = :none, subplot = i, linewidth = 2)
end
# plot connecting lines
upper_corners = [[-119.5, 0.68], [-9.5, 0.68]]
for i in 1:length(steps)
    plot!([xlims_zoom[i][1], upper_corners[1][1]], [ylim_zoom[1], upper_corners[1][2]],
          color = :black, label = :none, subplot = i, linewidth = 2)
    plot!([xlims_zoom[i][2], upper_corners[2][1]], [ylim_zoom[1], upper_corners[2][2]],
          color = :black, label = :none, subplot = i, linewidth = 2)
end
savefig(joinpath(OUT, "dingemans_solution_time_snapshots.pdf"))
