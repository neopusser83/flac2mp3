#!/bin/bash

if [ $# -ne 3 ]; then
  echo "Usage:"
  echo "$0 [source dir] [destination dir] [variable bitrate]"
  exit 1
fi

PIDD=$$
SOURCE_DIR=$(realpath "$1")
DESTINATION_DIR=$(realpath "$2")

LAME_VARIABLE_BITRATE=$3

FLAC_QUANT=0
FLAC_FIND=$(find "$SOURCE_DIR" -iname "*.flac")

if [[ -n "$FLAC_FIND" ]]; then

	declare -a FLAC_FILES
	
	while IFS= read -r line; do
		FLAC_FILES+=("$line")
	done <<< "$FLAC_FIND"

	declare -a MP3_DEST
	for(( i=0; i<${#FLAC_FILES[@]}; i++ )); do
		MP3_DEST[i]=$DESTINATION_DIR$(dirname "${FLAC_FILES[i]}" | sed -e s#"$SOURCE_DIR"##g)'/'$(basename "${FLAC_FILES[i]}" .flac).mp3		
	done
	
	mkdir -p "$DESTINATION_DIR"
	rsync -av --exclude='*.flac' "$SOURCE_DIR/" "$2"
	
	for(( i=0; i<${#FLAC_FILES[@]}; i++ )); do
		
		ARTIST=$(metaflac "${FLAC_FILES[i]}" --show-tag=ARTIST | sed s/.*=//g | head -n 1)
		TITLE=$(metaflac "${FLAC_FILES[i]}" --show-tag=TITLE | sed s/.*=//g)
		ALBUM=$(metaflac "${FLAC_FILES[i]}" --show-tag=ALBUM | sed s/.*=//g)
		GENRE=$(metaflac "${FLAC_FILES[i]}" --show-tag=GENRE | sed s/.*=//g)
		TRACKNUMBER=$(metaflac "${FLAC_FILES[i]}" --show-tag=TRACKNUMBER | sed s/.*=//g)
		DATE=$(metaflac "${FLAC_FILES[i]}" --show-tag=DATE | sed s/.*=//g)
		DISCNUMBER=$(metaflac "${FLAC_FILES[i]}" --show-tag=DISCNUMBER | sed s/.*=//g)
		LYRICS=$(metaflac "${FLAC_FILES[i]}" --show-tag=LYRICS | sed s/.*=//g)
		ALBUMARTIST=$(metaflac "${FLAC_FILES[i]}" --show-tag=ALBUMARTIST | sed s/.*=//g)

		COVER_ART=.cover_"$PIDD"_tmp.png
		LYRICS_FILE=.lyrics_"$PIDD"_tmp.txt

		metaflac --export-picture-to="$COVER_ART" "${FLAC_FILES[i]}" > /dev/null
		echo "$LYRICS" > "$LYRICS_FILE"
		
		flac -c -d -s "${FLAC_FILES[i]}" | lame -V$LAME_VARIABLE_BITRATE - "${MP3_DEST[i]}"
		
		eyeD3 --to-v2.4 --remove-all "${MP3_DEST[i]}" > /dev/null
		eyeD3 --remove-all-images "${MP3_DEST[i]}" > /dev/null
		eyeD3 --artist "$ARTIST" "${MP3_DEST[i]}" > /dev/null
		eyeD3 --album "$ALBUM" "${MP3_DEST[i]}" > /dev/null
		eyeD3 --album-artist "$ALBUMARTIST" "${MP3_DEST[i]}" > /dev/null
		eyeD3 --title "$TITLE" "${MP3_DEST[i]}" > /dev/null
		eyeD3 --genre "$GENRE" "${MP3_DEST[i]}"  > /dev/null
		eyeD3 --track="$TRACKNUMBER" "${MP3_DEST[i]}" > /dev/null
		eyeD3 --release-date "$DATE" "${MP3_DEST[i]}" > /dev/null
		eyeD3 --disc-num "$DISCNUMBER" "${MP3_DEST[i]}" > /dev/null

		if [[ -e "$COVER_ART" ]]; then
			eyeD3 --add-image "$COVER_ART:FRONT_COVER" "${MP3_DEST[i]}" > /dev/null
		fi

		if [[ -n "$LYRICS" ]]; then
			eyeD3 --add-lyrics "$LYRICS_FILE" "${MP3_DEST[i]}" > /dev/null
		fi

		rm -f "$COVER_ART"
		rm -f "$LYRICS_FILE"

		echo "${FLAC_FILES[i]} -> ${MP3_DEST[i]}" >> log

	done

	printf "\n\n\n"
	echo -e "\033[0;32mDone!"
	let "FLAC_QUANT++"

	echo -e "\033[0;33m${#FLAC_FILES[@]} flac files converted"
	echo -e "\033[0mPlease check the log file for more details"

else
	rsync -av --exclude='*.flac' "$SOURCE_DIR/" "$2"
	echo "No flac files found."
fi
