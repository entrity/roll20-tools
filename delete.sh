. shared.sh

if (($#)); then
	PARAMS="ids[count]=$#"
	for ID in "${@}"; do
		PARAMS+="&ids[imageids][]=$ID"
	done
elif ! [[ -t 0 ]]; then
	COUNT=0
	PARAMS=""
	while read ID; do
		PARAMS+="&ids[imageids][]=$ID"
	done
	PARAMS="ids[count]=$COUNT$PARAMS"
else
	exit 1
fi
docurl --data-raw "$PARAMS" 'https://app.roll20.net/image_library/permdelete/'
