# Setup packages
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

import SymPy; sp = SymPy

function math_replacements(s)
    s = replace(s, "cos(pi*" => "cospi(")
    s = replace(s, "sin(pi*" => "sinpi(")
    s = replace(s, "cos(2*pi*" => "cospi(2*")
    s = replace(s, "sin(2*pi*" => "sinpi(2*")
    s = replace(s, "cospi(2*x)" => "a1")
    s = replace(s, "sinpi(2*x)" => "a2")
    s = replace(s, "cospi((t - 2*x))" => "a3")
    s = replace(s, "sinpi((t - 2*x))" => "a4")
    s = replace(s, "sinpi((2*t - 4*x))" => "a5")
    s = replace(s, "sinpi((4*t - 2*x))" => "a6")
    s = replace(s, "cospi((4*t - 2*x))" => "a7")
    return s
end


function compute_source_terms(etasol, vsol, Dfunc, g; rational = true)
    (t, x) = sp.symbols("t, x", real=true)
    eta = etasol(t, x, Dfunc, g)
    v = vsol(t, x, Dfunc, g)
    D = Dfunc(x)

    println("1st equation:")
    sp.simplify(sp.diff(eta, t) + sp.diff(D*v, x) + sp.diff(eta*v, x) - 1/6*sp.diff(D^2*sp.diff(eta, x, t), x), rational = rational) |>
        sp.string |> math_replacements |> println

    println("2nd equation:")
    sp.simplify(sp.diff(v, t) + g*sp.diff(eta, x) + sp.diff(v^2/2, x) - 1/6*sp.diff(D^2*sp.diff(v, t), x, x), rational = rational) |>
        sp.string |> math_replacements |> println
end

function etasol_soliton(t, x, D, g)
    rho = 18/5
    c = 5/2*sqrt(g*D(x))
    xi = x - c*t
    theta = 1/2*sqrt(rho)*xi/D(x)
    return 15/4*D(x)*(2*sech(theta)^2 - 3*sech(theta)^4)
end
function vsol_soliton(t, x, D, g)
    rho = 18/5
    c = 5/2*sqrt(g*D(x))
    xi = x - c*t
    theta = 1/2*sqrt(rho)*xi/D(x)
    return 15/2*sqrt(g*D(x))*sech(theta)^2
end

function Dfunc_constant(x)
    sp.@syms D
    return D
end

sp.@syms g

println("Soliton constant D:")
compute_source_terms(etasol_soliton, vsol_soliton, Dfunc_constant, g; rational = false)
println("-"^100)

function etasol_manufactured(t, x, D, g)
    return exp(t) * cospi(2*(x - 2*t))
end

function vsol_manufactured(t, x, D, g)
    return exp(t/2) * sinpi(2*(x - t/2))
end


println("Manufactured constant D:")
compute_source_terms(etasol_manufactured, vsol_manufactured, Dfunc_constant, g)
println("-"^100)

Dfunc_cos(x) = 5.0 + 2.0*cospi(2*x)

println("Manufactured variable D:")
compute_source_terms(etasol_manufactured, vsol_manufactured, Dfunc_cos, g)
