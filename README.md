Sync2Mega
===========
Synchronize your files automatically to Mega

Requirements
------------

* Linux
* RSync
* Megatools
* Mega account

Installation
------------

```
apt-get install rsync megatools
```

Configuration
------------

Create .megarc with your Mega credentials:

```
[Login]
Username = <mailuseby@mega.co.nz>
Password = <megapassword>
```

Set permissions:

```
chmod 600 .megarc
```

Edit DATA and SQL as needed::

```
# DATA
echo "-> Backup data in ${TEMPDIR}..."
mkdir $TEMPDIR/apache2
rsync $OPTS /etc/apache2/sites-available $TEMPDIR/apache2
rsync $OPTS /var/www $TEMPDIR
# END DATA
# SQL
echo "-> Dump SQL databases in ${TEMPDIR}..."
mkdir $TEMPDIR/mysql
mysqldump -u<SQL user> -p<SQL password> <SQL base> | gzip >$TEMPDIR/mysql/<SQL base>.gz
#END SQL
```

Create a new entry to your crontab file:

```
crontab -e
```

And paste (every day at 6h):

```
0 6 * * * /path/to/sync2mega.sh
```

Source
------------

Backup2Mega: [https://github.com/hardware/Backup2Mega](https://github.com/hardware/Backup2Mega)

Sysadmin and DBA tips: [http://albertolarripa.com/2013/07/10/megatools-synchronizing-your-backups-to-mega/](http://albertolarripa.com/2013/07/10/megatools-synchronizing-your-backups-to-mega/)
