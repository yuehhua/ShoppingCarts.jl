using Pkg
Pkg.instantiate()

using PackageCompiler

create_sysimage(:ShoppingCarts;
    sysimage_path="ShoppingCarts.so",
    precompile_execution_file="deploy/precompile.jl")
