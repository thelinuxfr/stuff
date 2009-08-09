# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=0
REV="583"

DESCRIPTION="Mandriva Computer System Management - MMC misc"
HOMEPAGE="http://pulse2.mandriva.org/"

SRC_URI="http://pulse2.mandriva.org/pub/pulse2/server/sources/${PV}/${P}-${REV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="x86"

DEPEND="
	app-admin/mmc-web-base"
RDEPEND="${DEPEND}"

src_install() {
	emake PREFIX="${D}"/usr install || die "install failed"
}
