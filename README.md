# flac2mp3
Copy entire directories recursively, converting flac files to mp3, "without metadata loss".


## Dependencies
- flac
- lame
- rsync
- eyeD3
```
apt install flac lame rsync eyed3
```

## Usage
```bash
./flac2mp3.sh [source dir] [destination dir] [variable bitrate (quality)]
```

## Log support
for more details about the conversion, during script execution check the log file:
```bash
tail -f log
```

## A couple of things
This script is similar to running "cp -rv source/* dest/" converting the FLAC files to MP3.
Please consider the "source/*" because when using this script, it copies all the contents inside the specified folder, and not the source folder directly.


