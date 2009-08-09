# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit python gnome2 eutils

DESCRIPTION="Disk manager is a simple filesystem configurator"
HOMEPAGE="http://flomertens.free.fr/disk-manager/"

SRC_URI="http://flomertens.free.fr/disk-manager/download/source/${P}.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="amd64 x86"

IUSE="libnotify"

RDEPEND=">=sys-apps/hal-0.5.9-r1
	>=sys-fs/udev-60 
	>=dev-python/pygtk-2.10.4 
	>=dev-lang/python-2.5
	libnotify? ( dev-python/notify-python )"

DEPEND="${RDEPEND}
	dev-util/intltool"

DOCS="AUTHORS COPYING INSTALL README TODO"

#src_unpack() {
#	epatch "${FILESDIR}/python2.5.patch" || die "patch failed"
#}

