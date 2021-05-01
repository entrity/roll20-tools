# Roll20 tools
These are command-line tools for interacting with a roll20.net account.

Roll20 is a virtual tabletop for running games like Dungeons & Dragons.

## Upload files, add to a folder
```bash
# Upload files
./upload-image.sh dir1/1a.jpg
./upload-image.sh dir2/2a.jpg
./upload-image.sh dir2/2b.jpg
./upload-image.sh dir2/2c.jpg
# Load urls into database (and print to stdout)
./list.sh
# Copy select images to a Roll20 folder
sqlite3 map.db 'select id from map where path like "dir2/%"' | while read ID; do
	KEYWORDS=mykeyword ./copy_to_library.sh $FOLDERID $FOLDERNAME $ID
done
```

## Misc
```bash
./login.sh # Login and set cookies in `cookies.txt`
./folders.sh # List contents of root, including folders
./quota.sh # Show how much space you have used and can use
./delete.sh # Delete an image file
```

## Images
aHR0cHM6Ly9kcml2ZS5nb29nbGUuY29tL2RyaXZlL3UvMC9mb2xkZXJzLzBCLUNxeWZLcDVrWmtlVGd5VkZnMmVVVTJjVzg=
aHR0cHM6Ly93d3cuZHJvcGJveC5jb20vc2gvZW8xM3RkdXh0eGhsY2trL0FBQzd6WUYzdHU4cWJyYlg4WkpmaXpRaWE=
aHR0cDovL3B5bWFwcGVyLmNvbS90aWxlLWRvd25sb2Fkcy8=
