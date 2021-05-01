if (($#)); then
	sqlite3 map.db "select * from map where id = $1"
else
	sqlite3 map.db 'select * from map'
fi
