# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="The default Human theme. At the moment the package contains - the theme definitions - metacity theme elements. "
HOMEPAGE="http://www.ubuntu.com/"

SRC_URI="http://archive.ubuntu.com/ubuntu/pool/main/h/human-theme/${PN}_${PV}.tar.gz"
LICENSE=""
SLOT="0"

KEYWORDS="~x86"

DEPEND="
	x11-themes/gtk-engines-murrine
	dev-python/python-distutils-extra
	!x11-themes/gtk-engines-ubuntulooks"

RDEPEND="${DEPEND}"


src_unpack() {
	unpack ${A}
}

src_compile() {
	python setup.py build || die
}

src_install() {
	python setup.py install --root="${D}" || die
}
