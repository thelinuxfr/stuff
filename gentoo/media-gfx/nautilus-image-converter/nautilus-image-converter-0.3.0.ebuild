# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Nautilus, allow you to create copies of the selected image(s) resize to any desired size or rotate them like you want."
HOMEPAGE="http://www.bitron.ch/software/nautilus-image-converter.php"

SRC_URI="http://archive.ubuntu.com/ubuntu/pool/universe/n/nautilus-image-converter/${PN}_${PV}.orig.tar.gz"
LICENSE=""
SLOT="0"

KEYWORDS="~x86"

DEPEND="
	gnome-base/nautilus
	x11-libs/gtk+
	media-gfx/imagemagick"

RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch "${FILESDIR}/warnings.patch" || die "patch failed"
}

src_compile() {
	econf || die "configure failed"
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog CREDITS README
}

pkg_postinst() {
	gnome2_icon_cache_update
	elog "Execute in terminal: killall nautilus"
}

