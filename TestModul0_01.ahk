


;TODO: finish the test function by addign saveToVcf and saveToCSV


#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;Test module for application KRALJ


;Possible permutations
;{1,1,1} {1,1,2} {1,1,3} {1,2,1} {1,2,2} {1,2,3} {1,3,1} 
;{1,3,2} {1,3,3} {2,1,1} {2,1,2} {2,1,3} {2,2,1} {2,2,2} 
;{2,2,3} {2,3,1} {2,3,2} {2,3,3} {3,1,1} {3,1,2} {3,1,3} 
;{3,2,1} {3,2,2} {3,2,3} {3,3,1} {3,3,2} {3,3,3}
; OCCURENCE
;1. ,	79 (49.7%)
;2. 1	27 (17%) +
;3. 2	27 (17%) 11111
;4. 3	26 (16.4%) grupa
; 1. good number with +
; 2. good numer but already in phone contacts
; 3. grup or a contacts saved with a name



;__________________________VARIABLE________________________________________
#Include Gdip.ahk ;da mozemo ubaciti sliku u clipboard

EraseTries = 0
mailSent = 0
messageFileExists := FileExist(".\TestModule\message.txt")
FindThreeDotsTries=0






; Create the array, initially empty:
Array := [] ; or Array := Array()

; Write to the array:
Loop, Read, %A_ScriptDir%\TestModule\testModule.ini ; This loop retrieves each line from the file, one at a time.
{
    Array.Push(A_LoopReadLine) ; Append this line to the array.
}

; Read from the array:
; Loop % Array.MaxIndex()   ; More traditional approach.
for index, currentTelNumber in Array ; Enumeration is the recommended approach in most cases.
{


    
    if(previousTelNumber!=currentTelNumber) ;if the number has changed reset the erase tries
        EraseTries=0

;**********************************************BROJ JE VEC U BAZI PODATAKA********************************************
    if(InStr(currentTelNumber, "+")==0 and EraseTries==0) ;if there is no + or a new number then enter
    {
 
        if(messageFileExists != "")
        {
             ;SendMessageFromFile(".\data\message.txt")
        }
        else if(messageFileExists =="")
        {
           ; SendMessage()
        }


        SendImage() 
        DeleteContact() 
        previousTelNumber = currentTelNumber;
        
        
        EraseTries++
        
    }



	
	
	
;**********************************************NOVI BROJ********************************************
    else if (previousTelNumber!=currentTelNumber and InStr(currentTelNumber, "+")!=0) ;here we have a new number and we want to save it to a file
    {

        previousTelNumber = %currentTelNumber% ;later for checking do we really have a new number


        FileRead, newContactOrderNumber, .\data\newContactOrderNumber.txt ;take the number and use it as a new contacts name


        StringReplace, currentTelNumber, currentTelNumber, %A_SPACE%, , All ;clean the number of all spaces
        SaveContactInCSV(currentTelNumber,newContactOrderNumber) ;save the new contacts into google csv file
        SaveContactInVCF(currentTelNumber,newContactOrderNumber) ;save the new contact number into a vcf file


        ;*********Save the new number*******************
        newContactOrderNumber += 1
        FileDelete, .\data\newContactOrderNumber.txt
        FileAppend, %newContactOrderNumber%, .\data\newContactOrderNumber.txt




        currentTelNumber:=0 ;erase the current number


        ;SendMessage() ;  -- put this if you want to send a message
        
        ;SendMessageFromFile(".\data\message.txt")

        SendImage() 
        DeleteContact()
        EraseTries++

        Sleep 1000

    }
    else if(EraseTries>10)
    {
        if(mailSent!=1) ; if the mail was sent wait before the script is reset before sending the mail another time
        SendMailIfError()
    
        mailSent = 1
    }
    else 
    {
        if(EraseTries==0)
            previousTelNumber = %currentTelNumber%
        
        Sleep 3000
        DeleteContact() ;try to deleate
        Click, 791, 239 Left, 1 ;WARNING  - what if a user sends a picture then clicking in the middle of the screen is a problem
        Sleep, 400
        
        EraseTries++

    
        if(EraseTries >= 3) ; if the program tries to erase a kontakt message and it fails after 3 tries make sure we are not in a group
        {
          ExitFromWhatsappGroup()
          
        }
    } 
;*********************************************************************************************************




} 

















