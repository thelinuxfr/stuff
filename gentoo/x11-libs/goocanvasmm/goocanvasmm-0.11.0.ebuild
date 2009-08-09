# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="GooCanvas is a canvas widget for GTK+ using the cairo 2D library for drawing."
HOMEPAGE="http://sourceforge.net/projects/goocanvas"
SRC_URI="http://ftp.gnome.org/pub/gnome/sources/goocanvasmm/0.11/${P}.tar.gz"


LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.10
	x11-libs/cairo
	>=x11-libs/goocanvas-0.12"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"


src_compile() {
	econf || die "configure failed."
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TODO
}
