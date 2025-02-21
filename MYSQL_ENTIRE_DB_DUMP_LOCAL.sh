# Crontab
# 0 21 * * * /var/lib/mysql/jobscripts/entire_db_dump.sh >> /var/log/mysql/entire_db_dump.log 2>&1
#
#!/bin/bash

# INSERT HOSTNAME
HOSTNAME=''

# NAME OF PROGRAM FOR OUTPUTS
PROGRAM="$(basename "$0")"

# DATE STAMP OF BACKUP YYYYMMDD_HH:MM
DATE=$(date +"%Y%m%d_%H:%M")
echo $DATE

# LOCATION OF BACKUP
BACKUP_DIR="/var/lib/mysql/backup"
echo $BACKUP_DIR

# MySQL EXECUTABLE LOCATION
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
echo $MYSQL
echo $MYSQLDUMP

# DATABASE NAME
DB="nextcloud"
echo $DB


# LOG FILE LOCATION
OUTPUTFILE="/var/lib/mysql/jobscripts/logs/$PROGRAM.log"
echo $OUTPUTFILE

# BACKUP FILE LOCATION
FILE="$BACKUP_DIR/${DB}_$DATE.sql"
echo $FILE

# OUTPUT FOR LOG/EMAIL
echo "--------------------------------------------------------------" > $OUTPUTFILE
echo "--------------------------------------------------------------"
echo "Running program "$PROGRAM" on $(date)" >> $OUTPUTFILE
echo "Running program "$PROGRAM" on $(date)"
echo
echo "OutputFile    : "$OUTPUTFILE >> $OUTPUTFILE
echo "OutputFile    : "$OUTPUTFILE
echo

echo "Backing up database: $DB" >> $OUTPUTFILE
echo "Backing up database: $DB"

# PERFORM MYSQL DUMP
$MYSQLDUMP $DB > $FILE
# CHANGE OWNERSHIP TO MYSQL
chown mysql:mysql $FILE
# OUTPUT CONTENTS OF BACKUP INCLUDING FILE SIZE AND DATE OF FILE IN OUTPUT FILE
ls -lrt $BACKUP_DIR >> $OUTPUTFILE

echo "--------------------------------------------------------------" >> $OUTPUTFILE

BACKUP_SUCCESS=false

# CONFIRM BACKUP WAS SUCCESSFUL
if [ $? -eq 0 ]; then
    # CHECKS IF DUMP FILE IS EMPTY 
    if [ ! -s $FILE ]; then
        echo "Error: Backup of database $DB failed on $(date)." >> $OUTPUTFILE
        echo "Error: Backup of database $DB failed"
        echo "FILE OF BACKUP IS EMPTY" >> $OUTPUTFILE
    else
        echo "Backup of $DB completed successfully on $(date)." >> $OUTPUTFILE
        echo "Backup of $DB completed successfully on $(date)."
        BACKUP_SUCCESS=true

        # FIND FILE OF PREVIOUS BACKUP FOR COMPARISON 
        PREV_FILE=$(ls -t $BACKUP_DIR/${DB}_*.sql | head -n 2 | tail -n 1)  
        # IF PREVIOUS FILE EXISTS... FIND SIZE OF BOTH NEW AND PREVIOUS BACKUP FOR COMPARISON
        if [ -f "$PREV_FILE" ]; then
            PREV_SIZE=$(stat -c%s "$PREV_FILE")
            NEW_SIZE=$(stat -c%s "$FILE")
            echo "Previous backup size: $PREV_SIZE" >> $OUTPUTFILE
            echo "Previous backup size: $PREV_SIZE"
            echo "New backup size: $NEW_SIZE" >> $OUTPUTFILE
            echo "New backup size: $NEW_SIZE"
            # RAISE CAUTION IF PREV AND NEW BACKUPS ARE SAME SIZE
            if [ "$NEW_SIZE" -eq "$PREV_SIZE" ]; then
                echo "CAUTION: Size of the new backup is the same as the previous backup." >> $OUTPUTFILE
                echo "CAUTION: Size of the new backup is the same as the previous backup."
            fi
        fi
    fi
else
    echo "Error: Backup of database $DB failed on $(date)" >> $OUTPUTFILE
    echo "Error: Backup of database $DB failed"
fi

# IF BACKUP WAS SUCCESSFUL OR ERROR, SEND EMAIL
if [[ "$BACKUP_SUCCESS" == true ]]; then
    echo "BACKUP of database $DB on $HOSTNAME completed successfully on $(date)." | mailx -s "$HOSTNAME DATABASE: $DB BACKUP SUCCESSFUL" aparker51@fordham.edu stoffa@fordham.edu < $OUTPUTFILE
else
    echo "Error: Backup of database $DB FAILED on $HOSTNAME on $(date)" | mailx -s "ERROR: $HOSTNAME DATABASE $DB BACKUP FAILED" aparker51@fordham.edu stoffa@fordham.edu < $OUTPUTFILE
fi







