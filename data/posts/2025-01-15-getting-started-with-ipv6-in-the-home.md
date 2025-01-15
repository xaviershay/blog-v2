---
title: Getting Started with IPv6 in the Home
---

I recently enabled IPv6 on my home network.

I have an AmpliFi router, which features an IPv6 switch. I turned it on, keeping the default DHCP6 setting as my ISP supports IPv6. With this one change:

* My devices now receive an IPv6 address in addition to IPv4. (See below.)
* When I visit websites they connect using IPv6 by default. (See [Test IPv6](https://test-ipv6.com/) to validate.)
* Incoming IPv6 traffic is blocked by the router. (Use [Online IPv6 Port Scanner](https://ipv6.chappell-family.com/ipv6tcptest/) to validate.)

Let's explore the new IP address in more detail.

```
$ ip -6 addr show | grep -v valid_lft
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 state UNKNOWN qlen 1000
    inet6 ::1/128 scope host 
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP qlen 1000
    inet6 2400:3740:205:2f00:be24:11ff:fe4e:917a/64 scope global dynamic mngtmpaddr 
    inet6 fdaf:78a1:4860:2:be24:11ff:fe4e:917a/64 scope global dynamic mngtmpaddr 
    inet6 fe80::be24:11ff:fe4e:917a/64 scope link 
```

This host has four IPv6 addresses:
* `::1` is the loopback address, equivalent to `127.0.0.1`.
* `2400:3740:205:2f00:*` is a globally routable address. Any IPv6 host on the internet can route to this machine using this address. Unlike IPv4, NAT generally isn't required for IPv6 because we haven't (and aren't going to) run out of addresses. This simplifies things a lot.
* `fdaf:*` is "Unique Local Address" that is specific to my network, and not globally routable. The default configuration of my router causes this address to exist, it isn't present by default or in all configurations.
* `fe80:*` is the "link local" address, and IPv6 requires one on every interface. (`::1` on `lo` is effectively link local also.)

How are these IPs generated or assigned? Let's start with the router. This what
we get with an AmpliFi router and isn't configurable. Your router may be
different.

```
$ sudo apt install ndisc6
$ rdisc6 -v eth0
# Output edited for brevity
Soliciting ff02::2 (ff02::2) on eth0...

Stateful address conf.    :           No
Stateful other conf.      :          Yes
 Prefix                   : 2400:3740:205:2f00::/64
  Autonomous address conf.:          Yes
 Prefix                   : fdaf:78a1:4860:2::/64
  Autonomous address conf.:          Yes
```

This tells us:

* DHCP is _not_ available for address assignment (`Stateful address conf: No`)
* DHCP is available for other config, e.g. DNS (`Stateful other conf: Yes`)
* Hosts should generate their own addresses for both of the provided global and
* ULA prefixes (`Autonomous address conf: Yes`). That provides for two of the
  four addresses seen before. The other two are "defaults" and are always
  present.

If the router loses a connection to the internet, the `2400:*` prefix
dissappears. (Validate by unplugging WAN from router.) This will become relevant
when we come to DNS. 

How do hosts generate their own addresses? There are a few different options,
and they can result in either stable or dynamic addresses. For servers, we want
stable addresses so we can point DNS at them. For clients in dynamic mode, they
can regularly generate _new_ addresses to help with privacy preservation when
making outbound connections.

Address generation configuration lives in `/etc/sysctl.conf`, though your system
(like mine) may be relying on defaults instead of explicit configuration. To
check current configuration:

```
$ cat /proc/sys/net/ipv6/conf/eth0/use_tempaddr
0
$ cat /proc/sys/net/ipv6/conf/eth0/addr_gen_mode 
0
```

`0` for the first means a fixed address algorithm is being used on `eth0`. `0`
on the second means to use `EUI-64`, a method for generating a stable ID based
on MAC address that literally puts the MAC address in the IP address with some
padding. A give away is the `ff:fe` value in the middle of the last 64 bits of
the address, which is a constant padding value.

`RFC 7217` is a newer method for stable addressing that creates a hash
consisting of several inputs including the MAC address but also a local secret
key, interface name, and network ID. This doesn't expose the MAC address, but
also will change if the server is moved or reimaged -- which may or may not be
what you want. It can be enabled by setting `addr_gen_mode = 3` in `/etc/sysctl.conf`.

```
# Temporary/live
$ sudo sysctl -w net.ipv6.conf.eth0.addr_gen_mode=3

# Permanent
$ cat /etc/sysctl.conf | grep addr_gen_mode
net.ipv6.conf.eth0.addr_gen_mode=3

# Bounce interface to regenerate IPs
$ sudo ip link set eth0 down; sleep 1; sudo ip link set eth0 up
$ ip -6 addr show | grep -v valid_lft
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 state UNKNOWN qlen 1000
    inet6 ::1/128 scope host 
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP qlen 1000
    inet6 fdaf:78a1:4860:2:1540:e03f:d755:f840/64 scope global dynamic mngtmpaddr stable-privacy 
    inet6 2400:3740:205:2f00:c2c:5a86:649b:a2e3/64 scope global dynamic mngtmpaddr stable-privacy 
    inet6 fe80::399d:7384:37d1:c3f9/64 scope link stable-privacy 
```

Note the new IPs and `stable-privacy` flag.