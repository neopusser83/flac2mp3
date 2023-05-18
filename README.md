# flac2mp3
Copy entire directories recursively, converting flac files to mp3 320kbps, without metadata loss.


## Dependencies
- ffmpeg
- rsync

## Usage
```bash
./flac2mp3 [source dir] [destination dir]
```

## Log support
for more details about the conversion, during script execution check the log file:
```
tail -f log
```

## A couple of things
This script is similar to running "cp -rv source/* dest/" converting the FLAC files to MP3.
Please consider the "source/*" because when using this script, it copies all the contents inside the specified folder, and not the source folder directly.
