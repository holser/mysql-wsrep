########################################################################
# Bug #983695: --copy-back should ignore *.qp files
########################################################################

. inc/common.sh

if ! which qpress > /dev/null 2>&1 ; then
  echo "Requires qpress to be installed" > $SKIPPED_REASON
  exit $SKIPPED_EXIT_CODE
fi

start_server --innodb_file_per_table
load_sakila

innobackupex --compress --no-timestamp $topdir/backup

stop_server
rm -rf ${MYSQLD_DATADIR}/*

# Uncompress the backup
cd $topdir/backup
for i in *.qp sakila/*.qp;  do qpress -d $i ./; done;
cd -

innobackupex --copy-back $topdir/backup

run_cmd_expect_failure ls ${MYSQLD_DATADIR}/*.qp
run_cmd_expect_failure ls ${MYSQLD_DATADIR}/sakila/*.qp
