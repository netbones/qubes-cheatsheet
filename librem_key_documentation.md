## About the Librem Key

The Librem Key is a USB security token that can be used to store GPG keys, manage
passwords, provide multi-factor authentication, and can integrate with the Heads tamperevident BIOS to detect BIOS-level tampering. In this manual we will document how to perform
some of the most common operations with the Librem Key.

### What is a USB Security Token?

In case you haven’t heard of USB security tokens before, they are devices typically about the
size of a USB thumb drive that can act as “something you have” for multi-factor
authentication. With so many attacks on password logins, most security experts these days
recommend adding a second form of authentication (often referred to as “2FA” or “multi-factor
authentication”) in addition to your password so that if your password gets compromised the
attacker still has to compromise your second factor. USB security tokens work well as this
second factor because they are “something you have” instead of “something you know” like a
password is, and because they are portable enough you can just keep them in your pocket,
purse, or keychain and use them only when you need to login to a secure site.
In addition to multi-factor authentication, security tokens can also often store your private
GPG keys in a tamper-proof way so you can protect them from attackers who may
compromise your laptop. With your private keys on the security token, you can just insert the
key when you need to encrypt, decrypt, sign, or authenticate and then type in your PIN to
unlock the key. Since your private keys stay on the security token, even if an attacker
compromises your computer, they can’t copy your keys (and even if you leave the key
plugged in, they need to know your PIN to use it).

### About this Manual

This manual will guide you through some of the most common things you will do with your
Librem Key including using it to store GPG keys, integrating it with LUKS disk decryption, and
using it with the Heads tamper-evident BIOS. Because the Librem Key was made in
partnership with Nitrokey, it also works with Nitrokey’s own userspace software to perform
2FA and password management functions.

### Managing GPG Keys

Most of the tools (like GPG) you need to manage GPG keys on your Librem Key should
already be installed in PureOS or any other Linux distribution you might use with the
exception of scdaemon. This daemon manages OpenPGP smart cards on the system and exception of scdaemon.
This daemon manages OpenPGP smart cards on the system and
may not be installed by default, so use your package manager to install the “scdaemon”
package. If you want to use the command line you can type:
```
sudo apt install scdaemon
```
This will be necessary before you proceed to detect your OpenPGP Smart Card.
While your Librem Key can generate GPG keys on the device itself, doing so means you have
no backups. If you plan to use your GPG key for email encryption and signing, then you will
want to generate it on a computer so you can back it up. If you plan to just use the Librem Key
for tamper-evident boot with Heads, then you may not need a backup of the key since you can
still boot into your OS and can replace the current key in Heads with a different one later if you
ever lose the Librem Key.

### Detecting Your OpenPGP Smart Card

To detect your OpenPGP Smart Card, open a terminal application (hit the Purism logo key on
your keyboard and type “terminal” in the window that appears) and then type:

```
gpg --card-status

```

You will see output like:

```

Reader ...........: 20A0:4108:000000000000000000006143:0
Application ID ...: D2760001240103030005000061430000
Version ..........: 3.3
Manufacturer .....: ZeitControl
Serial number ....: 00006143
Name of cardholder: [not set]
Language prefs ...: de
Sex ..............: unspecified
URL of public key : [not set]
Login data .......: [not set]
Signature PIN ....: forced
Key attributes ...: rsa2048 rsa2048 rsa2048
Max. PIN lengths .: 64 64 64
PIN retry counter : 3 0 3
Signature counter : 4
Signature key ....: [none]
Encryption key....: [none]
Authentication key: [none]
General key info..: [none]

Change or Unblock a PIN on the Librem Key

```

By default the user PIN on the Librem Key is 123456 and the admin PIN is 12345678 which
are easy to guess. When you first get your Librem Key you will want to change the default PIN
to something else. First enter the interactive GPG card edit menu:
gpg --card-edit

Now in the gpg/card> prompt type admin to enter admin mode and then passwd to change
the PIN on your Librem Key:

```
admin
passwd
```

If you forget your PIN or enter it incorrectly too many times, the smart card will automatically
block that user PIN and you will have to enter your GPG admin PIN to unlock it. This uses the
same commands as to change the PIN:

```
admin
passwd
```

Once you are finished, you can type quit to exit. If you get stuck, type help for more
documentation on the available commands.

### Generate GPG Keys On Your Computer

For most people facing average threats, it’s better to generate the GPG keys on your
computer, back them up, and then transfer them to your Librem Key instead of generating
them directly on the Librem Key. Otherwise, if you lose the Librem Key you won’t be able to
restore your private GPG keys to a replacement.
The first step is to generate the key itself:

```
gpg --gen-key
```

This command will generate the master key used to sign any other GPG subkeys. You will be
prompted for the name and email address to use for this key. If you intend on using this key to
encrypt and sign email, be sure you specify the proper email address you intend to use.
When prompted to set an expiration date, either select the default (0) so the key doesn’t
expire, or specify a particular date that the key will expire. The idea behind key expiry is to
protect against an attacker who may have the capability in the future to crack your GPG
private key, given enough time. By setting an expiration date of, for instance, a few years into
the future, you are betting that it will take the attacker longer than that to crack the key or find
a flaw in the current encryption used for the key. By that time you will have switched to a new
key and all communications going forward will be protected. Whether you set an expiration
date or not largely depends on the threats you face personally, and the amount of effort you
are willing to spend to generate fresh keys.

Your master key will have its own unique long ID you can use to refer to it, in case you have
multiple GPG keys that have the same email address assigned to them:

```
gpg -k kyle.rankin@puri.sm
pub
rsa4096/0xBD83B92B2F4BFD99 2018-01-11 [SC]
Key fingerprint = 7B85 0961 8D82 0DF6 3924 1BB6 BD83 B92B 2F4B FD99
uid
[ unknown] Kyle Rankin <kyle.rankin@puri.sm>
```

The first line in the output shows you the key id (in my case 0xBD83B92B2F4BFD99):
pub

```
rsa4096/0xBD83B92B2F4BFD99 2018-01-11 [SC]
```

In the above example I referred to my key by its email address, but I could also use its id

```
0xBD83B92B2F4BFD99:
gpg -k 0xBD83B92B2F4BFD99
pub

rsa4096/0xBD83B92B2F4BFD99 2018-01-11 [SC]
Key fingerprint = 7B85 0961 8D82 0DF6 3924 1BB6 BD83 B92B 2F4B FD99
uid
[ unknown] Kyle Rankin <kyle.rankin@puri.sm>
```

### Add Subkeys to Your GPG Keys

Your Librem Key will not hold your master GPG key. That key will only be used to sign other
GPG keys. When you generate your master key it automatically generates a subkey
specifically for encryption, but you will need to generate additional subkeys for signing, and
authentication and it’s these three subkeys that will get stored and used from the Librem Key.
To generate subkeys, you will need to edit the key you just created:

```
gpg --expert --edit-key
```

This command will launch an interactive gpg> prompt where you can enter specific
commands. The addkey command will create a new subkey under your master key and walk
you through questions about:
• key type (this will vary depending on which subkey you create)
• key size (use 4096)
• key expiration date (if in doubt, pick a similar expiration date to the one you used for your
master key, or optionally a shorter one as it’s easier to rotate subkeys compared to a
master key). For this example I picked no expiration date (0).

First create a new signing subkey:

```
addkey
4
4096
0
```

Then create the authentication subkey. This one is a bit special as you will have to disable
Signing and Encryption capabilities and enable authenticate capabilities to generate this key:

```
addkey
8
S
E
A
Q
4096
0
```

Now that the subkeys are created, you should set the public key to the ultimate trust level and
then save:

```
trust
5
save
```

Now you will be back to a normal terminal prompt.

### Back Up your GPG Keys

The act of transferring subkeys over to the Librem Key will erase them on your current
system, so you will want to back them up to removable media like one or two separate USB
thumb drives. Then you can store those keys in a safe, safe-deposit box, or other secure
place. The advantage of backing up on two USB thumb drives is that you can store one onsite and one off-site.
Before you back everything up, you should generate a revocation certificate for your key. With
this backed up somewhere, you will be able to revoke your key in case it’s ever compromised
or you lose it:

```
gpg --output revoke.asc --gen-revoke 

```

Then you can back up the revoke.asc file that command generates.

Back Up the Whole GNUPG Directory

### Back Up the Whole GNUPG Directory

There are two main ways to back up your GPG keys. The first is to just copy your entire
~/.gnupg directory over to a thumb drive. Let’s say it is mounted at /media/kyle/8439-AFIJ
(your PureOS desktop will automatically mount a thumb drive in a location like that when you
insert it) you could use the GUI file manager to copy and paste the /home/
yourusername/.gnupg directory over to the thumb drive, or in a terminal you could type:

```
cp -a ~/.gnupg /media/kyle/8439-AFIJ/
cp revoke.asc /media/kyle/8439-AFIJ/
```

Remember to change the destination directory to match wherever your thumb drive was
mounted. If in doubt, you can type the mount command to get a list of the currently mounted
file systems.

### Back Up Just Your Keys

If you just want to back up your keys, you can export them separately:

```
gpg --armor --output privkey.sec --export-secret-key <youremail@yourdomain.com>
gpg --armor --output subkey.sec --export-secret-subkeys <youremail@yourdomain.com>
gpg --armor --output pubkey.asc --export <youremail@yourdomain.com>
```

Now you can copy the privkey.sec, subkey.sec, pubkey.asc and the revoke.asc to a thumb
drive:

```
cp privkey.sec subkey.sec pubkey.asc revoke.asc /media/kyle/8439-AFIJ/
```

Once you have backed them up, be sure to delete the privkey.sec, subkey.sec and
revoke.asc files.

### Move GPG Subkeys Over to The Librem Key

To transfer your GPG subkeys over to the Librem Key, first insert the Librem Key and make
sure that gpg --card-status shows that it has detected the key:

```
gpg --card-status
Reader ...........: 20A0:4108:000000000000000000006143:0
Application ID ...: D2760001240103030005000061430000
Version ..........: 3.3
Manufacturer .....: ZeitControl
Serial number ....: 00006143
Name of cardholder: [not set]
Language prefs ...: de
Sex ..............: unspecified
URL of public key : [not set]
public key
Login data .......: [not set]
Signature PIN ....: forced
Key attributes ...: rsa2048 rsa2048 rsa2048
Max. PIN lengths .: 64 64 64
PIN retry counter : 3 0 3
Signature counter : 4
Signature key ....: [none]
Encryption key....: [none]
Authentication key: [none]
General key info..: [none]
```

In this output you can see that no signature, encryption or authentication keys have been
loaded:

```
Signature key ....: [none]
Encryption key....: [none]
Authentication key: [none]
General key info..: [none]
```

To copy keys over, we go back to the interactive GPG menu that shows up when we edit our
key:

```
gpg --expert --edit-key <youremail@yourdomain.com>
```

In the output you will see a few subkeys listed:

```
$ gpg --expert --edit-key kyle.rankin@puri.sm
gpg (GnuPG) 2.1.18; Copyright (C) 2017 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Secret key is available.
pub

rsa4096/0xBD83B92B2F4BFD99
created: 2018-01-11 expires: never
trust: ultimate
validity: ultimate
ssb rsa2048/0x6A6F096B8E4C29C9
created: 2018-01-11 expires: never
ssb rsa2048/0x555577116BFA74B9
created: 2018-01-11 expires: never
ssb rsa2048/0x1801C77F078C5DEE
created: 2018-01-11 expires: never
[ unknown] (1). Kyle Rankin <kyle.rankin@puri.sm>

usage: SC

usage: E
usage: S
usage: A
```

Now inside the gpg> prompt we will type key 1 to select the first subkey which will add an
asterisk next to the “ssb” column for that key in the output:

```
key 1
pub
rsa4096/0xBD83B92B2F4BFD99
created: 2018-01-11 expires: never
trust: unknown
validity: unknown
ssb* rsa2048/0x6A6F096B8E4C29C9
created: 2018-01-11 expires: never
ssb rsa2048/0x555577116BFA74B9
created: 2018-01-11 expires: never
ssb rsa2048/0x1801C77F078C5DEE
created: 2018-01-11 expires: never
[ unknown] (1). Kyle Rankin <kyle.rankin@puri.sm>

usage: SC

usage: E
usage: S
usage: A
```

Now type the keytocard command to move that key over to the smart card. When prompted
tell it that you want to select 2, your Encryption key:

```
keytocard
```

Next you will type key 1 to untoggle key 1, then type key 2 to toggle key 2, and type
keytocard to add that to your Librem Key. When prompted tell it that you want to select 1,
your Signature Key:

```
key 1
key 2
keytocard
```

Finally you will type key 2 to untoggle key 2, then type key 3 to toggle key 3, and type
keytocard to add that to your Librem Key. When prompted tell it that you want to select 3,
your Authentication Key. Then save to exit:

```
key 2
key 3
keytocard
save
```

### Factory Reset GPG Keys on The Librem Key

If you ever want to delete all of the keys, passwords, and settings on the Librem Key you will
need to enter the card edit menu for GPG:

```
gpg --card-edit
```

Then from the gpg/card> prompt you will type admin to enter admin mode and then factoryreset to erase keys and PINs and refer to factory settings:

```
admin

factory-reset
```

### Generate GPG Subkeys on The Librem Key

If you do decide that you want your GPG keys to only exist on the Librem Key, you can
generate them directly on that device. First enter the GPG card edit menu:

```
gpg --card-edit
```

Then from the gpg/card> prompt type admin to enter admin mode and then generate to
generate new keys on the device:

```
admin
generate
```

Follow the interactive prompts to generate the keys. You should be prompted with the option
to export a copy of your keys to back them up, which I recommend you do. Type quit to exit
the menu when you are done:

```
quit
```

At the very least you will want a copy of your public key, so type:

```
gpg --armor --output pubkey.asc --export <youremail@yourdomain.com>
```

Then you can share pubkey.asc with a public key server or anyone you want to send you
encrypted communications.

### Change Language Settings on the Librem

/Key/
The Librem Key currently defaults to German as its on-board GPG language setting. This
means when you plug it in, you might get a desktop prompt in German instead of English. To
change the default language used by the Librem Key for GPG, first enter the GPG card edit
menu:

```
gpg --card-edit
```

Then from the gpg/card> prompt type admin to enter admin mode and then lang to change
the language. For instance to change it from German to English, set it to en when you see the

/Language preferences: prompt:/

```
admin
lang
```

Then type quit to exit the menu when you are done:

```
quit
```

### Decrypt LUKS-encrypted Drives with Librem Key

PureOS’s cryptsetup-initramfs now has support for using OpenPGP smartcards like the
Librem Key to unlock LUKS-encrypted volumes. This means when you boot, you just insert
your Librem Key and enter your GPG PIN instead of typing in your regular disk encryption
passphrase. If you are interested in trying this out yourself, we are working on adding a script
upstream to automate the process of configuring your root LUKS partition to use a Librem
Key.

In the mean time we have a basic script in place at https://source.puri.sm/pureos/packages/
smartcard-key-luks that you can use to automate the whole process (or just to use as a
reference to see what changes you need to make to enable this by hand). The script requires
the scdaemon package be installed and needs you to have an exported GPG public key in a
file on the local system that corresponds to the private key on your Librem Key. Then
download the script, ensure it has execute permissions, then run:

```
sudo ./smartcard-key-luks <gpg_public_key.asc>
```

This script will also set up the “recovery” Linux boot options in GRUB so that they bypass the
Librem Key and fall back to the passphrase you have already configured for your root volume.
Note that this script does modify the /etc/grub.d/10_linux and /usr/sbin/grub-mkconfig scripts
to allow for this recovery feature. We are working to upstream this patch to grub-common.

### Automatically Lock the Desktop When Removing the Librem Key

Through the use of a simple script and udev rules, you can have your computer lock the
screen when you pull out your Librem Key. This integration requires two files: /etc/udev/
rules.d/85-libremkey.rules and /usr/local/bin/gnome-screensaver-lock :

**85-libremkey.rules**

```
ACTION=="remove", ENV{PRODUCT}=="316d/4c4b/101" RUN+="/usr/local/bin/gnome-screensaver-lock"
```

**gnome-screensaver-lock**

```
#!/bin/sh
user=`ps aux | egrep "gdm-(wayland|x)-session" | head -n 1 | awk '{print $1}'`

if [ -n $user ]; then
su $user -c "/usr/bin/dbus-send --type=method_call --dest=org.gnome.ScreenSaver /org
fi

```
You will need to trigger udev to reload upon installation so it picks up the new rule. You can
do that this way:

```
systemctl restart udev
```

### Using the Librem Key with Heads

TODO: This section will be incomplete until we finalize the initial Heads UI. In the mean time
this blog post describes how the Librem Key integrates with Heads The Librem Key Makes
Tamper Detection Easy

### Technical Specs
• Key slots: Three key slots supporting RSA 2048-4096 bit and ECC 256-512 bit
• Supported elliptic curves: NIST P-256, P-384, P-521 (secp256r1/prime256v1,
secp384r1/ prime384v1, secp521r1/prime521v1), brainpoolP256r1, brainpoolP384r1,
brainpoolP512r1
• Protocols: CSP, OpenPGP, S/MIME, X.509, PKCS#11
• One-time password storage: 3x HOTP (RFC 4226), 15 x TOTP (RFC 6238)
• Integrated password manager: 16 entries
• Random number generator: 40 kbit/s true random number generator
• Tamper-resistant smart card
• Life expectancy: > 100,000 PIN entries
• Storage time: > 20 years
• USB: USB 2.0, type A
• Dimensions: 48 x 19 x 7 mm
• Weight: 6g
• Safety and environmental compliance: FCC, CE, RoHS, WEEE

### Other Resources
• [Librem Key Product Page](http://web.archive.org/web/20240927115201/https://puri.sm/products/librem-key) – where to go to order the Librem Key
• [Introducing the Librem Key](http://web.archive.org/web/20240927115201/https://puri.sm/posts/introducing-the-librem-key/) – a blog post that provides an easy-to-understand overview of
the Librem Key
• [The Librem Key Makes Tamper Detection Easy](http://web.archive.org/web/20240927115201/https://puri.sm/posts/the-librem-key-makes-tamper-detection-easy/) – a blog post that describes how the
Librem Key integrates with Heads
• [Librem Key firmware code](http://web.archive.org/web/20240927115201/https://github.com/Nitrokey/nitrokey-pro-firmware)
• [Librem Key HOTP userspace code](http://web.archive.org/web/20240927115201/https://github.com/Nitrokey/nitrokey-hotp-verification)
• [Supplemental Nitrokey Documentation](http://web.archive.org/web/20240927115201/https://www.nitrokey.com/documentation)
• [The Heads Project](http://web.archive.org/web/20240927115201/https://github.com/osresearch/heads/)


This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License 

2024/10/05, 09:38


````
