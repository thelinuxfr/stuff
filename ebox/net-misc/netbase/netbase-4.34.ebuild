# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=0
PREV="2"

DESCRIPTION="Basic TCP/IP networking Ubuntu system"
HOMEPAGE="http://www.ubuntu.com/"

SRC_URI="http://archive.ubuntu.com/ubuntu/pool/main/n/${PN}/${PN}_${PV}ubuntu${PREV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	sys-apps/lsb-release"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${PV}ubuntu${PREV}"

src_install() {
	insinto /etc
	newins "etc-protocols" protocols
	newins "etc-rpc" rpc
	newins "etc-services" services

	dodir /etc/network/

  if [ -e /etc/networks ]; then return 0; fi

  cat >> /etc/networks <<-EOF
	default		0.0.0.0
	loopback	127.0.0.0
	link-local	169.254.0.0
	
EOF

	doconfd ${PN}
	newinitd debian/netbase.init networking

	dodoc debian/README.Debian
}
