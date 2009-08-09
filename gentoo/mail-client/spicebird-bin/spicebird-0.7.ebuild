# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils mozilla-launcher multilib mozextension

#LANGS="af be bg ca cs da de el en-GB en-US es-AR es-ES eu fi fr ga-IE he hu it ja ko lt mk nb-NO nl nn-NO pa-IN pl pt-BR pt-PT ru sk sl sv-SE tr uk zh-CN zh-TW"
#NOSHORTLANGS="en-GB es-AR pt-BR zh-TW"

DESCRIPTION="Spicebird is your one platform for many collaboration needs"
SRC_URI="http://files.spicebird.org/pub/spicebird.org/spicebird/releases/${PV}/linux-i686/en-US/spicebird-beta-${PV}.en-US.linux-i686.tar.bz2"
HOMEPAGE="http://www.spicebird.com/"

KEYWORDS="-* ~x86"
SLOT="0"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
IUSE=""

#for X in ${LANGS} ; do
#	if [ "${X}" != "en" ] && [ "${X}" != "en-US" ]; then
#		SRC_URI="${SRC_URI}
#			linguas_${X/-/_}? ( http://dev.gentooexperimental.org/~armin76/dist/${P/-bin}-xpi/${P/-bin/}-${X}.xpi )"
#	fi
#	IUSE="${IUSE} linguas_${X/-/_}"
#	# english is handled internally
#	if [ "${#X}" == 5 ] && ! has ${X} ${NOSHORTLANGS}; then
#		if [ "${X}" != "en-US" ]; then
#			SRC_URI="${SRC_URI}
#				linguas_${X%%-*}? ( http://dev.gentooexperimental.org/~armin76/dist/${P/-bin}-xpi/${P/-bin/}-${X}.xpi )"
#		fi
#		IUSE="${IUSE} linguas_${X%%-*}"
#	fi
#done

DEPEND="app-arch/unzip"
RDEPEND="x11-libs/libXrender
	x11-libs/libXt
	x11-libs/libXmu
	x86? (
		>=x11-libs/gtk+-2.2
		=virtual/libstdc++-3.3
	)
	amd64? (
		>=app-emulation/emul-linux-x86-baselibs-1.0
		>=app-emulation/emul-linux-x86-gtklibs-1.0
		app-emulation/emul-linux-x86-compat
	)
	>=www-client/mozilla-launcher-1.41"

S="${WORKDIR}/spicebird-beta"

pkg_setup() {
	# This is a binary x86 package => ABI=x86
	# Please keep this in future versions
	# Danny van Dyk <kugelfang@gentoo.org> 2005/03/26
	has_multilib_profile && ABI="x86"
}

#linguas() {
#	local LANG SLANG
#	for LANG in ${LINGUAS}; do
#		if has ${LANG} en en_US; then
#			has en ${linguas} || linguas="${linguas:+"${linguas} "}en"
#			continue
#		elif has ${LANG} ${LANGS//-/_}; then
#			has ${LANG//_/-} ${linguas} || linguas="${linguas:+"${linguas} "}${LANG//_/-}"
#			continue
#		elif [[ " ${LANGS} " == *" ${LANG}-"* ]]; then
#			for X in ${LANGS}; do
#				if [[ "${X}" == "${LANG}-"* ]] && \
#					[[ " ${NOSHORTLANGS} " != *" ${X} "* ]]; then
#					has ${X} ${linguas} || linguas="${linguas:+"${linguas} "}${X}"
#					continue 2
#				fi
#			done
#		fi
#		ewarn "Sorry, but ${PN} does not support the ${LANG} LINGUA"
#	done
#}

src_unpack() {
	unpack spicebird-beta-${PV}.en-US.linux-i686.tar.bz2

#	linguas
#	for X in ${linguas}; do
#		[[ ${X} != en ]] && xpi_unpack ${P/-bin}-${X}.xpi
#	done
#	if [[ ${linguas} != "" && ${linguas} != "en" ]]; then
#		einfo "Selected language packs (first will be default): ${linguas}"
#	fi
}

src_install() {
	declare MOZILLA_FIVE_HOME="/opt/spicebird"

	# Install spicebird in /opt
	dodir ${MOZILLA_FIVE_HOME%/*}
	mv "${S}" "${D}"${MOZILLA_FIVE_HOME}

#	linguas
#	for X in ${linguas}; do
#		[[ ${X} != en ]] && xpi_install ${WORKDIR}/${P/-bin}-${X}
#	done

#	local LANG=${linguas%% *}
#	if [[ ${LANG} != "" && ${LANG} != "en" ]]; then
#		ebegin "Setting default locale to ${LANG}"
#		sed -i "s:pref(\"general.useragent.locale\", \"en-US\"):pref(\"general.useragent.locale\", \"${LANG}\"):" \
#			"${D}"${MOZILLA_FIVE_HOME}/defaults/pref/all-thunderbird.js \
#			"${D}"${MOZILLA_FIVE_HOME}/defaults/pref/all-l10n.js
#		eend $? || die "sed failed to change locale"
#	fi

	# Install /usr/bin/spicebird-bin
	install_mozilla_launcher_stub spicebird-bin ${MOZILLA_FIVE_HOME}

	# Install icon and .desktop for menu entry
	doicon "${FILESDIR}"/icon/spicebird16.xpm
	domenu "${FILESDIR}"/icon/${PN}.desktop

	# revdep-rebuild entry
	insinto /etc/revdep-rebuild
	doins "${FILESDIR}"/10spicebird-bin

	# install ldpath env.d
	doenvd "${FILESDIR}"/71spicebird-bin
}

pkg_preinst() {
	declare MOZILLA_FIVE_HOME="/opt/spicebird"

	# Remove entire installed instance to solve various
	# problems, for example see bug 27719
	rm -rf "${ROOT}"${MOZILLA_FIVE_HOME}
}

pkg_postinst() {

	update_mozilla_launcher_symlinks
}

pkg_postrm() {
	update_mozilla_launcher_symlinks
}
