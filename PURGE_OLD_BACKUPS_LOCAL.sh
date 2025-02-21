# Crontab
# 0 20 * * * /var/lib/mysql/jobscripts/rubrik_backup_delete_token_NEXTCLOUD.shl > /var/log/mysql/rubrik_backup_delete_token_NEXTCLOUD.log 2>&1
#
#!/bin/bash

# LOCATION OF BACKUP DIRECTORY
BACKUP_DIR=""
echo $BACKUP_DIR 

# NAME OF PROGRAM RUNNING
PROGRAM="$(basename "$0")"

# NAME OF SERVER HOST 
HOSTNAME=""

# NAME OF DATABASE
DB=""

# NUM. DAYS TO KEEP FILES
RETENTION=7
echo $RETENTION

# FILE FOR OUTPUT OF COMMANDS AND EMAIL DESCRIPTION
OUTPUTFILE="/var/lib/mysql/jobscripts/logs/$PROGRAM.log"


BORDER="--------------------------------------"

echo $BORDER > $OUTPUTFILE
echo $BORDER 
echo "Running program "$PROGRAM" on "`date` >> $OUTPUTFILE
echo "Running program "$PROGRAM" on "`date`
echo
echo "OutputFile    : "$OUTPUTFILE >> $OUTPUTFILE
echo "OutputFile    : "$OUTPUTFILE
echo

# FIND AMOUNT OF TOTAL BACKUP FILES IN DIRECTORY... IF NO FILES, EXIT
TOTAL_BACKUP_COUNT=$(ls -l ${BACKUP_DIR}/*.sql 2>/dev/null | wc -l)
if [ ${TOTAL_BACKUP_COUNT} -eq 0 ]; then
    echo $(date +"%Y-%m-%d %H:%M:%S") "Exiting. No Files Found For Deletion"
    echo ${BORDER}
    exit 0
fi

echo $BORDER >> $OUTPUTFILE
echo $BORDER 
# BACKUP FILES FOUND... OUTPUT AMOUNT AND LIST OF FILES 
echo $(date +"%Y-%m-%d %H:%M:%S") "Total Candidate Files:  ${TOTAL_BACKUP_COUNT}" >> $OUTPUTFILE
echo $(date +"%Y-%m-%d %H:%M:%S") "Total Candidate Files:  ${TOTAL_BACKUP_COUNT}" 
ls -lrt ${BACKUP_DIR}/*.sql >> $OUTPUTFILE
ls -lrt ${BACKUP_DIR}/*.sql
echo $BORDER >> $OUTPUTFILE
echo $BORDER 

# FIND AMOUNT OF BACKUP FILES TO DELETE BASED ON FILES ENDING IN '.sql' AND OLDER THAN ${RETENTION} DAYS IN BACKUP_DIR
NUMBER_OF_FILES_TO_DELETE=$(find ${BACKUP_DIR} -name '*.sql' -mtime +${RETENTION} 2>/dev/null | wc -l)
echo $(date +"%Y-%m-%d %H:%M:%S") "Total Selected Files:  ${NUMBER_OF_FILES_TO_DELETE}" >> $OUTPUTFILE
echo $(date +"%Y-%m-%d %H:%M:%S") "Total Selected Files:  ${NUMBER_OF_FILES_TO_DELETE}"
echo $BORDER >> $OUTPUTFILE
echo $BORDER 

echo $(date +"%Y-%m-%d %H:%M:%S") "Beginning Deletion of files more than ${RETENTION} days old" >> $OUTPUTFILE
echo $(date +"%Y-%m-%d %H:%M:%S") "Beginning Deletion of files more than ${RETENTION} days old"


# OUTPUT FILES TO BE DELETED
echo $(find ${BACKUP_DIR} -name '*.sql' -mtime +${RETENTION} -exec ls -lrt {} \;) >> $OUTPUTFILE
echo $(find ${BACKUP_DIR} -name '*.sql' -mtime +${RETENTION} -exec ls -lrt {} \;)

find ${BACKUP_DIR} -name '*.sql' -mtime +${RETENTION} -exec rm {} \;

# AMOUNT OF FILES AFTER PURGE CHECK
POST_PURGE_COUNT=$(ls -l ${BACKUP_DIR}/*.sql 2>/dev/null | wc -l)

echo $BORDER >> $OUTPUTFILE
echo $BORDER 
# OUTPUT DIRECTORY AFTER PURGE OF BACKUPS
ls -lrt $BACKUP_DIR >> $OUTPUTFILE
echo $BORDER >> $OUTPUTFILE
echo $BORDER 

PURGE_SUCCESS=false

# CONFIRM SCRIPT RAN SUCCESSFULLY AND CONFIRM AMOUNT OF FILES BEFORE DELETION IS GREATER THAN AFTER
if [[ $? -eq 0 ]]; then
    if [[ $TOTAL_BACKUP_COUNT -gt $POST_PURGE_COUNT ]]; then
        echo $(date +"%Y-%m-%d %H:%M:%S") "Done deleting backup files over ${RETENTION} days old." >> $OUTPUTFILE
        echo $(date +"%Y-%m-%d %H:%M:%S") "Done deleting backup files over ${RETENTION} days old."
        PURGE_SUCCESS=true
    else
        echo $(date +"%Y-%m-%d %H:%M:%S") "Backup purge was not successful." >> $OUTPUTFILE
        echo $(date +"%Y-%m-%d %H:%M:%S") "Backup purge not successful." 
        echo "TOTAL BACKUP FILE COUNT SAME AS BEFORE PURGE" >> $OUTPUTFILE
        echo "TOTAL BACKUP FILE COUNT SAME AS BEFORE PURGE"
        echo "TOTAL BACKUP FILE COUNT BEFORE: $TOTAL_BACKUP_COUNT" >> $OUTPUTFILE
        echo "TOTAL BACKUP FILE COUNT BEFORE: $TOTAL_BACKUP_COUNT"
        echo "TOTAL BACKUP FILE COUNT AFTER: $POST_PURGE_COUNT" >> $OUTPUTFILE
        echo "TOTAL BACKUP FILE COUNT AFTER: $POST_PURGE_COUNT"
    fi
else
    echo $(date +"%Y-%m-%d %H:%M:%S") "Backup purge not successful." >> $OUTPUTFILE
    echo $(date +"%Y-%m-%d %H:%M:%S") "Backup purge not successful." 
fi

echo $BORDER >> $OUTPUTFILE
echo $BORDER

# EMAIL NOTIFICATION
if [[ "$PURGE_SUCCESS" == true ]]; then
    echo "Purge of table backups for database $DB on $HOSTNAME completed successfully on `date`." | mailx -s "$HOSTNAME PURGE TABLE BACKUPS FOR DATABASE $DB SUCCESSFUL" aparker51@fordham.edu oracleadm@fordham.edu < $OUTPUTFILE
else
    echo "Error: Purge of database $DB tables backups FAILED on $HOSTNAME on `date`" | mailx -s "ERROR: $HOSTNAME PURGE TABLE BACKUPS FOR DATABASE $DB FAILED" aparker51@fordham.edu oracleadm@fordham.edu < $OUTPUTFILE
fi