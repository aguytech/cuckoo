#!/bin/bash

######################## CONF

_TRACE=debug
_PATH_BASE=$( readlink -f ${0%/*} )
_PATH_CONF=${HOME}/.config/cuckoo
_PATH_LOG=/var/log/cuckoo
_CMD="sudo apt"
_CMD_INS="sudo apt install -y"
_PATH_SOFTS=${_PATH_BASE}/softs
_FILE_PIP3="${_PATH_LOG}/install.pip3"
_FILE_PIP2="${_PATH_LOG}/install.pip2"

# inc
file=${_PATH_BASE}/bs/inc
! [ -f "${file}" ] && echo "Unable to find file: ${file}" && exit 1
! . ${file} && echo "Errors while sourcing file: ${file}" && exit 1

########################  SUB

_echoA "- Use from the HOST with Xubuntu 18.04 bionic already installed"
_askno "Validate to continue"

parts_sub="test data ${part_fs} init ssh upgrade global dev conf root"

for _PART in ${parts_sub}; do
	_source_sub "${_PART}"
done

########################  QEMU

parts_qemu="global share nbd conf"

for _PART in ${parts_qemu}; do
	_source_sub "${_PART}" qemu
done

########################  FORENSIC

parts_for="global binwalk regripper volatility"
parts_for+=" conf"
parts_for+=" autopsy wireshark idafree bytecode luyten cfr"

for _PART in ${parts_for}; do
	_source_sub "${_PART}" forensic
done

########################  CUCKOO

parts_cuc="data global mongodb pgsql qemu"
parts_cuc+=" pydeep m2crypto guacd tcpdump mitmproxy"
parts_cuc+=" cuckoo conf interface"

for _PART in ${parts_cuc}; do
	_source_sub "${_PART}" cuckoo
done

########################  PERSO

_source_sub perso

########################  END

_source_sub end

########################  MENU

parts_install=$( ls ${_PATH_BASE}/install )

while [ "${_PART}" != "quit" ]; do
	_SDATE=$(date +%s) # renew _SDATE
	parts_made=" $( cat "${_FILE_DONE}" | xargs ) "
	parts2do=" "
	for part in ${parts_install}; do
		[ "${parts_made/ ${part} }" = "${parts_made}" ] && parts2do+="$part "
	done

	_echod "parts_made='${parts_made}'"
	_echod "parts2do='${parts2do}'"

	[ "${parts_made}" ] && _echo "Part already made: ${cyanb}${parts_made}${cclear}"
	PS3="Give your choice: "
	select _PART in quit ${parts2do}; do
		if [ "${parts2do/ ${_PART} /}" != "${parts2do}" ] ; then
			_source "${_PATH_BASE}/install/${_PART}"
			break
		elif [ "${_PART}" = quit ]; then
			break
		else
			_echoe "Wrong option"
		fi
	done
done

_exit
