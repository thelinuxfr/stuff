# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Ubuntu Tweak is an application designed to config Ubuntu easier for everyone."
HOMEPAGE="http://ubuntu-tweak.com/"

SRC_URI="http://ubuntu-tweak.googlecode.com/files/${P}.tar.gz"
LICENSE="GPL-2"

KEYWORDS="x86 amd64"
SLOT="0"

DEPEND="
	dev-python/pygtk
	dev-python/pygobject
	dev-python/gnome-python
	x11-misc/xdg-user-dirs
	dev-python/pyxdg"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${PV}"


src_unpack() {
	unpack "${A}"
	cd ${S}
}

src_compile() {
	econf || die "configure failed"
	emake || die "make failed"
}

src_install() {
	einstall || die "einstall failed"
}
