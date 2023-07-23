module Service

using ..Model, ..Mapper

function createShoppingCart(obj)
    @assert haskey(obj, :items) && !isempty(obj.items)
    cart = ShoppingCart(obj.items)
    Mapper.create!(cart)
    return cart
end

function getShoppingCart(id::Int64)::ShoppingCart
    Mapper.get(id)
end

function updateShoppingCart(id, updated)
    cart = Mapper.get(id)
    cart.items = updated.items
    Mapper.update(cart)
    # delete!(ExpiringCaches.getcache(getShoppingCart), (id,))
    return cart
end

function deleteShoppingCart(id)
    Mapper.delete(id)
    # delete!(ExpiringCaches.getcache(getShoppingCart), (id,))
    return
end

function createCustomer(customer)
    @assert haskey(customer, :username) && !isempty(customer.username)
    @assert haskey(customer, :password) && !isempty(customer.password)
    customer = Customer(customer.username, customer.password)
    Mapper.create!(customer)
    return customer
end

function loginCustomer(customer)
    persistedUser = Mapper.get(customer)
    if persistedUser.password == customer.password
        persistedUser.password = ""
        return persistedUser
    else
        throw(Auth.UnauthenticatedException())
    end
end


end
