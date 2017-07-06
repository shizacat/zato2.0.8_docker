#!/bin/bash

PATH_PATCHES=/opt/patches
PATH_BASE=/opt/zato

for filename in ${PATH_PATCHES}/*
do
	if [[ -f $filename ]]; then
		echo "Apply: $filename"
		(
			cd ${PATH_BASE}
			patch -p1 < $filename
		)
	fi
done