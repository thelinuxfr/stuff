# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

NEED_PYTHON=2.5

inherit python

DESCRIPTION="enhancements to the Python build system"
HOMEPAGE="http://ubuntu.com/"
SRC_URI="http://archive.ubuntu.com/ubuntu/pool/main/p/${PN}/${PN}_${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 x86"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/debian"

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

