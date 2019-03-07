-- Connect to Ultrospec and write output to file
-- Kristian St¿dkilde-J¿rgensen 21-5-2013 

on program()
	
	set theFolder to get_folder()
	
	display dialog "UltroSpec Script
by Kristian St¿dkilde-J¿rgensen" with title "UltroSpec V0.2" buttons {"Proceed"} default button 1
	
	-- Find device from list
	set serialDevices to (do shell script "ls /dev/cu*")
	set theDeviceList to (paragraphs of serialDevices) as list
	set theDevice to (choose from list theDeviceList with title "UltroSpec V0.2" with prompt "Choose input")
	
	set text_ok to false
	repeat while text_ok is false
		display dialog "Name of output file:" default answer "" with title "UltroSpec V0.2" buttons {"Proceed"} default button 1
		set outputfile to (text returned of result)
		
		if check_outputfile(outputfile) is true then
			set outputfile to check_space(outputfile)
			if file_exist(theFolder, outputfile) is true then
				display dialog "File already exists!" buttons {"Try again"} default button 1 with title "UltroSpec V0.2"
			else
				set text_ok to true
			end if
		else
			set text_ok to false
		end if
	end repeat
	
	set filetext to "logfile " & theFolder & outputfile & ".txt"
	set filename to theFolder & "Result_location"
	
	-- make tmp screenrc file for Screen
	do shell script "echo " & filetext & ">" & filename
	
	tell application "Terminal"
		-- Use screen command and the device. -L enables us to log output
		do script "screen -c " & filename & " -L " & theDevice & " " & 19200
		
	end tell
	
	set done to false
	repeat while done is false
		set question to display dialog "Saving output to file: " & outputfile & "
" buttons {"Change file", "Open result", "Quit"} with title "UltroSpec V0.2"
		set answer to button returned of question
		
		if answer is equal to "Quit" then
			set done to true
			kill_screen(filename)
		end if
		
		if answer is equal to "Open result" then
			--set oldfolder so we have applescript version of pathname : instead of /, for TextEdit later on
			set oldfolder to (path to me as string)
			set newpath to (text 1 thru text item -15 of oldfolder) as Unicode text
			tell application "TextEdit"
				activate
				open newpath & outputfile & ".txt" as alias
			end tell
		end if
		
		if answer is equal to "Change file" then
			set text_ok to false
			repeat while text_ok is false
				display dialog "Name of output file:" default answer "" with title "UltroSpec V0.2" buttons {"Proceed"} default button 1
				set outputfile to (text returned of result)
				if check_outputfile(outputfile) is true then
					set outputfile to check_space(outputfile)
					if file_exist(theFolder, outputfile) is true then
						display dialog "File already exists!" with title "UltroSpec V0.2" buttons {"Try again"} default button 1
					else
						set text_ok to true
					end if
				else
					set text_ok to false
				end if
			end repeat
			
			set filetext to "logfile " & theFolder & outputfile & ".txt"
			set filename to theFolder & "Result_location"
			
			kill_screen(filename)
			
			-- make tmp screenrc file for Screen
			do shell script "echo " & filetext & ">" & filename
			
			tell application "Terminal"
				-- Use screen command and the device. -L enables us to log input
				do script "screen -c " & filename & " -L " & theDevice & " " & 19200
				
			end tell
		end if
	end repeat
end program
program()

to check_space(outputfile)
	if outputfile contains " " then
		set ASTID to AppleScript's text item delimiters
		set AppleScript's text item delimiters to " "
		set new_outputfile to text items of outputfile
		set AppleScript's text item delimiters to "_"
		set outputfile to (new_outputfile as string)
		set AppleScript's text item delimiters to ASTID
		display dialog "Spaces have been substitutet." & " 
File name: " & outputfile with title "UltroSpec V0.2" buttons {"Proceed"} default button 1
		return outputfile
	else
		return outputfile
	end if
end check_space

to check_outputfile(outputfile)
	if (count outputfile) is 0 then
		display dialog "Please type a file name" with title "UltroSpec V0.2" buttons {"Try again"} default button 1
		return false
	end if
	
	set legalCharacters to {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "_", "-", " "}
	
	repeat with thisCharacter in the characters of outputfile
		set thisCharacter to thisCharacter as text
		if thisCharacter is not in legalCharacters then
			display dialog "Illegal character '" & thisCharacter & "' in name." with title "UltroSpec V0.2" buttons {"Try again"} default button 1
			return false
		end if
	end repeat
	return true
end check_outputfile

to kill_screen(filename)
	set Screen to "SCREEN"
	set the_pid to (do shell script "ps ax | grep " & (quoted form of Screen) & " | grep -v grep | awk '{print $1}'")
	if the_pid is not "" then do shell script ("kill -9 " & the_pid)
	-- delete the Result_location file used to direct Screen to the proper file
	do shell script "rm -rf " & filename
end kill_screen

to get_folder()
	-- gets it in "/" form instead of ":"
	set myPath to POSIX path of (path to me as string)
	-- save Applescripts TextItem Delimiters
	set ASTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "/"
	-- fix path to ultrospec folder
	set theFolder to (text 1 thru text item -3 of myPath) & "/" as Unicode text
	-- restore
	set AppleScript's text item delimiters to ASTID
	return theFolder
end get_folder

to file_exist(theFolder, outputfile)
	set found to false
	tell application "Finder" to if exists theFolder & outputfile as POSIX file then set found to true
	return found
end file_exist
