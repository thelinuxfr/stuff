# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-im/amsn/amsn-0.97.2.ebuild,v 1.5 2008/08/08 18:55:40 nixnut Exp $

inherit autotools eutils fdo-mime gnome2-utils

MY_P=${P/_rc/RC}
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Alvaro's Messenger client for MSN"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"
HOMEPAGE="http://www.amsn-project.net"

# The tests are interactive
RESTRICT="test"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="alpha amd64 hppa ppc -sparc x86"
IUSE="debug static"

DEPEND=">=dev-lang/tcl-8.5
	>=dev-lang/tk-8.5
	>=dev-tcltk/tls-1.4.1
	media-libs/jpeg
	media-libs/libpng
	>=dev-tcltk/snack-2.2.10"

RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-0.97_rc1-nostrip.patch"
	eautoconf
}

src_compile() {
    local myconf
 
#    myconf="${myconf} --with-tcl=/usr/lib/tcl8.5 --with-tk=/usr/lib/tk8.5"

	econf \
		$(use_enable debug) \
		$(use_enable static) \
		${myconf} \
		|| die "configure script failed"
	emake || die "Compilation failed"
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AGREEMENT TODO README FAQ CREDITS

	domenu amsn.desktop
	sed -i -e s:.png:: "${D}/usr/share/applications/amsn.desktop"

	cd desktop-icons
	for i in *; do
		if [ -e ${i}/msn.png ]; then
			insinto /usr/share/icons/hicolor/${i}/apps
			doins  ${i}/msn.png
		fi
	done
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update

	ewarn "You might have to remove ~/.amsn prior to running as user if amsn hangs on start-up."
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
