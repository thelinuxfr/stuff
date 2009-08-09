# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils 

EAPI="0"

DESCRIPTION="eBox common library for server and client eBox is a framework."
HOMEPAGE="http://www.ebox-platform.com"
SRC_URI="http://ppa.launchpad.net/ebox/ubuntu/pool/main/libe/${PN}/${PN}_${PV}.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="
	sys-apps/iproute2
	dev-lang/perl
	dev-perl/log-dispatch
	dev-perl/Log-Log4perl
	dev-perl/HTML-Mason
	dev-perl/Net-IP
	dev-perl/Locale-gettext
	dev-perl/Net-IP
	dev-perl/Devel-StackTrace
	dev-perl/Readonly
	dev-perl/File-Slurp
	dev-perl/Perl6-Junction
	app-admin/sudo
	dev-perl/Error
	sys-devel/gettext
	dev-perl/Tree-Simple
	dev-perl/Tree-DAG_Node
	dev-perl/HTTP-Server-Simple-Mason
	dev-perl/Class-Singleton
	dev-perl/Clone"
RDEPEND="${DEPEND}"


S="${WORKDIR}/${PN}-${PV}"

src_unpack() {
	unpack "${A}"
	cd ${S}
}

src_compile() {
	econf --disable-runtime-tests --localstatedir=/var/ || die "Configure failed"
	emake || die "Make failed"
}

src_install() {
	emake install DESTDIR=${D} || die "Install failed"
}

pkg_prerm() {
    # clean up temp files
    [[ -d "${ROOT}/var/lib/ebox/" ]] && rm -rf "${ROOT}/var/lib/ebox/"
    [[ -d "${ROOT}/etc/ebox/" ]] && rm -rf "${ROOT}/etc/ebox/"
}
