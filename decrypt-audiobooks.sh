#!/bin/bash

declare -A activation_bytes
cd /root/tables

shopt -s globstar
AAX_FILES=(/data/**/*.aax)
if [[ "$AAX_FILES" == "/data/**/*.aax" ]]; then
  echo "No AAX files found, exiting."
  exit 1
else
  for aax_file in ${AAX_FILES[*]}; do
    echo "Processing $aax_file"
    m4a_file="${aax_file%%.*}.m4a"
    cover_file="${aax_file%%.*}.png"
    if [ ! -e "$m4a_file" ]; then
      PROBE_RESULT=`ffprobe "$aax_file" 2>&1 | fgrep 'file checksum == '`
      FILE_CHECKSUM=${PROBE_RESULT##* }
      if [[ ! -v activation_bytes[$FILE_CHECKSUM] ]]; then
        if [[ ! -z "${ACTIVATION_BYTES}" ]]; then
          echo "Setting activation bytes from ACTIVATION_BYTES environment variable: ${ACTIVATION_BYTES}"
          activation_bytes[$FILE_CHECKSUM]="$ACTIVATION_BYTES"
        else
          echo "Running RainbowCrack against checksum: $FILE_CHECKSUM"
          RAINBOWCRACK_RESULT=`./rcrack . -h $FILE_CHECKSUM | tail -1`
          if [ -z "$RAINBOWCRACK_RESULT" ]; then
            echo "Error running RainbowCrack, exiting."
            exit 1
          fi
          RETRIEVED_ACTIVATION_BYTES=${RAINBOWCRACK_RESULT##*:}
          echo "Retrieved activation bytes: ${RETRIEVED_ACTIVATION_BYTES}"
          activation_bytes[$FILE_CHECKSUM]="$RETRIEVED_ACTIVATION_BYTES"
        fi
      fi
      echo "Running conversion, outputting to $m4a_file"
      ffmpeg -loglevel panic -y -activation_bytes ${activation_bytes[$FILE_CHECKSUM]} -i "$aax_file" -c:a copy -vn "$m4a_file"
      echo "Adding cover to $m4a_file"
      if [ ! -e "$cover_file" ]; then
        ffmpeg -loglevel panic -y -i "$aax_file" "$cover_file"
      fi
      mp4art -q --add "$cover_file" "$m4a_file"
    else
      echo "Output file $m4a_file already exists, skipping"
    fi
  done
fi
