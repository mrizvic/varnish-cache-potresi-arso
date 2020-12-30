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

Če te zanima kaj se dogaja znotraj varnisha
```
varnishlog
```
