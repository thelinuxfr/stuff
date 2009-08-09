# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils python eutils

DESCRIPTION="Moovida is an open source, cross platform media center solution for Linux, MacOSX and Windows on top of GStreamer."
HOMEPAGE="http://www.moovida.com/"
SRC_URI="http://www.moovida.com/static/download/${PN}/${P}.tar.gz"

RESTRICT="nomirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~ppc x86"
IUSE="daap doc dvd hal ipod flash lirc upnp weather"
EAPI="2"

MAKEOPTS="-j1"

RDEPEND="!media-video/elisa
    >=dev-lang/python-2.5
	dev-python/setuptools
	>=dev-python/imaging-1
	=dev-python/twisted-8.2.0
	=dev-python/twisted-web-8.2.0
	=dev-python/twisted-web2-8.2.0
	dev-python/pyopenssl
	dev-python/pygtk
	dev-python/gnome-python-extras
	>=dev-python/pigment-python-0.3.12
	>=media-libs/gstreamer-0.10.4
	>=dev-python/gst-python-0.10
	>=media-plugins/gst-plugins-ogg-0.10
	>=media-plugins/gst-plugins-vorbis-0.10
	>=media-plugins/gst-plugins-theora-0.10
	media-plugins/libvisual-plugins:0.4
	media-fonts/freefont-ttf
	x11-misc/xdg-user-dirs
	dev-python/pyxdg
	dev-python/celementtree
	dev-python/pysqlite
	dev-python/pycairo
	dev-python/simplejson
	media-plugins/gst-plugins-a52dec
	media-plugins/gst-plugins-alsa
	media-plugins/gst-plugins-dvdread
	media-plugins/gst-plugins-faac
	media-plugins/gst-plugins-faad
	media-plugins/gst-plugins-flac
	media-plugins/gst-plugins-fluendo-mpegdemux
	media-plugins/gst-plugins-gnomevfs
	media-plugins/gst-plugins-jpeg 
	media-plugins/gst-plugins-lame
	media-plugins/gst-plugins-libpng
	media-plugins/gst-plugins-libvisual
	media-plugins/gst-plugins-mad
	media-plugins/gst-plugins-mpeg2dec 
	media-plugins/gst-plugins-xvideo
	dvd? (
		media-libs/libdvdcss
		>=media-plugins/gst-plugins-ffmpeg-0.10
		>=media-libs/gst-plugins-bad-0.10
		>=media-libs/gst-plugins-ugly-0.10
		dev-python/tagpy
	)
	flash? (
		>=media-plugins/gst-plugins-ffmpeg-0.10
		>=media-libs/gst-plugins-bad-0.10
		dev-python/gdata
	)
	lirc? (
		app-misc/lirc
		dev-python/pylirc
	)
	daap? (
		dev-python/python-daap
		>=sys-apps/dbus-1
		>=dev-python/dbus-python-0.71
		>=net-dns/avahi-0.6[python]
	)
	hal? (
		>=sys-apps/hal-0.5
		>=dev-python/dbus-python-0.71
	)
	ipod? (
		media-libs/libgpod[python]
	)
	upnp? (
		dev-python/coherence
	)
	weather? (
		dev-python/pymetar
	)"


DEPEND="${DEPEND}
	>=dev-util/pkgconfig-0.9"

PDEPEND="~media-plugins/moovida-plugins-good-${PV}
	~media-plugins/moovida-plugins-bad-${PV}
	~media-plugins/moovida-plugins-ugly-${PV}"

DOCS="AUTHORS ChangeLog COPYING NEWS FIRST_RUN"

S="${WORKDIR}/elisa-${PV}"

pkg_setup() {
	addpredict "/root/.gstreamer-0.10"
}
