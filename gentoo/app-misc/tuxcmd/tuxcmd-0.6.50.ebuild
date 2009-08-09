# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

EAPI=0

DESCRIPTION="File manager with 2 panels side by side similar to popular Total Commander"
HOMEPAGE="http://tuxcmd.sourceforge.net/"

SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~x86"
IUSE=""

DEPEND="
	dev-lang/fpc
	x11-libs/kylixlibs3-borqt
	gnome-base/gvfs"

RDEPEND="${DEPEND}"

src_unpack() {
	unpack "${A}"
	epatch "${FILESDIR}/02_skip_0_and_NULL_mount_points.patch" || die "patch failed"
	epatch "${FILESDIR}/03_restore_last_used_item_fix_for_connmgr.patch" || die "patch failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

}
