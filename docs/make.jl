using ShoppingCarts
using Documenter

DocMeta.setdocmeta!(ShoppingCarts, :DocTestSetup, :(using ShoppingCarts); recursive=true)

makedocs(;
    modules=[ShoppingCarts],
    authors="Yueh-Hua Tu <a504082002@gmail.com>",
    repo="https://github.com/yuehhua/ShoppingCarts.jl/blob/{commit}{path}#{line}",
    sitename="ShoppingCarts.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://yuehhua.github.io/ShoppingCarts.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/yuehhua/ShoppingCarts.jl",
    devbranch="main",
)
