if [ "$EUID" -eq 0 ]; then 
  echo "Do not run as root! Run as the user that the service should start as or the user directory it is installed under"
  exit
fi


if ! test -f "steamcmd.sh"; then
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
else
    echo "steamcmd.sh already exists no need to download"
fi


if ! test -f "steamcmd.sh"; then
    echo "Downloading and extracting steamcmd failed"
    echo "The command used was: 'curl -sqL \"https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz\" | tar zxvf -'"
    echo "The URL may have changed this is the first thing to check."
    exit 1
fi


if ! command -v screen &> /dev/null; then
    echo "Could not find the command 'screen'. This is required too run 7 Days To Die server. Please use your Linux Distro's package management system to install 'screen'"
fi


if test -z "$1"; then
    echo "You have not provided a directory for installing 7 Days to Die. Assuming the default dir value of 'seven'"
    serverDir="seven"
else
    serverDir="$1"
fi


if test -d "$serverDir"; then
    echo "Directory $serverDir already exists! If you wish to re-install move or delete this dir first ie: mv $serverDir $serverDir.bck or rm -rf $serverDir"
else
    mkdir $serverDir
fi

SEVEN_USER=$(whoami)
SEVEN_INSTANCE_NAME=$serverDir
SEVEN_BASE_DIR=$(pwd)

echo "==================================================="
echo "Installing $SEVEN_INSTANCE_NAME in $SEVEN_BASE_DIR"
echo "This will be using the $SEVEN_USER user"
echo "==================================================="
read -n 1 -s -r -p "Press any key to continue"
echo ""

echo "Installing 7 Days To Die"
/bin/bash update.sh $serverDir

echo "Testing 7 Days To Die server by starting and waiting and then stopping it again. There should be no errors during this part."

/bin/bash start.sh $serverDir

echo "Sleeping for 60 seconds"

counter=0
i=1
sp="/-\|"
echo -n ' '
until [ $counter -gt 60 ]
do
    printf "\b${sp:i++%${#sp}:1}"
    sleep 1
    ((counter=counter+1))
done

echo ""

/bin/bash stop.sh $serverDir

echo ""
echo "This script will now check the firewall on this device."
echo "NOTE: Make sure too open up port forwarding on your router for 26903/udp 26902/udp 26901/udp 26900/udp 26900/tcp"
echo ""


if ! command -v firewall-cmd &> /dev/null; then
    echo "firewall-cmd could not be found"
    echo "Cannot edit the firewall on this machine!"
elif [ "$(firewall-cmd --state 2>&1)" == "not running" ]; then
    echo "Firewall not running.. no need to edit the firewall"
else
    echo "Opening up ports: 26903/udp 26902/udp 26901/udp 26900/udp 26900/tcp"
    echo "This will ask for your root password."
    su -c "firewall-cmd --permanent --add-port=26903/udp; firewall-cmd --permanent --add-port=26902/udp; firewall-cmd --permanent --add-port=26901/udp; firewall-cmd --permanent --add-port=26900/udp; firewall-cmd --permanent --add-port=26900/tcp; systemctl restart firewalld" root
fi

echo ""
echo "Do you want to install a systemd control script?"
echo ""
read -p "Please enter (y/n) " yn

if [[ $yn =~ ^[Yy]$ ]]; then
    echo ""
    echo "This will ask for your root password."
    echo ""
    cp template_7days_service.service 7days_$SEVEN_INSTANCE_NAME.service
    sed -i "s/<SEVEN_USER>/$SEVEN_USER/g" 7days_$SEVEN_INSTANCE_NAME.service
    sed -i "s/<SEVEN_INSTANCE_NAME>/$SEVEN_INSTANCE_NAME/g" 7days_$SEVEN_INSTANCE_NAME.service
    sed -i "s|<SEVEN_BASE_DIR>|$SEVEN_BASE_DIR|g" 7days_$SEVEN_INSTANCE_NAME.service
    su -c "mv 7days_$SEVEN_INSTANCE_NAME.service /etc/systemd/system/7days_$SEVEN_INSTANCE_NAME.service; systemctl daemon-reload; systemctl enable 7days_$SEVEN_INSTANCE_NAME.service" root
    echo ""
    echo "You can now run systemctl start 7days_$SEVEN_INSTANCE_NAME as well as status and stop commands to control the instance"
fi

echo "Install finished"
exit 0
