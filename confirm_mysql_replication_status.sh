# OUTPUT FILE
# Crontab
# 0 12 * * * /var/lib/mysql/jobscripts/check_replication_status.sh >> /var/log/mysql/check_replication_status.log 2>&1
#
#!/bin/bash

# HOSTNAME OF MASTER INSTANCE
MASTERNAME=''

#HOSTNAME OF SLAVE INSTANCE
SLAVENAME=''

# PROGRAM NAME
PROGRAM="check_replication_status.sh"

# EMAIL FOR NOTIFICATION
EMAIL = ''

# DATESTAMP YYYYMMDD_HH:MM
DATE=$(date +"%Y%m%d_%H:%M")
echo $DATE

# LOCATION OF BACKUPS
BACKUP_DIR=""
echo $BACKUP_DIR

# MySQL EXECUTABLE LOCATION
MYSQL=/usr/bin/mysql
echo $MYSQL

# DATABASE NAME
DB=""
echo $DB


# LOG FILE
OUTPUTFILE="/var/lib/mysql/jobscripts/logs/$PROGRAM.log"
echo $OUTPUTFILE


echo "--------------------------------------------------------------" > $OUTPUTFILE
echo "--------------------------------------------------------------"
echo "Running program "$PROGRAM" on $(date)" >> $OUTPUTFILE
echo "Running program "$PROGRAM" on $(date)"
echo
echo "OutputFile    : "$OUTPUTFILE >> $OUTPUTFILE
echo "OutputFile    : "$OUTPUTFILE
echo


# BEGIN TO CHECK REPLICATION STATUS
echo "Checking replication status of $DB between $MASTERNAME and $SLAVENAME" >> $OUTPUTFILE
echo "Checking replication status of $DB between $MASTERNAME and $SLAVENAME"

# GET REPLICATION STATUS 
STATUS_OUTPUT=$(mysql -e "SHOW REPLICA STATUS\G")

STATUS_SUCCESS=false
# CHECK IF COMMAND WAS SUCCESSFUL
if [ $? -ne 0 ]; then
    echo "$(date) Error: SHOW REPLICA STATUS\G command failed" >> $OUTPUTFILE
    echo "$(date) Error: SHOW REPLICA STATUS\G command failed" 
fi

# CHECK IS STATUS IS AVAILABLE (IS IT A SLAVE SERVER?)
if [ -z "$STATUS_OUTPUT" ]; then
    echo "$(date): Replication status is empty. Is this a slave server?" >> $OUTPUTFILE
    echo "$(date): Replication status is empty. Is this a slave server?" 
fi

# PARSE REPLICATION STATUS
SLAVE_IO_RUNNING=$(echo "$STATUS_OUTPUT" | awk '/Slave_IO_Running:/ {print $2}')
SLAVE_SQL_RUNNING=$(echo "$STATUS_OUTPUT" | awk '/Slave_SQL_Running:/ {print $2}')
SECONDS_BEHIND_MASTER=$(echo "$STATUS_OUTPUT" | awk '/Seconds_Behind_Master:/ {print $2}')

echo "--------------------------------------------------------------" > $OUTPUTFILE
echo "--------------------------------------------------------------"

# CHECK IF REPLICATION IS ACTIVE
if [ "$SLAVE_IO_RUNNING" = "Yes" ] && [ "$SLAVE_SQL_RUNNING" = "Yes" ]; then
    STATUS_SUCCESS=true
    echo "SHOW REPLICA STATUS\G OUTPUT:" 
    echo "SHOW REPLICA STATUS\G OUTPUT:" >> $OUTPUTFILE
    echo "SHOW REPLICA STATUS\G OUTPUT:"
    echo $STATUS_OUTPUT >> $OUTPUTFILE
    echo $STATUS_OUTPUT
else
    STATUS_SUCCESS=false
    echo "SHOW REPLICA STATUS\G OUTPUT:" >> $OUTPUTFILE
    echo "SHOW REPLICA STATUS\G OUTPUT:"
    echo $STATUS_OUTPUT >> $OUTPUTFILE
    echo $STATUS_OUTPUT
fi
echo "--------------------------------------------------------------" > $OUTPUTFILE
echo "--------------------------------------------------------------"

# SEND NOTIFICATION
if [[ "$STATUS_SUCCESS" == true ]]; then
    echo "Replication Status of $MASTERNAME and $SLAVENAME for DATABASE: $DB is active on $(date)." | mailx -s "REPLICATION BETWEEN $MASTERNAME AND $SLAVENAME DATABASE: $DB IS ACTIVE" ${EMAIL} < $OUTPUTFILE
else
    echo "Error: Replication Status of $MASTERNAME and $SLAVENAME for DATABASE: $DB is NOT active on $(date)." | mailx -s "ERROR: REPLICATION BETWEEN $MASTERNAME AND $SLAVENAME DATABASE: $DB IS NOT ACTIVE" ${EMAIL} < $OUTPUTFILE
fi
