# Setup packages
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

import SymPy; sp = SymPy

function math_replacements(s)
    s = replace(s, "sin(2*pi*x)" => "a1")
    s = replace(s, "cos(2*pi*x)" => "a2")
    s = replace(s, "sin(pi*(-t + 2*x))" => "a3")
    s = replace(s, "cos(pi*(-t + 2*x))" => "a4")
    s = replace(s, "sin(pi*(t - 2*x))" => "a5")
    s = replace(s, "cos(pi*(t - 2*x))" => "a6")
    s = replace(s, "sin(pi*(-4*t + 2*x))" => "a7")
    s = replace(s, "exp(t/2)" => "a8")
    s = replace(s, "exp(t)" => "a9")
    s = replace(s, "a9*cos(pi*(-4*t + 2*x))" => "a10")
    s = replace(s, "(eta0 + 2.0*a2 + 5.0)" => "a11")
    s = replace(s, "sqrt(g*a11)" => "a12")
    s = replace(s, "(0.2*eta0 + 0.4*a2 + 1)" => "a13")
    s = replace(s, "alpha*a12*a13^2" => "a14")
    s = replace(s, "sqrt(a14)" => "a15")
    s = replace(s, "(-1.0*pi*a14*a1/a11 - 0.8*pi*alpha*a12*a13*a1)" => "a16")
    s = replace(s, "(-20.0*pi^2*a15*a10 - 10.0*pi*a15*a16*a9*a7/(a14))" => "a17")
    s = replace(s, "(-2*pi*a9*a7 - 4.0*pi*a1)" => "a18")
    s = replace(s, "(a10 + 2.0*a2 + 5.0)" => "a19")
    s = replace(s, "a18*a8*a3 + 2*pi*a19*a8*a4" => "a20")
    s = replace(s, "a15*(40.0*pi^3*a15*a9*a7 - 40.0*pi^2*a15*a16*a10/(a14) - 20.0*pi^2*a15*a16*a9*a1*a7/(a14*a11) - 16.0*pi^2*a15*a16*a9*a1*a7/(alpha*a12*a13^3) - 10.0*pi*a15*(-2.0*pi^2*a14*a2/a11 - 1.6*pi^2*alpha*a12*a13*a2 + 3.2*pi^2*alpha*a12*a13*a1^2/a11 + 0.56*pi^2*alpha*a12*a1^2)*a9*a7/(a14) - 10.0*pi*a15*a16^2*a9*a7/(alpha^2*g*a13^4*a11))" => "a21")
    return s
end

sp.@syms alpha, beta, gamma, eta0

function compute_source_terms(etasol, vsol, bfunc, g)
    (t, x) = sp.symbols("t, x", real=true)
    eta = etasol(t, x)
    v = vsol(t, x)
    b = bfunc(x)
    D = eta0 - b
    h = eta - b
    alpha_hat = sqrt(alpha*sqrt(g*D)*D^2)
    beta_hat = beta*D^3
    gamma_hat = gamma*sqrt(g*D)*D^3
    hv = h * v

    y = alpha_hat*sp.diff(alpha_hat*sp.diff(eta, x), x)
    v_x = sp.diff(v, x)

    # Written in conservative variables:
#     s1 = sp.simplify(sp.diff(h, t) + sp.diff(hv, x) - sp.diff(y, x))
#     println("1st equation:")
#     s1 |> sp.string |> math_replacements |> println
#
#     s2 = sp.simplify(sp.diff(hv, t) + sp.diff(hv*v, x) + g*h*sp.diff(eta, x) - sp.diff(v*y, x) - sp.diff(beta_hat*v_x, x, t) - 1/2*sp.diff(gamma_hat*v_x, x, x) - 1/2*sp.diff(gamma_hat*sp.diff(v_x, x), x))
#     println("2nd equation in conservative variables:")
#     s2 |> sp.string |> math_replacements |> println
#
#     # When writing the equations in primitive variables (eta, v) instead of conservative ones (h, hv), we apply the product rule in time
#     # and plug the first equation into the second. Thus, we need to take the contribution of the source term from the first equation
#     # also into account for the source term in the second equation, when it is written in primitive variables (as done in DispersiveShallowWater.jl)
#     s2_prim = sp.simplify(s2 - s1*v)

    # Written in primitive variables
    y_x = sp.diff(y, x)
    hv_x = sp.diff(hv, x)
    v_t = sp.diff(v, t)
    s1 = sp.diff(eta, t) + hv_x - y_x
    println("1st equation:")
    s1 |> sp.string |> math_replacements |> println
#     s1 = sp.simplify(s1) # Simplifying takes too long
    s2_prim = h * v_t - sp.diff(beta_hat * sp.diff(v_t, x), x) +
              1//2 * (sp.diff(hv*v, x) + h * v * v_x - v * sp.diff(hv, x)) +
              g * h * sp.diff(eta, x) -
              1//2 * (sp.diff(v * y, x) - v * y_x + y * v_x) -
              1//2 * sp.diff(gamma_hat * v_x, x, x) -
              1//2 * sp.diff(gamma_hat * sp.diff(v_x, x), x)
#     s2_prim = sp.simplify(s2_prim) # Simplifying takes too long
    println("2nd equation in primitive variables:")
    s2_prim |> sp.string |> math_replacements |> println
end

function bfunc_constant(x)
    sp.@syms D
    b = eta0 - D
    return b
end

sp.@syms g

function etasol_manufactured(t, x)
    return exp(t) * cospi(2 * (x - 2 * t))
end

function vsol_manufactured(t, x)
    return exp(t / 2) * sinpi(2 * (x - t / 2))
end

println("Manufactured constant b:")
compute_source_terms(etasol_manufactured, vsol_manufactured, bfunc_constant, g)
println("-"^100)

bfunc(x) = -5.0 - 2.0*cospi(2*x)

# This may take a while
println("Manufactured variable b:")
compute_source_terms(etasol_manufactured, vsol_manufactured, bfunc, g)
