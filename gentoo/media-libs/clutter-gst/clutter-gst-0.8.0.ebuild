# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=1

inherit gnome2 clutter

DESCRIPTION="GStreamer Integration library for Clutter"

KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND="${RDEPEND}
		media-libs/gstreamer:0.10
		media-libs/gst-plugins-base:0.10"

DEPEND="${RDEPEND}
		${DEPEND}"

DOCS="AUTHORS ChangeLog NEWS README TODO"

