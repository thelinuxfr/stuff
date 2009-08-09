# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
REV="21"

inherit eutils

DESCRIPTION="This package will attempt to auto-detect your laptop hardware"
HOMEPAGE="http://packages.ubuntu.com/en/hardy/hotkey-setup"
SRC_URI="http://archive.ubuntu.com/ubuntu/pool/main/h/${PN}/${PN}_${PV}-17ubuntu$REV.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-laptop/laptop-detect"
RDEPEND="sys-apps/dmidecode"

S="${WORKDIR}/${PN}-${PV}"

src_unpack() {
	unpack "${A}"
	epatch "${FILESDIR}/init.patch" || die "patch failed"
}

src_install() {
	dosbin dumpkeycodes
	dosbin thinkpad-keys

	insinto /usr/share/${PN}
	doins *.hk
	doins key-constants
	doins aliased-keys

	doconfd ${PN}
	newinitd debian/init.d ${PN}

	dodoc debian/README.Debian
}
