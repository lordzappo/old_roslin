#!/bin/bash

# load config
source ./settings.sh

if [ -z $PRISM_BIN_PATH ] || [ -z $PRISM_INPUT_PATH ]
then
    echo "Some necessary paths are not correctly configured."
    echo "PRISM_BIN_PATH=${PRISM_BIN_PATH}"
    echo "PRISM_INPUT_PATH=${PRISM_INPUT_PATH}"
    exit 1
fi

usage()
{
cat << EOF

USAGE: `basename $0` [options]

OPTIONS:

   -u      Username you want to configure a workplace for

EXAMPLE:

   `basename $0` -u chunj

EOF
}


while getopts “u:h” OPTION
do
    case $OPTION in
        u) USER_ID=$OPTARG ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z $USER_ID ]
then
    usage
    exit 1
fi

if [ `whoami` != "$USER_ID" ]
then
    echo "You can only run this from your own account (`whoami` != ${USER_ID})"
    echo "Aborted."
    exit 1
fi

# HOME_DIR=$HOME_DIR
HOME_DIR="/home/${USER_ID}"

if [ -d "${PRISM_INPUT_PATH}/${USER_ID}" ]
then
    echo "Your workspace already exists: ${PRISM_INPUT_PATH}/${USER_ID}"
    echo "Aborted."
    exit 1
fi

# create user directory
mkdir -p ${PRISM_INPUT_PATH}/${USER_ID}

# copy jumpstart exampels
tar xzf ${PRISM_BIN_PATH}/bin/setup/examples.tgz -C ${PRISM_INPUT_PATH}/${USER_ID} --strip-components 2

find ${PRISM_INPUT_PATH}/${USER_ID}/ -name "*.yaml" | xargs sed -i "s/inputs\/chunj/inputs\/${USER}/g"

# .prism
mkdir -p $HOME_DIR/.prism

# add under .prism the scripts & settings to be loaded upon user login
cp ./settings.sh $HOME_DIR/.prism/
echo "PATH=\$PATH:${PRISM_BIN_PATH}/bin/sing" > $HOME_DIR/.prism/sing.sh
echo "PATH=\$PATH:${PRISM_BIN_PATH}/bin/prism-runner" > ~/.prism/prism-runner.sh

cp $HOME_DIR/.profile $HOME_DIR/.profile.bak

settings_found=`grep "# PRISM.SETTINGS\$" $HOME_DIR/.profile`
if [ -z "$settings_found" ]
then
    echo "for file in $HOME_DIR/.prism/*.sh; do source \$file; done  # PRISM.SETTINGS" >> $HOME_DIR/.profile
fi

echo "Your workspace: ${PRISM_INPUT_PATH}/${USER_ID}"
echo "Done. Log out and log back in."