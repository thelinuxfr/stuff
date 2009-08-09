# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="http://pulse2.mandriva.org/svn/${PN}/trunk"

inherit distutils subversion

EAPI=0
REV="167"

DESCRIPTION="Mandriva Computer System Management - Common"
HOMEPAGE="http://pulse2.mandriva.org/"

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64 ~x86"

DEPEND="
	dev-python/setuptools
	dev-python/twisted-web"
RDEPEND="${DEPEND}"

src_install() {
	"${python}" setup.py install --root="${D}" --no-compile "$@" || die "install failed"
}
