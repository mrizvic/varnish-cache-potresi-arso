#
# This is an example VCL file for Varnish.
#
# It does not do anything by default, delegating control to the
# builtin VCL. The builtin VCL is called when there is no explicit
# return statement.
#
# See the VCL chapters in the Users Guide at https://www.varnish-cache.org/docs/
# and https://www.varnish-cache.org/trac/wiki/VCLExamples for more examples.

# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
vcl 4.0;

# Default backend definition. Set this to point to your content server.
backend default {
    # potresi.arso.gov.si is an alias for hmljn.arso.gov.si.
    # hmljn.arso.gov.si has address 193.2.208.18
    .host = "193.2.208.18";
    .port = "80";
}

sub vcl_recv {
    # Happens before we check if we have this in cache already.
    #
    # Typically you clean up the request here, removing cookies you don't need,
    # rewriting the request, etc.

    # Ce tole ni unset potem bo vedno cache miss
    unset req.http.cookie;

}

sub vcl_backend_fetch {
    # Called before sending the backend request.
    # In this subroutine you typically alter the request before it gets to the backend.

    # Forcamo host header
    set bereq.http.Host = "potresi.arso.gov.si";
    
    # Za PoC tole ne bomo kazali naokrog
    unset bereq.http.X-Forwarded-For;
    unset bereq.http.X-Forwarded-Proto;
    unset bereq.http.X-Varnish;
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    #
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.
    
    # Glej https://varnish-cache.org/docs/trunk/users-guide/vcl-grace.html
    # Slika pove več https://docs.varnish-software.com/tutorials/object-lifetime/
    set beresp.ttl = 1m;
    set beresp.grace = 2m;
    set beresp.keep = 3m;

    # Ce tole ni unset potem bo vedno cache miss
    unset beresp.http.cookie;
    unset beresp.http.Set-Cookie;
    unset beresp.http.Cache-Control;

}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.
}
