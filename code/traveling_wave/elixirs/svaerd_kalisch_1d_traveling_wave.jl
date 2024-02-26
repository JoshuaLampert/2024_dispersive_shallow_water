using OrdinaryDiffEq
using DispersiveShallowWater

###############################################################################
# Semidiscretization of the Svärd-Kalisch equations

equations = SvaerdKalischEquations1D(gravity_constant = 9.81, eta0 = 0.8, alpha = 0.0004040404040404049,
                                     beta = 0.49292929292929294, gamma = 0.15707070707070708)

function initial_condition_travelling_wave(x, t, equations::SvaerdKalischEquations1D, mesh)
    h0 = 0.8
    A = 0.02
    omega = 2*pi/(2.02*sqrt(2))
    k = 0.8406220896381442 # precomputed result of find_zero(k -> omega^2 - equations.gravity * k * tanh(k * h0), 1.0) using Roots.jl
    h = A * cos(k * x - omega * t)
    v = sqrt(equations.gravity / k * tanh(k * h0)) * h / h0
    eta = h + h0
    D = equations.eta0
    return SVector(eta, v, D)
end

initial_condition = initial_condition_travelling_wave
boundary_conditions = boundary_condition_periodic

# create homogeneous mesh
k = 0.8406220896381442
coordinates_min = 0
coordinates_max = 10*pi/k
N = 512
mesh = Mesh1D(coordinates_min, coordinates_max, N)

# create solver with periodic SBP operators of accuracy order 4
accuracy_order = 4
solver = Solver(mesh, accuracy_order)

# semidiscretization holds all the necessary data structures for the spatial discretization
semi = Semidiscretization(mesh, equations, initial_condition, solver,
                          boundary_conditions = boundary_conditions)

###############################################################################
# Create `ODEProblem` and run the simulation
tspan = (0.0, 70.0)
ode = semidiscretize(semi, tspan)
analysis_callback = AnalysisCallback(semi; interval = 10,
                                     extra_analysis_errors = (:conservation_error,),
                                     extra_analysis_integrals = (waterheight_total,
                                                                 entropy,
                                                                 entropy_modified))
callbacks = CallbackSet(analysis_callback)

saveat = range(tspan..., length = 501)
sol = solve(ode, Tsit5(), abstol = 1e-7, reltol = 1e-7,
            save_everystep = false, callback = callbacks, saveat = saveat,
            tstops = saveat)
