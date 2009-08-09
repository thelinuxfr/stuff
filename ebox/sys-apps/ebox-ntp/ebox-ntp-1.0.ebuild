# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="http://svn.ebox-platform.com/ebox-platform/branches/${PV}/client/ntp"

inherit eutils subversion

DESCRIPTION="the eBox platform - Modules NTP."
HOMEPAGE=" http://ebox-platform.com"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	~sys-libs/libebox-${PV}
	~sys-apps/ebox-${PV}
	~sys-apps/ebox-firewall-${PV}
	net-misc/ntp
	gnome-base/gconf"
	
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
