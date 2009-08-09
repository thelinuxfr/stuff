# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils 

EAPI="0"

DESCRIPTION="the eBox platform - DHCP Serveur."
HOMEPAGE="http://www.ebox-platform.com/"
SRC_URI="http://ppa.launchpad.net/ebox/ubuntu/pool/main/e/${PN}/${PN}_${PV}.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="
	~sys-libs/libebox-${PV}
	~sys-apps/ebox-${PV}
	~sys-apps/ebox-firewall-${PV}
	~sys-apps/ebox-services-${PV}
	net-misc/dhcp
	dev-perl/libtext-dhcpleases-perl"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${PV}"

src_unpack() {
	unpack "${A}"
	cd ${S}
}

src_compile() {
	econf --disable-runtime-tests --datarootdir=/usr/lib/ || die "configure failed"
	emake || die "make failed"
}

src_install() {
	emake install DESTDIR=${D} || die "install failed"

}
