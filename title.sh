#!/bin/bash

# This is a good testing ground for the regex

titleRegex="(.*)"
output='Music'

print_usage() {
  echo "Usage: ./yt-ag.sh [OPTIONS]"
  echo "Options:"
  echo "  -o    <output>        Output directory, default is 'Music' 
                        Using '.' will set it to the album name"
  echo "  -t    <regex>         Regex to match title, default: '(.*)', requires the use of a singular (). 
                        Sometimes, namely if the first part of the regex is a special char then they need to be escaped with '\\'. 
                        Example: wsl ./title.sh -t '^\(\w{3}\)' -o 'Happy Face', This gets the first 3 chars from the title.
                        Example: wsl ./title.sh -t '^[0-9]+ - (.*)$' -o 'TheWartoEndAllWars', This gets the title from after -p flag has been used. 
                        Note that escaping chars are not used in the second example."
}

while getopts 't:h o:' flag; do
  case "${flag}" in
    t) titleRegex="${OPTARG}" ;;
    o) output="${OPTARG}" ;;
    h) print_usage; exit 0 ;;
    *) print_usage
       exit 1 ;;
  esac
done
mkdir -p "./export/${output}/temp"

echo "cleatitleRegex: ${titleRegex}"

# # If the name of the file is <number> - <title>.mp3 then set the number to the track number
for file in ./export/"${output}"/*.mp3; do
    # Get the base filename of the file
    title="$(basename "${file}" .mp3)"

    [[ $title =~ $titleRegex  ]] && title2=${BASH_REMATCH[1]} || title2=${title}
    echo "(METADATA) ORIGINAL: ${title} :: To: ${title2}"
    ffmpeg -y -hide_banner -loglevel warning -i "${file}" -map 0 -c:a copy -c:s copy -c copy -id3v2_version 3 -metadata title="${title2}" "export/${output}/temp/${title%.*}.mp3"
done

  # move the files from the temp folder to the export/${output}/ folder and delete the temp folder
  mv export/"${output}"/temp/* export/"${output}"/