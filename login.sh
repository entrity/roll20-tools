# Load shared vars and functions
. shared.sh

login () {
	if [[ -z $USER ]] || [[ -z $PASS ]]; then
		>&2 echo "ERR USER or PASS undefined"
		exit 1
	fi
	docurl "https://app.roll20.net/sessions/create" \
	-d "email=${USER}&password=${PASS}" \
  -v -q
}

login
