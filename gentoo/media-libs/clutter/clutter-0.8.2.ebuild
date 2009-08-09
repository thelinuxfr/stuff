# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils gnome2 clutter

DESCRIPTION="Clutter is a library for creating graphical user interfaces"

KEYWORDS="~amd64 ~x86"
IUSE="doc opengl sdl"

# Dependency on gtk+ is for GdkPixBuf;
# change if/when GdkPixBuf separates.
RDEPEND="${RDEPEND}
		>=dev-libs/glib-2.14
		>=x11-libs/pango-1.18
		>=x11-libs/gtk+-2.0
		opengl? ( virtual/opengl
				  >=x11-libs/libXfixes-3
				  x11-libs/libXdamage
				  >=x11-libs/libXcomposite-0.4 )
		sdl? ( media-libs/libsdl )"

DEPEND="${RDEPEND}
		${DEPEND}
		doc? ( >=app-text/docbook-sgml-utils-0.6.14
			   app-text/xmlto )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	local msg="Select either opengl or sdl as your renderer"
	if ( use !opengl && use !sdl ) || ( use opengl && use sdl ); then
		eerror "${msg}"
		die "${msg}"
	fi

	G2CONF="${G2CONF}
		$(use_enable doc manual)"

	if use sdl; then
		elog "Using SDL for OpenGL backend"
		G2CONF="${G2CONF} --with-flavour=sdl"
	else
		elog "Using GLX for OpenGL backend"
		G2CONF="${G2CONF} --with-flavour=glx"
	fi
}

src_unpack() {
	gnome2_src_unpack

	epatch "${FILESDIR}/${P}-fix-namespace-collision-with-glibc-2.8.patch"
}

