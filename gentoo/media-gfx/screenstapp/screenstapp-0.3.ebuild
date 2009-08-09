# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="A tool to capture fullscreen or crop a portion of screen"
HOMEPAGE="http://polariscorp.free.fr/screenstapp.php"

SRC_URI="http://polariscorp.free.fr/apps/${P}.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~x86"

DEPEND="
	dev-python/pygtk
	media-gfx/imagemagick"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_install() {
	insinto /usr/share/${PN}
	doins ScreenStApp.glade
	doins insert-image.svg

	newbin ScreenStApp.py screenstapp
}
