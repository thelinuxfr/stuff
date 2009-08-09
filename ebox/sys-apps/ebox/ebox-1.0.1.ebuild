# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

EAPI="0"

DESCRIPTION="the eBox platform - Base framework."
HOMEPAGE=" http://ebox-platform.com"
SRC_URI="http://ppa.launchpad.net/ebox/ubuntu/pool/main/e/${PN}/${PN}_${PV}.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="ca cups dhcp dns firewall network ntp openvpn samba squid"

DEPEND="
	~sys-libs/libebox-${PV}
	~sys-libs/ebox-objects-${PV}
	dev-perl/Proc-ProcessTable
	dev-perl/XML-RSS
	dev-perl/File-MMagic
	dev-perl/File-Copy-Recursive
	dev-perl/Chart
	dev-perl/Filesys-Df
	dev-perl/Net-Jabber
	dev-perl/File-Tail
	dev-perl/pgperl
	dev-db/postgresql
	dev-perl/Apache-AuthCookie
	www-apache/mod_perl
	dev-libs/openssl
	www-servers/apache
	sys-process/runit
	perl-gcpan/Apache-Singleton
	perl-gcpan/Sys-CPU
	perl-gcpan/Sys-CpuLoad
	dev-perl/JSON
	dev-perl/GD
	ca? ( ~sys-apps/ebox-ca-${PV} )
	cups? ( ~sys-apps/ebox-printers-${PV} )
	dhcp? ( ~sys-apps/ebox-dhcp-${PV} )
	dns? ( ~sys-apps/ebox-dns-${PV} )
	firewall? ( ~sys-apps/ebox-firewall-${PV} )
	network? ( ~sys-apps/ebox-network-${PV} ) 
	ntp? ( ~sys-apps/ebox-ntp-${PV} ) 
	openvpn? ( ~sys-apps/ebox-openvpn-${PV} ) 
	samba? ( ~sys-apps/ebox-samba-${PV} ) 
	squid? ( ~sys-apps/ebox-squid-${PV} )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${PV}"

src_unpack() {
	unpack "${A}"
	cd ${S}
}

src_compile() {
	econf --disable-runtime-tests --localstatedir=/var || die "Configure failed"
	emake || die "Make failed"
}

src_install() {
	emake install DESTDIR=${D} || die "Install failed"

}

pkg_postinst() {
	elog "Finish install"
	elog "-----------------------"
	elog ""
	elog "	emerge --config =${CATEGORY}/${PF}"
	elog ""
	elog "-----------------------"
}

pkg_config() {




	## Create DB
db_name="eboxlogs"
db_user="ebox"

#if  ! invoke-rc.d postgresql-8.3 status > /dev/null 2>%1 
#then
#     invoke-rc.d postgresql-8.3 restart || true
#fi 
    
    su postgres -c 'psql -Alt' | grep -q '^$db_name|' && db_exists=1 || db_exists=0 || true
    if [ $db_exists -eq 0 ]; then
        echo "Creating the $db_name database"
        su postgres -c "createdb $db_name" > /dev/null 2>&1 || true
        su postgres -c "createuser -R -S -D $db_user" > /dev/null 2>&1 || true
        su postgres -c "psql -d $db_name -c \"GRANT ALL ON DATABASE $db_name TO $db_user\"" > /dev/null 2>&1 || true
    fi



	## create ebox's' apache certificates
	/usr/share/ebox/ebox-create-certificate /var/lib/ebox/conf/ssl > /dev/null 2>&1
       
	## Perms folder
	chown ebox:adm /var/log/ebox
        chown -R ebox:adm /var/lib/ebox/tmp
        chown -R ebox:adm /var/lib/ebox/conf
        chown -R ebox:adm /var/lib/ebox/log
 
        # Create and set permissions for ebox.sid
        EBOX_SID="/var/lib/ebox/conf/ebox.sid"
        if [ ! -e $EBOX_SID ]; then
            touch $EBOX_SID
        fi
        chown ebox:ebox $EBOX_SID
        chmod 0600 $EBOX_SID

        # add the stderr file needed by sudo
        STDERR_FILE=`perl -MEBox::Config -e'print EBox::Config::tmp() . 'stderr'; 1'`;
        touch ${STDERR_FILE}
        chmod 0600 ${STDERR_FILE}
        chown ebox:ebox ${STDERR_FILE}

        # add the dynamic-www- and downloads directories
        DYNAMIC_WWW_DIRS=$(perl -MEBox::Config -e'print EBox::Config::dynamicwww() ; print " " ; print join(" ", @{EBox::Config::dynamicwwwSubdirs()}); print " "; print EBox::Config::downloads;  1;'); 
        for DIR in $DYNAMIC_WWW_DIRS; do
            mkdir -p $DIR
            chown -R ebox:ebox $DIR
        done

        #change the /var/lib/ebox/ user
        chown  ebox:ebox /var/lib/ebox


        #sudo configuration
        /usr/share/ebox/ebox-sudoers-friendly

        # Set default passwd if it does not exist yet
#        if [ ! -f /var/lib/ebox/conf/ebox.passwd ]; then
#            store_password;
#        fi

        #Create user and database
        create_db

        /usr/share/ebox/ebox-sql-table add admin /usr/share/ebox/sqllog/admin.sql
        /usr/share/ebox/ebox-sql-table add consolidation /usr/share/ebox/sqllog/consolidation.sql

       

 #       if [ -z "$2" ]; then
 #           # Set eBox port only if it's the first time we install
 #           set_ebox_port
 #           invoke-rc.d ebox apache start || true
 #       else 
 #           invoke-rc.d ebox apache stop || true
 #           # Give apache some time to stop completely 
 #           # Otherwise it will fail to start as the port is being used
 #           sleep 5
 #           invoke-rc.d ebox apache start || true
 #       fi 
        

        # migrate log data
        /usr/share/ebox/ebox-migrate /usr/share/ebox-logs/migration



}
