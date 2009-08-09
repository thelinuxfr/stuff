# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

EAPI=0

DESCRIPTION="Aquadreams theme based on Tropical and Exotic themes"
HOMEPAGE="http://francois.vogelweith.com/"
SLOT="0"

SRC_URI="http://ftp.thelinuxfr.org/gentoo-distfiles/${PN}-GTK-${PV}.tar.gz
	http://ftp.thelinuxfr.org/gentoo-distfiles/${PN}-GDM-${PV}.tar.gz
	http://ftp.thelinuxfr.org/gentoo-distfiles/${PN}-Icons-${PV}.tar.gz"
LICENSE="GPL-2"

KEYWORDS="amd64 x86"

src_install() {
	dodir /usr/share/themes/${PN}
	cp -pR "${WORKDIR}"/${PN}-GTK-1.6.1/* "${D}/usr/share/themes/${PN}"

	dodir /usr/share/gdm/themes/${PN}
	cp -pR "${WORKDIR}"/${PN}-GDM-1.6.1/* "${D}/usr/share/gdm/themes/${PN}"

	dodir /usr/share/icons/aquadreams
	cp -pR "${WORKDIR}"/${PN}-Icons-1.6.1/* "${D}/usr/share/icons/${PN}"

}

pkg_postinst() {

	einfo ""
	einfo "Gnome Background Panel in /usr/share/themes/${PN}/gtk-2.0/Panels/"
	einfo ""
}
