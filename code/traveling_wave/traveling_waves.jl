# Setup packages
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using DispersiveShallowWater
using Plots

const EXAMPLES_DIR = joinpath(@__DIR__, "elixirs")
const OUT = "out/"
ispath(OUT) || mkpath(OUT)

linewidth = 2
fontsize = 16

N = 512
accuracy_order = 4
ylim = (0.77, 0.83)

g = 9.81
h0 = 0.8

# parameters for set 2 of the Svärd-Kalisch equations
alpha = 0.0004040404040404049
beta = 0.49292929292929294
gamma = 0.15707070707070708

# BBM-BBM equations need to be translated vertically
shifted_waterheight(q, equations) = waterheight_total(q, equations) + 0.8
DispersiveShallowWater.varnames(shifted_waterheight, equations) = ("η",)

# First plot (k = 0.8)
k = 0.8
omega = sqrt(g * k * tanh(k * h0))
tspan = (0.0, 50.0)
trixi_include(joinpath(EXAMPLES_DIR, "svaerd_kalisch_1d_traveling_wave.jl"); N = N, accuracy_order = accuracy_order, tspan = tspan,
              gravity_constant = g, h0 = h0, k = k, omega = omega, alpha = alpha, beta = beta, gamma = gamma)

# Plot "analytical" solution (i.e. traveling wave for the Euler equations)
# `plot_initial = true` does not work here because of some coloring issues (I want to choose colors for the initial condition and
# numerical solution independently)
x = DispersiveShallowWater.grid(semi)
q_initial = DispersiveShallowWater.compute_coefficients(initial_condition, tspan[2], semi)
p1 = plot(x, q_initial.x[1], ylims = ylim, label = "traveling wave",
          linewidth = linewidth, plot_title = "", linestyle = :dot, color = 3)

plot!(p1, semi => sol, ylims = ylim, conversion = waterheight_total, legend = false,
      linewidth = linewidth, titlefontsize = fontsize, plot_bathymetry = false,
      title = "", plot_title = "", linestyle = :solid, color = 1)

trixi_include(joinpath(EXAMPLES_DIR, "bbm_bbm_variable_bathymetry_1d_traveling_wave.jl"); N = N, accuracy_order = accuracy_order, tspan = tspan,
              gravity_constant = g, h0 = h0, k = k, omega = omega)

plot!(p1, semi => sol, ylims = ylim, conversion = shifted_waterheight, legend = false,
      linewidth = linewidth, plot_bathymetry = false, title = "", plot_title = "", linestyle = :dash, color = 2)

# Second plot (k = 5)
k = 5
omega = sqrt(g * k * tanh(k * h0))
tspan = (0.0, 1.0)
trixi_include(joinpath(EXAMPLES_DIR, "svaerd_kalisch_1d_traveling_wave.jl"); N = N, accuracy_order = accuracy_order, tspan = tspan,
              gravity_constant = g, h0 = h0, k = k, omega = omega, alpha = alpha, beta = beta, gamma = gamma)

# Plot "analytical" solution (i.e. traveling wave for the Euler equations)
# `plot_initial = true` does not work here because of some coloring issues (I want to choose colors for the initial condition and
# numerical solution independently)
x = DispersiveShallowWater.grid(semi)
q_initial = DispersiveShallowWater.compute_coefficients(initial_condition, tspan[2], semi)
p2 = plot(x, q_initial.x[1], ylims = ylim, label = "traveling wave",
          linewidth = linewidth, plot_title = "", linestyle = :dot, color = 3)

plot!(p2, semi => sol, ylims = ylim, conversion = waterheight_total, legend = false,
      linewidth = linewidth, titlefontsize = fontsize, plot_bathymetry = false,
      title = "", plot_title = "", linestyle = :solid, color = 1)

trixi_include(joinpath(EXAMPLES_DIR, "bbm_bbm_variable_bathymetry_1d_traveling_wave.jl"); N = N, accuracy_order = accuracy_order, tspan = tspan,
              gravity_constant = g, h0 = h0, k = k, omega = omega)

DispersiveShallowWater.varnames(shifted_waterheight, equations) = ("η",)
plot!(p2, semi => sol, ylims = ylim, conversion = shifted_waterheight, legend = false,
      linewidth = linewidth, plot_bathymetry = false, title = "", plot_title = "", linestyle = :dash, color = 2)

# Third plot (k = 15)
k = 15
omega = sqrt(g * k * tanh(k * h0))
tspan = (0.0, 1.0)
trixi_include(joinpath(EXAMPLES_DIR, "svaerd_kalisch_1d_traveling_wave.jl"); N = N, accuracy_order = accuracy_order, tspan = tspan,
              gravity_constant = g, h0 = h0, k = k, omega = omega, alpha = alpha, beta = beta, gamma = gamma)

# Plot "analytical" solution (i.e. traveling wave for the Euler equations)
# `plot_initial = true` does not work here because of some coloring issues (I want to choose colors for the initial condition and
# numerical solution independently)
x = DispersiveShallowWater.grid(semi)
q_initial = DispersiveShallowWater.compute_coefficients(initial_condition, tspan[2], semi)
p3 = plot(x, q_initial.x[1], ylims = ylim, legend = false,
          linewidth = linewidth, plot_title = "", linestyle = :dot, color = 3)

plot!(p3, semi => sol, ylims = ylim, conversion = waterheight_total, legend = false,
      linewidth = linewidth, titlefontsize = fontsize, plot_bathymetry = false,
      title = "", plot_title = "", linestyle = :solid, color = 1)

# parameters for set 3 of the Svärd-Kalisch equations
alpha = 0.0
beta = 0.27946992481203003
gamma = 0.0521077694235589

trixi_include(joinpath(EXAMPLES_DIR, "svaerd_kalisch_1d_traveling_wave.jl"); N = N, accuracy_order = accuracy_order, tspan = tspan,
              gravity_constant = g, h0 = h0, k = k, omega = omega, alpha = alpha, beta = beta, gamma = gamma)
plot!(p3, semi => sol, ylims = ylim, conversion = waterheight_total, legend = false,
      linewidth = linewidth, plot_bathymetry = false, title = "", plot_title = "", linestyle = :dashdot, color = 4)

p = plot(p1, p2, p3,
         # dummy plot to place the legend in the lower right
         plot((1:4)', legend = :topleft, framestyle = :none, color = [3 1 2 4], linestyles = [:dot :solid :dash :dashdot],
         linewidth = linewidth,
         labels = ["traveling wave" "Svärd-Kalisch (set 2)" "BBM-BBM" "Svärd-Kalisch (set 3)"]))
savefig(p, joinpath(OUT, "traveling_waves.pdf"))

