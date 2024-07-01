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
plot(layout = (3, 2), size = (600, 600))

N = 512
tspan = (0.0, 70.0)
saveat = range(tspan..., length = 1000)
accuracy_orders = [2, 4, 6]
linewidth = 2
linestyles = [:solid, :dash, :dashdot]

for (j, x) in enumerate(x_values)
    plot!(experimental_data.time, experimental_data[:, j + 1], subplot = j,
          xlim = tlims[j], ylim = ylim, legend = nothing,
          linewidth = linewidth, label = "experiment", linestyle = :dot)
end

for (i, accuracy_order) in enumerate(accuracy_orders)
    trixi_include(joinpath(EXAMPLES_DIR,
                           "svaerd_kalisch_1d_dingemans.jl");
                  N = N, tspan = tspan, accuracy_order = accuracy_order,
                  saveat = saveat, tstops = saveat)
    for (j, x) in enumerate(x_values)
        plot!(semi => sol, x, conversion = waterheight_total, subplot = j,
              xlim = tlims[j], ylim = ylim, plot_title = "", title = "x = $x",
              legend = nothing, yticks = yticks, linewidth = linewidth, titlefontsize = 10,
              label = "p = $accuracy_order ", linestyle = linestyles[i], xlabel = (j > 4 ? "t" : ""))
    end
end

plot!(subplot = 5, legend = (0.82, -0.5), legend_column = 2, legendfontsize = 8,
      bottom_margin = 10 * Plots.mm)
savefig(joinpath(OUT, "dingemans_waterheight_at_x_accuracy_order_Svaerd_Kalisch.pdf"))
