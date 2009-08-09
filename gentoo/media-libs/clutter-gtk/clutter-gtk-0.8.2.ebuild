# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils gnome2 clutter

DESCRIPTION="Clutter-GTK - GTK+ Integration library for Clutter"

KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND="${RDEPEND}
		>=x11-libs/gtk+-2.12"

DEPEND="${RDEPEND}
		${DEPEND}"

DOCS="AUTHORS ChangeLog NEWS README TODO"

