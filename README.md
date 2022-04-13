# yt-ag

YouTube-Album Generator

This script allows the user to download YouTube videos and play lists as either individual songs or albums. This script uses yt-dlp as the main backend for downloading the songs. Furthermore allows you to effortlessly customize the meta tags so the songs don't appear broken in your mp3 player of choice!

## Requires 
* ffmpeg
* yt-dlp
* Windows Subsystem for Linux + Linux distro (Windows Only)

# Usage and Options

On Linux:
```bash
./yt-ag [options] <YouTube URL>
```

On Windows:
```bash
wsl ./yt-ag [options] <YouTube URL>
```

| Option 	| Arguments           	| Notes                                                                                                                                                                                                                                                      	|
|--------	|---------------------	|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| -a     	| \<album name>       	| Sets the album name of the MP3 files                                                                                                                                                                                                                       	|
| -c     	| \<cover image>      	| Sets the album cover image, <br>if left empty it will default to the imbedded image.                                                                                                                                                                        	|
| -o     	| \<output directory> 	| If left empty it defaults to "Music" under the exports folder.<br>All exports are under the exports folder.<br>Note that if left as "." it will be set as the same as the album, this requires the use of `-a`.                                                                                                                                                	|
| -t     	| \<regex>            	| If set it will run a regex on the filename of the song and assigns that as the title of the song. <br>This option requires the use of ONE segment `()` as that is what will be used as the title.<br>Note that it can be required to escape the first `(`  	|
| -m     	| \<musician>         	| The name of the musician. Default is the creator of the video or <br>if it has a song attached to it in YouTube, the artist named there will be used. <br>Use '; ' or '/' to separate multiple names.                                                      	|
| -p     	|                     	| Is a playlist. This will reformat the filename to include the index in the playlist; `# - Title.mp3`                                                                                                                                                       	|
| -s     	|                     	| Is chapters (Split). If set, this will handle each chapter as individual songs, <br>it will also automatically reformat the filename to the same as the playlist option.                                                                                   	|

## Chapter Showcase
Command:
```bash
wsl ./yt-ag.sh -a "Rusty Brass" -o "." -m "Salted" -p -s https://www.youtube.com/watch?v=u6TQh231Unc
```
https://user-images.githubusercontent.com/43708321/163260850-13c3cf60-c449-4dd4-a78a-1ddfcee67e6a.mp4

## Album and Title Showcase
Command:
```bash
wsl ./yt-ag.sh -c ./The_War_to_End_All_Wars_Sabaton.jpg -a "The War to End All Wars" -o "." -t "^[0-9]+ - SABATON - (.*)\(.*$" -p https://www.youtube.com/playlist?list=PLA_zjX3swAf438D0GWjbh81cejxPwnmeR
```


https://user-images.githubusercontent.com/43708321/163268502-c0733a0c-57d7-4f22-94c8-20e87d7c50a8.mp4

