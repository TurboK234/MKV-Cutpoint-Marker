# MKV Cutpoint Marker
AutoHotkey script with GUI to assist video file cutting

This script was created to easily create the cutpoints for MKVToolNix while visually
checking for (for example) paddings or commercials in a video file.

The usage is based on the syntax used by mkvmerge-tool, using the timestamp based splitting
(option --split parts:start1-end1,+start2-end2). The advantage of this tool (over any other
tool?) is the support for DVB Subtitles which are preserved.

The script creates a GUI window that waits for a file to be dragged onto it.
It then gives the opportunity to open VLC to visually evaluate the cutpoints.
NOTE: the accuracy of the cutpoints is 1 sec, which is usually enough, as keyframes won't
allow subsecond accuracy, anyway. In fact, mkvmerge does not obay the cutpoints accurately.
It continues to the next keyframe, so the cutting result is very clean.

Portable versions of MKVToolNix and VLC are included and their location should be relative to the script.
The directory options are in the beginning and can be edited if necessary.

Requirements:
* AutoHotkey (version 1.1.29+)
* Windows 10 (NOTE: if you want to create self-contained .exe (with "Convert .ahk to .exe" -tool) you need to select 32-/64-bit version according to your OS)
* cUrl (Windows 10 version 17063 or later has curl.exe in System32 by default, for older versions there are builds available)
* VLC, portable version, the "vlc" folder should be in the same directory as this script. Version 4.0-development or later recommended.
* MKVToolNix, portable version, the "mkvtoolnix" folder should be in the same directory as this script. Version 25.0.0 or later recommended.
* Full read-write rights to 1) the folder where this script is located and 2) the source/target folder.

Recommended:
* Intel HD driver hotkeys disabled, as they are the same as long jumps in VLC (Ctrl-Alt-Right/Left). This is the fastest way to navigate large files.
