# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools gnome2 clutter

DESCRIPTION="Clutter-Cairo an experimental clutter cairo 'drawable' actor"

KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND="${RDEPEND}
		x11-libs/cairo"

DEPEND="${RDEPEND}
		${DEPEND}"

DOCS="AUTHORS ChangeLog NEWS README TODO"

src_unpack() {
	gnome2_src_unpack

	# Prevent autoconf version mismatch
	eautoreconf
}

