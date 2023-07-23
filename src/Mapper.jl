module Mapper

using ..Model, ..Contexts, ..ConnectionPools
using SQLite, DBInterface, Strapping, Tables

const DB_POOL = Ref{ConnectionPools.Pod{ConnectionPools.Connection{SQLite.DB}}}()
const COUNTER = Ref{Int64}(0)

function init(dbfile)
    new = () -> SQLite.DB(dbfile)
    DB_POOL[] = ConnectionPools.Pod(SQLite.DB, Threads.nthreads(), 60, 1000, new)
    if !isfile(dbfile)
        db = SQLite.DB(dbfile)
        DBInterface.execute(db, """
            CREATE TABLE shoppingcart (
                id INTEGER,
                customerid INTEGER,
                items TEXT
            )
        """)
        DBInterface.execute(db, """
            CREATE INDEX idx_shoppingcart_id ON shoppingcart (id)
        """)
        DBInterface.execute(db, """
            CREATE INDEX idx_shoppingcart_customerid ON shoppingcart (customerid)
        """)
        DBInterface.execute(db, """
            CREATE INDEX idx_shoppingcart_id_customerid ON shoppingcart (id, customerid)
        """)
        DBInterface.execute(db, """
            CREATE TABLE customer (
                id INTEGER PRIMARY KEY,
                username TEXT,
                password TEXT
            )
        """)
    end
    return
end

function execute(sql, params; executemany::Bool=false)
    withconnection(DB_POOL[]) do db
        stmt = DBInterface.prepare(db, sql)
        if executemany
            DBInterface.executemany(stmt, params)
        else
            DBInterface.execute(stmt, params)
        end
    end
end

function insert(cart)
    customer = Contexts.getcustomer()
    cart.customerid = customer.id
    execute("""
        INSERT INTO shoppingcart (id, customerid, items) VALUES(?, ?, ?)
    """, columntable(Strapping.deconstruct(cart)); executemany=true)
    return
end

function create!(cart::ShoppingCart)
    cart.id = COUNTER[] += 1
    insert(cart)
    return
end

function update(cart)
    delete(cart.id)
    insert(cart)
    return
end

function get(id)
    customer = Contexts.getcustomer()
    cursor = execute("SELECT * FROM shoppingcart WHERE id = ? AND customerid = ?", (id, customer.id))
    return Strapping.construct(ShoppingCart, cursor)
end

function delete(id)
    customer = Contexts.getcustomer()
    execute("DELETE FROM shoppingcart WHERE id = ? AND customerid = ?", (id, customer.id))
    return
end

function getAllAlbums()
    customer = Contexts.getcustomer()
    cursor = execute("SELECT * FROM shoppingcart WHERE customerid = ?", (customer.id,))
    return Strapping.construct(Vector{ShoppingCart}, cursor)
end

function create!(customer::Customer)
    x = execute("""
        INSERT INTO customer (username, password) VALUES (?, ?)
    """, (customer.username, customer.password))
    customer.id = DBInterface.lastrowid(x)
    return
end

function get(customer::Customer)
    cursor = execute("SELECT * FROM customer WHERE username = ?", (customer.username,))
    return Strapping.construct(Customer, cursor)
end

end
