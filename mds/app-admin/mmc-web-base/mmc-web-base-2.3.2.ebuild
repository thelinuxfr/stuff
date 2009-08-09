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
	sys-apps/lsb-release
	sys-devel/gettext
	~app-admin/mmc-agent-${PV}
        dev-lang/php[ldap,xmlrpc,nls]
	app-cdr/cdrkit"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.3.2-gentoo.patch

	# GentooLinux
	cp "${FILESDIR}"/logo_mandriva_small.png ${S}/img/login/
	cp "${FILESDIR}"/logomandriva_navbar.gif ${S}/img/common/
}

src_install() {
	emake DESTDIR="${D}" PREFIX=/usr HTTPDUSER=apache install || die "install failed"
	insinto /etc/mmc
	doins confs/mmc.ini || die "ini install failed"

	insinto /etc/apache2/vhosts.d
	newins confs/apache/mmc.conf 90_mmc.conf || die "vhosts install failed"
}
