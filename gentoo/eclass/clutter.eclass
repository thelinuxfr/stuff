# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# 
# clutter.eclass
#
# Sets SRC_URI, SLOT, and a few deps
#
# Authors:
# Nirbheek Chauhan <nirbheek.chauhan@gmail.com>
#
EAPI=1

inherit versionator

RV=($(get_version_components))
if test $((${RV[1]}/2)) != $(((${RV[1]}+1)/2)); then
	SLOT="${RV[0]}.$((${RV[1]}+1))"
else
	SLOT="${RV[0]}.${RV[1]}"
fi

if test "${PN}" != "clutter"; then
	RDEPEND="media-libs/clutter:${SLOT}"
fi

HOMEPAGE="http://www.clutter-project.org/"
SRC_URI="http://www.clutter-project.org/sources/${PN}/${RV[0]}.${RV[1]}/${P}.tar.bz2"
LICENSE="LGPL-2"
DOCS="AUTHORS ChangeLog NEWS README TODO"
DEPEND="dev-util/pkgconfig"

