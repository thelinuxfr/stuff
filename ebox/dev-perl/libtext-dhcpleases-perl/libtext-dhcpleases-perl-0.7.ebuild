# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit perl-module

EAPI="0"

DESCRIPTION="DHCP libs Perl."
HOMEPAGE="http://www.ebox-platform.com"
SRC_URI="http://ppa.launchpad.net/ebox/ubuntu/pool/main/libt/${PN}/${PN}_${PV}.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="
	dev-lang/perl"
RDEPEND="${DEPEND}"

S="${WORKDIR}/Text-DHCPLeases-${PV}"


