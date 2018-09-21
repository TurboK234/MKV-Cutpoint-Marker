; AutoHotkey script with GUI to assist video file cutting

; This script was created to easily create the cutpoints for MKVToolNix while visually checking
; for (for example) paddings or commercials in a video file.

; I created this script to make the workflow of removing ads from TV-recordings easier.
; I also found it useful when trimming old VHS tapes that I transferred to computer.

; The usage is based on the syntax used by mkvmerge -tool, using the timestamp based
; splitting (option --split parts:start1-end1,+start2-end2). The advantage of mkvtoolnix
; (over any other tool?) is the support for DVB Subtitles which are preserved and trimmed properly.

; The script creates a GUI window that waits for a file to be dragged onto it. It then gives
; the opportunity to open VLC to visually evaluate the cutpoints. NOTE: the accuracy of
; the cutpoints is 1 sec, which is usually enough, as keyframes won't allow subsecond
; accuracy, anyway. In fact, mkvmerge does not obay the cutpoints accurately. It continues to
; the next keyframe, so the cutting result is very clean.

; VLC uses the http-interface, cUrl is used to get the status.xml file from VLC.

; The script does not ask for a target filename, for simplicity. It will just create
; a file originalfilename_mkvcm.mkv in the same folder as the source.

; Requirements:

; * AutoHotkey (version 1.1.29+)
; * Windows 10 (NOTE: if you want to create self-contained .exe (with "Convert .ahk to .exe" -tool,
;    32-bit .exe included here in the repository) you need to select 32-/64-bit version according to your OS.
;    32-bit version works with both OS-versions, but VLC, MKVToolNix and cUrl should also be 32-bit (I still
;    use the all-32-bit setup for best portability/compatibility)
; * cUrl, portable version, the "curl" folder should be in the same directory as this script. Note: Windows 10
;    version 17063 or later has curl.exe in System32 by default, for older versions there are builds available.
; * VLC, portable version, the "vlc" folder should be in the same directory as this script. Version 4.0-development
;    or later recommended.
; * MKVToolNix, portable version, the "mkvtoolnix" folder should be in the same directory as this script.
;    version 25.0.0 or later recommended.
; * Full read-write rights to 1) the folder where this script is located and 2) the source/target folder.

; Recommended:

; Intel HD driver hotkeys disabled, as they are the same as long jumps in VLC (Ctrl-Alt-Right/Left). This is the fastest way to navigate large files.



; -----
; FOLDER SETTINGS, EDIT ONLY IF NEEDED / NECESSARY (!)
dir_mkvcm := A_ScriptDir
dir_vlc := dir_mkvcm "\vlc"
dir_mkvtoolnix := dir_mkvcm "\mkvtoolnix"
dir_curl := dir_mkvcm "\curl"
dir_target := "dir_source"							; Note: the target is (by default) only set after the source is selected. Use dir_source or empty for normal action. Custom folder needs to be written within "" and with no trailing backslash.

; -----
; GENERAL SETUP, DON'T EDIT, COMMENTS PROVIDED FOR CLARIFICATION.
SendMode, Input                         ; Recommended for new scripts due to its superior speed and reliability.
#NoEnv                                  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance FORCE                   ; There can be only one instance of this script running.
#NoTrayIcon                             ; This script should behave as much as a normal GUI program, no tray needed.
SetWorkingDir, %A_ScriptDir%            ; Ensures a consistent starting directory.
StringCaseSense, On                     ; Turns on case-sensitivity.
FileEncoding, UTF-8	                    ; The default encoding is UTF-8, since it seems to be most compatible.
EnvGet, Env_Path, Path

; -----
; THE ACTUAL ENGINE STARTS HERE, EDIT ONLY IF YOU ARE SURE.

Gui, Font, s8, Courier New
Gui, Add, Text,, Drag and drop a video file on this window.
Gui, Add, Text,, Dropped file (with path):
Gui, Add, Edit, w480 r2 vFilepathedit c1212F2 ReadOnly,
Gui, Add, Button,, Start VLC
Gui, Add, Text,, Go to the cutpoints (in VLC) and create timestamps.
Gui, Add, Text,, Mark each section to be _included_ with hotkeys or buttons below.
Gui, Add, Text,, *** Press "i" in the beginning of each section and `n*** Press "o" in the end of each section.
Gui, Add, Button,, Mark section start
Gui, Add, Button,, Mark section end
Gui, Add, Text,, Created Timestamp String for MKVToolNix:
Gui, Add, Edit, w480 r3 vTimestampstring_edit c1212F2,
Gui, Add, Button,, Copy timestamp string to Clipboard
Gui, Add, Text, w480, Click the button below for quick cut:
Gui, Add, Button,, Start mkvmerge with the Final Timestamp String
Gui, Add, Text, w480, (The target file (filename_mkvcm.mkv) is created in the same directory as the source)
Gui, Show, , MKVToolNix Cutpoint Marker

; Create the hotkeys for marking the timestamps (the timestamp parser substrings are located in the end of the script).
Hotkey, IfWinActive, MKVToolNix Cutpoint Marker
Hotkey, i, parse_timestamp_start
Hotkey, IfWinActive, MKVToolNix Cutpoint Marker
Hotkey, o, parse_timestamp_end

; Some variables to make startup consistent.
empty =
vlc_window_current = notgoingtobeactive

return

GuiDropFiles:
 Loop, Parse, A_GuiEvent, `n
 {
	firstfile = %A_LoopField%
	Break
 }
 filepath = %firstfile%
 SplitPath, filepath, filename, filefolder, fileextension, filebody, filedrive

 GuiControl,, Filepathedit, %filepath%
 start_applied = 0
 GuiControl,, Timestampstring_edit, %empty%
 return

ButtonStartVLC:
 If (vlc_window_current <> "")
 {
  IfWinExist, %vlc_window_current%
  {
   WinClose, %vlc_window_current%
   WinWaitClose, %vlc_window_current%, 5
   IfWinExist, %vlc_window_current%
   {
    MsgBox, 0, VLC error,
    (LTrim
    Previous instance of VLC could not be closed.
    Please close it manually before starting it again.
     	
    Click "OK" to continue.
	)
	return
   }
   Sleep 500
  }
 }
 If (filepath = "")
 {
  MsgBox, 0, VLC error,
  (LTrim
  No file was selected, please drop a file
  on this window before launching VLC.
  
  Click "OK" to continue.
  )
  return
 }
 Run, "%dir_vlc%\vlc.exe" --intf="qt" --extraintf="http" --http-port="18081" --http-password="mkvcm" --input-title-format="$p" --qt-notification="0" --no-crashdump "%filepath%"
 WinWait, %filename% - VLC, , 20
 Sleep 1000
 IfWinExist, %filename% - VLC
 {
  vlc_wrongname = 0
 }
 else
 {
  vlc_wrongname = 1
 }
 If (vlc_wrongname > 0 or ErrorLevel > 0)
 {
  MsgBox, 0, VLC error,
  (LTrim
  VLC window was not opened properly.
  Please check that the file is compatible
  and playable in VLC.
  
  Try again, if VLC launch took over
  20 seconds (when launching for the
  first time, for example).
  
  Click "OK" to continue.
  )
  return
 }
 WinGetTitle, vlc_window_current, %filename% - VLC
 WinActivate, %vlc_window_current%
 Hotkey, IfWinActive, %vlc_window_current%
 Hotkey, i, parse_timestamp_start
 Hotkey, IfWinActive, %vlc_window_current%
 Hotkey, o, parse_timestamp_end
 return

ButtonMarksectionstart:
 Gosub, parse_timestamp_start
 return
 
ButtonMarksectionend:
 Gosub, parse_timestamp_end
 return

ButtonCopytimestampstringtoClipboard:
 GuiControlGet, string_to_clipboard, , Timestampstring_edit
 clipboard =									; empty the clipboard first
 clipboard = %string_to_clipboard%
 return

ButtonStartmkvmergewiththeFinalTimestampString:
 If (filepath = "")
 {
  MsgBox, 0, mkvmerge error,
  (LTrim
  No file was selected, please drop a file
  on this window before trying to run mkvmerge.
  
  Click "OK" to continue.
  )
  return
 }
 If (dir_target = "dir_source" or dir_target = "")		; This is the default action.
 {
  dir_target = %filefolder%
 }
 GuiControlGet, string_to_mkvmerge, , Timestampstring_edit
 If (string_to_mkvmerge = "")
 {
  MsgBox, 1, Run mkvmerge,
  (LTrim
  No cutpoints were selected, do you
  still want to pass the file through
  with mkvmerge?
  
  Command to run:
  "%dir_mkvcm%\mkvtoolnix\mkvmerge.exe" -o "%dir_target%\%filebody%_mkvcm.mkv" "%filepath%"
  
  Click "OK" to continue or "Cancel" to return.
  )
  IfMsgBox, Cancel
  {
   return
  }
  else
  {
   Run, cmd /c ""%dir_mkvcm%\mkvtoolnix\mkvmerge.exe" -o "%filefolder%\%filebody%_mkvcm.mkv" "%filepath%" & pause"
  }
 }
 else
 {
  splitstring := "--split parts:" string_to_mkvmerge
  MsgBox, 1, Run mkvmerge,
  (LTrim
  With the cutpoint string created, mkvmerge
  is about to run with the following command:
  
  "%dir_mkvcm%\mkvtoolnix\mkvmerge.exe" -o "%filefolder%\%filebody%_mkvcm.mkv" %splitstring% "%filepath%"
  
  Click "OK" to continue or "Cancel" to return.
  )
  IfMsgBox, Cancel
  {
  return
  }
  else
  {
   run, cmd /c ""%dir_mkvcm%\mkvtoolnix\mkvmerge.exe" -o "%filefolder%\%filebody%_mkvcm.mkv" %splitstring% "%filepath%" & pause"
  }
 }
 return

parse_timestamp_start:
 time_stamp_final =
 GoSub, get_vlc_time
 RunWait, %comspec% /c "del /Q "%dir_mkvcm%\mkvcmvlcstatus.xml", , Hide"			; Delete the created curl output file right after the time has (or hasn't) been extracted.
 If (parsing_failed > 0)
 {
  return
 }
 GoSub, sectostamp
 time_stamp_final := hh_final ":" mm_final ":" ss_final
 GuiControlGet, string_prev, , Timestampstring_edit
 If (start_applied < 1 or string_prev = "")
 {
 string_current = %time_stamp_final%
 GuiControl,, Timestampstring_edit, %string_current%
 start_applied = 1
 }
 else
 {
 string_current = %string_prev%,+%time_stamp_final%
 GuiControl,, Timestampstring_edit, %string_current%
 }
 return
 
parse_timestamp_end:
 time_stamp_final =
 GoSub, get_vlc_time
 RunWait, %comspec% /c "del /Q "%dir_mkvcm%\mkvcmvlcstatus.xml", , Hide"			; Delete the created curl output file right after the time has (or hasn't) been extracted.
 If (parsing_failed > 0)
 {
  return
 }
 GoSub, sectostamp
 time_stamp_final := hh_final ":" mm_final ":" ss_final
 GuiControlGet, string_prev, , Timestampstring_edit
 string_current = %string_prev%-%time_stamp_final%
 GuiControl,, Timestampstring_edit, %string_current%
 return

get_vlc_time:
; Get the current play time from VLC and return the value (or tag parsing_failed = 1 if this fails).
 parsing_failed = 0
 IfWinNotExist, %vlc_window_current%
 {
  MsgBox, 0, Timestamp parsing error,
  (LTrim
  VLC window was not opened properly.
  Please launch VLC from the button above,
  after dropping the media file on this
  window.
 
  Click "OK" to continue.
  )
  parsing_failed = 1
  return
 }
 
 RunWait, %comspec% /c ""%dir_curl%\curl.exe" -u :mkvcm -g "http://localhost:18081/requests/status.xml" --output "%dir_mkvcm%\mkvcmvlcstatus.xml", , Hide"
 Loop, 40			; Perform the loop forty times (with the "Sleep 100" it means waiting for max four seconds).
 {
  If !FileExist(dir_mkvcm "\mkvcmvlcstatus.xml")
  {
   Sleep 100		; This is a delay before checking again.
   continue
  }
  else
  {
   Sleep 200		; This is a delay after the file is found, just to make sure that it is completely written before reading it.
   break			; Break the file searching loop.
  } 
 }

 If !FileExist(dir_mkvcm "\mkvcmvlcstatus.xml")		; If the file is not there after the initial waiting, give a message and return.
 {
  MsgBox, 0, Timestamp parsing error,
  (LTrim
  VLC did not respond to the status
  query (by curl). No status file found.
  Needs debugging.
  
  Is curl.exe installed? Do you have
  a correct (32-/64-bit) version of the
  compiled script?
  
  Click "OK" to continue.
  )
  parsing_failed = 1
  return
 }

 FileGetSize, vlcstatusfilesize, %dir_mkvcm%\mkvcmvlcstatus.xml
 vlcstatuswrite = 0
 Loop, 10			; Perform the loop up to ten times (with the "Sleep 100" it means waiting for max one second).
 {
  If (vlcstatusfilesize < 100)			; A proper VLC status is always more than 100 bytes.
  {
   Sleep 100		; This is a delay before checking again.
   continue
  }
  else
  {
   vlcstatuswrite = 1
   Sleep 200		; This is a delay after the correct status file was found.
   break			; Break the file searching loop.
  } 
 }
 
 If (vlcstatuswrite < 1)
 {
  MsgBox, 0, Timestamp parsing error,
  (LTrim
  VLC did not respond to the status
  query (by curl). File too small.
  Needs debugging.
  
  Is curl.exe installed? Do you have
  a correct (32-/64-bit) version of the
  compiled script?
  
  Click "OK" to continue.
  )
  parsing_failed = 1
  return
 }

 Loop, Read, %dir_mkvcm%\mkvcmvlcstatus.xml
 {
  timetagline =						; Clear the variable for each search.
  timetagpos := InStr(A_LoopReadLine, "<time>")
  If (timetagpos < 1)
  {
   continue			; The time tag is not on this line, continue to read the next line.
  }
  else				; The time tag is on this line, parse the seconds next.
  {
   timetagline = %A_LoopReadLine%								 				; Use an easier name for the line.
   time_first_number_pos := InStr(timetagline, ">", , 1, 1) + 1					; The position of the first > (plus one) is the position of the first number in the time.
   time_last_number_pos := InStr(timetagline, "<", , 1, 2)						; The position of the second < marks the end of the time.
   time_length := time_last_number_pos - time_first_number_pos					; The length of the string that has the time (not the length of the media file).
   time_sec_final := SubStr(timetagline, time_first_number_pos, time_length)	; Retrieve the final time (in secs).
   break
  }
 }
 
 If (timetagline = "")		; This means that the play time line / tag was not found on any line of the file.
 {
  MsgBox, 0, Timestamp parsing error,
  (LTrim
  Could not retrieve the current
  timestamp from VLC. timetagline was empty.
  Needs debugging.
  
  Click "OK" to continue.
  )
  parsing_failed = 1
  return
 }
 return 

sectostamp:
; Convert seconds to format HH:MM:SS
 hplus =										; First clear the variables
 hfloor =
 hh_final =
 secmin =
 mm_final =
 ss_final =
 
 If (time_sec_final >= 3600)
 {
  hplus := time_sec_final / 3600
  hfloor := Floor(hplus)
  If (hfloor < 10)
  {
   hh_final = 0%hfloor%
  }
  If (hfloor >= 10)
  {
   hh_final := hfloor
  }
 }
 else
 {
  hfloor = 0
  hh_final = 00
 }

 secmin := time_sec_final - hfloor * 3600
 If (secmin > 59)
 {
  minplus := secmin / 60
  minfloor := Floor(minplus)
  If (minfloor < 10)
  {
   mm_final = 0%minfloor%
  }
  If (minfloor >= 10)
  {
   mm_final := minfloor
  }
 }
 else
 {
  minfloor = 0
  mm_final := "00"
 }
 
 secleft := secmin - minfloor * 60
 If (secleft < 10)
 {
  ss_final = 0%secleft%
 }
 If (secleft >= 10)
 {
  ss_final := secleft
 } 
 return
 
GuiClose:
GuiEscape:
 ExitApp
