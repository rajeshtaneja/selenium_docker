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
    if [ "$(ls -A $MOODLE_DIR_ORG)" ]; then
       sudo mkdir -p $WWWDIR
       sudo chmod 777 $WWWDIR
       cp -r ${MOODLE_DIR_ORG} ${MOODLE_DIR}
       sudo chmod 777 $MOODLE_DIR
    else
        echo "#######################################################################################################"
        echo "Moodle directory is not mapped to container at /moodle or /var/www/html/moodle, @_file_upload will fail"
        echo "#######################################################################################################"
        exit 1
    fi

    # Create behatrun links.
    cd $MOODLE_DIR
    for ((i=0; i<${MAX_RUNS_SUPPORTED}; i++));
    do
        ln -s $MOODLE_DIR "behatrun${i}"
    done
fi

if [ -n "$1" ]; then
    if [ "$1" == "phantomjs" ]; then
        phantomjs --webdriver=4443
    elif [ "$1" == "bash" ]; then
        exec "$@"
    else
        if [ -n "$2" ] && [ "$2" == "verbose" ]; then
            xvfb-run -a java -jar /opt/selenium/selenium-server-standalone.jar > /dev/null 2>&1
        else
            xvfb-run -a java -jar /opt/selenium/selenium-server-standalone.jar
        fi
    fi
else
    usage 1
fi
