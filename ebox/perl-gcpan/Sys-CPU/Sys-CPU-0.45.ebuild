# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit perl-module

DESCRIPTION="Perl extension for getting CPU information. Currently only number of CPU's supported."
HOMEPAGE="http://search.cpan.org/dist/Sys-CPU/"
SRC_URI="mirror://cpan/authors/id/M/MZ/MZSANFORD/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ia64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE=""
DEPEND="dev-lang/perl"

