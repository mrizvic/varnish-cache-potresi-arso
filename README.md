# varnish-cache-potresi-arso
Varnish konfiguracija za caching spletne strani potresi.arso.gov.si

Postavi varnish in ga bindaj na port 80
```
ExecStart=/usr/sbin/varnishd -j unix,user=vcache -F -a :80 -T localhost:6082 -f /etc/varnish/default.vcl -S /etc/varnish/secret -s 
```

V lokalni DNS dodaj A record, da bo potresi.arso.gov.si kazal na IP kjer teče varnish.

Opazuj varnish za hit/miss cache objekte
```
varnishncsa -F '%U%q %{Varnish:hitmiss}x'
```
Pri zgornjem velja tole:
```
       %U     The request URL without the query string. Defaults to '-' if not known.
       %q     The query string. Defaults to an empty string if not present.
       %{X}x  Extended variables:
              Varnish:hitmiss
                     One  of  the 'hit' or 'miss' strings, depending on whether the request was a cache hit or miss. Pipe, pass
                     and synth are considered misses.
```

Če te zanima kaj se dogaja znotraj varnisha
```
varnishlog
```
