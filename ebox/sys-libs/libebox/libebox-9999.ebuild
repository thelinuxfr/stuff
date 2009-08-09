# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="http://svn.ebox-platform.com/ebox-platform/trunk/${PV}/common/libebox"

inherit eutils subversion

EAPI="0"

DESCRIPTION="eBox common library for server and client eBox is a framework."
HOMEPAGE=" http://www.ebox-platform.com"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
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

src_unpack() {
	subversion_src_unpack
}

src_compile() {
	./autogen.sh || die "autogen failed"
	econf --disable-runtime-tests || die "Configure failed"
	emake || die "Make failed"
}

src_install() {
	emake install DESTDIR=${D} || die "Install failed"

}

