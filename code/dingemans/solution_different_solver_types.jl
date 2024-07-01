# Setup packages
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using CSV, DataFrames
using DispersiveShallowWater
using SummationByPartsOperators: legendre_derivative_operator,
                                 legendre_second_derivative_operator,
                                 UniformPeriodicMesh1D,
                                 couple_discontinuously,
                                 couple_continuously
using SparseArrays: sparse
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
linestyles = [:solid, :dash, :dashdot]

coordinates_min = -138.0
coordinates_max = 46.0
p = 3 # N needs to be divisible by p + 1
D_legendre = legendre_derivative_operator(-1.0, 1.0, p + 1)
uniform_mesh = UniformPeriodicMesh1D(coordinates_min, coordinates_max, div(N, p + 1))
D1 = couple_discontinuously(D_legendre, uniform_mesh)
D_pl = couple_discontinuously(D_legendre, uniform_mesh, Val(:plus))
D_min = couple_discontinuously(D_legendre, uniform_mesh, Val(:minus))
D2 = sparse(D_pl) * sparse(D_min)
solver_DG = Solver(D1, D2)

mesh = Mesh1D(coordinates_min, coordinates_max, N)
accuracy_order = 4
solver_FD = Solver(mesh, accuracy_order)

p = 4 # N needs to be divisible by p
D_legendre = legendre_derivative_operator(-1.0, 1.0, p + 1)
uniform_mesh = UniformPeriodicMesh1D(coordinates_min, coordinates_max, div(N, p))
D1 = couple_continuously(D_legendre, uniform_mesh)
D2_legendre = legendre_second_derivative_operator(-1.0, 1.0, p + 1)
D2 = couple_continuously(D2_legendre, uniform_mesh)
solver_CG = Solver(D1, D2)

solvers = [solver_DG, solver_FD, solver_CG]
labels = ["DG ", "FD ", "CG "]

for (j, x) in enumerate(x_values)
    plot!(experimental_data.time, experimental_data[:, j + 1], subplot = j,
          xlim = tlims[j], ylim = ylim, legend = nothing,
          linewidth = 2, label = "experiment", linestyle = :dot)
end

for (i, solver) in enumerate(solvers)
    trixi_include(joinpath(EXAMPLES_DIR,
                           "svaerd_kalisch_1d_dingemans.jl");
                  N = N, tspan = tspan, accuracy_order = accuracy_order,
                  saveat = saveat, tstops = saveat, solver = solvers[i])
    for (j, x) in enumerate(x_values)
        plot!(semi => sol, x, conversion = waterheight_total, subplot = j,
              xlim = tlims[j], ylim = ylim, plot_title = "", title = "x = $x",
              legend = nothing, yticks = yticks, linewidth = 2, titlefontsize = 10,
              label = labels[i], linestyle = linestyles[i], xlabel = (j > 4 ? "t" : ""))
    end
end

plot!(subplot = 5, legend = (0.86, -0.5), legend_column = 2, legendfontsize = 8,
      bottom_margin = 10 * Plots.mm)
savefig(joinpath(OUT, "dingemans_waterheight_at_x_solver_types.pdf"))
