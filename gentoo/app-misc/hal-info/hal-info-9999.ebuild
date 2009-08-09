# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EGIT_REPO_URI="git://anongit.freedesktop.org/git/hal/hal-info"

inherit eutils git

DESCRIPTION="The fdi scripts that HAL uses"
HOMEPAGE="http://hal.freedesktop.org/"

unset SRC_URI

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ~mips sparc x86"
IUSE=""


RDEPEND=">=sys-apps/hal-0.5.10"
DEPEND="${RDEPEND}"

src_unpack() {
    git_src_unpack
}


src_compile() {
	./autogen.sh --prefix=/usr || "Autogen Failed"	
	econf || die "configure failed"
	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "install failed."
}
