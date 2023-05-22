#!/bin/bash

# MP3 quality
LAME_VARIABLE_BITRATE=4.1
# Enable  VBR  (Variable  BitRate)  and specifies the value of VBR
# quality (default = 4). Decimal values  can  be  specified,  like 4.51.
# 0 = highest quality.


if [ $# -ne 2 ]; then
  echo "Usage:"
  echo "$0 [source dir] [destination dir]"
  exit 1
fi

SOURCE_DIR=$1
DESTINATION_DIR=$2

export LC_ALL=en_US.UTF-8

FLAC_QUANT=0
FLAC_FIND=("$(find "$SOURCE_DIR" -iname "*.flac")")

MP3_DEST_="${FLAC_FIND//$SOURCE_DIR}"

MP3_DEST=$(echo $MP3_DEST_ | sed -e "s/.flac/.mp3\n/g")

declare -a FLAC_FILES
declare -a MP3_FILES

while IFS= read -r line; do
    FLAC_FILES+=("$line")
    let "FLAC_QUANT++"
done <<< "$FLAC_FIND"

while IFS= read -r lines; do
    MP3_FILES+=("$lines")
done <<< "$MP3_DEST"

let "FLAC_QUANT--"

#echo ${FLAC_FILES[$FLAC_QUANT]}
#echo $DESTINATION_DIR/${MP3_FILES[$FLAC_QUANT]:1}

mkdir -p $DESTINATION_DIR

rsync -av --exclude='*.flac' "$SOURCE_DIR" "$DESTINATION_DIR"

CONVERTED_FILES=0
ERROR_FILES=0

for (( i=0; i<=$FLAC_QUANT; i++ ))
do
	if [[ i -eq 0 ]]; then

###

  ARTIST=$(metaflac "${FLAC_FILES[$i]}" --show-tag=ARTIST | sed s/.*=//g | head -n 1)
  TITLE=$(metaflac "${FLAC_FILES[$i]}" --show-tag=TITLE | sed s/.*=//g)
  ALBUM=$(metaflac "${FLAC_FILES[$i]}" --show-tag=ALBUM | sed s/.*=//g)
  GENRE=$(metaflac "${FLAC_FILES[$i]}" --show-tag=GENRE | sed s/.*=//g)
  TRACKNUMBER=$(metaflac "${FLAC_FILES[$i]}" --show-tag=TRACKNUMBER | sed s/.*=//g)
  DATE=$(metaflac "${FLAC_FILES[$i]}" --show-tag=DATE | sed s/.*=//g)
  DISCNUMBER=$(metaflac "${FLAC_FILES[$i]}" --show-tag=DISCNUMBER | sed s/.*=//g)
  LYRICS=$(metaflac "${FLAC_FILES[$i]}" --show-tag=LYRICS | sed s/.*=//g)
  ALBUMARTIST=$(metaflac "${FLAC_FILES[$i]}" --show-tag=ALBUMARTIST | sed s/.*=//g)

  COVER_ART=".cover_tmp.png"
  metaflac --export-picture-to="$COVER_ART" "${FLAC_FILES[$i]}" > /dev/null
  
  LYRICS_FILE=".lyrics_tmp"
  echo "$LYRICS" > "$LYRICS_FILE"
  
  flac -c -d -s "${FLAC_FILES[$i]}" | lame -V$LAME_VARIABLE_BITRATE - "$DESTINATION_DIR/${MP3_FILES[$i]}"
  
  eyeD3 --to-v2.4 --remove-all "$DESTINATION_DIR/${MP3_FILES[$i]}" > /dev/null
  eyeD3 --remove-all-images "$DESTINATION_DIR/${MP3_FILES[$i]}" > /dev/null
  eyeD3 --artist "$ARTIST" "$DESTINATION_DIR/${MP3_FILES[$i]}" > /dev/null
  eyeD3 --album "$ALBUM" "$DESTINATION_DIR/${MP3_FILES[$i]}" > /dev/null
  eyeD3 --album-artist "$ALBUMARTIST" "$DESTINATION_DIR/${MP3_FILES[$i]}" > /dev/null
  eyeD3 --title "$TITLE" "$DESTINATION_DIR/${MP3_FILES[$i]}" > /dev/null
  eyeD3 --genre "$GENRE" "$DESTINATION_DIR/${MP3_FILES[$i]}"  > /dev/null
  eyeD3 --track="$TRACKNUMBER" "$DESTINATION_DIR/${MP3_FILES[$i]}" > /dev/null
  eyeD3 --release-date "$DATE" "$DESTINATION_DIR/${MP3_FILES[$i]}" > /dev/null
  eyeD3 --disc-num "$DISCNUMBER" "$DESTINATION_DIR/${MP3_FILES[$i]}" > /dev/null
  eyeD3 --add-image "$COVER_ART:FRONT_COVER" "$DESTINATION_DIR/${MP3_FILES[$i]}" > /dev/null

  if [[ -n "$LYRICS" ]]; then
      eyeD3 --add-lyrics "$LYRICS_FILE" "$DESTINATION_DIR/${MP3_FILES[$i]}" > /dev/null 
  fi

  rm -f "$COVER_ART"
  rm -f "$LYRICS_file"

  echo "${FLAC_FILES[$i]} -> $DESTINATION_DIR/${MP3_FILES[$i]}" >> log

###
	else
###

  ARTIST=$(metaflac "${FLAC_FILES[$i]}" --show-tag=ARTIST | sed s/.*=//g | head -n 1)
  TITLE=$(metaflac "${FLAC_FILES[$i]}" --show-tag=TITLE | sed s/.*=//g)
  ALBUM=$(metaflac "${FLAC_FILES[$i]}" --show-tag=ALBUM | sed s/.*=//g)
  GENRE=$(metaflac "${FLAC_FILES[$i]}" --show-tag=GENRE | sed s/.*=//g)
  TRACKNUMBER=$(metaflac "${FLAC_FILES[$i]}" --show-tag=TRACKNUMBER | sed s/.*=//g)
  DATE=$(metaflac "${FLAC_FILES[$i]}" --show-tag=DATE | sed s/.*=//g)
  DISCNUMBER=$(metaflac "${FLAC_FILES[$i]}" --show-tag=DISCNUMBER | sed s/.*=//g)
  LYRICS=$(metaflac "${FLAC_FILES[$i]}" --show-tag=LYRICS | sed s/.*=//g)
  ALBUMARTIST=$(metaflac "${FLAC_FILES[$i]}" --show-tag=ALBUMARTIST | sed s/.*=//g)

  COVER_ART=".cover_tmp.png"
  metaflac --export-picture-to="$COVER_ART" "${FLAC_FILES[$i]}" > /dev/null
  
  LYRICS_FILE=".lyrics_tmp"
  echo "$LYRICS" > "$LYRICS_FILE"
  
  flac -c -d -s "${FLAC_FILES[$i]}" | lame -V$LAME_VARIABLE_BITRATE - "$DESTINATION_DIR/${MP3_FILES[$i]:1}"
  
  eyeD3 --to-v2.4 --remove-all "$DESTINATION_DIR/${MP3_FILES[$i]:1}" > /dev/null
  eyeD3 --remove-all-images "$DESTINATION_DIR/${MP3_FILES[$i]:1}" > /dev/null
  eyeD3 --artist "$ARTIST" "$DESTINATION_DIR/${MP3_FILES[$i]:1}" > /dev/null
  eyeD3 --album "$ALBUM" "$DESTINATION_DIR/${MP3_FILES[$i]:1}" > /dev/null
  eyeD3 --album-artist "$ALBUMARTIST" "$DESTINATION_DIR/${MP3_FILES[$i]:1}" > /dev/null
  eyeD3 --title "$TITLE" "$DESTINATION_DIR/${MP3_FILES[$i]:1}" > /dev/null
  eyeD3 --genre "$GENRE" "$DESTINATION_DIR/${MP3_FILES[$i]:1}" > /dev/null
  eyeD3 --track="$TRACKNUMBER" "$DESTINATION_DIR/${MP3_FILES[$i]:1}" > /dev/null
  eyeD3 --release-date "$DATE" "$DESTINATION_DIR/${MP3_FILES[$i]:1}" > /dev/null
  eyeD3 --disc-num "$DISCNUMBER" "$DESTINATION_DIR/${MP3_FILES[$i]:1}" > /dev/null
  eyeD3 --add-image "$COVER_ART:FRONT_COVER" "$DESTINATION_DIR/${MP3_FILES[$i]:1}" > /dev/null

  if [[ -n "$LYRICS" ]]; then
      eyeD3 --add-lyrics "$LYRICS_FILE" "$DESTINATION_DIR/${MP3_FILES[$i]:1}"  > /dev/null
  fi

  rm -f "$COVER_ART"
  rm -f "$LYRICS_file"
	
  echo "${FLAC_FILES[$i]} -> $DESTINATION_DIR/${MP3_FILES[$i]:1}" >> log

###

	fi
done

printf "\n\n\n"
echo -e "\033[0;32mDone!"
let "FLAC_QUANT++"

echo -e "\033[0;33m$FLAC_QUANT flac files converted"
echo -e "\033[0mPlease check the log file for more details"
