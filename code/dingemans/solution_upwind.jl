# Setup packages
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using CSV, DataFrames
using DispersiveShallowWater
using Plots

file = joinpath(@__DIR__, "data_dingemans.csv")
experimental_data = CSV.read(file, DataFrame)

const EXAMPLES_DIR = joinpath(@__DIR__, "elixirs")
const OUT = "out/"
ispath(OUT) || mkpath(OUT)

ylim = (0.75, 0.85)
yticks = [0.76, 0.78, 0.8, 0.82, 0.84]
x_values = [3.04, 9.44, 20.04, 26.04, 30.44, 37.04]
tlims = [
    (20.0, 30.0),
    (25.0, 35.0),
    (35.0, 45.0),
    (40.0, 50.0),
    (45.0, 55.0),
    (50.0, 60.0),
]
p1 = plot(layout = (3, 2), size = (600, 600))

N = 512
tspan = (0.0, 70.0)
saveat = range(tspan..., length = 1000)
accuracy_order = 4
linestyles = [:solid, :dash, :dashdot]
linewidth = 2
titlefontsize = 10

labels = ["EC baseline", "EC relaxation  ", "ED upwind"]

for (j, x) in enumerate(x_values)
    plot!(p1, experimental_data.time, experimental_data[:, j + 1], subplot = j,
          xlim = tlims[j], ylim = ylim, legend = nothing,
          linewidth = 2, label = "experiment", linestyle = :dot)
end

function plot_at_x(semi, sol, i)
    for (j, x) in enumerate(x_values)
        plot!(p1, semi => sol, x, conversion = waterheight_total, subplot = j,
              xlim = tlims[j], ylim = ylim, plot_title = "", title = "x = $x",
              legend = nothing, yticks = yticks, linewidth = linewidth,
              titlefontsize = titlefontsize,
              label = labels[i], linestyle = linestyles[i], xlabel = (j > 4 ? "t" : ""))
    end
end

trixi_include(joinpath(EXAMPLES_DIR, "svaerd_kalisch_1d_dingemans.jl");
                N = N, tspan = tspan, accuracy_order = accuracy_order, saveat = saveat)
plot_at_x(semi, sol, 1)
p2 = plot(analysis_callback, title = labels[1], legend = :none,
          linestyles = [:solid :dash :dot],
          linewidth = linewidth, layout = 3, subplot = 1, titlefontsize = titlefontsize)

trixi_include(joinpath(EXAMPLES_DIR,
                        "svaerd_kalisch_1d_dingemans_relaxation.jl");
                N = N, tspan = tspan, accuracy_order = accuracy_order, saveat = saveat)
plot_at_x(semi, sol, 2)
plot!(p2, analysis_callback, title = labels[2], legend = :none,
      linestyles = [:solid :dash :dot],
      linewidth = linewidth, subplot = 2, titlefontsize = titlefontsize)

trixi_include(joinpath(EXAMPLES_DIR,
                        "svaerd_kalisch_1d_dingemans_upwind.jl");
              N = N, tspan = tspan, accuracy_order = accuracy_order, saveat = saveat)
plot_at_x(semi, sol, 3)
plot!(p2, analysis_callback, title = labels[3], legend = :none,
      linestyles = [:solid :dash :dot],
      linewidth = linewidth, subplot = 3, titlefontsize = titlefontsize)

plot!(p1, subplot = 5, legend = (0.7, -0.6), legend_column = 2, legendfontsize = 8,
        bottom_margin = 12 * Plots.mm)
plot!(p2, subplot = 3, legend = (1.3, 0.6), legendfontsize = 8)
savefig(p1, joinpath(OUT, "dingemans_waterheight_at_x_ec_ed.pdf"))
savefig(p2, joinpath(OUT, "dingemans_invariants_ec_ed.pdf"))
