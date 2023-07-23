module Model

import Base: ==

using StructTypes

export ShoppingCart, Customer


mutable struct ShoppingCart
    id::Int64
    customerid::Int64
    items::Vector{String}
end

==(x::ShoppingCart, y::ShoppingCart) = x.id == y.id
ShoppingCart() = ShoppingCart(0, 0, String[])
ShoppingCart(items) = ShoppingCart(0, 0, items)
StructTypes.StructType(::Type{ShoppingCart}) = StructTypes.Mutable()
StructTypes.idproperty(::Type{ShoppingCart}) = :id


mutable struct Customer
    id::Int64
    username::String
    password::String
end

==(x::Customer, y::Customer) = x.id == y.id
Customer() = Customer(0, "", "")
Customer(username::String, password::String) = Customer(0, username, password)
Customer(id::Int64, username::String) = Customer(id, username, "")
StructTypes.StructType(::Type{Customer}) = StructTypes.Mutable()
StructTypes.idproperty(::Type{Customer}) = :id


end
