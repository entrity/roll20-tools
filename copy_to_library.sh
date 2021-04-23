. shared.sh

ID=${1:-242690457}
NAME=${2:-mephit_steam.png}

docurl 'https://app.roll20.net/image_library/copy_asset_to_library/' \
-d 'type=item' -d "id=$ID" \
-d "foldername=cave" -d "folderid=-MYy0iEe1Ls8qHYje_45" \
-d 'url=https%3A%2F%2Fs3.amazonaws.com%2Ffiles.d20.io%2Fimages' \
-d "name=$NAME" -d "keywords="

# # --data-raw '
# type=item&
# id=242690457&
# name=mephit_steam.png&
# foldername=cave&
# folderid=-MYy0iEe1Ls8qHYje_45&
# keywords='

# type=item
# id=242696169
# name=4x4_Steps.png
# url=https://s3.amazonaws.com/files.d20.io/images/217607183/9byhOUl8WV9DJafyfEbaxw/thumb.png?1619169444
# newid=-MYy3fctEciBEN_mEhdh
# foldername=cave
# folderid=-MYy0iEe1Ls8qHYje_45
# keywords

# # curl 'https://app.roll20.net/image_library/copy_asset_to_library/' \
# # -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:87.0) Gecko/20100101 Firefox/87.0' \
# # -H 'Accept: */*' \
# # -H 'Accept-Language: en-US,en;q=0.5' --compressed \
# # -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
# # -H 'X-Requested-With: XMLHttpRequest' \
# # -H 'Origin: https://app.roll20.net' \
# # -H 'DNT: 1' \
# # -H 'Connection: keep-alive' \
# # -H 'Referer: https://app.roll20.net/editor/' \
# -H 'Cookie: __cfduid=d784d7305bd5cd53d45e59ef61fc80ff01619154806; rack.session=1478b72e25b16cb4b11ed870a6f47d682c87b9fc44e9139733d0c872e92e6ac5; _gcl_au=1.1.792900364.1619154811; gdpr_accepts_cookies=true; roll20tempauth=1; __stripe_mid=1f35076f-9e29-45bc-9120-ea1713c3acc6c59b1e; __stripe_mid=c3a85bd1-f237-4a36-b0c3-037e18498ca9188540' \
# -H 'TE: Trailers' --data-raw 'type=item&id=242690457&name=mephit_steam.png&url=https%3A%2F%2Fs3.amazonaws.com%2Ffiles.d20.io%2Fimages%2F217601500%2FUNd0-RmF83Rs6nPXb0ewRA%2Fthumb.png%3F1619165359&newid=-MYy0mRMXu5ByZTtTpZ5&foldername=cave&folderid=-MYy0iEe1Ls8qHYje_45&keywords='
