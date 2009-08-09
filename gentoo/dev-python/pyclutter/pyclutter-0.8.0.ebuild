# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=1

inherit autotools gnome2 clutter

DESCRIPTION="Python bindings for Clutter"

KEYWORDS="~amd64 ~x86"
IUSE="cairo doc gstreamer gtk"

RDEPEND="${RDEPEND}
		dev-lang/python:2.5
		dev-python/pygobject
		>=media-libs/clutter-0.8.2:${SLOT}
		cairo? ( media-libs/clutter-cairo:${SLOT} )
		gstreamer? ( media-libs/clutter-gst:${SLOT} )
		gtk? ( >=media-libs/clutter-gtk-0.8.2:${SLOT} )"

DEPEND="${RDEPEND}
		${DEPEND}
		doc? ( dev-libs/libxslt )
		cairo? ( dev-python/pycairo )
		gstreamer? ( media-libs/gstreamer
					 dev-python/gst-python )
		gtk? ( dev-python/pygtk )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF}
			$(use_with cairo cluttercairo)
			$(use_with gstreamer cluttergst)
			$(use_with gtk cluttergtk) \
			--disable-libtool-lock"
}

src_unpack() {
	gnome2_src_unpack

#	epatch "${FILESDIR}/${PN}-fix-docs-install-data-hook.patch"

	eautoreconf
}

