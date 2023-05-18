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

