#!/bin/sh

# Define values
eonconfpath=$(readlink -f "$0")
eonconfdir=$(dirname "$eonconfpath")
eondir="/srv/eyesofnetwork"
datadir="$eondir/eonweb"
eonwebdb="eonweb"
nagiosbpdb="nagiosbp"
notifierdb="notifier"

# change right acces for this files
chmod 775 ${datadir}/cache
chmod 664 /srv/eyesofnetwork/notifier/etc/notifier.cfg
chmod 664 /srv/eyesofnetwork/notifier/etc/notifier.rules
chown root:eyesofnetwork /srv/eyesofnetwork/notifier/etc/notifier.cfg
chown root:eyesofnetwork /srv/eyesofnetwork/notifier/etc/notifier.rules

# change own user for eonweb directory
chown -R root:eyesofnetwork ${datadir}*

# create the eonweb database
mysqladmin -u root --password=root66 create ${eonwebdb}
mysqladmin -u root --password=root66 create ${nagiosbpdb}
mysqladmin -u root --password=root66 create ${notifierdb}

# create the database content
mysql -u root --password=root66 ${eonwebdb} < ${eonconfdir}/eonweb.sql
mysql -u root --password=root66 ${nagiosbpdb} < ${eonconfdir}/nagiosbp.sql
mysql -u root --password=root66 ${notifierdb} < ${datadir}/module/admin_notifier/db/notifier.sql

# Change DocumentRoot for apache
sed -i 's/^DocumentRoot.*/DocumentRoot\ \"\/srv\/eyesofnetwork\/eonweb\"/g' /etc/httpd/conf/httpd.conf

# crons for eon
cp -rf ${eonconfdir}/eonbackup /etc/cron.d/
cp -rf ${eonconfdir}/eondowntime /etc/cron.d/
cp -rf ${eonconfdir}/eonwebpurge /etc/cron.d/

# start the services
/etc/init.d/httpd restart   > /dev/null 2>&1

