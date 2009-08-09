# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
 
MODULE_AUTHOR=FLORA
inherit perl-module
 
DESCRIPTION="Perl interface to the sexy widget collection"
SRC_URI="http://launchpadlibrarian.net/21311433/libgoo-canvas-perl_0.05.orig.tar.gz"
S="${WORKDIR}/libgoo-canvas-perl-0.05.orig"
 
SLOT="0"
LICENSE="LGPL-2.1"
KEYWORDS="~amd64 ~x86"
IUSE=""
 
RDEPEND="
  dev-perl/gtk2-perl
  dev-perl/glib-perl
  dev-perl/Cairo
  x11-libs/goocanvas
  dev-lang/perl"
DEPEND="${RDEPEND}
  dev-util/pkgconfig"
