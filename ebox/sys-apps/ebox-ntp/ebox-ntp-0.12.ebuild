# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="the eBox platform - Modules NTP."
HOMEPAGE=" http://ebox-platform.com"
SRC_URI="http://www.ebox-platform.com/releases/0.12/${PN}_${PV}.orig.tar.gz"


LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="
	sys-libs/libebox
	sys-apps/ebox
	sys-apps/ebox-firewall
	net-misc/ntp
	gnome-base/gconf"
	
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${PV}"

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_compile() {
	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR=${D} || die "Install failed"

}
