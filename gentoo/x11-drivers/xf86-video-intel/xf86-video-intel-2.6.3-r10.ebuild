# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org driver for Intel cards"

KEYWORDS="amd64 ia64 x86 ~x86-fbsd"
IUSE="dri"

RDEPEND=">=x11-base/xorg-server-1.5
	x11-libs/libXvMC"
DEPEND="${RDEPEND}
	>=x11-proto/dri2proto-1.99.3
	x11-proto/fontsproto
	x11-proto/randrproto
	x11-proto/renderproto
	x11-proto/xineramaproto
	x11-proto/glproto
	x11-proto/xextproto
	x11-proto/xproto
	dri? ( 	x11-proto/xf86driproto
			>=x11-libs/libdrm-2.4.5
			x11-libs/libX11 )"

CONFIGURE_OPTIONS="$(use_enable dri)"

PATCHES=(
"${FILESDIR}/${PV}/${PV}-0001-clean-up-man-page-generation-and-remove-all-traces-o.patch"
"${FILESDIR}/${PV}/103_quirk_intel_mb890.patch"
"${FILESDIR}/${PV}/105_no_modesetting.diff"
"${FILESDIR}/${PV}/106_remove_triple_buffering.diff"
"${FILESDIR}/${PV}/107_remove_pageflipping.diff"
"${FILESDIR}/${PV}/109_i830-fifo-watermark-conservative.patch"
"${FILESDIR}/${PV}/110_quirk_hp_mini.patch"
"${FILESDIR}/${PV}/112_num_used_fences.patch"
"${FILESDIR}/${PV}/114_fix_xv_with_non_gem.patch"
"${FILESDIR}/${PV}/${PV}-0002-Fix-Xv-crash-with-overlay-video.patch"
"${FILESDIR}/${PV}/116_8xx_disable_dri.patch"
"${FILESDIR}/${PV}/117_quirk_thinkpad_x30.patch"
"${FILESDIR}/${PV}/118_drop_legacy3d.patch"
"${FILESDIR}/${PV}/119_drm_bo_unreference_needs_null.patch"
"${FILESDIR}/${PV}/120_fix_vt_switch.patch"
)
