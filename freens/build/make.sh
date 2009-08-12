#!/usr/bin/env bash
# This is a script designed to automate the assembly of the FreeNAS OS.
# Created: 2/12/2006 by Scott Zahn
# Modified by Volker Theile (votdev@gmx.de)

# Debug script
#set -x

################################################################################
# Settings
################################################################################

# Global variables
FREENS_ROOTDIR="/usr/local/freens"
FREENS_WORKINGDIR="$FREENS_ROOTDIR/work"
FREENS_ROOTFS="$FREENS_ROOTDIR/rootfs"
FREENS_SVNDIR="$FREENS_ROOTDIR/svn"
FREENS_WORLD=""
FREENS_PRODUCTNAME=$(cat $FREENS_SVNDIR/etc/prd.name)
FREENS_VERSION=$(cat $FREENS_SVNDIR/etc/prd.version)
FREENS_REVISION=$(svn info ${FREENS_SVNDIR} | grep "Revision:" | awk '{print $2}')
FREENS_ARCH=$(uname -p)
FREENS_KERNCONF="$(echo ${FREENS_PRODUCTNAME} | tr '[:lower:]' '[:upper:]')-${FREENS_ARCH}"
FREENS_OBJDIRPREFIX="/usr/obj/$(echo ${FREENS_PRODUCTNAME} | tr '[:upper:]' '[:lower:]')"
FREENS_BOOTDIR="$FREENS_ROOTDIR/bootloader"
FREENS_TMPDIR="/tmp/freenstmp"

export FREENS_ROOTDIR
export FREENS_WORKINGDIR
export FREENS_ROOTFS
export FREENS_SVNDIR
export FREENS_WORLD
export FREENS_PRODUCTNAME
export FREENS_VERSION
export FREENS_ARCH
export FREENS_KERNCONF
export FREENS_OBJDIRPREFIX
export FREENS_BOOTDIR
export FREENS_REVISION
export FREENS_TMPDIR

# Local variables
FREENS_URL=$(cat $FREENS_SVNDIR/etc/prd.url)
FREENS_SVNURL="http://svn.thelinuxfr.org/svn/freens/trunk"

# Size in MB of the MFS Root filesystem that will include all FreeBSD binary
# and FreeNAS WEbGUI/Scripts. Keep this file very small! This file is unzipped
# to a RAM disk at FreeNAS startup.
if [ "amd64" = ${FREENS_ARCH} ]; then
FREENS_MFSROOT_SIZE=86
FREENS_IMG_SIZE=40
else
FREENS_MFSROOT_SIZE=80
FREENS_IMG_SIZE=36
fi

# Media geometry, only relevant if bios doesn't understand LBA.
FREENS_IMG_SIZE_SEC=`expr ${FREENS_IMG_SIZE} \* 2048`
FREENS_IMG_SECTS=32
FREENS_IMG_HEADS=16

# Options:
# Support bootmenu
OPT_BOOTMENU=1
# Support bootsplash
OPT_BOOTSPLASH=0
# Support serial console
OPT_SERIALCONSOLE=0

# Dialog command
DIALOG="dialog"

################################################################################
# Functions
################################################################################

# Update source tree and ports collection.
update_sources() {
	tempfile=$FREENS_WORKINGDIR/tmp$$

	# Choose what to do.
	$DIALOG --title "$FREENS_PRODUCTNAME - Update sources" --checklist "Please select what to update." 10 60 3 \
		"cvsup" "Update source tree" OFF \
		"freebsd-update" "Fetch and install binary updates" OFF \
		"portsnap" "Update ports collection" OFF \
		"portupgrade" "Upgrade ports on host" OFF 2> $tempfile
	if [ 0 != $? ]; then # successful?
		rm $tempfile
		return 1
	fi

	choices=`cat $tempfile`
	rm $tempfile

	for choice in $(echo $choices | tr -d '"'); do
		case $choice in
			freebsd-update)
				freebsd-update fetch install;;
			portsnap)
				portsnap fetch update;;
			cvsup)
				csup -L 2 ${FREENS_SVNDIR}/build/source-supfile;;
			portupgrade)
				portupgrade -aFP;;
  	esac
  done

	return $?
}

# Build world. Copying required files defined in 'build/freens.files'.
build_world() {
	# Make a pseudo 'chroot' to FreeNAS root.
  cd $FREENS_ROOTFS

	echo
	echo "Building world:"

	[ -f $FREENS_WORKINGDIR/freens.files ] && rm -f $FREENS_WORKINGDIR/freens.files
	cp $FREENS_SVNDIR/build/freens.files $FREENS_WORKINGDIR

	# Add custom binaries
	if [ -f $FREENS_WORKINGDIR/freens.custfiles ]; then
		cat $FREENS_WORKINGDIR/freens.custfiles >> $FREENS_WORKINGDIR/freens.files
	fi

	for i in $(cat $FREENS_WORKINGDIR/freens.files | grep -v "^#"); do
		file=$(echo "$i" | cut -d ":" -f 1)

		# Deal with directories
		dir=$(dirname $file)
		if [ ! -d $dir ]; then
		  mkdir -pv $dir
		fi

		# Copy files from world.
		cp -Rpv ${FREENS_WORLD}/$file $(echo $file | rev | cut -d "/" -f 2- | rev)

		# Deal with links
		if [ $(echo "$i" | grep -c ":") -gt 0 ]; then
			for j in $(echo $i | cut -d ":" -f 2- | sed "s/:/ /g"); do
				ln -sv /$file $j
			done
		fi
	done

	# Cleanup
	rm -f $FREENS_WORKINGDIR/freens.files

	return 0
}

# Create rootfs
create_rootfs() {
	$FREENS_SVNDIR/build/freens-create-rootfs.sh -f $FREENS_ROOTFS

	# Configuring platform variable
	echo ${FREENS_VERSION} > ${FREENS_ROOTFS}/etc/prd.version

	# Config file: config.xml
	cd $FREENS_ROOTFS/conf.default/
	cp -v $FREENS_SVNDIR/conf/config.xml .

	# Compress zoneinfo data, exclude some useless files.
	mkdir $FREENS_TMPDIR
	echo "Factory" > $FREENS_TMPDIR/zoneinfo.exlude
	echo "posixrules" >> $FREENS_TMPDIR/zoneinfo.exlude
	echo "zone.tab" >> $FREENS_TMPDIR/zoneinfo.exlude
	tar -c -v -f - -X $FREENS_TMPDIR/zoneinfo.exlude -C /usr/share/zoneinfo/ . | gzip -cv > $FREENS_ROOTFS/usr/share/zoneinfo.tgz
	rm $FREENS_TMPDIR/zoneinfo.exlude

	return 0
}

# Actions before building kernel (e.g. install special/additional kernel patches).
pre_build_kernel() {
	tempfile=$FREENS_WORKINGDIR/tmp$$
	patches=$FREENS_WORKINGDIR/patches$$

	# Create list of available packages.
	echo "#! /bin/sh
$DIALOG --title \"$FREENS_PRODUCTNAME - Kernel patches\" \\
--checklist \"Select the patches you want to add. Make sure you have clean/origin kernel sources (via cvsup) to apply patches successful.\" 22 75 14 \\" > $tempfile

	for s in $FREENS_SVNDIR/build/kernel-patches/*; do
		[ ! -d "$s" ] && continue
		package=`basename $s`
		desc=`cat $s/pkg-descr`
		state=`cat $s/pkg-state`
		echo "\"$package\" \"$desc\" $state \\" >> $tempfile
	done

	# Display list of available kernel patches.
	sh $tempfile 2> $patches
	if [ 0 != $? ]; then # successful?
		rm $tempfile
		return 1
	fi
	rm $tempfile

	echo "Remove old patched files..."
	for file in $(find /usr/src -name "*.orig"); do
		rm -rv ${file}
	done

	for patch in $(cat $patches | tr -d '"'); do
    echo
		echo "--------------------------------------------------------------"
		echo ">>> Adding kernel patch: ${patch}"
		echo "--------------------------------------------------------------"
		cd $FREENS_SVNDIR/build/kernel-patches/$patch
		make install
		[ 0 != $? ] && return 1 # successful?
	done
	rm $patches
}

# Building the kernel
build_kernel() {
	tempfile=$FREENS_WORKINGDIR/tmp$$

	# Make sure kernel directory exists.
	[ ! -d "${FREENS_ROOTFS}/boot/kernel" ] && mkdir -p ${FREENS_ROOTFS}/boot/kernel

	# Choose what to do.
	$DIALOG --title "$FREENS_PRODUCTNAME - Build/Install kernel" --checklist "Please select whether you want to build or install the kernel." 10 75 3 \
		"prebuild" "Apply kernel patches" OFF \
		"build" "Build kernel" OFF \
		"install" "Install kernel + modules" ON 2> $tempfile
	if [ 0 != $? ]; then # successful?
		rm $tempfile
		return 1
	fi

	choices=`cat $tempfile`
	rm $tempfile

	for choice in $(echo $choices | tr -d '"'); do
		case $choice in
			prebuild)
				# Apply kernel patches.
				pre_build_kernel;
				[ 0 != $? ] && return 1;; # successful?
			build)
				# Copy kernel configuration.
				cd /sys/${FREENS_ARCH}/conf;
				cp -f $FREENS_SVNDIR/build/kernel-config/${FREENS_KERNCONF} .;
				# Clean object directory.
				rm -f -r ${FREENS_OBJDIRPREFIX};
				# Compiling and compressing the kernel.
				cd /usr/src;
				env MAKEOBJDIRPREFIX=${FREENS_OBJDIRPREFIX} make buildkernel KERNCONF=${FREENS_KERNCONF};
				gzip -9cnv ${FREENS_OBJDIRPREFIX}/usr/src/sys/${FREENS_KERNCONF}/kernel > ${FREENS_WORKINGDIR}/kernel.gz;;
			install)
				# Installing the modules.
				echo "--------------------------------------------------------------";
				echo ">>> Install kernel modules";
				echo "--------------------------------------------------------------";

				[ -f ${FREENS_WORKINGDIR}/modules.files ] && rm -f ${FREENS_WORKINGDIR}/modules.files;
				cp ${FREENS_SVNDIR}/build/kernel-config/modules.files ${FREENS_WORKINGDIR};

				modulesdir=${FREENS_OBJDIRPREFIX}/usr/src/sys/${FREENS_KERNCONF}/modules/usr/src/sys/modules;
				for module in $(cat ${FREENS_WORKINGDIR}/modules.files | grep -v "^#"); do
					install -v -o root -g wheel -m 555 ${modulesdir}/${module} ${FREENS_ROOTFS}/boot/kernel
				done;;
  	esac
  done

	return 0
}

# Adding the libraries
add_libs() {
	echo
	echo "Adding required libs:"

	# Identify required libs.
	[ -f /tmp/lib.list ] && rm -f /tmp/lib.list
	dirs=(${FREENS_ROOTFS}/bin ${FREENS_ROOTFS}/sbin ${FREENS_ROOTFS}/usr/bin ${FREENS_ROOTFS}/usr/sbin ${FREENS_ROOTFS}/usr/local/bin ${FREENS_ROOTFS}/usr/local/sbin ${FREENS_ROOTFS}/usr/lib ${FREENS_ROOTFS}/usr/local/lib ${FREENS_ROOTFS}/usr/libexec ${FREENS_ROOTFS}/usr/local/libexec)
	for i in ${dirs[@]}; do
		for file in $(find -L ${i} -type f -print); do
			ldd -f "%p\n" ${file} 2> /dev/null >> /tmp/lib.list
		done
	done

	# Copy identified libs.
	for i in $(sort -u /tmp/lib.list); do
		if [ -e "${FREENS_WORLD}${i}" ]; then
			install -c -s -v ${FREENS_WORLD}${i} ${FREENS_ROOTFS}$(echo $i | rev | cut -d '/' -f 2- | rev)
		fi
	done

	# Cleanup.
	rm -f /tmp/lib.list

  return 0
}

# Creating msfroot
create_mfsroot() {
	echo "--------------------------------------------------------------"
	echo ">>> Generating the MFSROOT filesystem"
	echo "--------------------------------------------------------------"

	cd $FREENS_WORKINGDIR

	[ -f $FREENS_WORKINGDIR/mfsroot.gz ] && rm -f $FREENS_WORKINGDIR/mfsroot.gz
	[ -d $FREENS_SVNDIR ] && use_svn ;

	# Make mfsroot to have the size of the FREENS_MFSROOT_SIZE variable
	dd if=/dev/zero of=$FREENS_WORKINGDIR/mfsroot bs=1k count=$(expr ${FREENS_MFSROOT_SIZE} \* 1024)
	# Configure this file as a memory disk
	md=`mdconfig -a -t vnode -f $FREENS_WORKINGDIR/mfsroot`
	# Create label on memory disk
	bsdlabel -m ${FREENS_ARCH} -w ${md} auto
	# Format memory disk using UFS
	newfs -O1 -o space -m 0 /dev/${md}c
	# Umount memory disk (if already used)
	umount $FREENS_TMPDIR >/dev/null 2>&1
	# Mount memory disk
	mount /dev/${md} ${FREENS_TMPDIR}
	cd $FREENS_TMPDIR
	tar -cf - -C $FREENS_ROOTFS ./ | tar -xvpf -

	cd $FREENS_WORKINGDIR
	# Umount memory disk
	umount $FREENS_TMPDIR
	# Detach memory disk
	mdconfig -d -u ${md}

	gzip -9fnv $FREENS_WORKINGDIR/mfsroot

	return 0
}

create_image() {
	echo "--------------------------------------------------------------"
	echo ">>> Generating ${FREENS_PRODUCTNAME} IMG File (to be rawrite on CF/USB/HD)"
	echo "--------------------------------------------------------------"

	# Check if rootfs (contining OS image) exists.
	if [ ! -d "$FREENS_ROOTFS" ]; then
		echo "==> Error: ${FREENS_ROOTFS} does not exist."
		return 1
	fi

	# Cleanup.
	[ -f ${FREENS_WORKINGDIR}/image.bin ] && rm -f image.bin
	[ -f ${FREENS_WORKINGDIR}/image.bin.gz ] && rm -f image.bin.gz

	# Set platform information.
	PLATFORM="${FREENS_ARCH}-embedded"
	echo $PLATFORM > ${FREENS_ROOTFS}/etc/platform

	# Set build time.
	date > ${FREENS_ROOTFS}/etc/prd.version.buildtime

	# Set revision.
	echo ${FREENS_REVISION} > ${FREENS_ROOTFS}/etc/prd.revision

	IMGFILENAME="${FREENS_PRODUCTNAME}-${PLATFORM}-${FREENS_VERSION}.${FREENS_REVISION}.img"

	echo "===> Generating tempory $FREENS_TMPDIR folder"
	mkdir $FREENS_TMPDIR
	create_mfsroot;

	echo "===> Creating an empty IMG file"
	dd if=/dev/zero of=${FREENS_WORKINGDIR}/image.bin bs=${FREENS_IMG_SECTS}b count=`expr ${FREENS_IMG_SIZE_SEC} / ${FREENS_IMG_SECTS}`
	echo "===> Use IMG as a memory disk"
	md=`mdconfig -a -t vnode -f ${FREENS_WORKINGDIR}/image.bin -x ${FREENS_IMG_SECTS} -y ${FREENS_IMG_HEADS}`
	diskinfo -v ${md}
	echo "===> Creating partition on this memory disk"
	fdisk -BI -b $FREENS_BOOTDIR/mbr ${md}
	echo "===> Configuring FreeBSD label on this memory disk"
	echo "
# /dev/${md}:
8 partitions:
#        size   offset    fstype   [fsize bsize bps/cpg]
  a:    ${FREENS_IMG_SIZE_SEC}        0    4.2BSD        0     0
  c:    *            *    unused        0     0         # "raw" part, don't edit
" > ${FREENS_WORKINGDIR}/bsdlabel.$$
	bsdlabel -m ${FREENS_ARCH} -R -B -b ${FREENS_BOOTDIR}/boot ${md} ${FREENS_WORKINGDIR}/bsdlabel.$$
	bsdlabel ${md}
	echo "===> Formatting this memory disk using UFS"
	newfs -U -o space -m 0 /dev/${md}a
	echo "===> Mount this virtual disk on $FREENS_TMPDIR"
	mount /dev/${md}a $FREENS_TMPDIR
	echo "===> Copying previously generated MFSROOT file to memory disk"
	cp $FREENS_WORKINGDIR/mfsroot.gz $FREENS_TMPDIR

	echo "===> Copying bootloader file(s) to memory disk"
	mkdir -p $FREENS_TMPDIR/boot
	mkdir -p $FREENS_TMPDIR/boot/kernel $FREENS_TMPDIR/boot/defaults
	mkdir -p $FREENS_TMPDIR/conf
	cp $FREENS_ROOTFS/conf.default/config.xml $FREENS_TMPDIR/conf
	cp $FREENS_BOOTDIR/kernel/kernel.gz $FREENS_TMPDIR/boot/kernel
	cp $FREENS_BOOTDIR/boot $FREENS_TMPDIR/boot
	cp $FREENS_BOOTDIR/loader $FREENS_TMPDIR/boot
	cp $FREENS_BOOTDIR/loader.conf $FREENS_TMPDIR/boot
	cp $FREENS_BOOTDIR/loader.rc $FREENS_TMPDIR/boot
	cp $FREENS_BOOTDIR/loader.4th $FREENS_TMPDIR/boot
	cp $FREENS_BOOTDIR/support.4th $FREENS_TMPDIR/boot
	cp $FREENS_BOOTDIR/defaults/loader.conf $FREENS_TMPDIR/boot/defaults/
	cp $FREENS_BOOTDIR/device.hints $FREENS_TMPDIR/boot
	if [ 0 != $OPT_BOOTMENU ]; then
		cp $FREENS_SVNDIR/boot/menu.4th $FREENS_TMPDIR/boot
		cp $FREENS_BOOTDIR/screen.4th $FREENS_TMPDIR/boot
		cp $FREENS_BOOTDIR/frames.4th $FREENS_TMPDIR/boot
	fi
	if [ 0 != $OPT_BOOTSPLASH ]; then
		cp $FREENS_SVNDIR/boot/splash.bmp $FREENS_TMPDIR/boot
		install -v -o root -g wheel -m 555 ${FREENS_OBJDIRPREFIX}/usr/src/sys/${FREENS_KERNCONF}/modules/usr/src/sys/modules/splash/bmp/splash_bmp.ko $FREENS_TMPDIR/boot/kernel
	fi
	if [ "amd64" != ${FREENS_ARCH} ]; then
		cd ${FREENS_OBJDIRPREFIX}/usr/src/sys/${FREENS_KERNCONF}/modules/usr/src/sys/modules && install -v -o root -g wheel -m 555 apm/apm.ko acpi/acpi/acpi.ko $FREENS_TMPDIR/boot/kernel
	fi

	echo "===> Unmount memory disk"
	umount $FREENS_TMPDIR
	echo "===> Detach memory disk"
	mdconfig -d -u ${md}
	echo "===> Compress the IMG file"
	gzip -9n $FREENS_WORKINGDIR/image.bin
	cp $FREENS_WORKINGDIR/image.bin.gz $FREENS_ROOTDIR/$IMGFILENAME

	# Cleanup.
	[ -d $FREENS_TMPDIR ] && rm -rf $FREENS_TMPDIR
	[ -f $FREENS_WORKINGDIR/mfsroot.gz ] && rm -f $FREENS_WORKINGDIR/mfsroot.gz
	[ -f $FREENS_WORKINGDIR/image.bin ] && rm -f $FREENS_WORKINGDIR/image.bin
	[ -f $FREENS_WORKINGDIR/bsdlabel.$$ ] && rm -f $FREENS_WORKINGDIR/bsdlabel.$$

	return 0
}

create_iso () {
	# Check if rootfs (contining OS image) exists.
	if [ ! -d "$FREENS_ROOTFS" ]; then
		echo "==> Error: ${FREENS_ROOTFS} does not exist."
		return 1
	fi

	# Cleanup.
	[ -d $FREENS_TMPDIR ] && rm -rf $FREENS_TMPDIR
	[ -f $FREENS_WORKINGDIR/mfsroot.gz ] && rm -f $FREENS_WORKINGDIR/mfsroot.gz

	if [ ! $LIGHT_ISO ]; then
		LABEL="${FREENS_PRODUCTNAME}-${FREENS_ARCH}-LiveCD-${FREENS_VERSION}.${FREENS_REVISION}"
		VOLUMEID="${FREENS_PRODUCTNAME}-${FREENS_ARCH}-LiveCD-${FREENS_VERSION}"
		echo "ISO: Generating the $FREENS_PRODUCTNAME Image file:"
		create_image;
	else
		LABEL="${FREENS_PRODUCTNAME}-${FREENS_ARCH}-LiveCD-light-${FREENS_VERSION}.${FREENS_REVISION}"
		VOLUMEID="${FREENS_PRODUCTNAME}-${FREENS_ARCH}-LiveCD-light-${FREENS_VERSION}"
	fi

	# Set platform information.
	PLATFORM="${FREENS_ARCH}-liveCD"
	echo $PLATFORM > ${FREENS_ROOTFS}/etc/platform

	# Set revision.
	echo ${FREENS_REVISION} > ${FREENS_ROOTFS}/etc/prd.revision

	echo "ISO: Generating temporary folder '$FREENS_TMPDIR'"
	mkdir $FREENS_TMPDIR
	create_mfsroot;

	echo "ISO: Copying previously generated MFSROOT file to $FREENS_TMPDIR"
	cp $FREENS_WORKINGDIR/mfsroot.gz $FREENS_TMPDIR

	echo "ISO: Copying bootloader file(s) to $FREENS_TMPDIR"
	mkdir -p $FREENS_TMPDIR/boot
	mkdir -p $FREENS_TMPDIR/boot/kernel $FREENS_TMPDIR/boot/defaults
	cp $FREENS_BOOTDIR/kernel/kernel.gz $FREENS_TMPDIR/boot/kernel
	cp $FREENS_BOOTDIR/cdboot $FREENS_TMPDIR/boot
	cp $FREENS_BOOTDIR/loader $FREENS_TMPDIR/boot
	cp $FREENS_BOOTDIR/loader.conf $FREENS_TMPDIR/boot
	cp $FREENS_BOOTDIR/loader.rc $FREENS_TMPDIR/boot
	cp $FREENS_BOOTDIR/loader.4th $FREENS_TMPDIR/boot
	cp $FREENS_BOOTDIR/support.4th $FREENS_TMPDIR/boot
	cp $FREENS_BOOTDIR/defaults/loader.conf $FREENS_TMPDIR/boot/defaults/
	cp $FREENS_BOOTDIR/device.hints $FREENS_TMPDIR/boot
	if [ 0 != $OPT_BOOTMENU ]; then
		cp $FREENS_SVNDIR/boot/menu.4th $FREENS_TMPDIR/boot
		cp $FREENS_BOOTDIR/screen.4th $FREENS_TMPDIR/boot
		cp $FREENS_BOOTDIR/frames.4th $FREENS_TMPDIR/boot
	fi
	if [ 0 != $OPT_BOOTSPLASH ]; then
		cp $FREENS_SVNDIR/boot/splash.bmp $FREENS_TMPDIR/boot
		install -v -o root -g wheel -m 555 ${FREENS_OBJDIRPREFIX}/usr/src/sys/${FREENS_KERNCONF}/modules/usr/src/sys/modules/splash/bmp/splash_bmp.ko $FREENS_TMPDIR/boot/kernel
	fi
	if [ "amd64" != ${FREENS_ARCH} ]; then
		cd ${FREENS_OBJDIRPREFIX}/usr/src/sys/${FREENS_KERNCONF}/modules/usr/src/sys/modules && install -v -o root -g wheel -m 555 apm/apm.ko acpi/acpi/acpi.ko $FREENS_TMPDIR/boot/kernel
	fi

	if [ ! $LIGHT_ISO ]; then
		echo "ISO: Copying IMG file to $FREENS_TMPDIR"
		cp ${FREENS_WORKINGDIR}/image.bin.gz ${FREENS_TMPDIR}/${FREENS_PRODUCTNAME}-${FREENS_ARCH}-embedded.gz
	fi

	echo "ISO: Generating the ISO file"
	mkisofs -b "boot/cdboot" -no-emul-boot -r -J -A "${FREENS_PRODUCTNAME} CD-ROM image" -publisher "${FREENS_URL}" -V "${VOLUMEID}" -o "${FREENS_ROOTDIR}/${LABEL}.iso" ${FREENS_TMPDIR}
	[ 0 != $? ] && return 1 # successful?

	echo "Generating MD5 and SHA256 sums..."
	FREENS_CHECKSUMFILENAME="${FREENS_PRODUCTNAME}-${FREENS_ARCH}-${FREENS_VERSION}.${FREENS_REVISION}.checksum"
	cd ${FREENS_ROOTDIR} && md5 *.img *.iso > ${FREENS_ROOTDIR}/${FREENS_CHECKSUMFILENAME}
	cd ${FREENS_ROOTDIR} && sha256 *.img *.iso >> ${FREENS_ROOTDIR}/${FREENS_CHECKSUMFILENAME}

	# Cleanup.
	[ -d $FREENS_TMPDIR ] && rm -rf $FREENS_TMPDIR
	[ -f $FREENS_WORKINGDIR/mfsroot.gz ] && rm -f $FREENS_WORKINGDIR/mfsroot.gz

	return 0
}

create_iso_light() {
	LIGHT_ISO=1
	create_iso;
	unset LIGHT_ISO
	return 0
}

create_full() {
	[ -d $FREENS_SVNDIR ] && use_svn ;

	echo "FULL: Generating $FREENS_PRODUCTNAME tgz update file"

	# Set platform information.
	PLATFORM="${FREENS_ARCH}-full"
	echo $PLATFORM > ${FREENS_ROOTFS}/etc/platform

	# Set revision.
	echo ${FREENS_REVISION} > ${FREENS_ROOTFS}/etc/prd.revision

	FULLFILENAME="${FREENS_PRODUCTNAME}-${PLATFORM}-${FREENS_VERSION}.${FREENS_REVISION}.tgz"

	echo "FULL: Generating tempory $FREENS_TMPDIR folder"
	#Clean TMP dir:
	[ -d $FREENS_TMPDIR ] && rm -rf $FREENS_TMPDIR
	mkdir $FREENS_TMPDIR

	#Copying all FreeNAS rootfilesystem (including symlink) on this folder
	cd $FREENS_TMPDIR
	tar -cf - -C $FREENS_ROOTFS ./ | tar -xvpf -
	#tar -cf - -C $FREENS_ROOTFS ./ | tar -xvpf - -C $FREENS_TMPDIR

	echo "Copying bootloader file(s) to root filesystem"
	mkdir -p $FREENS_TMPDIR/boot/kernel $FREENS_TMPDIR/boot/defaults
	#mkdir $FREENS_TMPDIR/conf
	cp $FREENS_ROOTFS/conf.default/config.xml $FREENS_TMPDIR/conf
	cp $FREENS_BOOTDIR/kernel/kernel.gz $FREENS_TMPDIR/boot/kernel
	gunzip $FREENS_TMPDIR/boot/kernel/kernel.gz
	cp $FREENS_BOOTDIR/boot $FREENS_TMPDIR/boot
	cp $FREENS_BOOTDIR/loader $FREENS_TMPDIR/boot
	cp $FREENS_BOOTDIR/loader.rc $FREENS_TMPDIR/boot
	cp $FREENS_BOOTDIR/loader.4th $FREENS_TMPDIR/boot
	cp $FREENS_BOOTDIR/support.4th $FREENS_TMPDIR/boot
	cp $FREENS_BOOTDIR/defaults/loader.conf $FREENS_TMPDIR/boot/defaults/
	cp $FREENS_BOOTDIR/device.hints $FREENS_TMPDIR/boot
	if [ 0 != $OPT_BOOTMENU ]; then
		cp $FREENS_SVNDIR/boot/menu.4th $FREENS_TMPDIR/boot
		cp $FREENS_BOOTDIR/screen.4th $FREENS_TMPDIR/boot
		cp $FREENS_BOOTDIR/frames.4th $FREENS_TMPDIR/boot
	fi
	if [ 0 != $OPT_BOOTSPLASH ]; then
		cp $FREENS_SVNDIR/boot/splash.bmp $FREENS_TMPDIR/boot
		cp ${FREENS_OBJDIRPREFIX}/usr/src/sys/${FREENS_KERNCONF}/modules/usr/src/sys/modules/splash/bmp/splash_bmp.ko $FREENS_TMPDIR/boot/kernel
	fi
	if [ "amd64" != ${FREENS_ARCH} ]; then
		cd ${FREENS_OBJDIRPREFIX}/usr/src/sys/${FREENS_KERNCONF}/modules/usr/src/sys/modules && cp apm/apm.ko acpi/acpi/acpi.ko $FREENS_TMPDIR/boot/kernel
	fi

	#Generate a loader.conf for full mode:
	echo 'kernel="kernel"' >> $FREENS_TMPDIR/boot/loader.conf
	echo 'bootfile="kernel"' >> $FREENS_TMPDIR/boot/loader.conf
	echo 'kernel_options=""' >> $FREENS_TMPDIR/boot/loader.conf
	echo 'kern.hz="100"' >> $FREENS_TMPDIR/boot/loader.conf
	echo 'splash_bmp_load="YES"' >> $FREENS_TMPDIR/boot/loader.conf
	echo 'bitmap_load="YES"' >> $FREENS_TMPDIR/boot/loader.conf
	echo 'bitmap_name="/boot/splash.bmp"' >> $FREENS_TMPDIR/boot/loader.conf

	#Check that there is no /etc/fstab file! This file can be generated only during install, and must be kept
	[ -f $FREENS_TMPDIR/etc/fstab ] && rm -f $FREENS_TMPDIR/etc/fstab

	#Check that there is no /etc/cfdevice file! This file can be generated only during install, and must be kept
	[ -f $FREENS_TMPDIR/etc/cfdevice ] && rm -f $FREENS_TMPDIR/etc/cfdevice

	echo "FULL: tgz the directory"
	cd $FREENS_ROOTDIR
	tar cvfz $FULLFILENAME -C $FREENS_TMPDIR ./

	# Cleanup.
	echo "Cleaning tempo file"
	[ -d $FREENS_TMPDIR ] && rm -rf $FREENS_TMPDIR

	return 0
}

# Update subversion sources.
update_svn() {
	# Update sources from repository.
	cd $FREENS_ROOTDIR
	svn co $FREENS_SVNURL svn

	# Update revision number.
	FREENS_REVISION=$(svn info ${FREENS_SVNDIR} | grep Revision | awk '{print $2}')

	return 0
}

use_svn() {
	echo "===> Replacing old code with SVN code"

	cd ${FREENS_SVNDIR}/build && cp -pv CHANGES ${FREENS_ROOTFS}/usr/local/www
	cd ${FREENS_SVNDIR}/root && find . \! -iregex ".*/\.svn.*" -print | cpio -pdumv ${FREENS_ROOTFS}/root
	cd ${FREENS_SVNDIR}/etc && find . \! -iregex ".*/\.svn.*" -print | cpio -pdumv ${FREENS_ROOTFS}/etc
	cd ${FREENS_SVNDIR}/www && find . \! -iregex ".*/\.svn.*" -print | cpio -pdumv ${FREENS_ROOTFS}/usr/local/www
	cd ${FREENS_SVNDIR}/conf && find . \! -iregex ".*/\.svn.*" -print | cpio -pdumv ${FREENS_ROOTFS}/conf.default

	return 0
}

build_system() {
  while true; do
echo -n '
Bulding system from scratch
Menu:
1 - Update source tree and ports collection
2 - Create filesystem structure
3 - Build kernel
4 - Build world
5 - Build ports
6 - Build bootloader
7 - Add necessary libraries
8 - Modify file permissions
* - Quit
> '
		read choice
		case $choice in
			1)	update_sources;;
			2)	create_rootfs;;
			3)	build_kernel;;
			4)	build_world;;
			5)	build_ports;;
			6)	opt="-f";
					if [ 0 != $OPT_BOOTMENU ]; then
						opt="$opt -m"
					fi;
					if [ 0 != $OPT_BOOTSPLASH ]; then
						opt="$opt -b"
					fi;
					if [ 0 != $OPT_SERIALCONSOLE ]; then
						opt="$opt -s"
					fi;
					$FREENS_SVNDIR/build/freens-create-bootdir.sh $opt $FREENS_BOOTDIR;;
			7)	add_libs;;
			8)	$FREENS_SVNDIR/build/freens-modify-permissions.sh $FREENS_ROOTFS;;
			*)	main;;
		esac
		[ 0 == $? ] && echo "=> Successful" || echo "=> Failed"
		sleep 1
  done
}

build_ports() {
	tempfile=$FREENS_WORKINGDIR/tmp$$
	ports=$FREENS_WORKINGDIR/ports$$

	# Choose what to do.
	$DIALOG --title "$FREENS_PRODUCTNAME - Build/Install Ports" --menu "Please select whether you want to build or install ports." 10 45 2 \
		"build" "Build ports" \
		"install" "Install ports" 2> $tempfile
	if [ 0 != $? ]; then # successful?
		rm $tempfile
		return 1
	fi

	choice=`cat $tempfile`
	rm $tempfile

	# Create list of available ports.
	echo "#! /bin/sh
$DIALOG --title \"$FREENS_PRODUCTNAME - Ports\" \\
--checklist \"Select the ports you want to process.\" 21 75 14 \\" > $tempfile

	for s in $FREENS_SVNDIR/build/ports/*; do
		[ ! -d "$s" ] && continue
		port=`basename $s`
		state=`cat $s/pkg-state`
		case ${state} in
			[hH][iI][dD][eE])
				;;
			*)
				desc=`cat $s/pkg-descr`;
				echo "\"$port\" \"$desc\" $state \\" >> $tempfile;
				;;
		esac
	done

	# Display list of available ports.
	sh $tempfile 2> $ports
	if [ 0 != $? ]; then # successful?
		rm $tempfile
		rm $ports
		return 1
	fi
	rm $tempfile

	case ${choice} in
		build)
			# Set ports options
			echo;
			echo "--------------------------------------------------------------";
			echo ">>> Set ports options.";
			echo "--------------------------------------------------------------";
			cd ${FREENS_SVNDIR}/build/ports/options && make
			# Clean ports.
			echo;
			echo "--------------------------------------------------------------";
			echo ">>> Cleaning ports.";
			echo "--------------------------------------------------------------";
			for port in $(cat ${ports} | tr -d '"'); do
				cd ${FREENS_SVNDIR}/build/ports/${port};
				make clean;
			done;
			# Build ports.
			for port in $(cat $ports | tr -d '"'); do
				echo;
				echo "--------------------------------------------------------------";
				echo ">>> Building port: ${port}";
				echo "--------------------------------------------------------------";
				cd ${FREENS_SVNDIR}/build/ports/${port};
				make build;
				[ 0 != $? ] && return 1; # successful?
			done;
			;;
		install)
			for port in $(cat ${ports} | tr -d '"'); do
				echo;
				echo "--------------------------------------------------------------";
				echo ">>> Installing port: ${port}";
				echo "--------------------------------------------------------------";
				cd ${FREENS_SVNDIR}/build/ports/${port};
				# Delete cookie first, otherwise Makefile will skip this step.
				rm -f ./work/.install_done.*;
				env NO_PKG_REGISTER=1 make install;
				[ 0 != $? ] && return 1; # successful?
			done;
			;;
	esac
	rm ${ports}

  return 0
}

main() {
	# Ensure we are in $FREENS_WORKINGDIR
	[ ! -d "$FREENS_WORKINGDIR" ] && mkdir $FREENS_WORKINGDIR
	cd $FREENS_WORKINGDIR

	echo -n "
Welcome to the ${FREENS_PRODUCTNAME} build environment.
Menu:
1  - Update the sources to CURRENT
2  - Build system from scratch
10 - Create 'Embedded' (IMG) file (rawrite to CF/USB/DD)
11 - Create 'LiveCD' (ISO) file
12 - Create 'LiveCD' (ISO) file without 'Embedded' file
13 - Create 'Full' (TGZ) update file
*  - Quit
> "
	read choice
	case $choice in
		1)	update_svn;;
		2)	build_system;;
		10)	create_image;;
		11)	create_iso;;
		12)	create_iso_light;;
		13)	create_full;;
		*)	exit 0;;
	esac

	[ 0 == $? ] && echo "=> Successful" || echo "=> Failed"
	sleep 1

	return 0
}

while true; do
	main
done
exit 0
