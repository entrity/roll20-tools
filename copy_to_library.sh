#!/bin/bash

# IMAGE_ID can come from command-line arg, clipboard selection, or stdin

. shared.sh

FOLDER_ID=${1:--MYy0iEe1Ls8qHYje_45}
FOLDER_NAME=${2:-cave}
IMAGE_ID=${3}
if [[ -z $IMAGE_ID ]]; then
	if ! [[ -t 0 ]]; then
		read IMAGE_ID
	elif [[ $SHLVL -le 2 ]]; then
		IMAGE_ID=${3:-`xsel -b -o`}
	fi
fi
failifblank IMAGE_ID $IMAGE_ID
>&2 echo -ne "IMAGE_ID \033[96m$IMAGE_ID\033[0m"
>&2 echo -ne " FOLDER_NAME \033[96m$FOLDER_NAME\033[0m"
>&2 echo -ne " FOLDER_ID \033[96m$FOLDER_ID\033[0m"
>&2 echo

function readdb () {
>&2 lsof "$DB_FILE"
>&2 sqlite3 -separator $'\t' -batch "$DB_FILE" "select name, url from map where id = $IMAGE_ID"
	sqlite3 -separator $'\t' -batch "$DB_FILE" "select name, url from map where id = $IMAGE_ID"
}
IFS=$'\t' read -r IMAGE_NAME IMAGE_URL < <(readdb)

failifblank IMAGE_NAME $IMAGE_NAME
failifblank IMAGE_URL $IMAGE_URL
failifblank FOLDER_ID $FOLDER_ID
failifblank FOLDER_NAME $FOLDER_NAME

echo -e "\033[96m$IMAGE_NAME\033[0m..."

docurl 'https://app.roll20.net/image_library/copy_asset_to_library/' \
-d 'type=item' \
-d "id=$IMAGE_ID" \
--data-urlencode "name=$IMAGE_NAME" \
--data-urlencode "url=$IMAGE_URL" \
--data-urlencode "folderid=$FOLDER_ID" \
--data-urlencode "foldername=$FOLDER_NAME" \
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
