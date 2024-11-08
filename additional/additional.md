
## Troubleshooting

SEE: **Qubes VM troubleshooting](https://www.qubes-os.org/doc/vm-troubleshooting/)**

https://forum.qubes-os.org/t/qubes-salt-beginners-guide/20126

### [WARNING] top_file merging strategy is set to 'merge' and multiple top files were found. Merging order in not deterministic, it may be desirable to either set top_file_merging_strategy  to 'same' or use the 'env_order' configuration parameter to specify the merging order.

set these keys in /etc/salt/minion.d/f_defaults.conf:

```
top_file_merging_strategy: merge
env_order: ['base', 'user']
```

### [CRITICAL] Specified ext_pillar interface qvm_prefs is unavailable.

Excute the following commands:

 ```
qubesctl saltutil.clear_cache
qubesctl saltutil.sync_all refresh=true

qubesctl saltutil.sync_all 

sudo qubes state.highstate
 ```


 
 ### TLDR

```
qubesctl saltutil.clear_cache
qubesctl top.enable qvm.sys-net qvm.sys-firewall qvm.work qvm.personal qvm.untrusted qvm.vault
```
### for Whonix:
```qubesctl top.enable qvm.sys-whonix qvm.anon-whonix
```
### for USB VM (sys-usb):
```
qubesctl top.enable qvm.sys-usb
```
### apply all the above
```
qubesctl state.highstate
```

### for GUI-vm
```
qubesctl top.enable qvm.sys-gui
qubesctl top.enable qvm.sys-gui pillar=True
qubesctl --all state.highstate
```

### Whonix not starting
There were some recent Kernel updates in Qubes. In the Settings | Advanced for the TemplateVM if I switch from the (new) default 5.13.6-1.fc25 kernel back to an earlier version 5.12.14-1.fc25 then things start working normally again.

If I leave the AppVM based on this template at 5.12.14-1.fc25, then it works as well.

It seems that this particular Debian 10 template is the only one that breaks with the newer kernel. This template has some Snaps and other software installed. Other Debian (full & minimal) and Fedora templates appear to be working.

similer kernal issue, libexenlight fails https://forum.qubes-os.org/t/libxenlight-failed-to-create-new-domain/27032/12
## Templates, are handled through RPC policies 

1. For example, you could create the file /etc/qubes/policy.d/30-user.policy in dom0 with content similar to the following:

### HTTP proxy for downloading updates
### Update Whonix templates through sys-whonix
qubes.UpdatesProxy      *       @tag:whonix-updatevm    @default                allow target=sys-whonix
### Deny Whonix templates from using any other qube to update
qubes.UpdatesProxy      *       @tag:whonix-updatevm    @anyvm                  deny
### Update all other templates through sys-firewall and deny everything else
qubes.UpdatesProxy      *       @type:TemplateVM        @default                allow target=sys-firewall
qubes.UpdatesProxy      *       @anyvm                  @anyvm

#DNS
https://forum.qubes-os.org/docs?topic=13749