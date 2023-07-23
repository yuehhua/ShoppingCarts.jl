using ShoppingCarts
using Test

const DBFILE = joinpath(dirname(pathof(ShoppingCarts)), "../test/carts.sqlite")
const AUTHFILE = "file://" * joinpath(dirname(pathof(ShoppingCarts)), "../resources/authkeys.json")

server = @async ShoppingCarts.run(DBFILE, AUTHFILE)

Client.createCustomer("yuehhua", "il0veju1ia")
customer = Client.loginCustomer("yuehhua", "il0veju1ia")

using HTTP; HTTP.CookieRequest.COOKIEJAR

cart1 = Client.createShoppingCart(["Apple", "Sushi"])

@test Client.getShoppingCart(cart1.id) == cart1

push!(cart1.items, "Bike")
cart2 = Client.updateShoppingCart(cart1)
@test length(cart2.items) == 3
@test length(Client.getShoppingCart(cart1.id).items) == 3

Client.deleteShoppingCart(cart1.id)