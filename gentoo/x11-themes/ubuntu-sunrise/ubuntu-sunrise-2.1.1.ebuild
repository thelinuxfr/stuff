# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

EAPI=0

DESCRIPTION="Ubuntu-sunrise theme contains a full theme for GNOME based system."
HOMEPAGE="http://francois.vogelweith.com/"
SLOT="0"

SRC_URI="http://ppa.launchpad.net/bisigi/ppa/ubuntu/pool/main/u/ubuntu-sunrise-theme/ubuntu-sunrise-theme_2.1.1.jaunty.ppa1+nmu1.tar.gz"
LICENSE="GPL-2"

KEYWORDS="amd64 x86"

S="${WORKDIR}"/ubuntu-sunrise-theme-jaunty

src_install() {
	dodir /usr/share/themes/${PN}
	tar xvzf "${S}"/Gtk/${PN}.tar.gz \
	    -C  "${D}/usr/share/themes/"

#	dodir /usr/share/gdm/themes/${PN}
#	cp -pR "${WORKDIR}"/${PN}-GDM-1.6.1/* "${D}/usr/share/gdm/themes/${PN}"
#
#	dodir /usr/share/icons/aquadreams
#	cp -pR "${WORKDIR}"/${PN}-Icons-1.6.1/* "${D}/usr/share/icons/${PN}"

}

pkg_postinst() {

	einfo ""
	einfo "Gnome Background Panel in /usr/share/themes/${PN}/gtk-2.0/Panels/"
	einfo ""
}
