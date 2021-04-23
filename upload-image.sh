# Overview
# reqimage to get :code
# for each in mini, thumb, med, max, original:
#   POST name, type, size to https://app.roll20.net/image_library/s3putsign/:code to get :s3url
#   PUT image to aws s3 using :s3url

# Load shared vars and functions
. shared.sh

curl_img () {
	local fpath=$1
	local ext=${fpath##*.}
	# Reqimage
	local code=`curl_reqimage "$fpath"`
	echo "code: $code"
	# Send resized images
	curl_img_for_geom "$fpath" "mini.$ext"  16x16 || exit 5
	curl_img_for_geom "$fpath" "thumb.$ext" 64x64 || exit 5
	curl_img_for_geom "$fpath" "med.$ext"   256x256 || exit 5
	curl_img_for_geom "$fpath" "max.$ext"   512x512 || exit 5
	# Send original image
	local s3url=`curl_img_to_roll20 "$fpath" "$code"`
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
	local path=$1
	local code=$2
	local size=`stat --printf=%s "$path"`
	local mime=`file --mime-type "$path" | cut -d' ' -f2`
	local name=`basename "$path"`
	docurl "https://app.roll20.net/image_library/s3putsign/$code" \
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
	local geom=$3
	convert "$path" -resize "$geom" "$name"
	local s3url=`curl_img_to_roll20 "$name" "$code"`
	[[ -z "$s3url" ]] && exit 13
	curl_img_to_aws_s3 "$s3url" "$name"
}

##################################################

NAME="${2:-`basename "$1"`}" # Name should still end in appropriate file extension
curl_img "$1"
