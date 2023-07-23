module EndPoints

using Dates, HTTP, JSON3
using ..Model, ..Service, ..Auth, ..Contexts, ..Workers


const HOST = "0.0.0.0"
const PORT = 8080
const ROUTER = HTTP.Router()


createShoppingCart(req) = Service.createShoppingCart(JSON3.read(req.body))::ShoppingCart
HTTP.register!(ROUTER, "POST", "/cart", createShoppingCart)

getShoppingCart(req) = Service.getShoppingCart(parse(Int, HTTP.URIs.splitpath(req.target)[2]))::ShoppingCart
HTTP.register!(ROUTER, "GET", "/cart/*", getShoppingCart)

updateShoppingCart(req) = Service.updateShoppingCart(parse(Int, HTTP.URIs.splitpath(req.target)[2]), JSON3.read(req.body, ShoppingCart))::ShoppingCart
HTTP.register!(ROUTER, "PUT", "/cart/*", updateShoppingCart)

deleteShoppingCart(req) = Service.deleteShoppingCart(parse(Int, HTTP.URIs.splitpath(req.target)[2]))
HTTP.register!(ROUTER, "DELETE", "/cart/*", deleteShoppingCart)

function contextHandler(req)
    withcontext(Customer(req)) do
        HTTP.Response(200, JSON3.write(ROUTER(req)))
    end
end


const AUTH_ROUTER = HTTP.Router(contextHandler)

function authenticate(customer::Customer)
    resp = HTTP.Response(200, JSON3.write(customer))
    return Auth.addtoken!(resp, customer)
end

createCustomer(req) = authenticate(Service.createCustomer(JSON3.read(req.body))::Customer)
HTTP.register!(AUTH_ROUTER, "POST", "/customer", createCustomer)

loginCustomer(req) = authenticate(Service.loginCustomer(JSON3.read(req.body, Customer))::Customer)
HTTP.register!(AUTH_ROUTER, "POST", "/customer/login", loginCustomer)


function requestHandler(req)
    start = Dates.now(Dates.UTC)
    @info (timestamp=start, event="ServiceRequestBegin", tid=Threads.threadid(), method=req.method, target=req.target)
    local resp
    try
        resp = AUTH_ROUTER(req)
    catch e
        if e isa Auth.UnauthenticatedException
            resp = HTTP.Response(401)
        else
            s = IOBuffer()
            showerror(s, e, catch_backtrace(); backtrace=true)
            errormsg = String(resize!(s.data, s.size))
            @error errormsg
            resp = HTTP.Response(500, errormsg)
        end
    end
    stop = Dates.now(Dates.UTC)
    @info (timestamp=stop, event="ServiceRequestEnd", tid=Threads.threadid(), method=req.method, target=req.target, duration=Dates.value(stop - start), status=resp.status, bodysize=length(resp.body))
    return resp
end

function run()
    HTTP.serve(requestHandler, HOST, PORT)
end

end
