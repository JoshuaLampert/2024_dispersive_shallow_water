# Setup packages
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using Plots
using LaTeXStrings

const OUT = "out/"
ispath(OUT) || mkpath(OUT)

linewidth = 2
markersize = 5

h0 = 1.0
g = 1.0
c0 = sqrt(g * h0)

k = 0.01:0.5:(8 * pi)
k_zoom = 0.01:0.3:pi
ylim = (0.0, 1.1)

omega_euler(k) = sqrt(g * k) * sqrt(tanh(h0 * k))
c_euler(k) = omega_euler(k) / k
plot(k, c_euler.(k) ./ c0, label = "Euler", ylim = ylim, xguide = L"k",
     yguide = L"c/c_0", linewidth = linewidth, markershape = :circle,
     markersize = markersize)
plot!(k_zoom, c_euler.(k_zoom) ./ c0, ylim = (0.54, 1.0),
      inset = bbox(0.35, 0.1, 0.35, 0.3), subplot = 2, legend = nothing,
      linewidth = linewidth, markershape = :circle, markersize = markersize,
      framestyle = :box)

function plot_dispersion_relation(omega, label, markershape)
    c(k) = omega(k) / k
    plot!(k, c.(k) ./ c0, label = label, linewidth = linewidth,
          markershape = markershape, markersize = markersize)
    plot!(k_zoom, c.(k_zoom) ./ c0, subplot = 2, linewidth = linewidth,
          markershape = markershape, markersize = markersize)
end

omega_bbmbbm(k) = sqrt(g * h0) * k / (1 + 1 / 6 * (h0 * k)^2)
plot_dispersion_relation(omega_bbmbbm, "BBM-BBM", :cross)

alpha_set1 = -1 / 3 * c0 * h0^2
beta_set1 = 0.0 * h0^3
gamma_set1 = 0.0 * c0 * h0^3

alpha_set2 = 0.0004040404040404049 * c0 * h0^2
beta_set2 = 0.49292929292929294 * h0^3
gamma_set2 = 0.15707070707070708 * c0 * h0^3

alpha_set3 = 0.0 * c0 * h0^2
beta_set3 = 0.27946992481203003 * h0^3
gamma_set3 = 0.0521077694235589 * c0 * h0^3

alpha_set4 = 0.0 * c0 * h0^2
beta_set4 = 0.2308939393939394 * h0^3
gamma_set4 = 0.04034343434343434 * c0 * h0^3

function char_equation(alpha, beta, gamma, k)
    a = (1 + beta / h0 * k^2)
    b = (-alpha - beta * alpha / h0 * k^2 - gamma / h0) * k^3
    c = -g * h0 * k^2 + gamma * alpha / h0 * k^6
    omega1 = (-b + sqrt(b^2 - 4 * a * c)) / (2 * a)
#     omega2 = (-b - sqrt(b^2 - 4*a*c))/(2*a)
    return omega1
end

omega_set1(k) = char_equation(alpha_set1, beta_set1, gamma_set1, k)
plot_dispersion_relation(omega_set1, "S.-K. set 1", :rtriangle)

omega_set2(k) = char_equation(alpha_set2, beta_set2, gamma_set2, k)
plot_dispersion_relation(omega_set2, "S.-K. set 2", :star5)

omega_set3(k) = char_equation(alpha_set3, beta_set3, gamma_set3, k)
plot_dispersion_relation(omega_set3, "S.-K. set 3", :star8)

omega_set4(k) = char_equation(alpha_set4, beta_set4, gamma_set4, k)
plot_dispersion_relation(omega_set4, "S.-K. set 4", :diamond)

# Plot box
plot!([0.0, pi], [0.54, 0.54], color = :black, label = :none)
plot!([0.0, pi], [1.0, 1.0], color = :black, label = :none)
plot!([0.0, 0.0], [0.54, 1.0], color = :black, label = :none)
plot!([pi, pi], [0.54, 1.0], color = :black, label = :none)

# Plot connecting lines
plot!([pi, 6.8], [0.54, 0.629], color = :black, label = :none)
plot!([pi, 6.8], [1, 1.01], color = :black, label = :none)

savefig(joinpath(OUT, "dispersion_relations.pdf"))
