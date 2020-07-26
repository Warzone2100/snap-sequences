#!/bin/bash

function checkFileSHA256 {
 	local FileName="$1"
 	local SHA256Sum="$2"

 	local SHA256SumLoc="$(shasum -a 256 "${FileName}" | awk '{ print $1 }')"
 	if [ -z "${SHA256SumLoc}" ]; then
 		echo "warning: Unable to compute SHA256 for ${FileName}" >&2
 		return 1
 	elif [ "${SHA256SumLoc}" != "${SHA256Sum}" ]; then
 		echo "warning: SHA256 does not match for ${FileName}; (received: ${SHA256SumLoc}) (expecting: ${SHA256Sum})" >&2
 		rm -f "${FileName}"
 		return 1
 	fi

 	return 0
}

DLURL="$1"
FileName="$2"
SHA256Sum="$3"

# Fetch the file
echo "info: Fetching: ${DLURL}" >&2
curl -Lf "${DLURL}" --create-dirs --retry 3 --connect-timeout "30" --output "${FileName}"
result=${?}
if [ $result -ne 0 ]; then
      echo "warning: Fetch failed: ${DLURL}" >&2
      exit ${result}
fi

# Check SHA256 sum of downloaded file
checkFileSHA256 "${FileName}" "${SHA256Sum}"
result=${?}
if [ $result -ne 0 ]; then
      exit ${result}
fi

exit 0
