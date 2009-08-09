# Copyright 1999-2009 Gentoo Foundation
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
	=media-libs/mesa-7.0.3
	dri? ( x11-proto/xf86driproto
			x11-proto/glproto
			=x11-libs/libdrm-2.3.0
			x11-libs/libX11 )"

CONFIGURE_OPTIONS="$(use_enable dri)"

PATCHES=(
	"${FILESDIR}/2.4.1/01_gen_pci_ids.diff"
	"${FILESDIR}/2.4.1/11_textured_video_option.patch"
	"${FILESDIR}/2.4.1/20_thinkpad_g40_quirk.patch"
	"${FILESDIR}/2.4.1/21_quirk_lenovo.patch"
	"${FILESDIR}/2.4.1/22_no_pipe_for_hotplug_detection.patch"
	"${FILESDIR}/2.4.1/23_quirks_studiohybrid_eeepc_and_w251u.patch"
	"${FILESDIR}/2.4.1/24_no_render_suspend"
	"${FILESDIR}/2.4.1/25_quirk_nc6110.patch"
	"${FILESDIR}/2.4.1/26_i830-use-lfp-data-ptrs.patch"
	"${FILESDIR}/2.4.1/27_disable_fbc_on_965.patch"
	"${FILESDIR}/2.4.1/28_stolen_memory_counting_g4x.patch"
)



pkg_setup() {
	if use dri && ! built_with_use x11-base/xorg-server dri; then
		die "Build x11-base/xorg-server with USE=dri."
	fi
}
