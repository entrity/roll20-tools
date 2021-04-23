. shared.sh

if (($#)); then
	COUNT=$#
	PARAMS="ids[count]=$COUNT"
	for ID in "${@}"; do
		PARAMS+="&ids[imageids][]=$ID"
	done
elif ! [[ -t 0 ]]; then
	COUNT=0
	PARAMS=""
	while read ID; do
		PARAMS+="&ids[imageids][]=$ID"
		COUNT=$(( COUNT + 1 ))
	done
	PARAMS="ids[count]=$COUNT$PARAMS"
else
	exit 1
fi
if (($COUNT)); then
	docurl --data-raw "$PARAMS" 'https://app.roll20.net/image_library/permdelete/'
else
	>&2 echo -e "\033[31mNo request because COUNT is 0\033[0"
fi

# See also:
# curl 'https://app.roll20.net/image_library/deletelibraryitem/' \
#  --data-raw 'appid=$APPID&removetag=true&parent=root&deleteindex=0' \
