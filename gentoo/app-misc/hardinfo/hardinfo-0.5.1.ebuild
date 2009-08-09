# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=0

inherit gnome2

DESCRIPTION="HardInfo can gather information about your system's hardware and operating system"
HOMEPAGE="http://hardinfo.berlios.de/"

SRC_URI="http://download.berlios.de/hardinfo/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64 ~x86"

MAKEOPTS="-j1"
