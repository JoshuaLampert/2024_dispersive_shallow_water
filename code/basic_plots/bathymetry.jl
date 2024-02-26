# Setup packages
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using Plots
using LaTeXStrings

const OUT = "out/"
ispath(OUT) || mkpath(OUT)

L = 1.0
n = 100
x = LinRange(0.0, L, n)
fontsize = 20

# just pick some function for b and eta that look nice
H = 1.012
eta_0 = 2.4

b(x) = x * cos.(3 * pi * x) + H
plot(x, b, color = :gray, fill = (0, 0.8, :gray), fillstyle = :/, linewidth = 3,
     legend = nothing, ticks = nothing, border = :none, right_margin = 4 * Plots.mm)

eta(x) = x / (x^2 + 1) * sin(2 * pi * x) + H + 1.5
plot!(x, eta, color = :blue, fill = (b.(x), 0.4, :blue), linewidth = 3)

x1 = 0.2
plot!([x1, x1], [b(x1), eta(x1)], line = (Plots.Arrow(:open, :head, 2.5, 2.0), :black),
      annotation = (x1 - 0.08, (eta(x1) + b(x1)) / 2, text(L"h(t, x)", fontsize)),
      linewidth = 2)
x2 = 0.4
plot!([x2, x2], [0.0, b(x2)], line = (Plots.Arrow(:open, :head, 2.5, 2.0), :black),
      annotation = (x2 + 0.06, b(x2) / 2, text(L"b(x)", fontsize)), linewidth = 2)
x3 = 0.8
plot!([x3, x3], [0.0, eta(x3)], line = (Plots.Arrow(:open, :head, 2.5, 2.0), :black),
      annotation = (x3 - 0.08, eta(x3) / 2, text(L"\eta(t, x)", fontsize)),
      linewidth = 2)
x4 = 0.5
plot!([x4, x4], [b(x4), eta_0], line = (Plots.Arrow(:open, :head, 2.5, 2.0), :black),
      annotation = (x4 - 0.06, (eta_0 + b(x4)) / 2, text(L"D(x)", fontsize)),
      linewidth = 2)
plot!([0.0, L], [eta_0, eta_0], linestyle = :dash, color = :blue,
      annotation = (L + 0.04, eta_0, text(L"\eta_0", fontsize)),
      linewidth = 2)

savefig(joinpath(OUT, "bathymetry.pdf"))
