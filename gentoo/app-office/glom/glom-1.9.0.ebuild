# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v3
# $Header: $

inherit eutils gnome2

DESCRIPTION="A database application that is similar to filemakerpro, that uses popstgresql as backend"
HOMEPAGE="http://www.glom.org"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-cpp/bakery-2.6
	>=dev-cpp/libgdamm-3.0.0
	>=dev-util/intltool-0.40.5
	dev-util/pkgconfig
	dev-cpp/libgtksourceviewmm
	dev-python/pygtk
	dev-cpp/gtksourceviewmm
	dev-python/gnome-python-extras
	>=x11-libs/goocanvas-0.12
	>=x11-libs/goocanvasmm-0.12
	virtual/postgresql-server
	net-libs/libepc"
#in dev manual RDEPEND said to be removed in future.
RDEPEND="${DEPEND}" 

pkg_setup() {
	G2CONF="--with-postgres-utils=/usr/bin/"
}

	elog ""
	elog "Finish install to http://www.glom.org/wiki/index.php?title=Initial_Postgres_Configuration"
	elog ""
