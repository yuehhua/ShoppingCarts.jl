module Client

using HTTP, JSON3, Base64
using ..Model, ..Auth

const SERVER = Ref{String}("http://localhost:8080")
const AUTH_TOKEN = Ref{String}()

function createCustomer(username, password)
    body = (; username, password=base64encode(password))
    resp = HTTP.post(string(SERVER[], "/customer"), [], JSON3.write(body); cookies=true)
    if HTTP.hasheader(resp, Auth.JWT_TOKEN_COOKIE_NAME)
        AUTH_TOKEN[] = HTTP.header(resp, Auth.JWT_TOKEN_COOKIE_NAME)
    end
    return JSON3.read(resp.body, Customer)
end

function loginCustomer(username, password)
    body = (; username, password=base64encode(password))
    resp = HTTP.post(string(SERVER[], "/customer/login"), [], JSON3.write(body); cookies=true)
    if HTTP.hasheader(resp, Auth.JWT_TOKEN_COOKIE_NAME)
        AUTH_TOKEN[] = HTTP.header(resp, Auth.JWT_TOKEN_COOKIE_NAME)
    end
    return JSON3.read(resp.body, Customer)
end

function createShoppingCart(items)
    body = (; items)
    resp = HTTP.post(string(SERVER[], "/cart"), [Auth.JWT_TOKEN_COOKIE_NAME => AUTH_TOKEN[]], JSON3.write(body); cookies=true)
    return JSON3.read(resp.body, ShoppingCart)
end

function getShoppingCart(id)
    resp = HTTP.get(string(SERVER[], "/cart/$id"), [Auth.JWT_TOKEN_COOKIE_NAME => AUTH_TOKEN[]]; cookies=true)
    return JSON3.read(resp.body, ShoppingCart)
end

function updateShoppingCart(cart)
    resp = HTTP.put(string(SERVER[], "/cart/$(cart.id)"), [Auth.JWT_TOKEN_COOKIE_NAME => AUTH_TOKEN[]], JSON3.write(cart); cookies=true)
    return JSON3.read(resp.body, ShoppingCart)
end

function deleteShoppingCart(id)
    resp = HTTP.delete(string(SERVER[], "/cart/$id"), [Auth.JWT_TOKEN_COOKIE_NAME => AUTH_TOKEN[]]; cookies=true)
    return
end

end