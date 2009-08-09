# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $


inherit eutils gnome2-utils distutils


MY_PV="${PV/_/-}-${PR/r/}"


DESCRIPTION="Python subversion extension for Nautilus."
HOMEPAGE="http://code.google.com/p/nautilussvn/"
SRC_URI="http://nautilussvn.googlecode.com/files/${PN}_${MY_PV}.tar.gz"
S="${WORKDIR}/${PN}-${PV/_*/}"


LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="diff"


DEPEND=""
RDEPEND=">=gnome-extra/nautilus-python-0.5.1
		dev-python/configobj
		dev-python/pyinotify
		dev-python/pygtk
		dev-python/dbus-python
		dev-python/pysvn
		diff? ( dev-util/meld )"


pkg_preinst() {
	gnome2_icon_savelist
}


src_unpack() {
	distutils_src_unpack


	# we should not do gtk-update-icon-cache from setup script
	# we prefer portage for that
	sed 's/"install"/"fakeinstall"/' -i "${S}/setup.py"
}


pkg_postinst() {
	distutils_pkg_postinst
	gnome2_icon_cache_update


	elog "You should restart nautilus to changes take effect:"
	elog "# nautilus -q && nautilus &"
}
