module ShoppingCarts

export Model, Mapper, Service, EndPoints, Client

include("ConnectionPools.jl")
using .ConnectionPools

include("Workers.jl")
using .Workers

include("Model.jl")
using .Model

include("Auth.jl")
using .Auth

include("Contexts.jl")
using .Contexts

include("Mapper.jl")
using .Mapper

include("Service.jl")
using .Service

include("EndPoints.jl")
using .EndPoints

include("Client.jl")
using .Client

function run(dbfile, authkeysfile)
    Workers.init()
    Mapper.init(dbfile)
    Auth.init(authkeysfile)
    EndPoints.run()
end

end
