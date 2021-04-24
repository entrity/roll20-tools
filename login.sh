# Load shared vars and functions
. shared.sh

login () {
	if [[ -z $USER ]] || [[ -z $PASS ]]; then
		>&2 echo "ERR USER or PASS undefined"
		exit 1
	fi
	>&2 echo -e "\033[33m${@}\033[0m"
	local curlcmd=(
		curl "https://app.roll20.net/sessions/create"
		"${CURLARGS[@]}"
		-d "email=${USER}&password=${PASS}"
		-w "%{http_code}\t%{redirect_url}\n" -s -q
	)
	read STATUS REDIRECT < <("${curlcmd[@]}")
	if [[ $REDIRECT =~ /editor/$ ]]; then
		echo -e "\033[32m$STATUS\t$REDIRECT\033[0m"
	else
		echo -e "\033[31m$STATUS\t$REDIRECT\033[0m"
		exit 1
	fi
}

login
