# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="http://pulse2.mandriva.org/svn/${PN}/trunk"

inherit distutils subversion

EAPI="0"

DESCRIPTION="Mandriva Computer System Management - Package Server"
HOMEPAGE="http://pulse2.mandriva.org/"

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64 ~x86"

DEPEND="
	dev-python/twisted-web
	~app-admin/pulse2-common-${PV}
	dev-python/setuptools"
RDEPEND="${DEPEND}"


src_install() {
	"${python}" setup.py install --root="${D}" --no-compile "$@" || die "install failed"
	dosbin bin/pulse2-package-server || die "bin install failed"
	insinto etc/mmc/pulse2/pulse2-package-server/keys
	doins -r conf/keys/* || die "key install failed"
	insinto etc/mmc/pulse2/pulse2-package-server
	doins -r conf/*.ini || die "ini install failed"
	insinto usr/share/doc/${P}
	doins -r contrib || die "config samples install failed"
	dodoc Changelog

	newinitd "${FILESDIR}"/pulse2-package-server.initd pulse2-package-server
}
