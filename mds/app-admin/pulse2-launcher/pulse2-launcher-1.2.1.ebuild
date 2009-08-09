# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils

EAPI="0"
REV="383"

DESCRIPTION="Mandriva Computer System Management - Launcher"
HOMEPAGE="http://pulse2.mandriva.org/"

SRC_URI="http://pulse2.mandriva.org/pub/pulse2/server/sources/${PV}/${P}-${REV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64 x86"

DEPEND="
	dev-python/setuptools
	dev-python/twisted-web
	~app-admin/pulse2-common-${PV}"
RDEPEND="${DEPEND}"


src_install() {
	"${python}" setup.py install --root="${D}" --no-compile "$@" || die "install failed"
	dosbin bin/* || die "bin install failed"
#	newsbin ../wol-${WOL_PV}/src/wol pulse2-wol || die "sbin install failed"
	insinto etc/mmc/pulse2/launchers/keys
	doins -r conf/launchers/keys/* || die "key install failed"
	insinto etc/mmc/pulse2/launchers
	doins -r conf/launchers/*.ini || die "ini install failed"
	insinto usr/share/doc/${P}
	doins -r contrib || die "config sample install failed"
	dodoc Changelog

	newinitd "${FILESDIR}"/pulse2-launchers.initd pulse2-launchers
}
