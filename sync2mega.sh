#!/bin/sh

# Format de la date
DATE=`date +%Y-%m-%d`

# Répertoires local
BACKUPDIR="/backups"
LOGDIR=$BACKUPDIR/logs
TEMPDIR=$BACKUPDIR/$DATE
LOCALDIR=$BACKUPDIR/archives

# Répertoire Mega
MEGADIR="/Root/Debian-WEB"

# Répertoires SED
# /!\ Dois ABSOLUMENT correspondre avec LOCALDIR et MEGADIR en conservant les "\/" entre les dossiers /!\
SEDLOCALDIR="\/backups\/archives"
SEDMEGADIR="\/Root\/Debian-WEB"

# Fichiers
LOG=$LOGDIR/$DATE.log
ARCHIVE=$LOCALDIR/$DATE.tar.xz

# Directives
NBJOURS="6"
OPTS="-ah --force --ignore-errors"

echo " "
echo " +-----------------------------------------------------+"
echo " |                                                     |"
echo " |           Sauvegarde automatique sur Mega           |"
echo " |                       -------                       |"
echo " |       Par Rajaskank <rajaskank@overgeorge.org>      |"
echo " |           http://sync2mega.overgeorge.org           |"
echo " |                                                     |"
echo " +-----------------------------------------------------+"
echo " "
echo "-> Vérification des dossiers..."
if [ -d $BACKUPDIR ];
then
	echo "-> ${BACKUPDIR} existe !";
else
	echo "-> Création de ${BACKUPDIR}..."
	mkdir $BACKUPDIR;
fi

if [ -d $LOGDIR ];
then
	echo "-> ${LOGDIR} existe !";
else
echo "-> Création de ${LOGDIR}..."
	mkdir $LOGDIR;
fi

if [ -d $TEMPDIR ];
then
	echo "-> ${TEMPDIR} existe, suppression...";
	rm -rf $TEMPDIR
	echo "-> Création de ${TEMPDIR}..."
	mkdir $TEMPDIR;
else
	echo "-> Création de ${TEMPDIR}..."
	mkdir $TEMPDIR;
fi

if [ -d $LOCALDIR ];
then
	echo "-> ${LOCALDIR} existe !";
else
	echo "-> Création de ${LOCALDIR}..."
	mkdir $LOCALDIR;
fi

echo "-> Création de ${MEGADIR}..."
megamkdir --reload $MEGADIR;

# DATA
echo "-> Backup des données dans ${TEMPDIR}..."
# Apache
mkdir $TEMPDIR/apache2
rsync $OPTS /etc/apache2/sites-available $TEMPDIR/apache2
# www
rsync $OPTS /var/www $TEMPDIR
# END DATA
# SQL
echo "-> Dump SQL databases in ${TEMPDIR}..."
mkdir $TEMPDIR/mysql
mysqldump -u<SQL user> -p<SQL password> <SQL base> | gzip >$TEMPDIR/mysql/<SQL base>.gz
#END SQL

echo "-> Création de l'archive ${ARCHIVE}..."
tar --warning=none -Jcf $ARCHIVE --directory=$BACKUPDIR $DATE

echo "- Liste des archives à supprimés: "
find $LOCALDIR -type f -mtime +$NBJOURS

echo "-> Suppression des archives de plus de ${NBJOURS} jours en local..."
find $LOCALDIR -type f -mtime +$NBJOURS -exec rm -vf {} \;

echo "-> Suppression des archives de plus de ${NBJOURS} jours sur Mega..."
DELETE=`megasync --dryrun --reload --download --local $LOCALDIR --remote $MEGADIR | sed 's/F '$SEDLOCALDIR'/'$SEDMEGADIR'/g'`
for i in $DELETE;
do
	megarm --reload $i
done

echo "- Liste des archives en local: "
ls -1sh $LOCALDIR

echo "-> Synchronisation..."
megacopy --reload --local $LOCALDIR --remote $MEGADIR

echo "- Liste des archives sur Mega: "
megals --reload -lh $MEGADIR

echo "-> Suppression des fichiers temporaires..."
rm -rf $TEMPDIR

echo "- Espace disponible sur Mega: "
megadf --reload -h

echo " -> Suppression des logs de plus de ${NBJOURS} jours..."
find $LOGDIR -mtime +$NBJOURS -exec rm -vf {} \;

echo " "
echo " +-----------------------------------------------------+"
echo " |                                                     |"
echo " |                     ${DATE}                      |"
echo " |                Synchronisation OK !!                |"
echo " |                                                     |"
echo " +-----------------------------------------------------+"
echo " "

echo "${DATE}, synchronisation OK !!!" >> $LOG
echo "- Liste des archives supprimés: " >> $LOG
echo "$DELETE" >> $LOG
