FROM julia:1.9

RUN apt-get update && apt-get install -y gcc
ENV JULIA_PROJECT @.
WORKDIR /home

ENV VERSION 1
ADD . /home

RUN julia deploy/packagecompile.jl

EXPOSE 8080

ENTRYPOINT ["julia", "-JShoppingCarts.so", "-t", "2", "-e", "ShoppingCarts.run(\"test/carts.sqlite\", \"file:///home/resources/authkeys.json\")"]
