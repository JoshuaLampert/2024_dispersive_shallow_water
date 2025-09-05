using OrdinaryDiffEqTsit5
using DispersiveShallowWater

###############################################################################
# Semidiscretization of the BBM-BBM equations

equations = BBMBBMEquations1D(gravity_constant = 9.81, eta0 = 0.0)

function initial_condition_traveling_wave(x, t, equations::BBMBBMEquations1D, mesh)
    h0 = 0.8
    A = 0.02
    omega = 2*pi/(2.02*sqrt(2))
    k = 0.8406220896381442 # precomputed result of find_zero(k -> omega^2 - equations.gravity * k * tanh(k * h0), 1.0) using Roots.jl
    eta_prime = A * cos(k * x - omega * t) # linearizing eta around eta0, eta = eta0 + eta'
    v = sqrt(equations.gravity / k * tanh(k * h0)) * eta_prime / h0
    eta = eta_prime + equations.eta0
    D = h0 # = eta_0 - b (b = b0 = eta0 - h0)
    return SVector(eta, v, D)
end

initial_condition = initial_condition_traveling_wave
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
summary_callback = SummaryCallback()
analysis_callback = AnalysisCallback(semi; interval = 10,
                                     extra_analysis_errors = (:conservation_error,),
                                     extra_analysis_integrals = (waterheight_total,
                                                                 velocity, entropy))
callbacks = CallbackSet(analysis_callback, summary_callback)

saveat = range(tspan..., length = 501)
sol = solve(ode, Tsit5(), abstol = 1e-7, reltol = 1e-7,
            save_everystep = false, callback = callbacks, saveat = saveat,
            tstops = saveat)
