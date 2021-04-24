. shared.sh

GAME=${GAME:-1}

function request () {
	[[ -f $DB_FILE ]] || createdb
	if (($#)); then
		FOLDERID=$1
		docurl "https://app.roll20.net/image_library/fetchlibraryfolder/$FOLDERID"
	elif [[ -n $TRUEORPHANS ]]; then
		# Search for images which aren't in any folders
		docurl "https://app.roll20.net/image_library/fetchorphanassets/true/$GAME"
	else
		# Search for all images
		docurl "https://app.roll20.net/image_library/fetchorphanassets/false/$GAME"
	fi
}

function update_db () {
	jq -r -c '.[] | [.id, .name, .image_url]' | while read VALUES; do
		sqlite3 "$DB_FILE" "INSERT OR REPLACE INTO map(id, name, url) VALUES(${VALUES:2:-1})"
	done
}

function main () {
	request | tee >(update_db)
}

if [[ -t 1 ]]; then
	main | jq
else
	main
fi
