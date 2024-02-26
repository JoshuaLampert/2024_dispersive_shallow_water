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

k = 0.01:3.0:(50 * pi)
ylim = (0.0, 1.1)

omega_euler(k) = sqrt(g * k) * sqrt(tanh(h0 * k))
c_euler(k) = omega_euler(k) / k
plot(k, c_euler.(k) ./ c0, label = "Euler", ylim = ylim, xguide = L"k",
        yguide = L"c/c_0", linewidth = linewidth, markershape = :circle,
        markersize = markersize)

function plot_dispersion_relation(omega, label, markershape, color)
    c(k) = omega(k) / k
    plot!(k, c.(k) ./ c0, label = label, linewidth = linewidth,
          markershape = markershape, markersize = markersize,
          color = color)
end

omega_bbmbbm_(k, d0) = sqrt(g * h0) * k / (1 + 1 / 6 * (d0 * k)^2)
omega_bbmbbm(k) = omega_bbmbbm_(k, h0)
plot_dispersion_relation(omega_bbmbbm, "BBM-BBM", :cross, 2)

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

omega_set3(k) = char_equation(alpha_set3, beta_set3, gamma_set3, k)
plot_dispersion_relation(omega_set3, "S.-K. set 3", :star8, 5)

omega_set4(k) = char_equation(alpha_set4, beta_set4, gamma_set4, k)
plot_dispersion_relation(omega_set4, "S.-K. set 4", :diamond, 6)

savefig(joinpath(OUT, "dispersion_relations_long.pdf"))
