#!/bin/bash

# MP3 quality
LAME_VARIABLE_BITRATE=4
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

  ARTIST=$(metaflac "${FLAC_FILES[$i]}" --show-tag=ARTIST | sed s/.*=//g)
  TITLE=$(metaflac "${FLAC_FILES[$i]}" --show-tag=TITLE | sed s/.*=//g)
  ALBUM=$(metaflac "${FLAC_FILES[$i]}" --show-tag=ALBUM | sed s/.*=//g)
  GENRE=$(metaflac "${FLAC_FILES[$i]}" --show-tag=GENRE | sed s/.*=//g)
  TRACKNUMBER=$(metaflac "${FLAC_FILES[$i]}" --show-tag=TRACKNUMBER | sed s/.*=//g)
  DATE=$(metaflac "${FLAC_FILES[$i]}" --show-tag=DATE | sed s/.*=//g)

  flac -c -d -s "${FLAC_FILES[$i]}" | lame -V$LAME_VARIABLE_BITRATE --add-id3v2 --pad-id3v2 --ignore-tag-errors \
    --ta "$ARTIST" --tt "$TITLE" --tl "$ALBUM"  --tg "${GENRE:-12}" \
    --tn "${TRACKNUMBER:-0}" --ty "$DATE" - "$DESTINATION_DIR/${MP3_FILES[$i]}"

#	ffmpeg -i "${FLAC_FILES[$i]}" -ab 320k -map_metadata 0 -id3v2_version "$ID3V2" "$DESTINATION_DIR/${MP3_FILES[$i]}" -y


###
	else

###

 ARTIST=$(metaflac "${FLAC_FILES[$i]}" --show-tag=ARTIST | sed s/.*=//g)
  TITLE=$(metaflac "${FLAC_FILES[$i]}" --show-tag=TITLE | sed s/.*=//g)
  ALBUM=$(metaflac "${FLAC_FILES[$i]}" --show-tag=ALBUM | sed s/.*=//g)
  GENRE=$(metaflac "${FLAC_FILES[$i]}" --show-tag=GENRE | sed s/.*=//g)
  TRACKNUMBER=$(metaflac "${FLAC_FILES[$i]}" --show-tag=TRACKNUMBER | sed s/.*=//g)
  DATE=$(metaflac "${FLAC_FILES[$i]}" --show-tag=DATE | sed s/.*=//g)

  flac -c -d -s "${FLAC_FILES[$i]}" | lame -V$LAME_VARIABLE_BITRATE --add-id3v2 --pad-id3v2 --ignore-tag-errors \
    --ta "$ARTIST" --tt "$TITLE" --tl "$ALBUM"  --tg "${GENRE:-12}" \
    --tn "${TRACKNUMBER:-0}" --ty "$DATE" - "$DESTINATION_DIR/${MP3_FILES[$i]:1}"


#	ffmpeg -i "${FLAC_FILES[$i]}" -ab 320k -map_metadata 0 -id3v2_version "$ID3V2" "$DESTINATION_DIR/${MP3_FILES[$i]:1}" -y
###
	fi

	if [[ $? -ne 0 ]]; then
	let "ERROR_FILES++"
		if [[ i -eq 0 ]] then


			echo "ERROR!!! ${FLAC_FILES[$i]} -> $DESTINATION_DIR/${MP3_FILES[$i]}" >> log
                        echo "${FLAC_FILES[$i]} -> $DESTINATION_DIR/${MP3_FILES[$i]}" >> ERRORS.txt


		else
			echo "ERROR!!! ${FLAC_FILES[$i]} -> $DESTINATION_DIR/${MP3_FILES[$i]:1}" >> log
                        echo "${FLAC_FILES[$i]} -> $DESTINATION_DIR/${MP3_FILES[$i]:1}" >> ERRORS.txt

		fi

		else
	let "CONVERTED_FILES++"

		if [[ i -eq 0 ]] then
	
			echo "${FLAC_FILES[$i]} -> $DESTINATION_DIR/${MP3_FILES[$i]}" >> log 
		else
			echo "${FLAC_FILES[$i]} -> $DESTINATION_DIR/${MP3_FILES[$i]:1}" >> log 
		fi
	fi

done
printf "\n\n\n"
echo -e "\033[0;32mDone!"
let "FLAC_QUANT++"

echo -e "\033[0;33m$CONVERTED_FILES flac files converted, $ERROR_FILES files with error, total files: $FLAC_QUANT"
echo -e "\033[0mPlease check the log file for more details"
