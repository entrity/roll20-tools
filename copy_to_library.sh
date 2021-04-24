#!/bin/bash

# IMAGE_ID can come from command-line arg, clipboard selection, or stdin

. shared.sh

FOLDER_ID=${1:--MYy0iEe1Ls8qHYje_45}
FOLDER_NAME=${2:-cave}
if [[ -t 0 ]]; then
	IMAGE_ID=${3:-`xsel -b -o`}
else
	read IMAGE_ID
fi

function readdb () {
	sqlite3 -separator $'\t' -batch "$DB_FILE" "select name, url from map where id = $IMAGE_ID"
}
IFS=$'\t' read -r IMAGE_NAME IMAGE_URL < <(readdb)

failifblank () {
	if [[ -z $2 ]]; then
		>&2 echo "FAIL $1 cannot be blank"
		exit 2
	fi
}

failifblank IMAGE_ID $IMAGE_ID
failifblank IMAGE_NAME $IMAGE_NAME
failifblank IMAGE_URL $IMAGE_URL
failifblank FOLDER_ID $FOLDER_ID
failifblank FOLDER_NAME $FOLDER_NAME

echo -e "\033[96m$IMAGE_NAME\033[0m..."

docurl 'https://app.roll20.net/image_library/copy_asset_to_library/' \
-d 'type=item' \
-d "id=$IMAGE_ID" -d "name=$IMAGE_NAME" -d "url=$IMAGE_URL" \
-d "folderid=$FOLDER_ID" -d "foldername=$FOLDER_NAME" \
-d "keywords=$KEYWORDS"

# E.g.
# type=item
# id=242696169
# name=4x4_Steps.png
# url=https://s3.amazonaws.com/files.d20.io/images/217607183/9byhOUl8WV9DJafyfEbaxw/thumb.png?1619169444
# newid=-MYy3fctEciBEN_mEhdh
# foldername=cave
# folderid=-MYy0iEe1Ls8qHYje_45
# keywords
