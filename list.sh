. shared.sh

if (($#)); then
	FOLDERID=$1
	docurl "https://app.roll20.net/image_library/fetchlibraryfolder/$FOLDERID"
elif [[ -n $TRUEORPHANS ]]; then
	# Search for images which aren't in any folders
	docurl 'https://app.roll20.net/image_library/fetchorphanassets/true/1'
else
	# Search for all images
	docurl 'https://app.roll20.net/image_library/fetchorphanassets/false/1'
fi
