module Auth

using StructTypes, Dates, JWTs, HTTP
using ..Model


const JWT_AUTH_KEYS = Ref{JWKSet}()
const DATE_FORMAT = DateFormat("e, dd u yyyy HH:MM:SS G\\MT") # Wed, 21 Oct 2015 07:28:00 GMT
const JWT_TOKEN_COOKIE_NAME = "X-MusicAlbums-Jwt-Token"

struct UnauthenticatedException <: Exception end


function init(authkeysfile)
    JWT_AUTH_KEYS[] = JWKSet(authkeysfile)
    refresh!(JWT_AUTH_KEYS[])
    return
end

function addtoken!(resp::HTTP.Response, customer::Customer)
    exp = Dates.now(Dates.UTC) + Dates.Hour(12)
    payload = Dict("iss"=>"ShoppingCarts.jl", "exp"=>Dates.datetime2unix(exp), "aud"=>customer.username, "uid"=>customer.id)
    jwt = JWT(; payload=payload)
    keyid = first(first(JWT_AUTH_KEYS[].keys))
    sign!(jwt, JWT_AUTH_KEYS[], keyid)
    HTTP.setheader(resp, "Set-Cookie" => "$JWT_TOKEN_COOKIE_NAME=$(join([jwt.header, jwt.payload, jwt.signature], '.')); Expires=$(Dates.format(exp, DATE_FORMAT))")
    HTTP.setheader(resp, JWT_TOKEN_COOKIE_NAME => join([jwt.header, jwt.payload, jwt.signature], '.'))
    return resp
end


function Customer(req::HTTP.Request)
    if HTTP.hasheader(req, "Cookie")
        cookies = filter(x->x.name == JWT_TOKEN_COOKIE_NAME, HTTP.cookies(req))
        if !isempty(cookies) && !isempty(cookies[1].value)
            jwt = JWT(; jwt=cookies[1].value)
            verified = false
            for kid in JWT_AUTH_KEYS[].keys
                validate!(jwt, JWT_AUTH_KEYS[], kid[1])
                verified |= isverified(jwt)
            end
            if verified
                parts = claims(jwt)
                return Customer(parts["uid"], parts["aud"])
            end
        end
    elseif HTTP.hasheader(req, JWT_TOKEN_COOKIE_NAME)
        jwt = JWT(; jwt=String(HTTP.header(req, JWT_TOKEN_COOKIE_NAME)))
        verified = false
        for kid in JWT_AUTH_KEYS[].keys
            validate!(jwt, JWT_AUTH_KEYS[], kid[1])
            verified |= isverified(jwt)
        end
        if verified
            parts = claims(jwt)
            return Customer(parts["uid"], parts["aud"])
        end
    end
    throw(UnauthenticatedException())
end

end
