# Setup packages
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using Plots
using DispersiveShallowWater
using LaTeXStrings

const OUT = "out/"
ispath(OUT) || mkpath(OUT)

linewidth = 2
markersize = 5

eta0 = 0.0
h0 = 1.0
g = 1.0
c0 = sqrt(g * h0)

k = 0.01:0.5:(15 * pi)
k_zoom = 0.01:0.3:(2 * pi)
ylim = (0.0, 1.1)

# Inset Box coordinates
x_box_start = 0.0
x_box_end = last(k_zoom)
y_box_start = 0.48
y_box_end = 1.0

disp_rel = LinearDispersionRelation(h0)
euler = EulerEquations1D(; gravity_constant = g, eta0 = eta0)
plot(k, wave_speed.(disp_rel, euler, k; normalize = true),
     label = "Euler", ylim = ylim, xguide = L"k",
     yguide = L"c/c_0", linewidth = linewidth, markershape = :circle,
     markersize = markersize, subplot = 1)
plot!(k_zoom, wave_speed.(disp_rel, euler, k_zoom; normalize = true),
      ylim = (y_box_start, y_box_end),
      inset = bbox(0.35, 0.1, 0.35, 0.3), subplot = 2, legend = nothing,
      linewidth = linewidth, markershape = :circle, markersize = markersize,
      framestyle = :box)

function plot_dispersion_relation!(equations, label, markershape)
    plot!(k, wave_speed.(disp_rel, equations, k; normalize = true),
          subplot = 1, label = label, linewidth = linewidth,
          markershape = markershape, markersize = markersize)
    plot!(k_zoom, wave_speed.(disp_rel, equations, k_zoom; normalize = true),
          subplot = 2, linewidth = linewidth,
          markershape = markershape, markersize = markersize)
end

bbmbbm = BBMBBMEquations1D(; gravity_constant = g, eta0 = eta0)
plot_dispersion_relation!(bbmbbm, "BBM-BBM", :cross)

SK_set1 = SvaerdKalischEquations1D(; gravity_constant = g, eta0 = eta0,
                                   alpha = -1/3, beta = 0.0, gamma = 0.0)
plot_dispersion_relation!(SK_set1, "S.-K. set 1", :rtriangle)

SK_set2 = SvaerdKalischEquations1D(; gravity_constant = g, eta0 = eta0,
                                   alpha = 0.0004040404040404049, beta = 0.49292929292929294, gamma = 0.15707070707070708)
plot_dispersion_relation!(SK_set2, "S.-K. set 2", :star5)

SK_set3 = SvaerdKalischEquations1D(; gravity_constant = g, eta0 = eta0,
                                   alpha = 0.0, beta = 0.27946992481203003, gamma = 0.0521077694235589)
plot_dispersion_relation!(SK_set3, "S.-K. set 3", :star8)

SK_set4 = SvaerdKalischEquations1D(; gravity_constant = g, eta0 = eta0,
                                   alpha = 0.0, beta = 0.2308939393939394, gamma = 0.04034343434343434)
plot_dispersion_relation!(SK_set4, "S.-K. set 4", :diamond)

SK_set5 = SvaerdKalischEquations1D(; gravity_constant = g, eta0 = eta0,
                                   alpha = 0.0, beta = 1/3, gamma = 0.0)
plot_dispersion_relation!(SK_set5, "S.-K. set 5", :star4)

# Plot box
plot!([x_box_start, x_box_end], [y_box_start, y_box_start], color = :black, label = :none)
plot!([x_box_start, x_box_end], [y_box_end, y_box_end], color = :black, label = :none)
plot!([x_box_start, x_box_start], [y_box_start, y_box_end], color = :black, label = :none)
plot!([x_box_end, x_box_end], [y_box_start, y_box_end], color = :black, label = :none)

# Plot connecting lines
x_inset_start = 12.53
plot!([x_box_end, x_inset_start], [y_box_start, 0.626], color = :black, label = :none)
plot!([x_box_end, x_inset_start], [1, 1.01], color = :black, label = :none)

savefig(joinpath(OUT, "dispersion_relations.pdf"))
