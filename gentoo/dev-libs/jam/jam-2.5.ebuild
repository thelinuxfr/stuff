# Copyright 1999-2008 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License, v2 or later

S=${WORKDIR}/${P}
DESCRIPTION="A Cross platform build tool"
SRC_URI="ftp://ftp.perforce.com/pub/jam/${P}.tar"
HOMEPAGE="http://www.perforce.com/jam/jam.html"
LICENSE="as-is"
DEPEND="virtual/glibc"
RDEPEND=""
SLOT="0"

src_compile() {
    cd ${S}
    emake
    ./jam0 || die
}

src_install () {
    dodir usr/bin
    cp -af ${S}/bin.linux*/jam ${S}/bin.linux*/mkjambase ${D}/usr/bin
    dodoc README RELNOTES Jambase.html Jamfile.html
}
