. shared.sh

main () {
	docurl 'https://app.roll20.net/image_library/fetchroot'
}

if [[ -t 1 ]]; then
	main | jq
else
	main
fi
