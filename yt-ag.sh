#!/bin/bash

################################################################################
# yt-ag.sh - Youtube Album Generator                                           #
# "Fuck spotify, all my homies hate spotify"                                   #
#                                                                              #
# Requires:                                                                    #
#   - ffmpeg                                                                   #
#   - yt-dlp                                                                   #
#   - wsl (windows only)                                                       #
#                                                                              #
################################################################################

album=''
titleRegex=''
albumCover=''
playlist=''
artists=''
output='Music'

print_usage() {
  echo "Usage: ./yt-ag.sh [OPTIONS] <URL>"
  echo "Options:"
  echo "  -a    <album name>    Album name"
  echo "  -c    <cover image>   Cover image"
  echo "  -o    <output>        Output directory, default is 'Music' 
                        Using '.' will set it to the album name
                        Note that all exports are placed in the 'export' folder"
  echo "  -p                    Is a playlist"
  echo "  -h                    Print this help"
  echo "  -t    <regex>         Regex to match title, default: '(.*)', requires the use of a singular (). 
                        Sometimes, namely if the first part of the regex is a special char then they need to be escaped with '\\'. 
                        Example: wsl ./title.sh -t '^\(\w{3}\)' -o 'Happy Face', This gets the first 3 chars from the title.
                        Example: wsl ./title.sh -t '^[0-9]+ - (.*)$' -o 'TheWartoEndAllWars', This gets the title from after -p flag has been used. 
                        Note that escaping chars are not used in the second example."
  echo "  -m    <musician>      The name of the musician, default is video creator. Use '; ' or '/' to seperate multiple names."
  echo ""
  echo "Example:"
  echo '  PS> wsl ./yt-ag.sh -c ./The_War_to_End_All_Wars_Sabaton.jpg -a "The War to End All Wars" -o "." -t "^[0-9]+ - SABATON - (.*)\(.*$" -p https://www.youtube.com/playlist?list=PLA_zjX3swAf438D0GWjbh81cejxPwnmeR'
}

while getopts 'a:t:c:hpo:m:' flag; do
  case "${flag}" in
    a) album="${OPTARG}" ;;
    t) titleRegex="${OPTARG}" ;;
    c) albumCover="${OPTARG}" ;;
    p) playlist='true' ;;
    o) output="${OPTARG}" ;;
    m) artists="${OPTARG}" ;;
    h) print_usage; exit 0 ;;
    *) print_usage
       exit 1 ;;
  esac
done

[[ $output == "." ]] && output=$album && echo "Set the output to the album :: ${output}" 

echo "SETTING UP..."
mkdir -p "./export/${output}"

echo "DOWNLOADING..."
# This will rip all the music from the youtube URL
#yt-dlp --extract-audio --audio-format mp3 --audio-quality 0 --add-metadata --output "%(title)s.%(ext)s" $1
yt-dlp --quiet --extract-audio --audio-format mp3 --audio-quality 0 --embed-thumbnail --parse-metadata "description:(?s)(?P<meta_comment>.+) title:(%(title)s)" --add-metadata --output "./export/${output}/%(playlist_index|)s%(playlist_index& - |)s%(title)s.%(ext)s" ${@: -1}


# This is where we fine tune the metadata of the musics using ffmpeg
echo "FINETUNING..."

mkdir -p "./export/${output}/temp"

for file in ./export/"${output}"/*.mp3; do
    # Get the base filename of the file
    title="$(basename "${file}" .mp3)"
    
    # if the album and cover is set
    if [ -n "${album}" ] && [ -n "${albumCover}" ]; then
      echo "(METADATA) ALBUM : COVER :: ${album} : ${albumCover}"
      ffmpeg -hide_banner -loglevel warning -i "${file}" -i "${albumCover}" -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata album="${album}" -metadata:s:v comment="Cover (front)" "export/${output}/temp/${title%.*}.mp3"
      continue
    fi
    
    # if the album is set
    if [ -n "${album}" ]; then
      echo "(METADATA) ALBUM :: ${album}"
      ffmpeg -hide_banner -loglevel warning -i "${file}" -c copy -id3v2_version 3 -metadata album="${album}" "export/${output}/temp/${title%.*}.mp3"
      continue
    fi

    # if the cover is set
    if [ -n "${albumCover}" ]; then
      echo "(METADATA) ALBUMCOVER :: ${albumCover}"
      ffmpeg -hide_banner -loglevel warning -i "${file}" -i "${albumCover}" -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata:s:v comment="Cover (front)" "export/${output}/temp/${title%.*}.mp3"
      continue
    fi

    ffmpeg -hide_banner -loglevel warning -i "${file}" "export/${output}/temp/${title%.*}.mp3"
done

# move the files from the temp folder to the export/${output}/ folder and delete the temp folder
mv export/"${output}"/temp/* export/"${output}"/

# The following are based on if a flag has been set, the ones above are always done.

if [ -n "${titleRegex}" ]; then
  # # If the name of the file is <number> - <title>.mp3 then set the number to the track number
  for file in ./export/"${output}"/*.mp3; do
    # Get the base filename of the file
    title="$(basename "${file}" .mp3)"

    [[ $title =~ $titleRegex  ]] && title2=${BASH_REMATCH[1]} || title2=${title}
    echo "(METADATA) TITLE: ${title} :: To: ${title2}"
    ffmpeg -y -hide_banner -loglevel warning -i "${file}" -map 0 -c:a copy -c:s copy -c copy -id3v2_version 3 -metadata title="${title2}" "export/${output}/temp/${title%.*}.mp3"
  done

  # move the files from the temp folder to the export/${output}/ folder and delete the temp folder
  mv export/"${output}"/temp/* export/"${output}"/
fi


# # If the name of the file is <number> - <title>.mp3 then set the number to the track number
 if [ -n "${playlist}" ]; then
  regexp="^([0-9]+) -.*$"
  titleRegex="^[0-9]+ - (.{5,20}).*$"
 for file in ./export/"${output}"/*.mp3; do
    # Get the base filename of the file
    title="$(basename "${file}" .mp3)"

    if [[ $title =~ $regexp ]]; then
      number="${BASH_REMATCH[1]}" 
      [[ $title =~ $titleRegex  ]] && title2=${BASH_REMATCH[1]} || title2=${title}
      echo "(METADATA) TRACK: ${title2}... :: Track # to: ${number}"
      ffmpeg -y -hide_banner -loglevel warning -i "${file}" -map 0 -c:a copy -c:s copy -c copy -id3v2_version 3 -metadata track="${number}" "export/${output}/temp/${title%.*}.mp3"
    else
      echo "No track ID found"
    fi
  done

  # move the files from the temp folder to the export/${output}/ folder and delete the temp folder
  mv export/"${output}"/temp/* export/"${output}"/
fi

if [ -n "${artists}" ]; then
  # # If the name of the file is <number> - <title>.mp3 then set the number to the track number
  for file in ./export/"${output}"/*.mp3; do
    # Get the base filename of the file
    title="$(basename "${file}" .mp3)"
    echo "(METADATA) ARTISTS: ${artists}"
    ffmpeg -y -hide_banner -loglevel warning -i "${file}" -map 0 -c:a copy -c:s copy -c copy -id3v2_version 3 -metadata artist="${artists}" "export/${output}/temp/${title%.*}.mp3"
  done

  # move the files from the temp folder to the export/${output}/ folder and delete the temp folder
  mv export/"${output}"/temp/* export/"${output}"/
fi

echo "Cleaning up..."
rm -rf export/"${output}"/temp

echo "Done!"

echo "Location: $(find "$(pwd)"/export/"${output}" -type d)/"


