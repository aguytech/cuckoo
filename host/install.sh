#!/bin/bash
#
# write by Aguy

######################## CONF
_TRACE=debug
_PATH_BASE=$( readlink -f ${0%/*} )
_PATH_CONF=${HOME}/.config/cuckoo
_PATH_LOG=/var/log/cuckoo
_CMD="sudo apt"
_CMD_INS="sudo apt install -y"

file=${_PATH_BASE}/bs/inc
! [ -f ${file} ] && echo "Unable to find file: ${file}" && exit 1
! . ${file} && echo "Errors while importing ${file}" && exit 1

_echoA "- Use from the HOST with Xubuntu 18.04 bionic already installed"
_askno "Valid to continue"

########################  DATA

# btrfs
if [ -z ${_BTRFS+x} ]; then
	_askyn "BTRFS are used for system?"
	_BTRFS=${_ANSWER/n/}
	_confset _BTRFS "${_BTRFS}"
fi
[ "${_BTRFS}" ] && part_fs="btrfs" || part_fs="nobtrfs"

# halt
if [ -z ${_HALT+x} ]; then
	_askyn "Enable halt between each parts?"
	_HALT=${_ANSWER/n/}
	_confset _HALT "${_HALT}"
fi

########################  MANDATORY

_PARTS_MAN="${part_fs} init ssh upgrade global configuration root end"

for _PART in ${_PARTS_MAN}; do
	if ! _parthave ${_PART} ${_FILE_DONE}; then
		grep -q "^# ${_PART}" ${_FILE_CONF} || echo "# ${_PART}" >> ${_FILE_CONF}
		_source "${_PATH_BASE}/sub/${_PART}"
		[ "${_HALT}" ] && _askno "Valid to continue"
	fi
done

########################  MENU

_PARTS_ALL=$( ls ${_PATH_BASE}/install )

while [ "${_PART}" != "quit" ]; do
	_SDATE=$(date +%s) # renew _SDATE
	parts_made=" $( cat "${_FILE_DONE}" | xargs ) "
	parts2do=" "
	for part in ${_PARTS_ALL}; do
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
