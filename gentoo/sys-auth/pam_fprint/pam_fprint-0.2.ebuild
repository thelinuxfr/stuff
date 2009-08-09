# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

DESCRIPTION="pam_fprint"
HOMEPAGE="http://www.reactivated.net/fprint/wiki/Pam_fprint"
SRC_URI="mirror://sourceforge/fprint/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND="=media-libs/libfprint-0.0.5
	sys-libs/pam"

src_install() {
	emake DESTDIR="${D}" install
}


pkg_postinst() {
	elog "Add the following to /etc/pam.d/system-auth after pam_env.so"
	elog "auth     sufficient     pam_fprint.so"
	elog ""
	elog "Your system-auth should look similar to:"
	elog "auth     required     pam_env.so"
	elog "auth     sufficient   pam_fprint.so"
	elog "auth     sufficient   pam_unix.so try_first_pass likeauth nullok"
}
