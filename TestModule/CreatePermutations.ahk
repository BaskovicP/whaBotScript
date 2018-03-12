#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


saveLocation = \testModule.ini

;this was a test for numbers
Array :=  [1,1,1,1,1,2,1,1,3,1,2,1,1,2,2,1,2,3,1,3,1,1,3,2,1,3,3,2,1,1,2,1,2,2,1,3,2,2,1,2,2,2,2,2,3,2,3,1,2,3,2,2,3,3,3,1,1,3,1,2,1,3,3,2,1,3,2,2,3,2,3,3,3,1,3,3,2,3,3,3]
	

For index, value in array
{
	Random, rand1, 10000, 9999999
	 Random, rand2, 10000, 9999999
	
	if(value == 1)
		FileAppend, +%rand1%`n, testModule.ini
	else if(value ==2)
		FileAppend, %rand2%`n, testModule.ini
	else
		FileAppend, group`n, testModule.ini
}




