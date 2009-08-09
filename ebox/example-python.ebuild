# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Ubuntu Themes made by the artwork community. At the moment the package contains"
HOMEPAGE="http://foo.bar.com/"

SRC_URI="http://archive.ubuntu.com/ubuntu/pool/universe/c/community-themes/${PN}_${PV}.tar.gz"
LICENSE=""
SLOT="0"

KEYWORDS="~x86"

DEPEND="
	x11-themes/gtk-engines-murrine
	dev-python/python-distutils-extra"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_compile() {
	python setup.py build || die
}

src_install() {
	python setup.py install --root="${D}" || die
}
