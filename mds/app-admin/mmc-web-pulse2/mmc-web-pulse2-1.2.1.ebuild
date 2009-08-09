# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="0"
REV="100"

DESCRIPTION="Mandriva Computer System Management - MMC Pulse2"
HOMEPAGE="http://pulse2.mandriva.org/"

SRC_URI="http://pulse2.mandriva.org/pub/pulse2/server/sources/${PV}/${P}-${REV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64 x86"

DEPEND="
	app-admin/mmc-web-base
	~app-admin/pulse2-mmc-plugins-${PV}"
RDEPEND="${DEPEND}"

src_install() {
	emake PREFIX="${D}"/usr install || die "install failed"
}
