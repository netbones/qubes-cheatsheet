## Qubes OS Quirks
---

### Documentation for the HP EliteBook 820 G3

These are current known working configurations for the HP EliteBook 820 G3.

---
#### *0. Dom0*

* Template:

`AdminVM`

* Basic

* Advanced

`Default Disp template: default-dvm`

* Firewall Rules

* Devices

* Applications

* Services

---

#### *1. Sys-net*

* Basic

  Net Qube/Net VM:
  `current i.e sys-net`

* Advanced

  `Initial Mem: 400mb`

  `Max: `

  `VCPUs: 2`

  Kernel: `provided by Qube (current)`

  `Virtualization: HVM`

* Firewall Rules

* Devices

* Applications

* Services

 `clocksync`

 `qubes-update-proxy`

 ---

#### 2. *Sys-firewall*

* Template: 

`whonix-workstation-17-dvm`

* Basic

  Net Qube/Net VM: 
  
  `sys-net`

* Advanced:

  `Initial Mem: 400mb`

  `Max: 4000mb`

  `VCPUs: 2`

  `Default Disp template: whonix-workstation`

  `Kernel 6.1.62-1.fc37`

  `Virtualization: PVH`
  `
* Firewall Rules:

* Devices:

* Applications:

* Services:

---

## Notes

### To check the IP rules in the qube:

>**$GURU MEDITATION:** ```sudo nft list ruleset```

To allow incoming IPv4 ICMP:

```sudo nft add rule ip qubes custom-input meta l4proto icmp accept```

To make it persistent add it in ```/rw/config/rc.local.```

Also check [this Firewall guide]https://www.qubes-os.org/doc/firewall/):

### Network service qubes

>**$GURU MEDITATION:** `qvm-ls -n`

Qubes does not support running any networking services (e.g. VPN, local DNS server, IPS, …) directly in a qube that is used to run the Qubes firewall service (usually sys-firewall) for good reasons. In particular, if you want to ensure proper functioning of the Qubes firewall, you should not tinker with nftables rules in such qubes.

Instead, you should deploy a network infrastructure such as

```sys-net <--> sys-firewall-1 <--> network service qube <--> sys-firewall-2 <--> [client qubes]```

Thereby sys-firewall-1 is only needed if you have other client qubes connected there, or you want to manage the traffic of the local network service qube. The sys-firewall-2 proxy ensures that:

    Firewall changes done in the network service qube cannot render the Qubes firewall ineffective.
    Changes to the Qubes firewall by the Qubes maintainers cannot lead to unwanted information leakage in combination with user rules deployed in the network service qube.
    A compromise of the network service qube does not compromise the Qubes firewall.

If you adopt this model, you should be aware that all traffic will arrive at the network service qube appearing to originate from the IP address of sys-firewall-2