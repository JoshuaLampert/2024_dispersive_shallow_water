using Trixi
using OrdinaryDiffEqTsit5

equations = ShallowWaterEquations1D(gravity_constant = 9.81, H0 = 0.8)

function initial_condition_dingemans_trixi(x, t, equations::ShallowWaterEquations1D)
    h0 = 0.8
    A = 0.02
    # omega = 2*pi/(2.02*sqrt(2))
    k = 0.8406220896381442 # precomputed result of find_zero(k -> omega^2 - equations.gravity * k * tanh(k * h0), 1.0) using Roots.jl
    if x[1] < -34.5 * pi / k || x[1] > -4.5 * pi / k
        eta_prime = 0.0
    else
        eta_prime = A * cos(k * x[1])
    end
    v = sqrt(equations.gravity / k * tanh(k * h0)) * eta_prime / h0
    if 11.01 <= x[1] && x[1] < 23.04
        b = 0.6 * (x[1] - 11.01) / (23.04 - 11.01)
    elseif 23.04 <= x[1] && x[1] < 27.04
        b = 0.6
    elseif 27.04 <= x[1] && x[1] < 33.07
        b = 0.6 * (33.07 - x[1]) / (33.07 - 27.04)
    else
        b = 0.0
    end
    eta = eta_prime + equations.H0 # H0 = eta0
    D = equations.H0 - b
    return Trixi.prim2cons(SVector(eta, v, b), equations)
end

initial_condition = initial_condition_dingemans_trixi

volume_flux = (flux_wintermeyer_etal, flux_nonconservative_wintermeyer_etal)
surface_flux = (FluxHydrostaticReconstruction(flux_lax_friedrichs,
                                              hydrostatic_reconstruction_audusse_etal),
                flux_nonconservative_audusse_etal)
accuracy_order = 3
solver = DGSEM(polydeg = accuracy_order, surface_flux = surface_flux,
               volume_integral = VolumeIntegralFluxDifferencing(volume_flux))

coordinates_min = -138.0
coordinates_max = 46.0
mesh = TreeMesh(coordinates_min, coordinates_max,
                initial_refinement_level = 7,
                n_cells_max = 10_000)

semi = SemidiscretizationHyperbolic(mesh, equations, initial_condition, solver)
tspan = (0.0, 70.0)
ode = Trixi.semidiscretize(semi, tspan)

summary_callback = Trixi.SummaryCallback()

analysis_callback = Trixi.AnalysisCallback(semi, interval = 100)

callbacks = CallbackSet(summary_callback, analysis_callback)

saveat = range(tspan..., length = 501)
sol = solve(ode, Tsit5(), reltol = 1e-7, abstol = 1e-7,
            save_everystep = false, callback = callbacks, saveat = saveat,
            tstops = saveat);
summary_callback() # print the timer summary
