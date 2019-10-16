#!/bin/bash
######################################################
#         script developed by PerformanceDB          #
#               wwww.performancedb.com               #
######################################################
#                   Make a Backup                    #
######################################################

#PDBTools interface with Whiptail dev by Alexandre Inacio ainacio01@gmail.com

export NEWT_COLORS='
window=,blue
border=white,blue
textbox=white,blue
button=black,gray
root=white,gray
sellistbox=blackwhite
actsellistbox=black,white
actlistbox=black,white
#shadow=black,white
title
actbutton
checkbox=black,gray
'

#goto the pdbtools directory
cd /opt/pdbtools/

#pdbtools config file
if [ ! -e /etc/pdbtools.cnf ]; then
  echo ""
  echo "Configuration file not found, check file permitions on /etc/pdbtools.cnf or reinstall the PDB Tools. "
  echo ""
  exit
fi

. /etc/pdbtools.cnf

if [ "$_pdbtools_server_pidof" = "" ]; then
  _pidof=$(which pidof)
  _pidof_sed=$(echo $_pidof|sed -e 's/\//\\\//g')
  sed -i -e 's/\(_pdbtools_server_pidof=\).*/\1'$_pidof_sed'/' /etc/pdbtools.cnf
fi

whiptail --title "Setting up the PDB-BACKUP" --nocancel --msgbox "The PDB-BACKUP is not a backup tool, but a set of scripts that facilitates and controls the generation of full and incremental MySQL backups through mysqldump, Percona Xtrabackup, MariaDB mariabackup or MySQL Enterprise Backup." 15 60

whiptail --title "Setting up the PDB-BACKUP" --nocancel --msgbox "Some settings will be necessary for the correct operation of the PDB-BACKUP, as well as the backup tool used, but all the settings requested here can be changed manually by editing the PDB Tools configuration file /etc/pdbtools.cnf." 15 60



if [ "$_pdbtools_database_user" = "" ]; then
_v_pdbtools_database_user=$(whiptail --inputbox "To perform backups using PDB-BACKUP it is necessary to inform the user of the database that will be used." 10 60 --title "User" 3>&1 1>&2 2>&3)
  sed -i -e 's/\(_pdbtools_database_user=\).*/\1'$_v_pdbtools_database_user'/' /etc/pdbtools.cnf
  _pdbtools_database_user=$_v_pdbtools_database_user
fi

if [ "$_pdbtools_database_password" = "" ]; then
  _v_pdbtools_database_password=$(whiptail --inputbox "To perform backups using PDB-BACKUP it is necessary to inform the password of the user "$_pdbtools_database_user"." 10 60 --title "Password" 3>&1 1>&2 2>&3)
  sed -i -e 's/\(_pdbtools_database_password=\).*/\1'$_v_pdbtools_database_password'/' /etc/pdbtools.cnf
fi


if [ $(type -p mysqldump) ]; then
  menumysqldump="installed"
else
  menumysqldump="not installed"
fi
if [ $(type -p xtrabackup) ]; then
  menuxtrabackup="installed"
else
  menuxtrabackup="not installed"
fi
if [ $(type -p mariabackup) ]; then
  menumariabackup="installed"
else
  menumariabackup="not installed"
fi
if [ $(type -p mysqlbackup) ]; then
  menumysqlbackup="installed"
else
  menumysqlbackup="not installed"
fi


while true ; do
function advancedMenu() {
_pdbtoolsBackupProgram=$(whiptail --title "Setting up the PDB-BACKUP" --nocancel --fb --menu "Which of option above programs will be used to perform the backups?" 20 90 7 \
"1" "mysqldump ($menumysqldump)  " \
"2" "Percona Xtrabackup ($menuxtrabackup) " \
"3" "MariaDB mariabackup ($menumariabackup)" \
"4" "MySQL Enterprise Backup ($menumysqlbackup)" \
"5" "Exit" 3>&1 1>&2 2>&3)


	case $_pdbtoolsBackupProgram in
	    1)

			if [ ! $(type -p mysqldump) ]; then

				whiptail --title "mysqldump" --nocancel --msgbox "The program 'mysqldump' is not installed. Before proceeding, install 'mysqldump' and then run pdb-tools-config again. If you have the mysqldump installed, but the path to the binary is not configured in the linux paths, enter the path to the mysqldump binary in /etc/pdbtools.cnf and try again." 15 60

			  else
			
				whiptail --title "mysqldump" --nocancel --msgbox "Done! I have already verified that 'mysqldump' is installed, we will continue the configuration of PDB Backup. To perform incremental backups with mysqldump, make sure your binary log is enabled. To perform incremental backups with mysqldump, inform in the /etc/pdbtools.cnf file of the path the path to the binary logs." 15 60
			    sed -i -e 's/\(_pdbtools_backup_program=\).*/\1mysqldump/' /etc/pdbtools.cnf

				_pdbtoolsBackupTableCreated=$(whiptail --title "Create Table Backup" --nocancel --fb --menu "Now it is necessary to create the table that will control the execution of the backups, so execute this scripts in your database: /opt/pdbtools/share/pdb-backup-create-table.sql" 15 60 3 \
				"Y" "YES" \
				"N" "NO" 3>&1 1>&2 2>&3)

				if [ $_pdbtoolsBackupTableCreated != "Y" ]; then
				  echo ""
				  whiptail --title "Create Table Backup" --nocancel --msgbox "Understood! Execute this scripts in your database: /opt/pdbtools/share/pdb-backup-create-table.sql, when you want to complete the configuration, just execute the pdb-tools-config again" 10 60
				  exit
				fi

				_pdbtoolsBackupPath=$(whiptail --inputbox "Now enter the path that backups should be saved. * Important: do not put the / at the end. e.g. /backup" 10 60 --title "Enter the backup path here" 3>&1 1>&2 2>&3)
				_pdbtoolsBackupPath=$(echo $_pdbtoolsBackupPath|sed -e 's/\//\\\//g')
				sed -i -e 's/\(_pdbtools_backup_path=\).*/\1'$_pdbtoolsBackupPath'/' /etc/pdbtools.cnf

				if [ $(type -p tar) ]; then
				  tar="installed"
				else
				  tar="not installed"
				fi
				if [ $(type -p zip) ]; then
				  zip="installed"
				else
				  zip="not installed"
				fi

				_pdbtoolsBackupToBeCompressed=$(whiptail --title "Compress Backup" --nocancel --fb --menu "Do you want the backup to be compressed?" 15 60 3 \
				"Y" "YES" \
				"N" "NO" 3>&1 1>&2 2>&3)

				if [ $_pdbtoolsBackupToBeCompressed = "Y" ]; then
				  sed -i -e 's/\(_pdbtools_backup_tobe_compressed=\).*/\11/' /etc/pdbtools.cnf

				_pdbtoolsBackupCompressionType=$(whiptail --title "Compress Backup" --nocancel --fb --menu "Choose the form of compression, below I will show a list with the options available on your server." 20 90 7 \
				"tar" "($tar)" \
				"zip" "($zip) " 3>&1 1>&2 2>&3) 
				 echo ""

				  if [ ! $(type -p $_pdbtoolsBackupCompressionType) ]; then
				 
				      whiptail --title "Create Table Backup" --nocancel --msgbox "Informed compression is not available on your server, but at any time you can activate it by running the pdb-tools-config - bye bye" 10 60
				      sed -i -e 's/\(_pdbtools_backup_tobe_compressed=\).*/\10/' /etc/pdbtools.cnf
				      exit

				    else
				  	  sed -i -e 's/\(_pdbtools_backup_compression_type=\).*/\1'$_pdbtoolsBackupCompressionType'/' /etc/pdbtools.cnf
				  fi

				else
				  sed -i -e 's/\(_pdbtools_backup_tobe_compressed=\).*/\10/' /etc/pdbtools.cnf
				fi

				touch pdb-backup.configured

				echo ""
				echo "Very well!"
				echo "The pdb-backup is ready to use, below you will see some info on how to perform the backups and some important information, so read carefully."
				echo ""
				echo "To change the backup settings:"
				echo "Just run the pdb-tools-config command"
				echo "OR"
				echo "Edit the /etc/pdbtools.cnf configuration file"

				echo ""
				echo "Incremental Backup:"
				echo "The Percona XtraBackup, mariabackup and MEB(MySQL Enterprise Backup) implements the incremental backup for InnoDB tables but no for other engines and the tables will always be copied in full, for more information, please consult the manual of your backup program."
				echo "The incremental backup using mysqldump is done by copying the binary logs since the last full backup and for this it is necessary to have the binary log enabled, in addition it is not 100% accurate because there are commands that can be executed without being recorded in the binary log (e.g. commands executed after SET sql_log_bin = 0;), so analyze well before using this feature."
				echo "If the backup is performed on a slave server, make sure log_slave_updates is enabled."
				echo "---------> To perform incremental backups with mysqldump, inform in the /etc/pdbtools.cnf file of the path the path to the binary logs.  <---------"

				echo ""
				echo "Examples of backup scheduling (crontab):"
				echo "0 0 * * * pdb-backup full >/dev/null 2>&1"
				echo "0 6,12,18 * * * pdb-backup incremental >/dev/null 2>&1"

				echo ""
				echo "If you have any questions, bug report or suggestions, send an email to pdbtools@performancedb.com"
				echo "Thank you for using the scripts developed by PerformanceDB. These scripts are developed and distributed free of charge, from DBA to DBA."
				echo "www.performancedb.com"
				echo "pdbtools@performancedb.com"


			fi

		;;
        
        2)


		    if [ ! $(type -p xtrabackup) ]; then

				whiptail --title "xtrabackup" --nocancel --msgbox "The program 'xtrabackup' is not installed. Before proceeding, install 'xtrabackup' and then run pdb-backup again." 10 60

		      else

		   	    whiptail --title "xtrabackup" --nocancel --msgbox "Done! I have already verified that 'xtrabackup' is installed, we will continue the configuration of PDB Backup." 10 60
		        sed -i -e 's/\(_pdbtools_backup_program=\).*/\1xtrabackup/' /etc/pdbtools.cnf

				_pdbtoolsBackupTableCreated=$(whiptail --title "Create Table Backup" --nocancel --fb --menu "Now it is necessary to create the table that will control the execution of the backups, so execute this scripts in your database: /opt/pdbtools/share/pdb-backup-create-table.sql" 15 60 3 \
				"Y" "YES" \
				"N" "NO" 3>&1 1>&2 2>&3)

				if [ $_pdbtoolsBackupTableCreated != "Y" ]; then
				  echo ""
				  whiptail --title "Create Table Backup" --nocancel --msgbox "Understood! Execute this scripts in your database: /opt/pdbtools/share/pdb-backup-create-table.sql, when you want to complete the configuration, just execute the pdb-tools-config again" 10 60
				  exit
				fi

				_pdbtoolsBackupPath=$(whiptail --inputbox "Now enter the path that backups should be saved. * Important: do not put the / at the end. e.g. /backup" 10 60 --title "Enter the backup path here" 3>&1 1>&2 2>&3)
				_pdbtoolsBackupPath=$(echo $_pdbtoolsBackupPath|sed -e 's/\//\\\//g')
				sed -i -e 's/\(_pdbtools_backup_path=\).*/\1'$_pdbtoolsBackupPath'/' /etc/pdbtools.cnf

				if [ $(type -p tar) ]; then
				  tar="installed"
				else
				  tar="not installed"
				fi
				if [ $(type -p zip) ]; then
				  zip="installed"
				else
				  zip="not installed"
				fi

				_pdbtoolsBackupToBeCompressed=$(whiptail --title "Compress Backup" --nocancel --fb --menu "Do you want the backup to be compressed?" 15 60 3 \
				"Y" "YES" \
				"N" "NO" 3>&1 1>&2 2>&3)

				if [ $_pdbtoolsBackupToBeCompressed = "Y" ]; then
				  sed -i -e 's/\(_pdbtools_backup_tobe_compressed=\).*/\11/' /etc/pdbtools.cnf

				_pdbtoolsBackupCompressionType=$(whiptail --title "Compress Backup" --nocancel --fb --menu "Choose the form of compression, below I will show a list with the options available on your server." 20 90 7 \
				"tar" "($tar)" \
				"zip" "($zip) " 3>&1 1>&2 2>&3) 
				 echo ""

				  if [ ! $(type -p $_pdbtoolsBackupCompressionType) ]; then
				 
				      whiptail --title "Create Table Backup" --nocancel --msgbox "Informed compression is not available on your server, but at any time you can activate it by running the pdb-tools-config - bye bye" 10 60
				      sed -i -e 's/\(_pdbtools_backup_tobe_compressed=\).*/\10/' /etc/pdbtools.cnf
				      exit

				    else
				  	  sed -i -e 's/\(_pdbtools_backup_compression_type=\).*/\1'$_pdbtoolsBackupCompressionType'/' /etc/pdbtools.cnf
				  fi

				else
				  sed -i -e 's/\(_pdbtools_backup_tobe_compressed=\).*/\10/' /etc/pdbtools.cnf
				fi

				touch pdb-backup.configured

				echo ""
				echo "Very well!"
				echo "The pdb-backup is ready to use, below you will see some info on how to perform the backups and some important information, so read carefully."
				echo ""
				echo "To change the backup settings:"
				echo "Just run the pdb-tools-config command"
				echo "OR"
				echo "Edit the /etc/pdbtools.cnf configuration file"

				echo ""
				echo "Incremental Backup:"
				echo "The Percona XtraBackup, mariabackup and MEB(MySQL Enterprise Backup) implements the incremental backup for InnoDB tables but no for other engines and the tables will always be copied in full, for more information, please consult the manual of your backup program."
				echo "The incremental backup using mysqldump is done by copying the binary logs since the last full backup and for this it is necessary to have the binary log enabled, in addition it is not 100% accurate because there are commands that can be executed without being recorded in the binary log (e.g. commands executed after SET sql_log_bin = 0;), so analyze well before using this feature."
				echo "If the backup is performed on a slave server, make sure log_slave_updates is enabled."
				echo "---------> To perform incremental backups with mysqldump, inform in the /etc/pdbtools.cnf file of the path the path to the binary logs.  <---------"

				echo ""
				echo "Examples of backup scheduling (crontab):"
				echo "0 0 * * * pdb-backup full >/dev/null 2>&1"
				echo "0 6,12,18 * * * pdb-backup incremental >/dev/null 2>&1"

				echo ""
				echo "If you have any questions, bug report or suggestions, send an email to pdbtools@performancedb.com"
				echo "Thank you for using the scripts developed by PerformanceDB. These scripts are developed and distributed free of charge, from DBA to DBA."
				echo "www.performancedb.com"
				echo "pdbtools@performancedb.com"

		        	
		    fi

		;;

        3)
            
            if [ ! $(type -p mariabackup) ]; then

				whiptail --title "mariabackup" --nocancel --msgbox "The program 'mariabackup' is not installed. Before proceeding, install 'mariabackup' and then run pdb-backup again." 10 60

		      else
				
				whiptail --title "mariabackup" --nocancel --msgbox "Done! I have already verified that 'mariabackup' is installed, we will continue the configuration of PDB Backup." 10 60
		        sed -i -e 's/\(_pdbtools_backup_program=\).*/\1mariabackup/' /etc/pdbtools.cnf

				_pdbtoolsBackupTableCreated=$(whiptail --title "Create Table Backup" --nocancel --fb --menu "Now it is necessary to create the table that will control the execution of the backups, so execute this scripts in your database: /opt/pdbtools/share/pdb-backup-create-table.sql" 15 60 3 \
				"Y" "YES" \
				"N" "NO" 3>&1 1>&2 2>&3)

				if [ $_pdbtoolsBackupTableCreated != "Y" ]; then
				  echo ""
				  whiptail --title "Create Table Backup" --nocancel --msgbox "Understood! Execute this scripts in your database: /opt/pdbtools/share/pdb-backup-create-table.sql, when you want to complete the configuration, just execute the pdb-tools-config again" 10 60
				  exit
				fi

				_pdbtoolsBackupPath=$(whiptail --inputbox "Now enter the path that backups should be saved. * Important: do not put the / at the end. e.g. /backup" 10 60 --title "Enter the backup path here" 3>&1 1>&2 2>&3)
				_pdbtoolsBackupPath=$(echo $_pdbtoolsBackupPath|sed -e 's/\//\\\//g')
				sed -i -e 's/\(_pdbtools_backup_path=\).*/\1'$_pdbtoolsBackupPath'/' /etc/pdbtools.cnf

				if [ $(type -p tar) ]; then
				  tar="installed"
				else
				  tar="not installed"
				fi
				if [ $(type -p zip) ]; then
				  zip="installed"
				else
				  zip="not installed"
				fi

				_pdbtoolsBackupToBeCompressed=$(whiptail --title "Compress Backup" --nocancel --fb --menu "Do you want the backup to be compressed?" 15 60 3 \
				"Y" "YES" \
				"N" "NO" 3>&1 1>&2 2>&3)

				if [ $_pdbtoolsBackupToBeCompressed = "Y" ]; then
				  sed -i -e 's/\(_pdbtools_backup_tobe_compressed=\).*/\11/' /etc/pdbtools.cnf

				_pdbtoolsBackupCompressionType=$(whiptail --title "Compress Backup" --nocancel --fb --menu "Choose the form of compression, below I will show a list with the options available on your server." 20 90 7 \
				"tar" "($tar)" \
				"zip" "($zip) " 3>&1 1>&2 2>&3) 
				 echo ""

				  if [ ! $(type -p $_pdbtoolsBackupCompressionType) ]; then
				 
				      whiptail --title "Create Table Backup" --nocancel --msgbox "Informed compression is not available on your server, but at any time you can activate it by running the pdb-tools-config - bye bye" 10 60
				      sed -i -e 's/\(_pdbtools_backup_tobe_compressed=\).*/\10/' /etc/pdbtools.cnf
				      exit

				    else
				  	  sed -i -e 's/\(_pdbtools_backup_compression_type=\).*/\1'$_pdbtoolsBackupCompressionType'/' /etc/pdbtools.cnf
				  fi

				else
				  sed -i -e 's/\(_pdbtools_backup_tobe_compressed=\).*/\10/' /etc/pdbtools.cnf
				fi

				touch pdb-backup.configured

				echo ""
				echo "Very well!"
				echo "The pdb-backup is ready to use, below you will see some info on how to perform the backups and some important information, so read carefully."
				echo ""
				echo "To change the backup settings:"
				echo "Just run the pdb-tools-config command"
				echo "OR"
				echo "Edit the /etc/pdbtools.cnf configuration file"

				echo ""
				echo "Incremental Backup:"
				echo "The Percona XtraBackup, mariabackup and MEB(MySQL Enterprise Backup) implements the incremental backup for InnoDB tables but no for other engines and the tables will always be copied in full, for more information, please consult the manual of your backup program."
				echo "The incremental backup using mysqldump is done by copying the binary logs since the last full backup and for this it is necessary to have the binary log enabled, in addition it is not 100% accurate because there are commands that can be executed without being recorded in the binary log (e.g. commands executed after SET sql_log_bin = 0;), so analyze well before using this feature."
				echo "If the backup is performed on a slave server, make sure log_slave_updates is enabled."
				echo "---------> To perform incremental backups with mysqldump, inform in the /etc/pdbtools.cnf file of the path the path to the binary logs.  <---------"

				echo ""
				echo "Examples of backup scheduling (crontab):"
				echo "0 0 * * * pdb-backup full >/dev/null 2>&1"
				echo "0 6,12,18 * * * pdb-backup incremental >/dev/null 2>&1"

				echo ""
				echo "If you have any questions, bug report or suggestions, send an email to pdbtools@performancedb.com"
				echo "Thank you for using the scripts developed by PerformanceDB. These scripts are developed and distributed free of charge, from DBA to DBA."
				echo "www.performancedb.com"
				echo "pdbtools@performancedb.com"

		    fi
        ;;

        4)
           
            if [ ! $(type -p mysqlbackup) ]; then

			    whiptail --title "MySQL Enterprise Backup" --nocancel --msgbox "The program 'MySQL Enterprise Backup' is not installed. Before proceeding, install 'MySQL Enterprise Backup' and then run pdb-backup again." 10 60

			  else

				whiptail --title "MySQL Enterprise Backup" --nocancel --msgbox "Done! I have already verified that 'MySQL Enterprise Backup' is installed, we will continue the configuration of PDB Backup. Before starting the backup, make sure that the mysql sockect is declared in the mysql configuration file (eg /etc/my.cnf) in the client session ([client]) OR when completing the PDB Backup configuration edit the file /etc/pdbtools.cnf and enter the path to the sockect." 20 60
			    sed -i -e 's/\(_pdbtools_backup_program=\).*/\1mysqlbackup/' /etc/pdbtools.cnf

				_pdbtoolsBackupTableCreated=$(whiptail --title "Create Table Backup" --nocancel --fb --menu "Now it is necessary to create the table that will control the execution of the backups, so execute this scripts in your database: /opt/pdbtools/share/pdb-backup-create-table.sql" 15 60 3 \
				"Y" "YES" \
				"N" "NO" 3>&1 1>&2 2>&3)

				if [ $_pdbtoolsBackupTableCreated != "Y" ]; then
				  echo ""
				  whiptail --title "Create Table Backup" --nocancel --msgbox "Understood! Execute this scripts in your database: /opt/pdbtools/share/pdb-backup-create-table.sql, when you want to complete the configuration, just execute the pdb-tools-config again" 10 60
				  exit
				fi

				_pdbtoolsBackupPath=$(whiptail --inputbox "Now enter the path that backups should be saved. * Important: do not put the / at the end. e.g. /backup" 10 60 --title "Enter the backup path here" 3>&1 1>&2 2>&3)
				_pdbtoolsBackupPath=$(echo $_pdbtoolsBackupPath|sed -e 's/\//\\\//g')
				sed -i -e 's/\(_pdbtools_backup_path=\).*/\1'$_pdbtoolsBackupPath'/' /etc/pdbtools.cnf

				if [ $(type -p tar) ]; then
				  tar="installed"
				else
				  tar="not installed"
				fi
				if [ $(type -p zip) ]; then
				  zip="installed"
				else
				  zip="not installed"
				fi

				_pdbtoolsBackupToBeCompressed=$(whiptail --title "Compress Backup" --nocancel --fb --menu "Do you want the backup to be compressed?" 15 60 3 \
				"Y" "YES" \
				"N" "NO" 3>&1 1>&2 2>&3)

				if [ $_pdbtoolsBackupToBeCompressed = "Y" ]; then
				  sed -i -e 's/\(_pdbtools_backup_tobe_compressed=\).*/\11/' /etc/pdbtools.cnf

				_pdbtoolsBackupCompressionType=$(whiptail --title "Compress Backup" --nocancel --fb --menu "Choose the form of compression, below I will show a list with the options available on your server." 20 90 7 \
				"tar" "($tar)" \
				"zip" "($zip) " 3>&1 1>&2 2>&3) 
				 echo ""

				  if [ ! $(type -p $_pdbtoolsBackupCompressionType) ]; then
				 
				      whiptail --title "Create Table Backup" --nocancel --msgbox "Informed compression is not available on your server, but at any time you can activate it by running the pdb-tools-config - bye bye" 10 60
				      sed -i -e 's/\(_pdbtools_backup_tobe_compressed=\).*/\10/' /etc/pdbtools.cnf
				      exit

				    else
				  	  sed -i -e 's/\(_pdbtools_backup_compression_type=\).*/\1'$_pdbtoolsBackupCompressionType'/' /etc/pdbtools.cnf
				  fi

				else
				  sed -i -e 's/\(_pdbtools_backup_tobe_compressed=\).*/\10/' /etc/pdbtools.cnf
				fi

				touch pdb-backup.configured

				echo ""
				echo "Very well!"
				echo "The pdb-backup is ready to use, below you will see some info on how to perform the backups and some important information, so read carefully."
				echo ""
				echo "To change the backup settings:"
				echo "Just run the pdb-tools-config command"
				echo "OR"
				echo "Edit the /etc/pdbtools.cnf configuration file"

				echo ""
				echo "Incremental Backup:"
				echo "The Percona XtraBackup, mariabackup and MEB(MySQL Enterprise Backup) implements the incremental backup for InnoDB tables but no for other engines and the tables will always be copied in full, for more information, please consult the manual of your backup program."
				echo "The incremental backup using mysqldump is done by copying the binary logs since the last full backup and for this it is necessary to have the binary log enabled, in addition it is not 100% accurate because there are commands that can be executed without being recorded in the binary log (e.g. commands executed after SET sql_log_bin = 0;), so analyze well before using this feature."
				echo "If the backup is performed on a slave server, make sure log_slave_updates is enabled."
				echo "---------> To perform incremental backups with mysqldump, inform in the /etc/pdbtools.cnf file of the path the path to the binary logs.  <---------"

				echo ""
				echo "Examples of backup scheduling (crontab):"
				echo "0 0 * * * pdb-backup full >/dev/null 2>&1"
				echo "0 6,12,18 * * * pdb-backup incremental >/dev/null 2>&1"

				echo ""
				echo "If you have any questions, bug report or suggestions, send an email to pdbtools@performancedb.com"
				echo "Thank you for using the scripts developed by PerformanceDB. These scripts are developed and distributed free of charge, from DBA to DBA."
				echo "www.performancedb.com"
				echo "pdbtools@performancedb.com"

			fi
        ;;

        5)
              
            exit

        ;;
    
    esac
	}
advancedMenu

done
