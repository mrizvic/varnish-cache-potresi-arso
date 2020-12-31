# varnish-cache-potresi-arso
Varnish konfiguracija za caching spletne strani potresi.arso.gov.si.
Ob povečanem obisku se namreč strežnik omenjene spletne strani sesuje. Varnish vidim kot najlažjo možno rešitev za obvladovanje prometnih špic. Prednost je namreč v tem, da ni potrebno popravljati backend kode.

Kaj je varnish?

Si bom kar sposodil dva odstavka iz https://www.tecmint.com/install-varnish-cache-for-nginx-on-centos-rhel-8/

> Varnish Cache (commonly referred to as Varnish) is an open-source, powerful and fast reverse-proxy HTTP accelerator with modern architecture and flexible configuration language. Being a reverse proxy simply means it is a software that you can deploy in front of your web server (which is the origin server or backend) such as Nginx, to receive clients HTTP requests and forward to the origin server for processing. And it delivers the response from the origin server to clients.
>
> Varnish acts as a middleman between Nginx and clients but with some performance benefits. Its main purpose is to make your applications load faster, by working as a caching engine. It receives requests from clients and forwards them to the backend once to cache the requested content (store files and fragments of files in memory). Then all future requests for exactly similar content will be served from the cache.

Uradna dokumentacija je na https://varnish-cache.org/

Odlicna dokumentacija je pa tule https://docs.varnish-software.com/ ter https://info.varnish-software.com/the-varnish-book

Postavitev na kratko pa takole:
```
apt install varnish
```
Datoteko `default.vcl` skopiraj v `/etc/varnish/`.

Preden poženeš servis popravi ustrezen systemd unit (ali naredi override), da bo poslušal na portu 80.
```
ExecStart=/usr/sbin/varnishd -j unix,user=vcache -F -a :80 -T localhost:6082 -f /etc/varnish/default.vcl -S /etc/varnish/secret -s 
```

Start in status:
```
systemctl enable --now varnish
systemctl status varnish
```

V lokalni DNS dodaj A record, da bo potresi.arso.gov.si kazal na IP kjer teče varnish.
Če nimaš dostopa do DNS dodaj vnos v `C:\Windows\System32\drivers\etc\hosts` na wintendo platformah ali v `/etc/hosts` na večini ostalih OS. Primer:
```
10.172.19.155 potresi.arso.gov.si
```

Ko imaš vse up and running greš na http://potresi.arso.gov.si in če je vse OK bi moral brskalnik poslati request na varnish, le-ta pa naprej na backend (ARSO) strežnik. Vsi responsi bodo v cacheu skladno z nastavitvami `beresp.ttl`, `beresp.grace` in `beresp.keep` nastavitvami v `/etc/varnish/default.vcl`

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

Za proper rešitev je treba pred varnish postaviti še haproxy (lahko tudi apache ali nginx v vlogi reverse proxy) z ustreznimi certifikati, da offloadaš SSL in potem proxiraš na varnish za cachiranje.

