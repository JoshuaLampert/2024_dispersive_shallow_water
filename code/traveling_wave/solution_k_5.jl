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

N = 512
tspan = (0.0, 1.0)
accuracy_order = 4
ylim = (0.77, 0.83)

g = 9.81
h0 = 0.8
k = 5
omega = sqrt(g * k * tanh(k * h0))

# parameters for set 2 of the Svärd-Kalisch equations
alpha = 0.0004040404040404049
beta = 0.49292929292929294
gamma = 0.15707070707070708

trixi_include(joinpath(EXAMPLES_DIR, "svaerd_kalisch_1d_traveling_wave.jl"); N = N, accuracy_order = accuracy_order, tspan = tspan,
              gravity_constant = g, h0 = h0, k = k, omega = omega, alpha = alpha, beta = beta, gamma = gamma)

# Plot "analytical" solution (i.e. traveling wave for the Euler equations)
# `plot_initial = true` does not work here because of some coloring issues (I want to choose colors for the initial condition and
# numerical solution independently)
x = DispersiveShallowWater.grid(semi)
q_initial = DispersiveShallowWater.wrap_array(DispersiveShallowWater.compute_coefficients(initial_condition, tspan[2], semi), semi)
plot(x, q_initial[1, :], ylims = ylim, label = "traveling wave",
     linewidth = linewidth, plot_title = "", linestyle = :dot, color = 3)

plot!(semi => sol, ylims = ylim, conversion = waterheight_total, legend = :bottomleft,
      label = "η Svärd-Kalisch (set 2)", linewidth = linewidth, titlefontsize = fontsize, plot_bathymetry = false,
      plot_title = "", linestyle = :solid, color = 1)

trixi_include(joinpath(EXAMPLES_DIR, "bbm_bbm_variable_bathymetry_1d_traveling_wave.jl"); N = N, accuracy_order = accuracy_order, tspan = tspan,
              gravity_constant = g, h0 = h0, k = k, omega = omega)
# BBM-BBM equations need to be translated vertically
shifted_waterheight(q, equations) = waterheight_total(q, equations) + 0.8
DispersiveShallowWater.varnames(shifted_waterheight, equations) = ("η",)
plot!(semi => sol, ylims = ylim, conversion = shifted_waterheight, legend = :bottomleft,
      label = "η BBM-BBM", linewidth = linewidth, plot_bathymetry = false,
      plot_title = "", linestyle = :dash, color = 2)

savefig(joinpath(OUT, "traveling_wave_$(k)_set2.pdf"))
