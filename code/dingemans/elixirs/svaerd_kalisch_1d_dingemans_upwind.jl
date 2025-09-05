using OrdinaryDiffEqTsit5
using DispersiveShallowWater
using SummationByPartsOperators: upwind_operators, periodic_derivative_operator

###############################################################################
# Semidiscretization of the Svärd-Kalisch equations

equations = SvaerdKalischEquations1D(gravity_constant = 9.81, eta0 = 0.8, alpha = 0.0004040404040404049,
                                     beta = 0.49292929292929294, gamma = 0.15707070707070708)

function initial_condition_dingemans_calibrated(x, t, equations::SvaerdKalischEquations1D, mesh)
    h0 = 0.8
    A = 0.02
    # omega = 2*pi/(2.02*sqrt(2))
    k = 0.8406220896381442 # precomputed result of find_zero(k -> omega^2 - equations.gravity * k * tanh(k * h0), 1.0) using Roots.jl
    x_trans = 2.2
    if x - x_trans < -34.5 * pi / k || x - x_trans > -4.5 * pi / k
        eta_prime = 0.0
    else
        eta_prime = A * cos(k * (x - x_trans))
    end
    v = sqrt(equations.gravity / k * tanh(k * h0)) * eta_prime / h0
    if 11.01 <= x && x < 23.04
        b = 0.6 * (x - 11.01) / (23.04 - 11.01)
    elseif 23.04 <= x && x < 27.04
        b = 0.6
    elseif 27.04 <= x && x < 33.07
        b = 0.6 * (33.07 - x) / (33.07 - 27.04)
    else
        b = 0.0
    end
    eta = eta_prime + equations.eta0
    D = equations.eta0 - b
    return SVector(eta, v, D)
end

initial_condition = initial_condition_dingemans_calibrated
boundary_conditions = boundary_condition_periodic

# create homogeneous mesh
coordinates_min = -138.0
coordinates_max = 46.0
N = 512
mesh = Mesh1D(coordinates_min, coordinates_max, N)

# create solver with periodic SBP operators of accuracy order 4
accuracy_order = 4
D1 = upwind_operators(periodic_derivative_operator; derivative_order = 1,
                      accuracy_order = accuracy_order, xmin = mesh.xmin, xmax = mesh.xmax,
                      N = mesh.N)
D2 = periodic_derivative_operator(2, accuracy_order, mesh.xmin, mesh.xmax, mesh.N)
solver = Solver(D1, D2)

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

saveat = range(tspan..., length = 500)
sol = solve(ode, Tsit5(), abstol = 1e-7, reltol = 1e-7,
            save_everystep = false, callback = callbacks, saveat = saveat,
            tstops = saveat)
