# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils gnome2

DESCRIPTION="H.323 and SIP VoIP softphone"
HOMEPAGE="http://www.ekiga.org/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="avahi dbus debug doc eds gconf gnome ldap libnotify xv"
# dbus-service has been ignored
# gdu instead of gnome + doc ?

RDEPEND=">=dev-libs/ptlib-2.4.1
	>=net-libs/opal-3.4.1
	>=x11-libs/gtk+-2.12.0
	>=dev-libs/glib-2.8.0
	>=dev-libs/libsigc++-2.0.0
	>=dev-libs/libxml2-2.0
	avahi? ( >=net-dns/avahi-0.6.0 )
	dbus? ( >=dev-libs/dbus-glib-0.36 )
	eds? ( >=gnome-extra/evolution-data-server-1.2 )
	gconf? ( >=gnome-base/gconf-2.6.0 )
	gnome? (
		>=gnome-base/libgnome-2.14.0
		>=gnome-base/libgnomeui-2.14.0 )
	ldap? ( net-nds/openldap )
	libnotify? ( x11-libs/libnotify )
	xv? ( x11-libs/libXv )"

DEPEND="${RDEPEND}
	>=sys-devel/make-3.81
	>=dev-util/pkgconfig-0.12.0
	>=dev-util/intltool-0.35
	gnome? ( doc? ( app-text/scrollkeeper
		app-text/gnome-doc-utils ) )"

DOCS="AUTHORS ChangeLog FAQ NEWS README"

pkg_setup() {
	local myconf

	if use gnome && use doc; then
		myconf="--enable-gdu"
	else
		myconf="--disable-gdu"
	fi

	G2CONF="${G2CONF}
		$(use_enable avahi)
		$(use_enable dbus)
		$(use_enable debug)
		$(use_enable doc)
		$(use_enable eds)
		$(use_enable gconf)
		$(use_enable gnome)
		$(use_enable ldap)
		$(use_enable libnotify notify)
		$(use_enable xv)
		${myconf}"
}

src_install() {
	if use gnome; then
		gnome2_src_install
	else
		emake DESTDIR="${D}" install || die "emake install failed"

		dodoc ${DOCS} || die "dodoc failed"
	fi
}

pkg_postinst() {
	if use gnome; then
		gnome2_pkg_postinst

		# Note : someone has to test if it's needed
		# we need to fix the GConf permissions, see bug #59764
#		einfo "Fixing GConf permissions for ekiga"
#		ekiga-config-tool --fix-permissions
	fi

	if ! use gnome; then
		ewarn "USE=-gnome is experimental, some weirdness with the UI and \
config keys should appear."
	fi
}
