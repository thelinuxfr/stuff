# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="VeriCAD is a 2D/3D parametric CAD/CAM software with BOM support."
HOMEPAGE="http://www.vericad.com/"
SRC_URI="varicad2008-en_3.04_i386.deb"

IUSE=""
LICENSE=""
SLOT="0"

# NOTE: varicad binaries are supplied just pre-stripped.
RESTRICT="fetch strip"

KEYWORDS="~amd64 ~x86"

DEPEND="x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXext
	x11-libs/libXmu
	x11-libs/libXrender
	x11-libs/libXt
	virtual/opengl
	amd64? (
		>=app-emulation/emul-linux-x86-baselibs-1.0
		app-emulation/emul-linux-x86-compat
	)"

S="${WORKDIR}"

pkg_nofetch() {
	echo
	eerror "Please go to: http://www.varicad.com/download.phtml"
	eerror
	eerror "and download the ${PN} 2008 ${PV} package."
	eerror "After downloading it, put the .deb into:"
	eerror "  ${DISTDIR}"
	echo
}

src_unpack() {
	unpack ${A}
	unpack ./data.tar.gz
	cd "${S}"

	# removing not necessary content
	rm control.tar.gz data.tar.gz debian-binary
	rm opt/VariCAD/desktop/*.sh \
		usr/share/menu/varicad2008-en \
		opt/VariCAD/desktop/varicad.mdkmenu \
		opt/VariCAD/desktop/varicad.wmconfig

	# NOTE: we need to strip some (useless) quotes
	sed -i \
		-e "s:\"::g" opt/VariCAD/desktop/varicad.desktop \
		|| die "seding varicad.desktop failed"
}

src_install() {
	# creating the desktop menu
	domenu opt/VariCAD/desktop/varicad.desktop || die "domenu failed."
	domenu opt/VariCAD/desktop/x-varicad.desktop || die "domenu mime failed."
	doicon opt/VariCAD/desktop/{varicad*.png,varicad.xpm}  || die "doicon failed."
	rm opt/VariCAD/desktop/*.desktop \
		opt/VariCAD/desktop/varicad*.png \
		opt/VariCAD/desktop/varicad.xpm
	rm -r opt/VariCAD/desktop

	# installing the docs
	dodoc usr/share/doc/varicad2008-en/{README-en.txt,ReleaseNotes.txt,README.Debian,copyright,changelog.Debian.gz}
	rm usr/share/doc/varicad2008-en/*

	# installing VariCAD
	cp -pPR * "${D}"/ || die "installing data failed"
}

pkg_config() {
	# license keywork file permissions
	# NOTE1: by default VariCAD software save the license keywork into the file:
	# /opt/VariCAD/lib/varicad.lck but with 0600 permissions, making impossible
	# to the non-root users to use VariCAD after the activation process.
	# here below we fix the permissions for the .lck file.
	# NOTE2: using src_install to create a void varicad.lck file with right 0640
	# permissions, make the license erasable by an emerge process of the package
	# (for example a version upgrade). For this reason we use pkg_config which
	# let preserve the license file avoiding the need to repeat the activation
	# process at every package upgrades.
	LICENSE_KEY="/opt/VariCAD/lib/varicad.lck"
	if [[ -f ${LICENSE_KEY} ]]; then
		einfo "Found VariCAD license: ${LICENSE_KEY}"
		ebegin "Fixing VariCAD license file permissions"
			chmod 0640 ${LICENSE_KEY}
			chown root:users ${LICENSE_KEY}
		eend $?
	else
		ewarn "Sorry but do not exists the file: ${LICENSE_KEY}."
		ewarn "Please successfuly complete the VariCAD activation process and then run:"
		ewarn "  # emerge --config =${CATEGORY}/${PF}"
	fi
}

pkg_postinst() {
	echo
	elog "You must first run VariCAD as root to invoke product registration."
	elog "After the VariCAD activation process, please run:"
	elog "  # emerge --config =${CATEGORY}/${PF}"
	elog
	elog "If you want to change your working directory, start VariCAD with the parameter"
	elog "'-askworkdir'.  Next time VariCAD start, you will be asked to define a"
	elog "path to your working directory."
	echo
}
