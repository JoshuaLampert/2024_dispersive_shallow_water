using OrdinaryDiffEq
using DispersiveShallowWater

###############################################################################
# Semidiscretization of the BBM-BBM equations

equations = SvaerdKalischEquations1D(gravity_constant = 9.81, eta0 = 1.0,
                                     alpha = 0.0004040404040404049,
                                     beta = 0.49292929292929294,
                                     gamma = 0.15707070707070708)

function intial_condition_two_waves(x, t, equations::SvaerdKalischEquations1D, mesh)
    eta = equations.eta0 + exp(-50*x^2)
    v = 0
    D = equations.eta0 - 0.3*cospi(x)
    return SVector(eta, v, D)
end

initial_condition = intial_condition_two_waves
boundary_conditions = boundary_condition_periodic

# create homogeneous mesh
coordinates_min = -1.0
coordinates_max = 1.0
N = 512
mesh = Mesh1D(coordinates_min, coordinates_max, N)

# create solver with periodic central SBP operators of accuracy order 4
accuracy_order = 4
solver = Solver(mesh, accuracy_order)

# semidiscretization holds all the necessary data structures for the spatial discretization
semi = Semidiscretization(mesh, equations, initial_condition, solver,
                          boundary_conditions = boundary_conditions)

###############################################################################
# Create `ODEProblem` and run the simulation
tspan = (0.0, 1.0)
ode = semidiscretize(semi, tspan)
summary_callback = SummaryCallback()
analysis_callback = AnalysisCallback(semi; interval = 1000,
                                     extra_analysis_errors = (:conservation_error,),
                                     extra_analysis_integrals = (waterheight_total,
                                                                 velocity, entropy))
callbacks = CallbackSet(analysis_callback, summary_callback)

saveat = range(tspan..., length = 100)
sol = solve(ode, Tsit5(), abstol = 1e-12, reltol = 1e-12,
            save_everystep = false, callback = callbacks, saveat = saveat)
