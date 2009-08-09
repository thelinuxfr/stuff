# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit gnome2 eutils

DESCRIPTION="The Easy Publish and Consume library provides an easy method"
HOMEPAGE="http://live.gnome.org/libepc/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"

DEPEND="
	dev-libs/ossp-uuid
	net-dns/avahi
	dev-libs/glib
	net-libs/gnutls
	net-libs/libsoup"
RDEPEND="${DEPEND}"
