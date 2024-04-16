#!/bin/bash

shopt -s nullglob
for lib in *.dylib *.so
do
	test -L $lib && continue
	otool -l $lib | grep -q "cmd LC_ID_DYLIB" && install_name_tool -id "@rpath/$lib" $lib
	IFS=$'\n' loaddylib=($(otool -l $lib | grep "cmd LC_LOAD_DYLIB" -A 2 | grep "name /opt/local/" | sed "s/ *name //" | sed -E "s/ \(offset.*\)$//"))
	if [ ${#loaddylib[@]} -gt 0 ]; then
		for (( i=0; i<${#loaddylib[@]}; i++ ))
		do
			install_name_tool -change "${loaddylib[$i]}" "@loader_path/$(basename ${loaddylib[$i]})" "$lib"
		done
	fi
	otool -l $lib | grep "cmd LC_RPATH" -A2 | grep " path /opt/local/lib " && install_name_tool -delete_rpath /opt/local/lib $lib || continue
done
exit 0
