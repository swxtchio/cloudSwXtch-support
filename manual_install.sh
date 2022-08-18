#!/bin/bash
# Script to install cloudSwXtch on a VM
# Copyright (C) 2022 swXtch.io
# Permission to copy and modify is granted under the MIT license
ThisScriptVersion="1.0.0"

if [ $# -ne 1 ]; then
    echo "Invalid number of arguments supplied."
    echo "usage: script <version>"
    echo "<version> must be in the form 'v1.2.3' and match that of a install package in the local directory."
    exit -1
fi

# Must be root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root"
    exit -1
fi

SoftwareVersion=${1}
TarGzPath=$(realpath ./install-${SoftwareVersion}.tar.gz)
if [ ! -f "$TarGzPath" ]; then
    echo "The install package '$TarGzPath' was not found."
    echo "Please make sure the package is in the same directory as"
    echo "as the script and run again."
    exit -1
fi

# Dynamically determined values
SUBNET_CTRL_PREFIX=$(ip route list scope link | grep eth0 | awk -F' ' '{ print $1 }')
SUBNET_DATA_PREFIX=$(ip route list scope link | grep eth1 | awk -F' ' '{ print $1 }')
SWXTCH_SIZE=$(curl -sH Metadata:true "http://169.254.169.254/metadata/instance?api-version=2020-10-01" | python3 -c 'import sys, json; print(json.load(sys.stdin)["compute"]["vmSize"])')
SWXTCH_NAME=$(hostname)
TENANT_ID="unknown"
SUB_ID=$(curl -sH Metadata:true "http://169.254.169.254/metadata/instance?api-version=2020-10-01" | python3 -c 'import sys, json; print(json.load(sys.stdin)["compute"]["subscriptionId"])')
MANAGED_RG_NAME=$(curl -sH Metadata:true "http://169.254.169.254/metadata/instance?api-version=2020-10-01" | python3 -c 'import sys, json; print(json.load(sys.stdin)["compute"]["resourceGroupName"])')
CUSTOMER_RG_NAME=${MANAGED_RG_NAME}

# Settings that shouldn't change
TREE_NODES=1
BILLING_PLAN=licensed
MAX_CLIENT_COUNT=0
MAX_PACKET_RATE_KPPS=0
MAX_BW_MBPS=0
BILLING_FIELDS=seconds
VERIFICATION_LEVEL=none
TRIAL_PERIOD=60

InstallDir="/swxtch"
OutputDir="${InstallDir}/install-${SoftwareVersion}"
CONFIGFILE="${InstallDir}/swxtch_config"

# make pushd silent
pushd () {
    command pushd "$@" > /dev/null
}
# make popd silent
popd () {
    command popd "$@" > /dev/null
}

# Log the given message at the given level. All logs are written to stderr with a timestamp.
function log {
    local -r level="$1"
    local -r message="$2"
    local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local -r script_name="$(basename "$0")"
    >&2 echo -e "${timestamp} [${level}] [$script_name] ${message}"
}

# Log the given message at INFO level. All logs are written to stderr with a timestamp.
function log_info {
    local -r message="$1"
    log "INFO" "$message"
}

# Log the given message at WARN level. All logs are written to stderr with a timestamp.
function log_warn {
    local -r message="$1"
    log "WARN" "$message"
}

# Log the given message at ERROR level. All logs are written to stderr with a timestamp.
function log_error {
    local -r message="$1"
    log "ERROR" "$message"
}

# Check that the value of the given arg is not empty. If it is, exit with an error.
function assert_not_empty {
    local -r arg_name="$1"
    local -r arg_value="$2"
    local -r reason="$3"

    if [[ -z "$arg_value" ]]; then
        log_error "The value for '$arg_name' cannot be empty. $reason"
        exit 1
    fi
}

CreateInstallDirectory() {
    mkdir -p ${InstallDir}
    chmod 0700 ${InstallDir}
}

CreateConfigFile() {
    guid=$(uuidgen | tr -d -)
    # Write parameters to config file
    echo "[CONFIG]" > $CONFIGFILE
    echo "SOFTWARE_VERSION=${SoftwareVersion}" >> $CONFIGFILE
    echo "SWXTCH_GUID=${guid}" >> $CONFIGFILE
    echo "SUBNET_CTRL_PREFIX=${SUBNET_CTRL_PREFIX}" >> $CONFIGFILE
    echo "SUBNET_DATA_PREFIX=${SUBNET_DATA_PREFIX}" >> $CONFIGFILE
    echo "SWXTCH_SIZE=${SWXTCH_SIZE}" >> $CONFIGFILE
    echo "TREE_NODES=${TREE_NODES}" >> $CONFIGFILE
    echo "SWXTCH_NAME=${SWXTCH_NAME}" >> $CONFIGFILE
    echo "TENANT_ID=${TENANT_ID}" >> $CONFIGFILE
    echo "SUB_ID=${SUB_ID}" >> $CONFIGFILE
    echo "MANAGED_RG_NAME=${MANAGED_RG_NAME}" >> $CONFIGFILE
    echo "CUSTOMER_RG_NAME=${CUSTOMER_RG_NAME}" >> $CONFIGFILE
    echo "BILLING_PLAN=${BILLING_PLAN}" >> $CONFIGFILE
    echo "MAX_CLIENT_COUNT=${MAX_CLIENT_COUNT}" >> $CONFIGFILE
    echo "MAX_PACKET_RATE_KPPS=${MAX_PACKET_RATE_KPPS}" >> $CONFIGFILE
    echo "MAX_BW_MBPS=${MAX_BW_MBPS}" >> $CONFIGFILE
    echo "BILLING_FIELDS=${BILLING_FIELDS}" >> $CONFIGFILE
    echo "VERIFICATION_LEVEL=${VERIFICATION_LEVEL}" >> $CONFIGFILE
    echo "TRIAL_PERIOD=${TRIAL_PERIOD}" >> $CONFIGFILE
    # No previous version so set to current to indicate this is a new installation.
    PreviousSoftwareVersion=${SoftwareVersion}
    log_info "Creating new config file @ $CONFIGFILE"
    # Copy this script to the install directory just incase someone wants to see/use it
    local -r __SCRIPT_LOC=$(readlink -f "$0")
    cp -f $__SCRIPT_LOC ${InstallDir}
}

UpdateMOTD() {
    # Add preview banner to MOTD
    MotdLoc="/etc/motd"
    printf "*******************************************************\n"              >  $MotdLoc
    printf "**  cloudSwXtch version %-10s                    **\n" $SoftwareVersion >> $MotdLoc
    printf "**  For support, email 'support@swxtch.io'           **\n"              >> $MotdLoc
    printf "**  Installed on %-30s      **\n" "$(date)"                            >> $MotdLoc
    printf "*******************************************************\n"              >>  $MotdLoc
}

UpdateDistributionPackages() {
    apt-get update
    apt-get upgrade -y
    apt-get install -y librdmacm-dev librdmacm1 libnuma-dev libmnl-dev binutils-dev libcrypt-dev
}

# Creats a directory for the installer packets, then copies it from blobstorage and
# un-tars the contents, finally removing the tar.gz file.
#
# @param targzpath  full path to the install tar.gz
# @param outputDir  where to put the extracted files
ExtractInstallPkg() {
    local -r __targzpath=$1
    local -r __outputDir=$2
    tempFile="./temp.tar.gz"
    mkdir -p $__outputDir
    pushd $__outputDir
    cp "${__targzpath}" $tempFile
    tar -xf $tempFile
    rm $tempFile
    popd
}

RunInstaller() {
    local -r __packageDir=$1
    pushd ${__packageDir}
    chmod +x install_swxtch.sh
    ./install_swxtch.sh "install" ${SoftwareVersion} ${PreviousSoftwareVersion} | tee installer.log
    popd
}

#---------------------------------------------------------------------------------------
# MAIN LOGIC
#---------------------------------------------------------------------------------------

log_info "Running cloudSwXtch install for ${SoftwareVersion}[${TarGzPath}]"
UpdateDistributionPackages
UpdateMOTD
CreateInstallDirectory
CreateConfigFile
ExtractInstallPkg "$TarGzPath" "$OutputDir"
log_info "Running second stage installer from ${OutputDir}"
RunInstaller ${OutputDir}
# Minimize actions in this script that happen after RunInstaller above
# because that installer schedules a reboot to occur 10 seconds after that installer terminates.
log_info "swXtch installation complete"
