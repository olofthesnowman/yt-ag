#!/bin/bash
str="9 - SABATON - The Valley Of Death (Official Lyric Video)"
regex1="([0-9]+)(.+)"
regex="^([0-9]+) -.*$"
if [[ $str =~ $regex ]]; then
    echo "String is '${str}'"
    echo "Track number is: ${BASH_REMATCH[1]}"
else
  echo "no"
fi