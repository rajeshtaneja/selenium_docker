#!/bin/bash

HOMEDIR=/
WWWDIR=/var/www/html
MOODLE_DIR_ORG=/moodle
MOODLE_DIR=/var/www/html/moodle

MAX_RUNS_SUPPORTED=50

# To avoid chomedriver from hanging.
export DBUS_SESSION_BUS_ADDRESS=/dev/null

# Usage o/p
function usage() {
cat << EOF
####################################### Usage ##############################################
#                                                                                          #
#                          To start selenium docker instance                               #
#                                                                                          #
############################################################################################
# ./init {PROFILE_NAME}                                                                    #
#   PROFILE_NAME can be either of the following:                                           #
#     - default                                                                            #
#     - chrome                                                                             #
#     - firefox                                                                            #
#     - phantomjs                                                                          #
#     - phantomjs-selenium                                                                 #
#                                                                                          #
############################################################################################
EOF
    if [ -n "$1" ]; then
        exit $1
    else
        exit 0
    fi
}

if [ ! -d "$MOODLE_DIR" ]; then
    # Check if /moodle exits.
    if [ -d "$MOODLE_DIR_ORG" ]; then
       # Remove any old dir.
       if [ ! -d "$WWWDIR" ]; then
           sudo mkdir -p $WWWDIR
           sudo chmod 777 $WWWDIR
       fi
       cp -r ${MOODLE_DIR_ORG} ${MOODLE_DIR}
       sudo chmod 777 $MOODLE_DIR
       # Create behatrun links.
       cd $MOODLE_DIR

       for ((i=0; i<${MAX_RUNS_SUPPORTED}; i++));
       do
          ln -s $MOODLE_DIR "behatrun${i}"
       done

    elif [ -d "$WWWDIR" ]; then
        echo "#######################################################################################################"
        echo " Moodle directory is not mapped to container at /moodle "
        echo " Ensure you have mapped you current Moodle path at same location in this docker to pass  @_file_upload"
        echo "#######################################################################################################"
    fi

fi

DOCKERIP=$(ip addr | grep global | awk '{print substr($2,1,length($2)-3)}')
echo "###############################################################"
echo "## Selenium ip address is ${DOCKERIP}"
echo "###############################################################"

# Start selenium or phantomjs.
if [ "$1" == "phantomjs" ]; then
    shift
    if [ $# -gt 0 ]; then
        echo "Starting phantomjs at $1 port"
        PORT=$1
        shift
        while test $# -gt 0; do
            echo "Starting phantomjs at $1 port"
            phantomjs --webdriver=$1 > /dev/null 2>&1 &
            if [ "$?" -ne 0 ]; then
                echo "!!! Failed staring phantomjs at $PORT port !!!"
            fi
            shift
        done
        phantomjs --webdriver=$PORT
        if [ "$?" -ne 0 ]; then
            echo "!!! Failed staring phantomjs at $1 port !!!"
        fi
    else
        phantomjs --webdriver=4443
        if [ "$?" -ne 0 ]; then
            echo "!!! Failed staring phantomjs at 4443 port !!!"
        fi
    fi
elif [ "$1" == "help" ]; then
    usage 1
else
    # If first value is profile then don't bother just ignore.
    if [ $# -gt 0 ]; then
        re='^[0-9]+$'
        if ! [[ $1 =~ $re ]] ; then
            shift
        fi
    fi

    if [ $# -gt 0 ]; then
        while test $# -gt 0; do
            echo "Starting selenium at $1 port"
            LOGFILE=~/selenium${1}.log
            xvfb-run -a java -jar /opt/selenium/selenium-server-standalone.jar -port $1 > /dev/null 2>&1 &
            if [ "$?" -ne 0 ]; then
                echo "!!! Failed staring selenium at $1 port !!!"
            fi
            sleep 5
            shift
        done
        tail -f /dev/null
    else
        xvfb-run -a java -jar /opt/selenium/selenium-server-standalone.jar
        if [ "$?" -ne 0 ]; then
            echo "!!! Failed staring selenium at 4444 port !!!"
        fi
    fi
fi