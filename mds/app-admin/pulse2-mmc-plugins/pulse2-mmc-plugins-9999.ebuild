# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="http://pulse2.mandriva.org/svn/${PN}/trunk"

inherit distutils subversion

EAPI="0"

DESCRIPTION="Mandriva Computer System Management - MMC Plugins"
HOMEPAGE="http://pulse2.mandriva.org/"

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64 x86"

DEPEND="
	dev-python/twisted-web
	~app-admin/pulse2-common-${PV}
	app-admin/mmc-agent
	dev-python/setuptools"
RDEPEND="${DEPEND}"


src_install() {
	"${python}" setup.py install --root="${D}" --no-compile "$@" || die "install failed"
	insinto etc/mmc/plugins
	doins -r conf/plugins/*.ini || die "ini install failed"
	insinto usr/share/doc/${P}
	doins -r contrib || die "config samples install failed"
	dodoc Changelog
	python_version
	# we need to remove this file because it collides with the one
	# from mmc-agent (which we depend on).
	rm "${D}/usr/$(get_libdir)/python${PYVER}/site-packages/mmc/__init__.py"
	rm "${D}/usr/$(get_libdir)/python${PYVER}/site-packages/mmc/plugins/__init__.py"
}

