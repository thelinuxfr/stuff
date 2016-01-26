#!/bin/bash
# ==============================================================================
# Frederic LIETART 2016
# ==============================================================================
# Inspired from zenlord (https://bbs.archlinux.org/viewtopic.php?id=114585)
# Install rdiff-backup for RHEL or CentOS (from EPEL https://fedoraproject.org/wiki/EPEL)
# ==============================================================================
# Add crontab (for exemple runs the backup every night at 2.40h)
# 40 2 * * * /usr/local/backups-mount.sh
# ==============================================================================

# ==============================================================================
# Variables
EMAILFROM="test@test.fr"
EMAILADMIN="toto@toto.fr"
TASKNAME="mytask"
LOG="/tmp/$TASKNAME.log"

# Set source location
BACKUP_FROM="/home"

# Set target location
BACKUP_TO="/mnt/backups/"
BACKUP_DEV="xxxxx-xxxx-xxxx-xxxx-xxxxxxxxx" #UUID of the disk (blkid)
BACKUP_MNT="/mnt/backups"

# Set purge delay D(ay), W(eek), M(onth), Y(ear)
PURGEDELAY="1W"
# ==============================================================================

# Check that the log file exists
if [ -f "$LOG" ]; then
        rm -f $LOG
fi

# Check that source dir exists and is readable.
if [ ! -r  "$BACKUP_FROM" ]; then
        echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to read source dir." >> "$LOG"
        echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to sync." >> "$LOG"
        echo "" >> "$LOG"
        cat $LOG | mail -s "$HOSTNAME : ERROR : source dir exists and is readable ($TASKNAME)" -S from="$EMAILFROM" $EMAILADMIN
        exit 1
fi

# Check that target dir exists and is writable.
if [ ! -w  "$BACKUP_TO" ]; then
        echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to write to target dir." >> "$LOG"
        echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to sync." >> "$LOG"
        echo "" >> "$LOG"
        cat $LOG | mail -s "$HOSTNAME : ERROR : target dir exists and is writable ($TASKNAME)" -S from="$EMAILFROM" $EMAILADMIN
        exit 1
fi

# Check if the drive is mounted
if ! mountpoint "$BACKUP_MNT"; then
        echo "$(date "+%Y-%m-%d %k:%M:%S") - WARNING: Backup device needs mounting!" >> "$LOG"

        # If not, mount the drive
        if mount -U "$BACKUP_DEV"; then
                echo "$(date "+%Y-%m-%d %k:%M:%S") - Backup device mounted." >> "$LOG"
        else
                echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to mount backup device." >> "$LOG"
                echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to sync." >> "$LOG"
                echo "" >> "$LOG"
                cat $LOG | mail -s "$HOSTNAME : ERROR : Unable to mount backup device ($TASKNAME)" -S from="$EMAILFROM" $EMAILADMIN
                exit 1
        fi
fi

# Start entry in the log
echo "==============================================================================" >> "$LOG"
echo "$(date "+%Y-%m-%d %k:%M:%S") - Sync started." >> "$LOG"
echo "==============================================================================" >> "$LOG"

# Start sync
if rdiff-backup --force "$BACKUP_FROM" "$BACKUP_TO" &>> "$LOG"; then
        echo "$(date "+%Y-%m-%d %k:%M:%S") - Sync completed succesfully." >> "$LOG"
        rdiff-backup --remove-older-than "$PURGEDELAY" --force "$BACKUP_TO" &>> "$LOG"
else
        echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: rsync-command failed." >> "$LOG"
        echo "$(date "+%Y-%m-%d %k:%M:%S") - ERROR: Unable to sync." >> "$LOG"
        echo "" >> "$LOG"
        cat $LOG | mail -s "$HOSTNAME : ERROR : rsync-command failed ($TASKNAME)" -S from="$EMAILFROM" $EMAILADMIN
        exit 1
fi

# Unmount the drive so it does not accidentally get damaged or wiped
if umount "$BACKUP_MNT"; then
  echo "$(date "+%Y-%m-%d %k:%M:%S") - Backup device unmounted." >> "$LOG"
else
	echo "$(date "+%Y-%m-%d %k:%M:%S") - WARNING: Backup device could not be unmounted." >> "$LOG"
fi

# End entry in the log
echo "" >> "$LOG"
echo "==============================================================================" >> "$LOG"
echo "$(date "+%Y-%m-%d %k:%M:%S") - END LOG" >> "$LOG"
echo "==============================================================================" >> "$LOG"
exit 0
