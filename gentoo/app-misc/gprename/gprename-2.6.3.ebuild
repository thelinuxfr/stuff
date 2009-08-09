# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit gnome2

EAPI=0

DESCRIPTION="GPRename is a complete batch renamer for files and directories"
HOMEPAGE="http://gprename.sourceforge.net/"

SRC_URI="http://switch.dl.sourceforge.net/sourceforge/gprename/${P}.tar.bz2"
LICENSE="GNU"
SLOT="0"

KEYWORDS="~x86"

DEPEND=""
RDEPEND="${DEPEND}"

src_compile() {
	emake || die "Make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}

pkg_postinst() {
	gnome2_pkg_postinst

}
