#!/bin/bash

shopt -s nullglob
for lib in *.so
do
	otool -l $lib | grep -q "cmd LC_ID_DYLIB" && install_name_tool -id "@rpath/$lib" $lib
	IFS=$'\n' loaddylib=($(otool -l $lib | grep "cmd LC_LOAD_DYLIB" -A 2 | grep "name /opt/local/" | sed "s/ *name //" | sed -E "s/ \(offset.*\)$//"))
	if [ ${#loaddylib[@]} -gt 0 ]; then
		for (( i=0; i<${#loaddylib[@]}; i++ ))
		do
			install_name_tool -change "${loaddylib[$i]}" "@rpath/$(basename ${loaddylib[$i]})" "$lib"
		done
	fi
	install_name_tool -rpath /opt/local/lib @loader_path/../.. $lib
done
exit 0
