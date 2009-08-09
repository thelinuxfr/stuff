# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="A collection of Gentoo themes for splashutils."
HOMEPAGE="http://www.kde-look.org/content/download.php?content=44870&id=1"
SRC_URI="http://thelinux.free.fr/pub/Distributions_Linux/gentoo/Gentoo-Grey-Splash.tar.gz"

IUSE=""
LICENSE="freedist"
SLOT="0"

KEYWORDS="amd64 ~ppc x86"
DEPEND=">=media-gfx/splashutils-1.1.9.5"

src_install() {
	dodir /etc/splash/Gentoo-Grey-fbsplash
	cp -pR ${WORKDIR}/Gentoo-Grey-fbsplash ${D}/etc/splash

}


pkg_postinst() {
	echo
	einfo "Add to /boot/grub/menu.lst"
	einfo "kernel /boot/kernel-genkernel-x86-2.6.18-gentoo...splash=silent,theme:Gentoo-Grey-fbsplash console=tty1 vga=791"
	echo
	einfo "And config /etc/conf.d/splash"
	einfo "SPLASH_THEME=Gentoo-Grey-fbsplash"
}
