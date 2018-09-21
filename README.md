# MKV Cutpoint Marker
AutoHotkey script with GUI to assist video file cutting

This script was created to easily create the cutpoints for MKVToolNix while visually
checking for (for example) paddings or commercials in a video file.

I created this script to make the workflow of removing ads from TV-recordings easier.
I also found it useful when trimming old VHS tapes that I transferred to computer.

The usage is based on the syntax used by mkvmerge -tool, using the timestamp based splitting
(option --split parts:start1-end1,+start2-end2). The advantage of mkvtoolnix (over any other
tool?) is the support for DVB Subtitles which are preserved and trimmed properly.

The script creates a GUI window that waits for a file to be dragged onto it.
It then gives the opportunity to open VLC to visually evaluate the cutpoints.
NOTE: the accuracy of the cutpoints is 1 sec, which is usually enough, as keyframes won't
allow subsecond accuracy, anyway. In fact, mkvmerge does not obay the cutpoints accurately.
It continues to the next keyframe, so the cutting result is very clean.

VLC uses the http-interface, cUrl is used to get the status.xml file from VLC.

The script does not ask for a target filename, for simplicity. It will just create a
file originalfilename_mkvcm.mkv in the same folder as the source.

Requirements:
* AutoHotkey (version 1.1.29+)
* Windows 10 (NOTE: if you want to create self-contained .exe (with "Convert .ahk to .exe" -tool, 32-bit .exe included here in the repository) you need to select 32-/64-bit version according to your OS. 32-bit version works with both OS-versions)
* cUrl, portable version, the "curl" folder should be in the same directory as this script. Note: Windows 10 version 17063 or later has curl.exe in System32 by default, for older versions there are builds available.
* VLC, portable version, the "vlc" folder should be in the same directory as this script. Version 4.0-development or later recommended.
* MKVToolNix, portable version, the "mkvtoolnix" folder should be in the same directory as this script. Version 25.0.0 or later recommended.
* Full read-write rights to 1) the folder where this script is located and 2) the source/target folder.

Recommended:
* Intel HD driver hotkeys disabled, as they are the same as long jumps in VLC (Ctrl-Alt-Right/Left). This is the fastest way to navigate large files.

AutoHotkey can be downloaded at: https://www.autohotkey.com/download/ 

Portable version of MKVToolNix can be downloaded at: https://mkvtoolnix.download/downloads.html 

Portable nightly version of VLC can be downloaded at: https://nightlies.videolan.org/ 

Portable version of cUrl can be downloaded at: https://curl.haxx.se/download.html 
