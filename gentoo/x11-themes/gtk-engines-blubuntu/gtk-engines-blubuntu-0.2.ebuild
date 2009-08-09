# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

PATCH_LEVEL=4

MY_PN=blubuntu-look

DESCRIPTION="a derivative of the standard Blubuntu engine."
HOMEPAGE="http://www.ubuntu.com/"
SRC_URI="http://archive.ubuntu.com/ubuntu/pool/universe/b/${MY_PN}/${MY_PN}_${PV}.orig.tar.gz
	http://archive.ubuntu.com/ubuntu/pool/universe/b/${MY_PN}/${MY_PN}_${PV}-0ubuntu${PATCH_LEVEL}.diff.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.8"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}"/${MY_PN}-${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_compile() {
	econf --enable-animation
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog README
}
