module Contexts

export withcontext, getcustomer

using ..Model

mutable struct Context
    customer::Customer
end

function withcontext(f, customer::Customer)
    task_local_storage(:CONTEXT, Context(customer)) do
        f()
    end
end

function getcustomer()
    if haskey(task_local_storage(), :CONTEXT)
        return task_local_storage(:CONTEXT).customer
    else
        throw(ArgumentError("no valid context set"))
    end
end

end
