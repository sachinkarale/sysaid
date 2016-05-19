# !/bin/sh

# If this script fails, please verify:
# 1) connection.
# 2) user. (root)
# 3) unzip package.
# 4) activation.xml file

# Variables in this script are:
# U = the current user
# Location = the current locaion (not install.sh location)
# License = the location that was entered by user for activation.xml
# continue = if user entered y / n 
# Count = count the number of times user set the location of activation.xml 
# KEY = check for activation.xml.
# MainPort = the port that will be used to access SysAid.
# CheckMainPort = check if the port entered by user is available.
# ShutDownPort = the port to shutdown tomcat.
# CheckShutDownPort = check if shut down port is available.
# Validated = run the condition to look up ports until the port was validate that it is free.
# AMD = check for the machine OS 32 / 64 bit.
# MainUser = set the name of the main user to access SysAid by default it is sysaid unless the user use MySql the name changes.
# MainPass = set the password for the main user to access SysAid. by default it is changeit unless the user use MySql the password changes.
# Route = define the main network device in order to aquire the IP address for the final link that is provided to user.
# NAME = hostname
# URL = machine IP address (only for eth0) 

# Additional variables are only activated if the user choose to install with MySql:
# SYSAID_HOME, JAVA_BIN, cp, DBHOST, DBNAME, DBUSER, DBPASSWORD, UNICODE, CONNSTATUS, answer, CHECKOUT, ACCOUNT, SERIAL, USER, PASSWORD.

# Set all Variables:

U=
Location=
License=
continue=
Count=
KEY=
MainPort=
CheckMainPort=
ShutDownPort=
CheckShutDownPort=
Validated=
AMD=
MainUser=
MainPass=
Route=
NAME=
URL=

# Check if this is the root user.

U=`whoami` 
Location=`pwd`
date | cat >> "$Location"/Install.log
echo "User is" "$U" | cat >> Install.log
echo "the target location to install tomcat is:" "$Location" | cat >> "$Location"/Install.log

clear
echo "Welcome to SysAid Linux Server installation process."
echo " "
echo "Please verify the following:" 
echo " "
echo "1) That you know the location of the license key (activation.xml)"
echo '2) That packages Unzip and Wget are installed on your machine'
echo "3) That you have an empty new MySql or MsSql database to use with SysAid"
echo " "
echo 'If you need to install Unzip and/or Wget, run one of the following commands:'
echo "sudo apt-get install <package name>" 
echo "yum install <package name>"
echo " "
continue=
    echo " "
    echo -n "Do you wish to continue (type y/n)?"
    read continue
    if [ "$continue" != "y" ];
       then
       echo " " 
       echo "The installation was aborted by user!"
       echo " "
       echo " "
       echo " "
       exit

   fi
clear

if  [ "$U" != "root" ] ; then
   echo "You do not have root privileges. Installation was aborted."
   echo " "
   echo "Please switch to root user and run install.sh again."
   echo "(If you are using Linux Ubuntu, then please switch to the root user by entering the command: sudo su)"
   echo " "
   exit

fi

clear

# Check for activation.xml file exist.
if [ ! -f activation.xml ] ;
   then

   echo "Please enter the path to the license key. Do not include the file name."
   echo "This attempt is attempt 1 out of 3."
   License=

   read License
   echo " " | cat >> "$Location"/Install.log
   date | cat >> "$Location"/Install.log
   echo "activation file location entered by user is:" "$License" | cat >> "$Location"/Install.log
   cd /

   cd "$License"

   KEY=`ls | grep activation.xml`
   Count=1
   while [ "$KEY" != "activation.xml" ] && [ $Count -lt 3 ] ;
      do
      clear

      echo "The license key was not found in:"
      echo $License
      echo " "
      echo "Please enter the correct path to the license key. Do not include the file name."
      let Count2=Count+1
      echo This attempt is attempt "$Count2" out of 3.
      License=

      read License

      cd /
      cd "$License"

      KEY=`ls | grep activation.xml`
      let Count=Count+1

      echo "activation file location entered by user is:" "$License" | cat >> "$Location"/Install.log

   done

clear

# Stop install.sh if activation.xml was not found.

if [ "$KEY" != "activation.xml" ] ;
   then
   echo "The license file (activation.xml) was not found."
   echo " "
   echo "Installation was aborted. Please contact us at: support@sysaid.com"
   echo " " | cat >> "$Location"/Install.log
   date | cat >> "$Location"/Install.log
   echo "activation.xml was not found" | cat >> "$Location"/Install.log
   echo " "
   exit

fi

   else
   License=$Location
   echo "License file was found at $Location" | cat >> "$Location"/Install.log
fi

cd /
cd "$Location"

# Download and un tar Tomcat.

clear

echo "This step will download the Apache Tomcat 7 Server and install it in the following location:"
echo " "
echo "$Location"
echo " "
echo " "
continue=
    echo -n "Do you wish to continue (y/n)?"
    read continue
    if [ "$continue" != "y" ];
    then
    echo " "
    echo "The installation was aborted by user."
    echo " "
    exit

    clear
    echo "Please wait while Tomcat is downloading and unpacking..."
    echo " " 
    fi

wget http://cdn1.sysaid.com/apache-tomcat-7.tar.gz
echo " " | cat >> "$Location"/Install.log
date | cat >> "$Location"/Install.log
tar -zxvf apache-tomcat-7.tar.gz | cat >> "$Location"/Install.log
mv apache-tomcat-7.0.32 apache-tomcat-7

clear

# Check for Main port
clear

MainPort=8080;
CheckMainPort=`netstat -lpn | grep LISTEN | grep -v LISTENING | grep :"$MainPort " | wc -l`

if [ $CheckMainPort -ge 1 ];
then
	echo "The default port (8080) is already in use.";
	continue="y";
else
	echo "The default port that will be used to access SysAid is 8080.";
	echo -n "Do you wish to use a different port (y/n)?"
	continue=
	read continue	
fi

if [ "$continue" = "y" ] ;
then
	Validated=0;
	while [ $Validated -eq 0 ];
	do
		echo -n "Please enter a different port number:"
		MainPort=
		read MainPort
		if [ $MainPort -ne 0 -o $MainPort -eq 0 2>/dev/null ]
		then
			if [ $MainPort -lt 1 -o $MainPort -gt 65535 ];
			then
                                echo " "
				echo "Port number must be an integer between 1 and 65535."
			else
				CheckMainPort=`netstat -lpn | grep LISTEN | grep -v LISTENING | grep :"$MainPort " | wc -l`
				if [ $CheckMainPort -ge 1 ];
				then
					echo "Port $MainPort is already in use."
				else
					Validated=1;
				fi
			fi
		else
                        echo " "
			echo "Port number must be an integer between 1 and 65535."
		fi
	done

else
	MainPort="8080"
fi



echo " " | cat >> "$Location"/Install.log
date | cat >> "$Location"/Install.log
echo "The Main Port that was selected by user is:" "$MainPort" | cat >> "$Location"/Install.log

# Check for Shutdown Port (8005) and change if needed.

ShutDownPort="8005"

CheckShutDownPort=`netstat -lpn | grep LISTEN | grep -v LISTENING | grep :"$ShutDownPort " | wc -l`

while [ "$CheckShutDownPort" != "0" ] && [ $ShutDownPort -lt 8050 ] ;
 do
      let  ShutDownPort=$ShutDownPort+1
      CheckShutDownPort=`netstat -lpn | grep LISTEN | grep -v LISTENING | grep :"$MainPort " | wc -l`
done

# Change ports on Apache Tomcat, and disable port 8009

cd /
cd "$Location"/apache-tomcat-7/conf
sed -e 's/="8080"/="'"$MainPort"'"/' -e 's/="8005"/="'"$ShutDownPort"'"/' -e 's/<Connector port="8009" protocol="AJP\/1.3" redirectPort="8443" \/>/<!-- <Connector port="8009" protocol="AJP\/1.3" redirectPort="8443" \/> -->/' server.xml > server2.xml

mv server.xml server.old
mv server2.xml server.xml
chmod 700 server.xml

cd /
cd "$Location"

# Download and deploy Java jre 1.7 by the machine type (32bit / 64bit).

clear
echo "This step will download Java Runtime Environment (JRE) and install it at the following location:"
continue=
    echo " "
    echo "$Location"
    echo " "
    echo -n "Do you want to continue (y/n)?"
    read continue
    if [ "$continue" != "y" ];
    then
    echo "The installation was aborted by user."
    exit
    clear 
    echo "Please wait while Java JRE is downloading and unpacking..."  
    echo " " 
    fi

echo " " | cat >> "$Location"/Install.log
date | cat >> "$Location"/Install.log
AMD=`uname -m`
echo " " | cat >> Install.log
echo "This Linux OS is" "$AMD" | cat >> "$Location"/Install.log
echo " "

    if [ "$AMD" = "i686" ]; then

    wget http://cdn1.sysaid.com/java.tar.gz
    else
 
    wget http://cdn1.sysaid.com/java64.tar.gz
    mv java64.tar.gz java.tar.gz

    fi

echo " " | cat >> Install.log
date | cat >> "$Location"/Install.log
tar -zxvf java.tar.gz | cat >> Install.log
echo " " | cat >> Install.log



# Edit startup.sh and shutdown.sh scripts to point to the JRE location.

cd "$Location"/apache-tomcat-7/bin

mv startup.sh startup.bak
echo '#!/bin/sh' > startup.sh
echo 'export JAVA_HOME="'"$Location"'/jre1.7.0_09"' >> startup.sh
echo 'export JRE_HOME="'"$Location"'/jre1.7.0_09"' >> startup.sh
cat startup.bak | grep -v '#!/bin/sh' >> startup.sh
chmod 700 startup.sh

mv shutdown.sh shutdown.bak
echo '#!/bin/sh' > shutdown.sh
echo 'export JAVA_HOME="'"$Location"'/jre1.7.0_09"' >> shutdown.sh
echo 'export JRE_HOME="'"$Location"'/jre1.7.0_09"' >> shutdown.sh
cat shutdown.bak | grep -v '#!/bin/sh' >> shutdown.sh
chmod 700 shutdown.sh

cd "$Location"

clear


# Download and deploy SysAid Server.

echo "Please wait while SysAid is downloading and unpacking..."


wget http://cdn3.sysaid.com/sysaid-server-linux.tar.gz

cd /
cd "$Location"
echo " " | cat >> "$Location"/Install.log
date | cat >> "$Location"/Install.log
tar -zxvf sysaid-server-linux.tar.gz | cat >> Install.log
cd "$Location"/sysaid-server-linux
mkdir ROOT
cd ROOT
cp -r "$Location"/sysaid-server-linux/sysaid.war "$Location"/sysaid-server-linux/ROOT/sysaid.zip
cd "$Location"/sysaid-server-linux/ROOT
date | cat >> "$Location"/Install.log
unzip sysaid.zip | cat >> "$Location"/Install.log


mv "$Location"/apache-tomcat-7/webapps/ROOT "$Location"/apache-tomcat-7/webapps/OLD_ROOT
cp -r "$Location"/sysaid-server-linux/ROOT "$Location"/apache-tomcat-7/webapps/ROOT
cp -r "$License"/activation.xml "$Location"/apache-tomcat-7/webapps/ROOT/WEB-INF/conf/activation.xml | cat >> "$Location"/Install.log


clear

# Remove installation files.

cd "$Location"
rm -r apache-tomcat-7.tar.gz
rm -r java.tar.gz
rm -r sysaid-server-linux.tar.gz

echo " " | cat >> "$Location"/Install.log
date | cat >> "$Location"/Install.log
ps aux | grep tomcat | head -1 | cat >> "$Location"/Install.log

clear

#choose database type

while [ "$type" != 1 ] && [ "$type" != "2" ] ;
do

echo "Please choose the type of database to use with SysAid"
echo "For MsSql please enter 1"
echo "For MySql please enter 2"

read type


if [ "$type" = "1" ]
then
echo "This step will configure the connection to MsSql database." 

		SYSAID_HOME="$Location"/apache-tomcat-7/webapps/ROOT
		if [ ! -s "$SYSAID_HOME/WEB-INF/conf/sysaid.ver" ]; then
			echo "Root SysAid directory not found at $SYSAID_HOME. Please deploy the SysAid web application into the Tomcat server before running this script.";
			exit 1;
		fi
		JAVA_BIN="$Location"/jre1.7.0_09/bin/java
		if [ "$?" -ne 0 ]; then
			# Complain and quit
			echo "Could not find java executable. Please make sure the java command is in your path."
			exit 1;
		fi

	CP=
	for i in ${SYSAID_HOME}/WEB-INF/lib/*.jar ; do
		CP=$i:${CP}
	done
	export CP

	DBHOST="localhost";
	DBNAME="sysaid";
	DBUSER="sa";
	DBPASSWORD="password";
	UNICODE="Y";

	CONNSTATUS="1";


	while ["" eq ""]; do
                echo " "
		echo "Please enter the host name or IP address of the MsSql server:";
		read answer
		if [ "$answer" != "" ]; then
			DBHOST="$answer";
		fi
                echo " "
		echo "Please enter the database name that will contain the SysAid data (you may need to create an empty database):";
		read answer
		if [ "$answer" != "" ]; then
			DBNAME="$answer";
		fi
                echo " "
		echo "Please enter the database login user name [$DBUSER]:";
		read answer
		if [ "$answer" != "" ]; then
			DBUSER="$answer";
		fi
                echo " "
		echo "Please enter the database login password [$DBPASSWORD]:";
		read answer
		if [ "$answer" != "" ]; then
			DBPASSWORD="$answer";
		fi

                clear
		echo "Please review the following information:";
                echo " "
		echo "Host name: $DBHOST";
		echo "Database name: $DBNAME";
		echo "Database user name: $DBUSER";
		echo "Database password: $DBPASSWORD";
                echo " "
		echo "Do you want to continue (y/n)?";
		read cont
		if [ "$cont" != "Y" ] && [ "$cont" != "y" ]; then
			continue
		fi
                echo " "
		echo "Would you like to check your connection to the database server (y/n)?"
		read ischeck
		if [ "$ischeck" != "Y" ] && [ "$ischeck" != "y" ]; then
			$JAVA_BIN -cp ${CP} com.ilient.server.CheckConf "$SYSAID_HOME" "$SYSAID_HOME/WEB-INF/logs/initdb.log" "net.sourceforge.jtds.jdbc.Driver" "jdbc:jtds:sqlserver://$DBHOST/$DBNAME" "$DBUSER" "$DBPASSWORD" "mssql" $UNICODE
			break;  
		fi
                echo " "
		echo "Checking connection...";
		$JAVA_BIN -cp ${CP} com.ilient.server.CheckConf "$SYSAID_HOME" "$SYSAID_HOME/WEB-INF/logs/initdb.log" "net.sourceforge.jtds.jdbc.Driver" "jdbc:jtds:sqlserver://$DBHOST/$DBNAME" "$DBUSER" "$DBPASSWORD" "mssql" $UNICODE
		CONNSTATUS="$?";
		if [ "$CONNSTATUS" -ne 0 ]; then
			# Complain and quit
                        echo " "
			echo "Connection verified."
                        echo " "
                        echo " "
			break;
		fi
		CHECKOUT=`cat $SYSAID_HOME/WEB-INF/logs/initdb.log`
		echo "Error while checking connection: $CHECKOUT"
	done

	echo "Validating license..."; 
	$JAVA_BIN -cp ${CP} com.ilient.server.CheckLicense "$SYSAID_HOME" "$SYSAID_HOME/WEB-INF/logs/checklic.log"
	if [ "$?" -eq 0 ]; then
		# Complain and quit
		CHECKOUT=`cat $SYSAID_HOME/WEB-INF/logs/checklic.log`
		echo "FATAL: $CHECKOUT"
		exit 1;
	fi
	CHECKOUT=`cat $SYSAID_HOME/WEB-INF/logs/checklic.log | sed -e 's/accountID=//' | sed -e 's/serial=//'`
	#echo "$CHECKOUT";
	set -- $CHECKOUT;

	ACCOUNT="$1";
	SERIAL="$2";
        echo " "
	echo "License verified. Account ID is $ACCOUNT. Serial number is $SERIAL."
        echo " "
        echo " "
	if [ $CONNSTATUS -ne 0 ]; then
 
		USER="sysaid";
		echo "Please enter a main user name. This will be used for your first login into SysAid [$USER]:"
		read answer
		if [ "$answer" != "" ]; then
			USER="$answer";
		fi

		PASSWORD="changeit";
		echo "Please enter a password for user $USER:"
		read answer
		if [ "$answer" != "" ]; then
			PASSWORD="$answer";
		fi
                clear
		echo "Initializing database..."
		$JAVA_BIN -cp ${CP} com.ilient.server.InitAccount "$SYSAID_HOME" "$ACCOUNT" "$SERIAL" "$USER" "$PASSWORD" 2
		if [ "$?" -eq 0 ]; then
			# Complain and quit    
			echo "FATAL error while initializing database. For more information, please consult the SysAid log at $SYSAID_HOME/WEB-INF/logs/sysaid.log."
			exit 1;
		fi

	fi
fi


#set MySQL database.

if [ "$type" = "2" ]
then

echo "This step will configure the connection to MySql database." 

		SYSAID_HOME="$Location"/apache-tomcat-7/webapps/ROOT
		if [ ! -s "$SYSAID_HOME/WEB-INF/conf/sysaid.ver" ]; then
			echo "Root SysAid directory not found at $SYSAID_HOME. Please deploy the SysAid web application into the Tomcat server before running this script.";
			exit 1;
		fi
		JAVA_BIN="$Location"/jre1.7.0_09/bin/java
		if [ "$?" -ne 0 ]; then
			# Complain and quit
			echo "Could not find java executable. Please make sure the java command is in your path."
			exit 1;
		fi

	CP=
	for i in ${SYSAID_HOME}/WEB-INF/lib/*.jar ; do
		CP=$i:${CP}
	done
	export CP

	DBHOST="localhost";
	DBNAME="sysaid";
	DBUSER="root";
	DBPASSWORD="password";
	UNICODE="Y";

	CONNSTATUS="1";


	while ["" eq ""]; do
                echo " "
		echo "Please enter the host name or IP address of the MySQL server:";
		read answer
		if [ "$answer" != "" ]; then
			DBHOST="$answer";
		fi
                echo " "
		echo "Please enter the database name that will contain the SysAid data (you may need to create an empty database):";
		read answer
		if [ "$answer" != "" ]; then
			DBNAME="$answer";
		fi
                echo " "
		echo "Please enter the database login user name [$DBUSER]:";
		read answer
		if [ "$answer" != "" ]; then
			DBUSER="$answer";
		fi
                echo " "
		echo "Please enter the database login password [$DBPASSWORD]:";
		read answer
		if [ "$answer" != "" ]; then
			DBPASSWORD="$answer";
		fi

                clear
		echo "Please review the following information:";
                echo " "
		echo "Host name: $DBHOST";
		echo "Database name: $DBNAME";
		echo "Database user name: $DBUSER";
		echo "Database password: $DBPASSWORD";
                echo " "
		echo "Do you want to continue (y/n)?";
		read cont
		if [ "$cont" != "Y" ] && [ "$cont" != "y" ]; then
			continue
		fi
                echo " "
		echo "Would you like to check your connection to the database server (y/n)?"
		read ischeck
		if [ "$ischeck" != "Y" ] && [ "$ischeck" != "y" ]; then
			$JAVA_BIN -cp ${CP} com.ilient.server.CheckConf "$SYSAID_HOME" "$SYSAID_HOME/WEB-INF/logs/initdb.log" "org.gjt.mm.mysql.Driver" "jdbc:mysql://$DBHOST/$DBNAME" "$DBUSER" "$DBPASSWORD" "mysql" $UNICODE
			break;  
		fi
                echo " "
		echo "Checking connection...";
		$JAVA_BIN -cp ${CP} com.ilient.server.CheckConf "$SYSAID_HOME" "$SYSAID_HOME/WEB-INF/logs/initdb.log" "org.gjt.mm.mysql.Driver" "jdbc:mysql://$DBHOST/$DBNAME" "$DBUSER" "$DBPASSWORD" "mysql" $UNICODE
		CONNSTATUS="$?";
		if [ "$CONNSTATUS" -ne 0 ]; then
			# Complain and quit
                        echo " "
			echo "Connection verified."
                        echo " "
                        echo " "
			break;
		fi
		CHECKOUT=`cat $SYSAID_HOME/WEB-INF/logs/initdb.log`
		echo "Error while checking connection: $CHECKOUT"
	done

	echo "Validating license..."; 
	$JAVA_BIN -cp ${CP} com.ilient.server.CheckLicense "$SYSAID_HOME" "$SYSAID_HOME/WEB-INF/logs/checklic.log"
	if [ "$?" -eq 0 ]; then
		# Complain and quit
		CHECKOUT=`cat $SYSAID_HOME/WEB-INF/logs/checklic.log`
		echo "FATAL: $CHECKOUT"
		exit 1;
	fi
	CHECKOUT=`cat $SYSAID_HOME/WEB-INF/logs/checklic.log | sed -e 's/accountID=//' | sed -e 's/serial=//'`
	#echo "$CHECKOUT";
	set -- $CHECKOUT;

	ACCOUNT="$1";
	SERIAL="$2";
        echo " "
	echo "License verified. Account ID is $ACCOUNT. Serial number is $SERIAL."
        echo " "
        echo " "
	if [ $CONNSTATUS -ne 0 ]; then
 
		USER="sysaid";
		echo "Please enter a main user name. This will be used for your first login into SysAid [$USER]:"
		read answer
		if [ "$answer" != "" ]; then
			USER="$answer";
		fi

		PASSWORD="changeit";
		echo "Please enter a password for user $USER:"
		read answer
		if [ "$answer" != "" ]; then
			PASSWORD="$answer";
		fi
                clear
		echo "Initializing database..."
		$JAVA_BIN -cp ${CP} com.ilient.server.InitAccount "$SYSAID_HOME" "$ACCOUNT" "$SERIAL" "$USER" "$PASSWORD" 2
		if [ "$?" -eq 0 ]; then
			# Complain and quit    
			echo "FATAL error while initializing database. For more information, please consult the SysAid log at $SYSAID_HOME/WEB-INF/logs/sysaid.log."
			exit 1;
		fi

	fi
 fi

if [ "$type" != "1" ] && [ "$type" != "2" ] ;
then
   echo "The number that was entered is not a valid option"
fi
done

# set the new user and password into the variables for the link in the end of script

    MainUser="$USER"
    MainPass="$PASSWORD"	



# Start the Apache Tomcat 

cd /
cd "$Location"/apache-tomcat-7/bin
echo " " | cat >> "$Location"/Install.log
date | cat >> "$Location"/Install.log
echo "Tomcat startup.sh after sysaid.war file is copied to webapps folder" | cat >> Install.log
./startup.sh | cat >> "$Location"/Install.log

# Add Tomcat 7 as a service called Sysaid Server at etc/init.d folder, and add the service to the boot sequence.

continue=
    echo " " 
    echo -n "Do you wish to install SysAid as a service (/etc/init.d/SysAidServer)?"
    read continue
    if [ "$continue" = "y" ];
    then

    echo "#!/bin/sh" > /etc/init.d/SysAidServer
    echo "### BEGIN INIT INFO" >> /etc/init.d/SysAidServer
    echo "# Provides:          SysAidServer" >> /etc/init.d/SysAidServer
    echo "# Required-Start:    \$remote_fs \$syslog" >> /etc/init.d/SysAidServer
    echo "# Required-Stop:     \$remote_fs \$syslog" >> /etc/init.d/SysAidServer
    echo "# Default-Start:     2 3 4 5" >> /etc/init.d/SysAidServer
    echo "# Default-Stop:      0 1 6" >> /etc/init.d/SysAidServer
    echo "# Short-Description: Start SysAid Server at boot time" >> /etc/init.d/SysAidServer
    echo "# Description:       Enable SysAid Server" >> /etc/init.d/SysAidServer
    echo "### END INIT INFO" >> /etc/init.d/SysAidServer
    echo "" >> /etc/init.d/SysAidServer
    echo "PID=\`ps -aef | grep $Location/jre | grep -v grep | awk '{print \$2}'\`" >> /etc/init.d/SysAidServer
    echo "" >> /etc/init.d/SysAidServer
    echo "" >> /etc/init.d/SysAidServer
    echo "case \$1 in" >> /etc/init.d/SysAidServer
    echo "start)" >> /etc/init.d/SysAidServer
    echo "        if [ \$PID -ne 0 -o \$PID -eq 0 2>/dev/null ];" >> /etc/init.d/SysAidServer
    echo "        then" >> /etc/init.d/SysAidServer
    echo "                echo \"SysAid Server Appears Started. Try restarting instead...\"" >> /etc/init.d/SysAidServer
    echo "        else" >> /etc/init.d/SysAidServer
    echo "                sh $Location/apache-tomcat-7/bin/startup.sh >/dev/null" >> /etc/init.d/SysAidServer
    echo "        fi" >> /etc/init.d/SysAidServer
    echo "        ;;" >> /etc/init.d/SysAidServer
    echo "stop)" >> /etc/init.d/SysAidServer
    echo "       #sh $Location/apache-tomcat-7/bin/shutdown.sh >/dev/null" >> /etc/init.d/SysAidServer
    echo "        if [ \$PID -ne 0 -o \$PID -eq 0 2>/dev/null ];" >> /etc/init.d/SysAidServer
    echo "        then" >> /etc/init.d/SysAidServer
    echo "                kill -9 \"\$PID\"" >> /etc/init.d/SysAidServer
    echo "        fi" >> /etc/init.d/SysAidServer
    echo "        ;;" >> /etc/init.d/SysAidServer
    echo "restart)" >> /etc/init.d/SysAidServer
    echo "        if [ \$PID -ne 0 -o \$PID -eq 0 2>/dev/null ];" >> /etc/init.d/SysAidServer
    echo "        then" >> /etc/init.d/SysAidServer
    echo "               #sh $Location/apache-tomcat-7/bin/shutdown.sh >/dev/null" >> /etc/init.d/SysAidServer
    echo "                PID=\`ps -aef | grep $Location/jre | grep -v grep | awk '{print \$2}'\`" >> /etc/init.d/SysAidServer
    echo "                if [ \$PID -ne 0 -o \$PID -eq 0 2>/dev/null ];" >> /etc/init.d/SysAidServer
    echo "                then" >> /etc/init.d/SysAidServer
    echo "                        kill -9 \"\$PID\"" >> /etc/init.d/SysAidServer
    echo "                fi" >> /etc/init.d/SysAidServer
    echo "        fi" >> /etc/init.d/SysAidServer
    echo "        sh $Location/apache-tomcat-7/bin/startup.sh >/dev/null" >> /etc/init.d/SysAidServer
    echo "        ;;" >> /etc/init.d/SysAidServer
    echo "*)" >> /etc/init.d/SysAidServer
    echo "        scriptPath=\`basename \$1\`;" >> /etc/init.d/SysAidServer
    echo "        echo \"Syntax: \$scriptPath start/stop/restart\"" >> /etc/init.d/SysAidServer
    echo "esac" >> /etc/init.d/SysAidServer
    echo "exit 0" >> /etc/init.d/SysAidServer

    chmod 700 /etc/init.d/SysAidServer

# Add to boot sequence for debian based OS

         if [ -f "/usr/sbin/update-rc.d" ]; then
         /usr/sbin/update-rc.d SysAidServer defaults
         fi

# Add to boot sequence for Red Hat based OS

         if [ -f "/sbin/chkconfig" ]; then
         /sbin/chkconfig --add SysAidServer
         /sbin/chkconfig SysAidServer on
         fi

# Add a link to /usr/bin for SysAidServer service, to allow start, stop, restart. On all locations

    cd /
    cd /usr/bin
    ln -s /etc/init.d/SysAidServer SysAidServer
    cd /
    fi

clear

# Check for the Linux machine IP address, and name, and provide a link to the user.

Route=`route | grep default | awk '{print $8}'`

NAME=`hostname`

URL=`ifconfig "$Route" | grep 'inet ' | sed 's/inet addr:/inet /' | cut -f2 | awk '{ print $2}'`

clear

# InstallMongoDB - cancelling for the installation of 14.3 - not used any longer
	# InstallCentos(){
		# var=`uname -m`
		# if [ "$var" = "x86_64" ]; then
			# echo "x86_64"
			# echo "[10gen]" > /etc/yum.repos.d/10gen.repo		
			# echo "name=10gen Repository" >> /etc/yum.repos.d/10gen.repo
			# echo "baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64" >> /etc/yum.repos.d/10gen.repo
			# echo "gpgcheck=0" >> /etc/yum.repos.d/10gen.repo
			# echo "enabled=1" >> /etc/yum.repos.d/10gen.repo
			# yum install mongo-10gen mongo-10gen-server -y
			# sed '11s/.*/port = 28000/' /etc/mongod.conf > /etc/mongod2.conf
			# mv /etc/mongod2.conf /etc/mongod.conf
			# service mongod start

		# else
			# echo "i686"
			# echo "[10gen]" > /etc/yum.repos.d/10gen.repo		
			# echo "name=10gen Repository" >> /etc/yum.repos.d/10gen.repo
			# echo "baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/i686" >> /etc/yum.repos.d/10gen.repo
			# echo "gpgcheck=0" >> /etc/yum.repos.d/10gen.repo
			# echo "enabled=1" >> /etc/yum.repos.d/10gen.repo
			# yum install mongo-10gen mongo-10gen-server -y
			# sed '11s/.*/port = 28000/' /etc/mongod.conf > /etc/mongod2.conf
			# mv /etc/mongod2.conf /etc/mongod.conf
			# service mongod start

		# fi
	# }

	# InstallDebian(){
		# echo "It's Debian"
		# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
		# echo 'deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen' | sudo tee /etc/apt/sources.list.d/10gen.list
		# sudo apt-get update
		# sudo apt-get install mongodb-10gen
		# sed '11s/.*/port = 28000/' /etc/mongod.conf > /etc/mongod2.conf
		# mv /etc/mongod2.conf /etc/mongod.conf
		# service mongod start
	# }

	# InstallUbuntu(){
		# echo "It's Ubuntu"
		# sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
		# echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/10gen.list
		# sudo apt-get update
		# sudo apt-get install mongodb-10gen
		# sed '11s/.*/port = 28000/' /etc/mongod.conf > /etc/mongod2.conf
		# mv /etc/mongod2.conf /etc/mongod.conf
		# service mongod start
	# }

	# InstallMongoDB(){
		# echo "loop"
		# var=`cat /etc/*-release | tr '[:lower:]' '[:upper:]'`
		# echo $var;

		# case $var in
		# *UBUNTU*) echo "Installing MongoDB on UBUNTU";InstallUbuntu;;
		# *CENTOS*) echo "Installing MongoDB on CentOs";InstallCentos;;
		# *DEBIAN*) echo "Installing MongoDB on DEBIAN";InstallDebian;;
		# *) echo "Linux distribution not supported. This patch supports Ubuntu, Debian and CentOS..."
		# esac
	# }

#echo " "
#echo "MongoDB was installed succesfully | cat >> "$Location"/Install.log"

echo " " | cat >> "$Location"/Install.log
date | cat >> "$Location"/Install.log
echo "http://"$URL":"$MainPort"" | cat >> "$Location"/Install.log
echo "The installation process is finished."
echo " "
echo " "
echo "In order to log in to SysAid, please copy the following address, and paste it in your browser:"
echo "http://"$URL":"$MainPort""
echo " "
echo "Alternatively, you may log in to SysAid using the Machine DNS Name:" 
echo " "
echo "http://"$NAME":"$MainPort""
echo " "
echo "Please use the following user credentials:"
echo User:     "$MainUser" 
echo Password: "$MainPass"
echo " "
echo " "
echo "Thank you for installing SysAid." 
echo "If you need further assistance, contact us at: support@sysaid.com"
echo " "








