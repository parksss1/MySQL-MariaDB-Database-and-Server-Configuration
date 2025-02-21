# Crontab
# 00 19 * * * /var/lib/mysql/jobscripts/purge_rubrik_tokens.sh > /var/log/mysql/purge_rubrik_tokens.log 2>&1
#
#!/bin/bash

# LOCATION OF RUBRIK TOKENS
BACKUP_DIR=""
echo $BACKUP_DIR 

# NAME OF PROGRAM RUNNING
PROGRAM=""

# NAME OF SERVER HOST 
HOSTNAME=""

# DATABASE NAME
DB=""

# EMAIL FOR NOTIFICATIONS
EMAIL = ''
# NUM. DAYS TO KEEP FILES
RETENTION=2
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

# FIND AMOUNT OF TOTAL TOKEN FILES IN DIRECTORY... IF NO FILES, EXIT
TOTAL_TOKEN_COUNT=$(find ${BACKUP_DIR} -name 'rubrik_token_request_*' 2>/dev/null | wc -l)

if [ ${TOTAL_TOKEN_COUNT} -eq 0 ]; then
    echo $(date +"%Y-%m-%d %H:%M:%S") "Exiting. No Files Found For Deletion"
    echo ${BORDER}
    exit 0
fi

echo $BORDER >> $OUTPUTFILE
echo $BORDER 
# TOKEN FILES FOUND... OUTPUT AMOUNT AND LIST OF FILES 
echo $(date +"%Y-%m-%d %H:%M:%S") "Total Candidate Files:  ${TOTAL_TOKEN_COUNT}" >> $OUTPUTFILE
echo $(date +"%Y-%m-%d %H:%M:%S") "Total Candidate Files:  ${TOTAL_TOKEN_COUNT}" 
ls -lrt ${BACKUP_DIR} >> $OUTPUTFILE
ls -lrt ${BACKUP_DIR}
echo $BORDER >> $OUTPUTFILE
echo $BORDER 

# FIND AMOUNT OF TOKEN FILES TO DELETE BASED ON FILES STARTING WITH 'rubrik_token_request_*' AND OLDER THAN ${RETENTION} DAYS IN $(BACKUP_DIR)
NUMBER_OF_FILES_TO_DELETE=$(find ${BACKUP_DIR} -name 'rubrik_token_request_*' -mtime +${RETENTION} 2>/dev/null | wc -l)
echo $(date +"%Y-%m-%d %H:%M:%S") "Total Selected Files:  ${NUMBER_OF_FILES_TO_DELETE}" >> $OUTPUTFILE
echo $(date +"%Y-%m-%d %H:%M:%S") "Total Selected Files:  ${NUMBER_OF_FILES_TO_DELETE}"
echo $BORDER >> $OUTPUTFILE
echo $BORDER 

echo $(date +"%Y-%m-%d %H:%M:%S") "Beginning Deletion of files more than ${RETENTION} days old" >> $OUTPUTFILE
echo $(date +"%Y-%m-%d %H:%M:%S") "Beginning Deletion of files more than ${RETENTION} days old"


# OUTPUT FILES TO BE DELETED
echo $(find ${BACKUP_DIR} -name 'rubrik_token_request_*' -mtime +${RETENTION} -exec ls -lrt {} \;) >> $OUTPUTFILE
echo $(find ${BACKUP_DIR} -name 'rubrik_token_request_*' -mtime +${RETENTION} -exec ls -lrt {} \;)

# REMOVE FILES
find ${BACKUP_DIR} -name 'rubrik_token_request_*' -mtime +${RETENTION} -exec rm {} \;

echo $BORDER >> $OUTPUTFILE
echo $BORDER 
# AMOUNT OF FILES AFTER PURGE CHECK
POST_PURGE_COUNT=$(find ${BACKUP_DIR} -name 'rubrik_token_request_*' 2>/dev/null | wc -l)
echo $(date +"%Y-%m-%d %H:%M:%S") "Total files post purge: ${POST_PURGE_COUNT}" >> $OUTPUTFILE
echo $(date +"%Y-%m-%d %H:%M:%S") "Total files post purge: ${POST_PURGE_COUNT}" 

# OUTPUT DIRECTORY AFTER PURGE OF TOKENS
ls -lrt $BACKUP_DIR >> $OUTPUTFILE
ls -lrt $BACKUP_DIR
echo $BORDER >> $OUTPUTFILE
echo $BORDER 

PURGE_SUCCESS=false

# CONFIRM SCRIPT RAN SUCCESSFULLY AND CONFIRM AMOUNT OF FILES BEFORE DELETION IS GREATER THAN AFTER
if [[ $? -eq 0 ]]; then
    if [[ $TOTAL_TOKEN_COUNT -gt $POST_PURGE_COUNT ]]; then
        echo $(date +"%Y-%m-%d %H:%M:%S") "Done deleting Rubrik Token files over ${RETENTION} days old." >> $OUTPUTFILE
        echo $(date +"%Y-%m-%d %H:%M:%S") "Done deleting Rubrik Token files over ${RETENTION} days old."
        PURGE_SUCCESS=true
    else
        echo $(date +"%Y-%m-%d %H:%M:%S") "Rubrik Token purge was not successful." >> $OUTPUTFILE
        echo $(date +"%Y-%m-%d %H:%M:%S") "Rubrik Token purge was not successful." 
        echo "TOTAL Rubrik Token FILE COUNT SAME AS BEFORE PURGE" >> $OUTPUTFILE
        echo "TOTAL Rubrik Token FILE COUNT SAME AS BEFORE PURGE"
        echo "TOTAL Rubrik Token FILE COUNT BEFORE: $TOTAL_TOKEN_COUNT" >> $OUTPUTFILE
        echo "TOTAL Rubrik Token FILE COUNT BEFORE: $TOTAL_TOKEN_COUNT"
        echo "TOTAL Rubrik Token FILE COUNT AFTER: $POST_PURGE_COUNT" >> $OUTPUTFILE
        echo "TOTAL Rubrik Token FILE COUNT AFTER: $POST_PURGE_COUNT"
    fi
else
    echo $(date +"%Y-%m-%d %H:%M:%S") "Rubrik Token purge not successful." >> $OUTPUTFILE
    echo $(date +"%Y-%m-%d %H:%M:%S") "Rubrik Token purge not successful." 
fi

echo $BORDER >> $OUTPUTFILE
echo $BORDER

if [[ "$PURGE_SUCCESS" == true ]]; then
    echo "Purge of Rubrik Tokens on $HOSTNAME completed successfully on `date`." | mailx -s "$HOSTNAME PURGE Rubrik Tokens SUCCESSFUL" ${EMAIL} < $OUTPUTFILE
else
    echo "Error: Purge of Rubrik Token on $HOSTNAME on `date`" | mailx -s "ERROR: $HOSTNAME PURGE Rubrik Tokens FAILED" ${EMAIL} < $OUTPUTFILE
fi