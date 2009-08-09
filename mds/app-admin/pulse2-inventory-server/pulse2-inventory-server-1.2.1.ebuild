# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils

EAPI="0"
REV="191"

DESCRIPTION="Mandriva Computer System Management - Inventory Server"
HOMEPAGE="http://pulse2.mandriva.org/"

SRC_URI="http://pulse2.mandriva.org/pub/pulse2/server/sources/${PV}/${P}-${REV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64 x86"

DEPEND="
	dev-python/twisted-web
	dev-python/sqlalchemy
	~app-admin/pulse2-common-${PV}
	~app-admin/pulse2-mmc-plugins-${PV}
	dev-python/setuptools"
RDEPEND="${DEPEND}"


src_install() {
	"${python}" setup.py install --root="${D}" --no-compile "$@" || die "install failed"
	dosbin bin/pulse2-inventory-server bin/pulse2-inventory-ssl-proxy || die "bin install failed"
	insinto etc/mmc/pulse2/inventory-server/keys
	doins -r conf/keys/* || die "key install failed"
	insinto etc/mmc/pulse2/inventory-server
	doins -r conf/inventory-server/*.ini || die "ini install failed"
	doins -r contrib/OcsNGMap.xml || die "ini install failed"
	insinto usr/share/doc/${P}
	doins -r contrib || die "config sample install failed"
	dodoc Changelog

	newinitd "${FILESDIR}"/pulse2-inventory-server.initd pulse2-inventory-server
}
