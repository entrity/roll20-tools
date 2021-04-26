. shared.sh

[[ -n $TRUEORPHANS ]] && TRUEORPHANS=true

function request () {
	if [[ -n $FOLDER_ID ]]; then
		docurl "https://app.roll20.net/image_library/fetchlibraryfolder/$FOLDER_ID" # Param is folder id
	else
		docurl "https://app.roll20.net/image_library/fetchorphanassets/${TRUEORPHANS:-false}/$1" # Param is page number
	fi
}

function update_db () {
	jq -r -c '.[] | [.id, .name, .image_url]' | while read VALUES; do
		SQL="INSERT OR REPLACE INTO map(id, name, url) VALUES(${VALUES:2:-1})"
		if ! sqlite3 -batch "$DB_FILE" "$SQL"; then
			>&2 echo FAILED $CMD
			exit 45
		fi
	done
}

function main () {
	local PAGE=1
	while ((1)); do
		COUNT=`request $PAGE | tee /dev/fd/3 >(update_db) | jq length`
		>&2 echo "Got COUNT $COUNT PAGE $PAGE"
		if [[ -z $COUNT ]] || [[ $COUNT -lt 50 ]]; then break; fi
		local PAGE=$(( 1 + PAGE ))
	done 3>&1 | jq -s -c flatten
}

if [[ -t 1 ]]; then
	main | jq
else
	main
fi
