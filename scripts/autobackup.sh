DB="nko4"
FROM_DB="--host URL:PORT -d $DB -u USER -p PASSWORD"
DATENOW=$(date +"%b-%d-%y--%H")
BACKUPPATH="/home/ubuntu/backupnko/back${DATENOW}"

echo "=> $DATENOW"
echo "=> $BACKUPPATH"
mkdir -p $BACKUPPATH/$DB
mongodump $FROM_DB -o $BACKUPPATH
