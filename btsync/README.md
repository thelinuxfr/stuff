1) Installation of BTSync binaries on /usr/local/sbin
------
* http://www.bittorrent.com/intl/fr/sync


2) Create Daemon User
------
* adduser --quiet --system --group --disabled-password btsync


3) Create Configuration File
------
* /etc/btsync.conf


4) Declare Service Auto-start
------
* chmod +x /etc/init.d/btsync
* update-rc.d btsync defaults
* service btsync start


5) Copie des binaires
------
* copier **btsync-update** et **btsync-ignorelist** dans /usr/local/bin
* renseigner la variable **ARCH** dans **btsync-update**

***
*Sources*
* http://bernaerts.dyndns.org/linux/75-debian/290-debian-server-btsync-permanent-peer
* Nicolas Bernaerts
