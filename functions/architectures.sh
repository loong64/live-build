#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2016-2020 The Debian Live team
## Copyright (C) 2006-2015 Daniel Baumann <mail@daniel-baumann.ch>
##
## This program comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Check_architectures ()
{
	local ARCHITECTURE
	for ARCHITECTURE in "${@}"; do
		if [ "${ARCHITECTURE}" = "${LB_ARCHITECTURE}" ]; then
			return
		fi

		if [ "${ARCHITECTURE}" = "${LB_BOOTSTRAP_QEMU_ARCHITECTURE}" ]; then
			if [ ! -e "${LB_BOOTSTRAP_QEMU_STATIC}" ]; then
				Echo_warning "skipping %s, qemu-static binary ${LB_BOOTSTRAP_QEMU_ARCHITECTURE} was not found" "${0}"
				continue
			fi

			if [ ! -x "${LB_BOOTSTRAP_QEMU_STATIC}" ]; then
				Echo_warning "skipping %s, qemu-static binary ${LB_BOOTSTRAP_QEMU_STATIC} is not executable" "${0}"
				continue
			fi

			return
		fi
	done

	Echo_warning "skipping %s, foreign architecture(s)." "${0}"
	exit 0
}

Check_crossarchitectures ()
{
	local HOST
	if command -v dpkg >/dev/null; then
		HOST="$(dpkg --print-architecture)"
	else
		HOST="$(uname -m)"
	fi

	local CROSS
	case "${HOST}" in
		amd64|i386|x86_64)
			CROSS="amd64 i386"
			;;

		powerpc|ppc64)
			CROSS="powerpc ppc64"
			;;

		*)
			CROSS="${HOST}"
			;;
	esac

	if [ "${LB_ARCHITECTURE}" = "${LB_BOOTSTRAP_QEMU_ARCHITECTURE}" ]; then
		if [ ! -e "${LB_BOOTSTRAP_QEMU_STATIC}" ]; then
			Echo_warning "skipping %s, qemu-static binary ${LB_BOOTSTRAP_QEMU_ARCHITECTURE} was not found" "${0}"
			exit 0
		fi

		if [ ! -x "${LB_BOOTSTRAP_QEMU_STATIC}" ]; then
			Echo_warning "skipping %s, qemu-static binary ${LB_BOOTSTRAP_QEMU_STATIC} is not executable" "${0}"
			exit 0
		fi
		return
	fi

	Check_architectures "${CROSS}"
}
