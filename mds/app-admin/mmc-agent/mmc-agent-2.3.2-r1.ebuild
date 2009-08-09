# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit distutils

DESCRIPTION="The MMC Agent and its Python plugins."
HOMEPAGE="http://mds.mandriva.org/"
SRC_URI="http://mds.mandriva.org/pub/mds/sources/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~ppc ~ppc64 ~sparc x86 ~x86-fbsd"
IUSE=""

SLOT="0"

RDEPEND=">=dev-python/twisted-web-0.7.0
	>=dev-python/python-ldap-2.2.1
	>=dev-python/psycopg-2.0.2
	dev-python/pyopenssl
	dev-python/python-ldap
	=dev-python/sqlalchemy-0.4.6"

DEPEND=">=dev-python/setuptools-0.6_rc1"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.3.1-kerberos-1.patch
	epatch "${FILESDIR}"/${PN}-2.3.2-printing-1.patch
	epatch "${FILESDIR}"/${PN}-2.3.2-powerdns-1.patch
}

# from marienz's setuptools.eclass:
src_install() {
	"${python}" setup.py install --root="${D}" --no-compile "$@" || die "install failed"
	dosbin bin/* || die "bin install failed"
	insinto etc/mmc/agent/keys
	doins -r conf/agent/keys/* || die "key install failed"
	insinto etc/mmc/agent
	doins -r conf/agent/*.ini || die "agent ini install failed"
	insinto etc/mmc/plugins
	doins -r conf/plugins/*.ini || die "plugins ini install failed"
	insinto usr/share/doc/${P}
	doins -r contrib || die "ldap schemas install failed"
	dodoc Changelog || die "doc install failed"

	newinitd "${FILESDIR}"/mmc-agent.initd mmc-agent
}

pkg_postinst() {
	elog "To disable some plugin in your mmc environments, you have to set"
	elog "disable to 1 in /etc/mmc/plugins/*.ini"
	elog "(one config file per service)"
	elog "You can't disable the base plugin."
}
