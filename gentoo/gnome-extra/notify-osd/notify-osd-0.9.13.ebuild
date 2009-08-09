# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit gnome2 eutils flag-o-matic


MY_P="notify-osd-${PV}"
EAPI=0

DESCRIPTION="daemon that displays passive pop-up notifications"
HOMEPAGE="https://launchpad.net/notify-osd"

SRC_URI="http://launchpad.net/notify-osd/0.9/${PV}/+download/${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"

KEYWORDS="~amd64 ~x86"
DEPEND="
	!x11-misc/notification-daemon
	sys-apps/dbus
	>=x11-libs/gtk+-2.14
	>=sys-devel/gcc-4.3.2"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

MAKEOPTS="-j1"

src_unpack() {
	unpack "${A}"
	cd ${S}
}

src_compile() {
	econf --disable-gtktest || die "configure failed"
	sed -i "s|\(^SUBDIRS.*\)examples\(.*\)$|\1\2|" Makefile
	emake || die "make failed"
}

