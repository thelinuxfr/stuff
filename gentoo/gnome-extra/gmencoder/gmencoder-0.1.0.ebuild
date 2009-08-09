# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="0"

DESCRIPTION="Frontend to mencoder for Gnome environment"
SRC_URI="mirror://sourceforge/gmencoder/${P}.tgz"
HOMEPAGE="http://gmencoder.sourceforge.net/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="media-video/mplayer"

src_compile() {
	econf || die "Configure failed"
	emake || die "Make failed"
}

src_install() {
	einstall || die "Install failed"
}
