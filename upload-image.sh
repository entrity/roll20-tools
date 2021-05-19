#!/bin/bash
# Overview
# reqimage to get :code
# for each in mini, thumb, med, max, original:
#   POST name, type, size to https://app.roll20.net/image_library/s3putsign/:code to get :s3url
#   PUT image to aws s3 using :s3url

# Load shared vars and functions
. shared.sh

get_ext () {
	echo -n "${1##*.}"
}

curl_img () {
	local fpath=$1
	local ext=`get_ext "$fpath"`
	# Reqimage
	IMAGE_ID=`curl_reqimage "$fpath"`
	echo "code: $IMAGE_ID"
	printf -v sqlcmd "INSERT INTO map(id, path, name) VALUES(%d, '%q', '%q')" $IMAGE_ID "$fpath" "$NAME"
	sqlite3 -batch "$DB_FILE" "$sqlcmd"
	# Send resized images
	curl_img_for_geom "$fpath" "mini.$ext"  64 || exit 5
	curl_img_for_geom "$fpath" "thumb.$ext" 256 || exit 5
	curl_img_for_geom "$fpath" "med.$ext"   512 || exit 5
	curl_img_for_geom "$fpath" "max.$ext"   1024 || exit 5
	# Send original image
	local s3url=`curl_img_to_roll20 "$fpath" "$IMAGE_ID"`
	curl_img_to_aws_s3 "$s3url" "$fpath" # In the browser, the script names this "original.${ext}"
}

##################################################
# Private functions
##################################################
curl_reqimage () {
	local size=`stat --printf=%s "$fpath"`
	local mime=`file --mime-type "$fpath" | cut -d' ' -f2`
	docurl 'https://app.roll20.net/image_library/reqimage' \
	-d "name=$NAME" -d "size=$size" -d "type=$mime"
}

curl_img_to_roll20 () {
	fail_if_blank IMAGE_ID $IMAGE_ID
	local path=$1
	local size=`stat --printf=%s "$path"`
	local mime=`file --mime-type "$path" | cut -d' ' -f2`
	local name=`basename "$path"`
	docurl "https://app.roll20.net/image_library/s3putsign/$IMAGE_ID" \
	-d "name=$name" -d "size=$size" -d "type=$mime" \
	| tee /dev/stderr \
	| jq -c -r '[.base, .additional] | join("")'
}

curl_img_to_aws_s3 () {
	printf -v awss3url %b "${1}"
	local path=$2
	local mime=`file --mime-type "$path" | cut -d' ' -f2`
	local curlcmd=(
		curl "$awss3url"
		-s
		-X PUT
		-H 'Accept-Language: en-US,en;q=0.5'
		-H 'Accept: */*'
		-H 'Cache-Control: max-age=31104000,public'
		-H 'Connection: keep-alive'
		-H "Content-Type: ${mime}"
		-H 'DNT: 1'
		-H 'Origin: https://app.roll20.net'
		-H 'Referer: https://app.roll20.net/'
		-H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:87.0) Gecko/20100101 Firefox/87.0'
		-H 'x-amz-acl: public-read'
		-H 'X-Requested-With: XMLHttpRequest'
		--data-binary "@$path"
	)
	local res=`"${curlcmd[@]}"`
	if [[ $res =~ Error ]]; then
		>&2 echo "Bad response $res"
		>&2 echo -ne "\033[31m"
		>&2 printf " %q" "${curlcmd[@]}"
		>&2 echo -e "\033[30m"
		exit 1
	else
		>&2 echo -e "\033[32m$res\033[0m"
		>&2 echo -e "\033[34mAWS ok\033[0m"
	fi
}

curl_img_for_geom () {
	local path=$1
	local name=$2
	local dim0=$3
	local dimZ=$(( dim0 < SRC_DIM ? dim0 : SRC_DIM ))
	fail_if_blank $dimZ dimZ
	local geom="${dimZ}x${dimZ}"
	convert "$path" -resize "$geom" "$name"
	local s3url=`curl_img_to_roll20 "$name"`
	[[ -z "$s3url" ]] && exit 13
	curl_img_to_aws_s3 "$s3url" "$name"
}

fail_if_blank () {
	if [[ -z $2 ]]; then
		>&2 echo "FAIL: $1 cannot be blank"
		exit 2
	fi
}

##################################################

while getopts "n:f:i:r" opt; do
  case ${opt} in
    n )  NAME=$OPTARG
      ;;
    f )  FOLDER_NAME=$OPTARG
			;;
    i )  FOLDER_ID=$OPTARG
			;;
		r )  RECURSIVE=1
			;;
    \? ) echo "Usage: cmd [-r] [-i folderid] [-f foldername] [-n name] <file>"
      ;;
    : )  echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

function run () {
	[[ -n $NAME ]] || NAME=`basename "$1"` # Name should still end in appropriate file extension
	NAME_EXT=`get_ext "$NAME"`
	FILE_EXT=`get_ext "$1"`
	[[ $NAME_EXT == $FILE_EXT ]] || NAME="$NAME.$NAME_EXT"
	SRC=`readlink -f "$1"`
	echo -e "\033[96m$NAME\033[0m"
	read WIDTH HEIGHT < <(identify -format "%w"$'\t'"%h" "$SRC")
	fail_if_blank SRC $SRC
	fail_if_blank NAME $NAME
	fail_if_blank WIDTH $WIDTH
	fail_if_blank HEIGHT $HEIGHT
	SRC_DIM=$(( HEIGHT > WIDTH ? HEIGHT : WIDTH )) # Max dimension of input file
	fail_if_blank SRC_DIM $SRC_DIM

	curl_img "$SRC"

	if [[ -n $FOLDER_ID ]]; then
		if TRUEORPHANS=1 >/dev/null ./list.sh; then
			echo List OK
			./copy_to_library.sh $FOLDER_ID "$FOLDER_NAME" $IMAGE_ID
		else
			>&2 echo FAIL list
			exit 56
		fi
	fi
}

if (($RECURSIVE)); then
	>&2 echo -e "\033[36mRecursive $1...\033[0m"
	find "$1" ! -type d | while read f; do
		MIME=`mimetype --brief --dereference "$f"`
		if [[ $MIME =~ ^image/ ]]; then
			run "$f"
		fi
	done
else
	run "$1"
fi
