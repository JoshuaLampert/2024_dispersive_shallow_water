using DispersiveShallowWater
using Printf
using PrettyTables
using LaTeXStrings

const EXAMPLES_DIR = joinpath(@__DIR__, "elixirs")

table_str_BBM_BBM = []
table_str_SK = []

accuracy_orders = [2, 4, 6]

for accuracy_order in accuracy_orders
    trixi_include(joinpath(EXAMPLES_DIR, "bbm_bbm_variable_bathymetry_1d_well_balanced.jl"), accuracy_order = accuracy_order)
    l2, _ = analysis_callback(sol)
    push!(table_str_BBM_BBM, [string(accuracy_order), @sprintf("%.2e", l2[1]), @sprintf("%.2e", l2[2])])

    trixi_include(joinpath(EXAMPLES_DIR, "svaerd_kalisch_1d_well_balanced.jl"), accuracy_order = accuracy_order)
    l2, _ = analysis_callback(sol)
    push!(table_str_SK, [string(accuracy_order), @sprintf("%.2e", l2[1]), @sprintf("%.2e", l2[2])])
end


tf_latex_booktabs_mod = LatexTableFormat(
    top_line = "\\toprule",
    header_line = "\\midrule",
    mid_line = "\\midrule",
    bottom_line = "\\bottomrule",
    left_vline = "",
    mid_vline = "",
    right_vline = "",
    header_envs = String[],
    subheader_envs = ["texttt"],
)

println("\\begin{table}[!htb]")
println("\\caption{\$L^2\$-error for lake-at-rest test case for different orders of accuracy \$p\$.}")
println("\\label{table:well_balanced_errors}")
println("\\begin{subtable}{.5\\linewidth}")
println("\\subcaption{BBM-BBM equations}")
println("\\centering")
pretty_table(permutedims(hcat(table_str_BBM_BBM...)), header = ["Order", L"\eta", "v"], backend = Val(:latex), tf = tf_latex_booktabs_mod, alignment = :c)
println("\\end{subtable}%")
println("\\begin{subtable}{.5\\linewidth}")
println("\\subcaption{Svärd-Kalisch equations}")
println("\\centering")
pretty_table(permutedims(hcat(table_str_SK...)), header = ["Order", L"\eta", "v"], backend = Val(:latex), tf = tf_latex_booktabs_mod, alignment = :c)
println("\\end{subtable}%")
println("\\end{table}")
