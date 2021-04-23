COOKIE_FILE=cookies.txt
DB_FILE=map.db

CURLARGS=(-s --compressed \
	-b "$COOKIE_FILE" -c "$COOKIE_FILE" \
	-H 'Accept-Language: en-US,en;q=0.5' \
	-H 'Accept: */*' \
	-H 'Connection: keep-alive' \
	-H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
	-H 'Origin: https://app.roll20.net' \
	-H 'Referer: https://app.roll20.net/editor/' \
	-H 'TE: Trailers' \
	-H 'User-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.72 Safari/537.36' \
	-H 'X-Requested-With: XMLHttpRequest' \
	-H 'Authority: app.roll20.net' \
	-w '\n%{http_code}'
)
# Execute curl request with headers and cookies
docurl () {
	>&2 echo -e "\033[33m${@}\033[0m"
	local curlcmd=(curl "${CURLARGS[@]}" "${@}")
	< <( "${curlcmd[@]}" ) readarray ARR
	HTTP_CODE=${ARR[-1]}
	>&2 echo "HTTP_CODE $HTTP_CODE"
	unset ARR[-1] # Pop HTTP response status
	printf "%s" "${ARR[@]}"
	if ! [[ "$HTTP_CODE" =~ 2.. ]]; then
		>&2 echo
		>&2 printf " %q" "${curlcmd[@]}"
		>&2 echo "Bad response $HTTP_CODE"
		exit 1
	fi
}

# Create sqlite db for mapping roll20 ids to local file paths
createdb () {
	cat <<-EOF | sqlite3 -batch "$DB_FILE"
		create table map (
			id integer,
			path string,
			name string
		);
	EOF
}
