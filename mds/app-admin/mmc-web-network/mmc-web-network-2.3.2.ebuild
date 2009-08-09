# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils

DESCRIPTION="Mandriva Directory Server - Base Server"
HOMEPAGE="http://mds.mandriva.org/"
SRC_URI="http://mds.mandriva.org/pub/mds/sources/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 x86 ~x86-fbsd"
SLOT="0"

IUSE=""

DEPEND="
	~app-admin/mmc-agent-${PV}"
RDEPEND="${DEPEND}"

src_install() {
	emake DESTDIR="${D}" PREFIX=/usr install || die "install failed"
}
