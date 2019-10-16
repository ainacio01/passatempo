#!/bin/bash
######################################################
#         script developed by PerformanceDB          #
#               wwww.performancedb.com               #
######################################################
#                  PDB Toold Config                  #
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
  echo "Configuration file not found, check file permissions on /etc/pdbtools.cnf or reinstall the PDB Tools. "
  echo ""
  exit
fi

. /etc/pdbtools.cnf

if [ "$_pdbtools_server_pidof" = "" ]; then
  _pidof=$(which pidof)
  _pidof_sed=$(echo $_pidof|sed -e 's/\//\\\//g')
  sed -i -e 's/\(_pdbtools_server_pidof=\).*/\1'$_pidof_sed'/' /etc/pdbtools.cnf
fi

_pdbtoolsConfigOption=null
_pdbtoolsConfigOption1=null
_pdbtoolsConfigOption2=null
_pdbtoolsConfigOption3=null

while true ; do

function advancedMenu() {
    _pdbtoolsConfigOption=$(whiptail --title "Main Menu - PDB-TOOLS" --nocancel --fb --menu "Choose an option" 15 60 5 \
        "1" "MySQL Access and Path Information.   " \
		"2" "Notifications   " \
		"3" "MySQL Replication Checker   " \
		"4" "Backup   " \
		"0" "Exit" 3>&1 1>&2 2>&3)
    case $_pdbtoolsConfigOption in
        1)

            while true ; do
            function advancedMenu1() {
            _pdbtoolsConfigOption1=$(whiptail --title "MySQL Access and Path Information." --nocancel --fb --menu "Choose an option" 20 65 10 \
			"1" "MySQL client binary path(current value is: $_pdbtools_mysql_bin)   " \
			"2" "MySQL deamon binary path(current value is: $_pdbtools_mysql_daemon)   " \
			"3" "MySQL user(current value is: $_pdbtools_database_user)   " \
	        "4" "MySQL password(current value is: $_pdbtools_database_password)   " \
	   	    "5" "MySQL port(current value is: $_pdbtools_database_port)   " \
			"6" "MySQL socket path(current value is: $_pdbtools_database_socket)   " \
			"7" "Return to Main Menu" \
			"0" "Exit" 3>&1 1>&2 2>&3)

	
				case $_pdbtoolsConfigOption1 in
				    1)
		            
			            _pdbtools_mysql_cli_map=$(which mysql)

			            if [ "$_pdbtools_mysql_cli_map" != "" ]; then
					        whiptail --title "MySQL client binary path" --msgbox "[Notice] We verify that the MySQL Client is mapped to your operating system correctly, so just enter the value 'mysql'. (Current value is: $_pdbtools_mysql_bin)" 10 60
					      else
					        whiptail --title "MySQL client binary path" --msgbox "[Notice] We verified that the MySQL Client is not mapped on your operating system properly, so please inform the full MySQL Client path. (Current value is: $_pdbtools_mysql_bin)" 10 60
					    fi
     
					      _pdbtools_mysql_bin_new=$(whiptail --inputbox "To change the MySQL Client path enter the new value or keep empty so you do not change." 10 60 --title "MySQL client binary path" 3>&1 1>&2 2>&3)
					      
					    if [ "$_pdbtools_mysql_bin_new" = "" ]; then
					        whiptail --title "MySQL client binary path" --msgbox "[Notice] The path to the MySQL Client did not change." 10 60
					      else
					        _pdbtools_mysql_bin_new_sed=$(echo $_pdbtools_mysql_bin_new|sed -e 's/\//\\\//g')
					        sed -i -e 's/\(_pdbtools_mysql_bin=\).*/\1'$_pdbtools_mysql_bin_new_sed'/' /etc/pdbtools.cnf
					        whiptail --title "MySQL client binary path" --msgbox "[OK] The path to the MySQL Client has changed successfully." 10 60
					         _pdbtools_mysql_bin=$_pdbtools_mysql_bin_new
					    fi
					;;
			        
			        2)
			            
  			            _pdbtools_mysql_daemon_map=$(which mysqld)
					     
					    if [ "$_pdbtools_mysql_daemon_map" != "" ]; then
					        whiptail --title "MySQL deamon binary path" --msgbox "[Notice] We verify that the MySQL Deamon is mapped to your operating system correctly, so just enter the value 'mysqld'. (Current value is: $_pdbtools_mysql_daemon)" 10 60
					      else
					        whiptail --title "MySQL deamon binary path" --msgbox "[Notice] We verified that the MySQL Deamon is not mapped on your operating system properly, so please inform the full MySQL Deamon path. (Current value is: $_pdbtools_mysql_daemon)" 10 60
					    fi

					      _pdbtools_mysql_daemon_new=$(whiptail --inputbox "To change the MySQL Deamon path enter the new value or keep empty so you do not change." 10 60 --title "New MySQL Deamon Path: " 3>&1 1>&2 2>&3)
					    
					    if [ "$_pdbtools_mysql_daemon_new" = "" ]; then
					        whiptail --title "MySQL deamon binary path" --msgbox "[Notice] The path to the MySQL Deamon did not change." 10 60  
					      else
					        _pdbtools_mysql_daemon_new_sed=$(echo $_pdbtools_mysql_daemon_new|sed -e 's/\//\\\//g')
					        sed -i -e 's/\(_pdbtools_mysql_daemon=\).*/\1'$_pdbtools_mysql_daemon_new_sed'/' /etc/pdbtools.cnf
					        whiptail --title "MySQL deamon binary path" --msgbox "[OK] The path to the MySQL Deamon has changed successfully." 10 60
					        _pdbtools_mysql_daemon=$_pdbtools_mysql_daemon_new
					    fi
	 
			        ;;

			        3)
			            
					    _pdbtools_database_user_new=$(whiptail --inputbox "To change the MySQL user enter the new value or keep empty so you do not change." 10 60 --title "MySQL user" 3>&1 1>&2 2>&3)
					      
					    if [ "$_pdbtools_database_user_new" = "" ]; then
					        whiptail --title "MySQL user" --msgbox "[Notice] The MySQL User did not change." 10 60
					      else
					        sed -i -e 's/\(_pdbtools_database_user=\).*/\1'$_pdbtools_database_user_new'/' /etc/pdbtools.cnf
					        whiptail --title "MySQL user" --msgbox "[OK] The MySQL User has changed successfully." 10 60
					        _pdbtools_database_user=$_pdbtools_database_user_new
					    fi
			        ;;

			        4)

						_pdbtools_database_password_new=$(whiptail --inputbox "To change the MySQL password enter the new value or keep empty so you do not change." 10 60 --title "MySQL password" 3>&1 1>&2 2>&3)
					    
					    if [ "$_pdbtools_database_password_new" = "" ]; then
					        whiptail --title "MySQL password" --msgbox "[Notice] The MySQL password did not change." 10 60
					      else
					        sed -i -e 's/\(_pdbtools_database_password=\).*/\1'$_pdbtools_database_password_new'/' /etc/pdbtools.cnf
					        whiptail --title "MySQL password" --msgbox "[OK] The MySQL password has changed successfully." 10 60
					        _pdbtools_database_password=$_pdbtools_database_password_new
					    fi
			        ;;

			        5)

					    _pdbtools_database_port_new=$(whiptail --inputbox "To change the MySQL port enter the new value or keep empty so you do not change." 10 60 --title "MySQL port" 3>&1 1>&2 2>&3)
					    
					    if [ "$_pdbtools_database_port_new" = "" ]; then
					        whiptail --title "MySQL port" --msgbox "[Notice] The MySQL port did not change." 10 60
					      else
					        sed -i -e 's/\(_pdbtools_database_port=\).*/\1'$_pdbtools_database_port_new'/' /etc/pdbtools.cnf
					        whiptail --title "MySQL port" --msgbox "[OK] The MySQL port has changed successfully." 10 60
					        _pdbtools_database_port=$_pdbtools_database_port_new
					    fi
			        ;;

			        6)

					    _pdbtools_database_socket_new=$(whiptail --inputbox "To change the MySQL socket enter the new value or keep empty so you do not change." 10 60 --title "MySQL socket path" 3>&1 1>&2 2>&3)
					      
					    if [ "$_pdbtools_database_socket_new" = "" ]; then
					        whiptail --title "MySQL socket path" --msgbox "[Notice] The MySQL socket did not change." 10 60
					      else
					        _pdbtools_database_socket_new_sed=$(echo $_pdbtools_database_socket_new|sed -e 's/\//\\\//g')
					        sed -i -e 's/\(_pdbtools_database_socket=\).*/\1'$_pdbtools_database_socket_new_sed'/' /etc/pdbtools.cnf
					         whiptail --title "MySQL socket path" --msgbox "[OK] The MySQL socket has changed successfully." 10 60
					        _pdbtools_database_socket=$_pdbtools_database_socket_new
					    fi
			        ;;

			        7)
			            break
			        ;;

			        0)
			            exit
			        ;;
			    
			    esac
				}
			advancedMenu1
			done

		;;
        
        2)

			while true ; do
            function advancedMenu2() {
            _pdbtoolsConfigOption2=$(whiptail --title "Notifications" --nocancel --fb --menu "Choose an option" 20 90 10 \
			"1" "Enable/Disable notifications(current value is: $_pdbtools_send_notification)   " \
			"2" "Program to sending notifications(current value is: $_pdbtools_notification_program)   " \
			"3" "Email to receive notifications: $_pdbtools_email_to_recive_notifications)   " \
	        "4" "Sparkpost API KEY: $_pdbtools_sparkpost_api_key)   " \
	   	    "5" "Sparkpost email from(current value is: $_pdbtools_sparkpost_email_sender)   " \
			"6" "Script to send notifications(current value is: $_pdbtools_notification_script)   " \
			"7" "Return to Main Menu" \
			"0" "Exit" 3>&1 1>&2 2>&3)

	
				case $_pdbtoolsConfigOption2 in
				    1)

					      _pdbtools_send_notification_new=$(whiptail --title "Enable/Disable notifications" --nocancel --fb --menu "To change the configuration to enable or disable notifications on PDB Tools choose the new value." 15 60 4 \
							"1" "ENABLE" \
							"0" "DISABLE" 3>&1 1>&2 2>&3)
    	   
					        sed -i -e 's/\(_pdbtools_send_notification=\).*/\1'$_pdbtools_send_notification'/' /etc/pdbtools.cnf
					        whiptail --title "Enable/Disable notifications" --msgbox "[OK] The PDB Tools enable/disable notifications has changed successfully." 10 60
					        _pdbtools_send_notification=$_pdbtools_send_notification_new
					;;
			        
			        2)

					    _pdbtools_notification_program_new=$(whiptail --title "Program to sending notifications" --nocancel --fb --menu "To change the program to send notifications on PDB Tools choose the new option." 15 65 5 \
						"mail" "Mail service from you operational system.  " \
						"sparkpost" "SparkPost Plataform API" \
						"script" "Script to send notifications" 3>&1 1>&2 2>&3)
					    
						    sed -i -e 's/\(_pdbtools_notification_program=\).*/\1'$_pdbtools_notification_program_new'/' /etc/pdbtools.cnf
						    whiptail --title "Program to sending notifications" --msgbox "[OK] The PDB Tools program to send notifications has changed successfully." 10 60
						    _pdbtools_notification_program=$_pdbtools_notification_program_new
			        ;;

			        3)

					    _pdbtools_email_to_recive_notifications_new=$(whiptail --inputbox "To change the e-mail to recive notifications from PDB Tools enter the new value or keep empty so you do not change." 10 60 --title "Email to receive notifications" 3>&1 1>&2 2>&3)
					      
					    if [ "$_pdbtools_email_to_recive_notifications_new" = "" ]; then
					        whiptail --title "Email to receive notifications" --msgbox "[Notice] The e-mail to recive notifications from PDB Tools did not change." 10 60
					      else
					        sed -i -e 's/\(_pdbtools_email_to_recive_notifications=\).*/\1'$_pdbtools_email_to_recive_notifications_new'/' /etc/pdbtools.cnf
					        whiptail --title "Email to receive notifications" --msgbox "[OK] The e-mail to recive notifications from PDB Tools has changed successfully." 10 60
					        _pdbtools_email_to_recive_notifications=$_pdbtools_email_to_recive_notifications_new
					    fi

			        ;;

			        4)

					    _pdbtools_sparkpost_api_key_new=$(whiptail --inputbox "To change the Sparkpost API KEY on PDB Tools enter the new value or keep empty so you do not change." 10 60 --title "Sparkpost API KEY" 3>&1 1>&2 2>&3)
					    
					    if [ "$_pdbtools_sparkpost_api_key_new" = "" ]; then
					        whiptail --title "Sparkpost API KEY" --msgbox "[Notice] The Sparkpost API KEY on PDB Tools did not change." 10 60
					      else
					        sed -i -e 's/\(_pdbtools_sparkpost_api_key=\).*/\1'$_pdbtools_sparkpost_api_key_new'/' /etc/pdbtools.cnf
					        whiptail --title "Sparkpost API KEY" --msgbox "[OK] The Sparkpost API KEY on PDB Tools has changed successfully." 10 60
					        _pdbtools_sparkpost_api_key=$_pdbtools_sparkpost_api_key_new
					    fi

			        ;;

			        5)

					    _pdbtools_sparkpost_email_sender_new=$(whiptail --inputbox "To change the Sparkpost 'email from' on PDB Tools enter the new value or keep empty so you do not change." 10 60 --title "Email domain must be set to Sparkpost." 3>&1 1>&2 2>&3)
					    
					    if [ "$_pdbtools_sparkpost_email_sender_new" = "" ]; then
					        whiptail --title "Email domain must be set to Sparkpost." --msgbox "[Notice] The Sparkpost 'email from' on PDB Tools did not change." 10 60
					      else
					        sed -i -e 's/\(_pdbtools_sparkpost_email_sender=\).*/\1'$_pdbtools_sparkpost_email_sender_new'/' /etc/pdbtools.cnf
					        whiptail --title "Email domain must be set to Sparkpost." --msgbox "[OK] The Sparkpost 'email from' on PDB Tools has changed successfully." 10 60
					        _pdbtools_sparkpost_email_sender=$_pdbtools_sparkpost_email_sender_new
					    fi

			        ;;

			        6)

					    _pdbtools_notification_script_new=$(whiptail --inputbox "Enter the complete command, as it should be executed by the command line. E.g. php /home/user/sendmail.php" 10 60 --title "Script to send notifications" 3>&1 1>&2 2>&3)
					     	
						if [ "$_pdbtools_notification_script_new" = "" ]; then
							whiptail --title "Script to send notifications" --msgbox "[Notice] The script(developed by you) used to send notification from PDB Tools did not change." 10 60
      						else
        					 _pdbtools_rpl_notification_script_new_sed=$(echo $_pdbtools_notification_script_new|sed -e 's/\//\\\//g')
        					 sed -i -e 's/\(_pdbtools_notification_script="\).*/\1'"$_pdbtools_rpl_notification_script_new_sed"'"/' /etc/pdbtools.cnf
						    whiptail --title "Script to send notifications" --msgbox "The script(developed by you) used to send notification from PDB Tools has changed successfully." 10 60
						    _pdbtools_notification_script=$_pdbtools_notification_script_new
      					fi

				        ;;

			        7)
			            break
			        ;;

			        0)
			            exit
			        ;;
			    
			    esac
				}
			advancedMenu2
			done

        ;;

        3)
            

			while true ; do
            function advancedMenu3() {
            _pdbtoolsConfigOption3=$(whiptail --title "MySQL Replication Checker" --nocancel --fb --menu "Choose an option" 20 90 10 \
			"1" "Your replication is multi-source(current value is: $_pdbtools_rpl_multi_source)   " \
			"2" "Replication Channel(s) Name(s)(current value is: $_pdbtools_rpl_channels)   " \
			"3" "Return to Main Menu" \
			"4" "Exit" 3>&1 1>&2 2>&3)

	
				case $_pdbtoolsConfigOption3 in
				    1)

   				        _pdbtools_rpl_multi_source_new=$(whiptail --title "Your replication is multi-source?" --nocancel --fb --menu "To change the Multi-Source Replication information on PDB Tools MySQL Replication Checker choose the new value." 15 60 4 \
						"1" "YES" \
						"0" "NO" 3>&1 1>&2 2>&3)
    	   
					        sed -i -e 's/\(_pdbtools_rpl_multi_source=\).*/\1'$_pdbtools_rpl_multi_source_new'/' /etc/pdbtools.cnf
					        whiptail --title "Enable/Disable notifications" --msgbox "[OK] The PDB Tools MySQL Replication Checker Multi-Source Replication information has changed successfully." 10 60
					        _pdbtools_rpl_multi_source=$_pdbtools_rpl_multi_source_new
					;;
			        
			        2)

					    _pdbtools_rpl_channels_new=$(whiptail --inputbox "To change the Channel(s) Name(s) on PDB Tools MySQL Replication Checker enter the new value or keep empty so you do not change. The names must be separated by space. (e.g. master-1 master2)" 10 60 --title "Replication Channel(s) Name(s)" 3>&1 1>&2 2>&3)
					    
					    if [ "$_pdbtools_rpl_channels_new" = "" ]; then
					        whiptail --title "Replication Channel(s) Name(s)" --msgbox "[Notice] The PDB Tools MySQL Replication Checker Channel(s) Name(s) did not change." 10 60
					      else
					      	_pdbtools_rpl_channels_new_sed=$(echo $_pdbtools_rpl_channels_new|sed -e 's/\//\\\//g')
					        sed -i -e 's/\(_pdbtools_rpl_channels="\).*/\1'"$_pdbtools_rpl_channels_new_sed"'"/' /etc/pdbtools.cnf
					        whiptail --title "Replication Channel(s) Name(s)" --msgbox "[OK] The PDB Tools MySQL Replication Checker Channel(s) Name(s) has changed successfully." 10 60
					        _pdbtools_rpl_channels=$_pdbtools_rpl_channels_new
					    fi

					;;

			        3)
			            break
			        ;;

			        4)
			            exit
			        ;;
			    
			    esac
				}
			advancedMenu3
			done

        ;;

        4)
            pdb-backup-config
  			exit
        ;;

        0)
            break
        ;;
    
    esac
}
advancedMenu

done

echo ""
echo "If you have any questions, bug report or suggestions, send an email to pdbtools@performancedb.com"
echo "PDB Tools is a set of scripts developed by PerformanceDB (www.performancedb.com). All PDB Tools scripts are free and have been developed from DBA to DBA."
echo "www.performancedb.com"
echo "pdbtools@performancedb.com"
