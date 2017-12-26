#!/bin/bash

#set -x  # echo on

# Usage:
#  $ "./iconarchive.sh" -u="http://www.iconarchive.com/show/noir-social-media-icons-by-uiconstock/github-icon.html" -o="./img/icons"
#  $ "./iconarchive.sh" --url="http://www.iconarchive.com/show/social-stamps-icons-by-designbolts/Github-icon.html" --output="./img/icons"

url="http://www.iconarchive.com/show/socialmedia-icons-by-uiconstock/Github-icon.html"
output="."

for i in "$@"
do
case $i in
    -u=*|--url=*)
    url="${i#*=}"
    shift # past argument=value
    ;;
    -o=*|--output=*)
    output="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done

page="`wget -qO- $url`"

show=$(echo "$url" | grep -P -o '(?<=http:\/\/www\.iconarchive\.com\/show\/)[\w-]+(?=\/[\w-]+\.html)')
artist=$(echo "$show" | grep -P -o '(?<=-icons-by-)[\w-]+')
iconset=$(echo "$show" | grep -P -o '[\w-]+(?=-icons-by-)')

filename="${url##*/}"
name=$(echo $filename | cut -f 1 -d '.')

matches=$(echo "$page" | grep -P -o 'http:\/\/icons\.iconarchive\.com\/icons\/'$artist'\/'$iconset'\/\d+\/'$name'\.png')

echo "$matches" | sort -V -u | while read line ; do
    path=$(echo $line | sed 's/https\?:\/\///')
    dir=$(dirname "${path}")
    wget --quiet "http://$path" -P "$output/$dir/"
done
