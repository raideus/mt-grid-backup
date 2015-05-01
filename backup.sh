#!/bin/bash

#
# backup.sh
# MT Grid Backup
# by Sean Butze (sbutze@gmail.com)
# 8/24/14
#
# Main backup script for MT Grid Backup.
# usage:  sh backup.sh [-d | -D | -f | -F | -c ]
#
# -d : Backup databases
# -D : Upload database backups
# -f : Backup files
# -F : Upload file backups
# -c : Cleanup local backup archives
#

# Load configuration options
ROOT=`dirname $0`
source "$ROOT/backup.conf"

# Create temp storage directories if we need to
if [[ ! -d "$ROOT/db" ]]; then
        mkdir $ROOT/db
fi

if [[ ! -d "$ROOT/files" ]]; then
        mkdir $ROOT/files
fi


# DATABASE BACKUP
# Create mysql dump files of all databases
function db_backup {
    databases=`mysql --user=$DB_USER --password=$DB_PASSWORD -h $DB_HOST -e "SHOW DATABASES;" | tr -d "| " | grep -v Database` 
    for db in $databases; do
        if [[ "$db" != "information_schema" ]] && [[ "$db" != _* ]] ; then
            filename=$db.`date +$DATEFORMAT`
            echo "Dumping database: $db"
            mysqldump --force --single-transaction --user=$DB_USER --password=$DB_PASSWORD -h $DB_HOST --databases $db > $ROOT/db/$filename.sql
            gzip $ROOT/db/$filename.sql
            rm -f $ROOT/db/$filename.sql
        fi
    done

    echo "Database backup done"
}

# FILE BACKUP
# Create compressed archives of all domains
function file_backup {
    for dir in $HOMEDIR/*/
    do
        dir=${dir%*/}
        dirname=${dir##*/}
        tar -zcf $ROOT/files/$dirname.`date +$DATEFORMAT`.tar.gz $dir/
    done

    echo "File backup done."  
}

# S3 UPLOAD
# Uploads local backup files to Amazon S3
function s3_upload {
    if [ $# -lt 1 ]; then
        echo "ERROR: Must specify file type ('db' or 'files')."
        exit
    fi

    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
    export AWS_SECRET_KEY=$AWS_SECRET_KEY
    export AWS_S3_BUCKET=$AWS_S3_BUCKET

    for filepath in $ROOT/$1/*.gz
    do
        php $ROOT/src/s3upload.php $1 $filepath
    done  

    echo "S3 upload done."  
}

# CLEANUP
# Removes local backup files
function cleanup {
    rm $ROOT/db/*.gz  > /dev/null 2>&1
    rm $ROOT/db/*.sql > /dev/null 2>&1
    rm $ROOT/files/*.tar.gz  > /dev/null 2>&1  
    echo "Cleanup done."  
}

# Parse command line arguments
while [ $# -gt 0 ]
do
    case $1 in
        -d|--db) db_backup
        ;;
        -f|--file) file_backup
        ;;
        -D|--db-upload) s3_upload db
        ;;
        -F|--file-upload) s3_upload files
        ;;
        -c|--cleanup) cleanup
        ;;
        (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1
        ;;
        (*) break
        ;;
    esac
    shift
done

shift $((OPTIND - 1))
