# Setup packages
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using DispersiveShallowWater
using SummationByPartsOperators: periodic_derivative_operator, upwind_operators
using SparseArrays
using Plots
using LaTeXStrings

const OUT = "out/"
ispath(OUT) || mkpath(OUT)
const EXAMPLES_DIR_BBMBBM = joinpath(examples_dir(), "bbm_bbm_1d")
const EXAMPLES_DIR_BBMBBM_VARIABLE = joinpath(examples_dir(), "bbm_bbm_variable_bathymetry_1d")

linewidth = 2
linestyles = [:solid, :dash, :dot, :dashdot]

g = 9.81
D = 2.0
c = 5 / 2 * sqrt(g * D)
xmin = -35.0
xmax = 35.0
tspan = (0.0, 15 * (xmax - xmin) / c)
N = 512
accuracy_order = 8

plot(xscale = :log10, yscale = :log10,
     start_from = 2 # exclude first entry since it is 0, which is a problem for the loglog plot
     )

D1 = periodic_derivative_operator(1, accuracy_order, xmin, xmax, N)
D2 = sparse(D1)^2
solver_widestencil = Solver(D1, D2)

D1 = periodic_derivative_operator(1, accuracy_order, xmin, xmax, N)
D2 = periodic_derivative_operator(2, accuracy_order, xmin, xmax, N)
solver_narrowstencil = Solver(D1, D2)

D1 = upwind_operators(periodic_derivative_operator; derivative_order = 1,
                      accuracy_order = accuracy_order, xmin = xmin, xmax = xmax,
                      N = N)
D2 = sparse(D1.plus) * sparse(D1.minus)
solver_upwind = Solver(D1, D2)
solvers = [
    solver_narrowstencil,
    solver_narrowstencil,
    solver_widestencil,
    solver_upwind,
]
labels = [
    "narrow-stencil",
    "narrow-stencil in velocity equation",
    "wide-stencil",
    "upwind",
]
examples = [joinpath(EXAMPLES_DIR_BBMBBM, "bbm_bbm_1d_relaxation.jl"),
    joinpath(EXAMPLES_DIR_BBMBBM_VARIABLE,
             "bbm_bbm_variable_bathymetry_1d_relaxation.jl"),
    joinpath(EXAMPLES_DIR_BBMBBM_VARIABLE,
             "bbm_bbm_variable_bathymetry_1d_relaxation.jl"),
    joinpath(EXAMPLES_DIR_BBMBBM_VARIABLE,
             "bbm_bbm_variable_bathymetry_1d_relaxation.jl")]

for (i, solver) in enumerate(solvers)
    trixi_include(examples[i],
                  gravity_constant = g, coordinates_min = xmin,
                  coordinates_max = xmax, tspan = tspan, N = N,
                  accuracy_order = accuracy_order, solver = solver)
    plot!(analysis_callback, title = "", what = (:errors,),
          label_extension = labels[i], linestyle = linestyles[i],
          linewidth = linewidth,
          start_from = 2, # exclude first entry since it is 0, which is a problem for the loglog plot
          ylabel = L"\Vert\eta - \eta_{ana}\Vert_2 + \Vert v - v_{ana}\Vert_2",
          exclude = [:conservation_error, :linf_error])
end

savefig(joinpath(OUT, "soliton_BBM_BBM_errors_stencils.pdf"))
