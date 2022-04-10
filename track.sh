#!/bin/bash
# regexp="^([0-9]+) -.*$"
# # If the name of the file is <number> - <title>.mp3 then set the number to the track number
# for file in ./export/done/*.mp3; do
#     # Get the base filename of the file
#     title="$(basename "${file}" .mp3)"
#     echo "Title: ${title}"
    
#     if [[ $title =~ $regexp ]]; then
#         echo "Changeing track to: ${BASH_REMATCH[1]}"
#         number="${BASH_REMATCH[1]}" 
#         ffmpeg -y -hide_banner -loglevel warning -i "${file}" -c copy -id3v2_version 3 -metadata track="${number}" "export/done/${title%.*}.mp3"
#     else
#         echo "No track ID found"
#     fi
# done
while getopts 'a:r:c:h t p o:' flag; do
  case "${flag}" in
    a) album="${OPTARG}" ;;
    r) regex="${OPTARG}" ;;
    c) albumCover="${OPTARG}" ;;
    t) clean='true' ;;
    p) playlist='true' ;;
    o) output="${OPTARG}" ;;
    h) print_usage; exit 0 ;;
    *) print_usage
       exit 1 ;;
  esac
done

mkdir -p export/${output}/temp

  regexp="^([0-9]+) -.*$"

  for file in ./export/${output}/*.mp3; do
      # Get the base filename of the file
      title="$(basename "${file}" .mp3)"
      echo "Title: ${title}"
      
      if [[ $title =~ $regexp ]]; then
          echo "Changeing track to: ${BASH_REMATCH[1]}"
          number="${BASH_REMATCH[1]}" 
                   ffmpeg -y -hide_banner -loglevel warning -i "${file}" -map 0 -c:a copy -c:s copy -c copy -id3v2_version 3 -metadata track="${number}" "export/${output}/temp/${title%.*}.mp3"
      else
          echo "No track ID found"
      fi
  done

# move the files from the temp folder to the export/${output}/ folder and delete the temp folder
mv export/${output}/temp/* export/${output}/
rm -rf export/${output}/temp
