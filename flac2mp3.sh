#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage:"
  echo "$0 [source dir] [destination dir]"
  exit 1
fi

SOURCE_DIR=$1
DESTINATION_DIR=$2

FLAC_QUANT=0
FLAC_FIND=("$(find $SOURCE_DIR -iname "*.flac")")

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

for (( i=1; i<=$FLAC_QUANT; i++ ))
do
#	echo "${FLAC_FILES[$i]} -> $DESTINATION_DIR/${MP3_FILES[$i]:1}" 
	ffmpeg -i "${FLAC_FILES[$i]}" -ab 320k -map_metadata 0 -id3v2_version 3 "$DESTINATION_DIR/${MP3_FILES[$i]:1}"
done


