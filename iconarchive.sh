#!/bin/bash

#set -x  # echo on

# Usage:
#  $ "./iconarchive.sh" -u="http://www.iconarchive.com/show/noir-social-media-icons-by-uiconstock/github-icon.html" -o="./img/icons" -s="16,48,128"
#  $ "./iconarchive.sh" --url="http://www.iconarchive.com/show/social-stamps-icons-by-designbolts/Github-icon.html" --output="./img/icons" --size="16,48,128"

url="http://www.iconarchive.com/show/socialmedia-icons-by-uiconstock/Github-icon.html"
output="."
size=""

for i in "$@"; do
	case $i in
		-u=*|--url=*)
			url="${i#*=}"
			shift # past argument=value
			;;
		-o=*|--output=*)
			output="${i#*=}"
			shift # past argument=value
			;;
		-s=*|--size=*)
			size="${i#*=}"
			shift # past argument=value
			;;
		*)
			# unknown option
			;;
	esac
done

if [ -n "$size" ]; then
	IFS=',' read -r -a sz_array <<< "$size"
fi

page="`wget -qO- $url`"

show=$(echo "$url" | grep -P -o '(?<=http:\/\/www\.iconarchive\.com\/show\/)[\w-]+(?=\/[\w-]+\.html)')
artist=$(echo "$show" | grep -P -o '(?<=-icons-by-)[\w-]+')
iconset=$(echo "$show" | grep -P -o '[\w-]+(?=-icons-by-)')

filename="${url##*/}"
name=$(echo $filename | cut -f 1 -d '.')

matches=$(echo "$page" | grep -P -o 'http:\/\/icons\.iconarchive\.com\/icons\/'$artist'\/'$iconset'\/\d+\/'$name'\.png')

echo "$matches" | sort -V -u | while read line ; do

	if [ -n "$size" ]; then
		icon_size=$(echo "$line" | grep -P -o '(?<=http:\/\/icons\.iconarchive\.com\/icons\/'$artist'\/'$iconset'\/)\d+(?=\/'$name'\.png)')
		is_skip=true
		for element in "${sz_array[@]}"; do
			if [ "$element" = "$icon_size" ]; then
				is_skip=false
			fi
		done
		if [ "$is_skip" = true ] ; then
			continue
		fi
	fi

	path=$(echo $line | sed 's/https\?:\/\///')
	dir=$(dirname "${path}")
	wget --quiet "http://$path" -P "$output/$dir/"

	if [ ! -f "$output/$path" ]; then
		echo "File does not exist!"
	else
		echo "$output/$path"
	fi
done

