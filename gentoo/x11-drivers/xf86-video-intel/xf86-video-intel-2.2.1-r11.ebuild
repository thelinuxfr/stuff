# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org driver for Intel cards"

KEYWORDS="amd64 arm ia64 sh x86 x86-fbsd"
IUSE="dri"

RDEPEND=">=x11-base/xorg-server-1.2
	x11-libs/libXvMC"
DEPEND="${RDEPEND}
	x11-proto/fontsproto
	x11-proto/randrproto
	x11-proto/renderproto
	x11-proto/xextproto
	x11-proto/xineramaproto
	x11-proto/xproto
	x11-proto/glproto
	=media-libs/mesa-7.0.3
	dri? ( x11-proto/xf86driproto
			=x11-libs/libdrm-2.3.0
			x11-libs/libX11 )"
src_unpack() {
	unpack ${A}
	cd "${S}"

epatch "${FILESDIR}/${PV}/0001-fixup-pciaccess-version-detect.patch"
epatch "${FILESDIR}/${PV}/01_fix_compiz_video.diff"
epatch "${FILESDIR}/${PV}/01_gen_pci_ids.diff"
epatch "${FILESDIR}/${PV}/03_dell_1535_quirk.diff"
epatch "${FILESDIR}/${PV}/04_dell_1735_quirk.diff"
epatch "${FILESDIR}/${PV}/05_intel_exa_force_greedy.patch"
epatch "${FILESDIR}/${PV}/08_945gm_quirk.diff"
epatch "${FILESDIR}/${PV}/10_hw_overlay.diff"
epatch "${FILESDIR}/${PV}/11_hw_overlay_option.diff"
epatch "${FILESDIR}/${PV}/12_quirk_sync.patch"
epatch "${FILESDIR}/${PV}/13_dpms_low_power_overlay.patch"
epatch "${FILESDIR}/${PV}/14_sysfs_fujitsu_backlight.patch"
epatch "${FILESDIR}/${PV}/15_quirk_sony_vaio_vgn-sz4mn.patch"
epatch "${FILESDIR}/${PV}/16_legacy_backlight_blc_pwn_ctl.patch"
epatch "${FILESDIR}/${PV}/17_lockup_virtual_size_2048.patch"

}

CONFIGURE_OPTIONS="$(use_enable dri)"

pkg_setup() {
	if use dri && ! built_with_use x11-base/xorg-server dri; then
		die "Build x11-base/xorg-server with USE=dri."
	fi
}
