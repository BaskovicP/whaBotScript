;**************************************************************************************************************************
;**************************************************************************************************************************
;**************************************************************************************************************************
; WhatsappBot
; Version 0.96 ---- 5.3.2018  - EDITING
; Programmer: Paulo B.
; Email: pbaskovi@gmail.com
;
;
;
;**************************************************************************************************************************
;**************************************************************************************************************************
;**************************************************************************************************************************
;**************************************************************************************************************************



#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

WinWaitActive, WhatsApp ahk_exe WhatsApp.exe

#Include Gdip.ahk ; a script to insert an image into the Clipboard to paste it later

EraseTries = 0
mailSent = 0
messageFileExists := FileExist(".\data\message.txt")
FindThreeDotsTries=0

Loop ;main program loop
{


    Loop ;loop unti you find that there are three dots in the upper right corner
    {


        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, 1139, 8, 1373, 135, .\pictures\threeDots.png
        CenterImgSrchCoords(".\pictures\threeDots.jpg", FoundX, FoundY)  
        FindThreeDotsTries++
    } Until ErrorLevel = 0 or FindThreeDotsTries > 5 ;TODO: check this part of the code
    FindThreeDotsTries=0

    Loop ;Put the mouse over a tooltip and get the number from the (tooltip) contact name and do this until you get the number
    {
        WinWaitActive, WhatsApp ahk_exe WhatsApp.exe
        Click, 495, 56, 0
        Sleep, 1000
        ControlGetText, currentTelNumber,,ahk_class tooltips_class32
        Click, 563, -539, 0


    } Until currentTelNumber!=""
   





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




} until mailSent==1





ChechStringForLetters(tekst)
{
    if tekst contains Q,W,E,R,T,Z,U,I,O,P,Š,Đ,A,S,D,F,G,H,J,K,L,Č,Ć,Ž,Y,X,C,V,B,N,M,q,w,e,r,t,z,u,i,o,p,š,đ,a,s,d,f,g,h,j,k,l,č,ć,ž,y,x,c,v,b,n,m
        return true
    else
        return false
    
}





;********************************************************************BRISANJE KONTAKTA**********************************************************************

DeleteContact()
{
Loop
{
    CoordMode, Pixel, Window
    ImageSearch, FoundX, FoundY, 1139, 8, 1373, 135, .\pictures\threeDots.png
    CenterImgSrchCoords(".\pictures\threeDots.png", FoundX, FoundY) 
    If ErrorLevel = 0
    	Click, %FoundX%, %FoundY% Left, 1
    Sleep, 10
}
Until ErrorLevel = 0

tries = 0
Loop
{
    CoordMode, Pixel, Window
    ImageSearch, FoundX, FoundY, 988, 8, 1373, 374, .\pictures\izbrisiKontaktTekst.png
	  CenterImgSrchCoords(".\pictures\izbrisiKontaktTekst.png", FoundX, FoundY) 
    If ErrorLevel = 0
    	Click, %FoundX%, %FoundY%, 1
    Sleep, 10
    tries++
}
Until ErrorLevel = 0 or tries >= 20

if(tries<20) ;ako je nasao tipka
{
    Sleep 3000
    Click, 789, 419 Left, 1
}

}


ExitFromWhatsappGroup()
{
Click, 1226, 276 Left, 1
Sleep, 1000

Click, 794, 419 Left, 1
Sleep, 3000

Click, 1336, 65 Left, 1
Sleep, 3000

Click, 1225, 279 Left, 1
Sleep, 3000

Click, 792, 417 Left, 1
Sleep, 5000





}





;********************************************************************POŠALJI PORUKU********************************************************************

SendMessageFromFile(path)
{
    
    
    FileRead, Clipboard, %path%
    Click, 538, 702 Left, 1
    Sleep, 10
    Sleep, 300
    Send, {Control Down}
    Sleep, 10
    Send, {v Down}
    Sleep, 50
    Send, {v Up}
    Sleep, 50
    Send, {Control Up}
    Sleep, 50
    Sleep, 400
    Send, {Enter} 
    
}

SendMessage(message)
{
Click, 538, 702 Left, 1
Sleep, 10
Clipboard = %message%
Sleep, 300
Send, {Control Down}
Sleep, 10
Send, {v Down}
Sleep, 50
Send, {v Up}
Sleep, 50
Send, {Control Up}
Sleep, 50
Sleep, 400
Send, {Enter}
}







SendImage()
{
    pToken := Gdip_Startup() ;put the image into the Clipboard
    Gdip_SetBitmapToClipboard(pBitmap := Gdip_CreateBitmapFromFile(".\pictures\welcome.png"))
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
    
    Click, 538, 702 Left, 1

    Sleep, 300
    Send, {Control Down}
    Sleep, 10
    Send, {v Down}
    Sleep, 50
    Send, {v Up}
    Sleep, 50
    Send, {Control Up}
    Sleep, 50
    Sleep, 3000

Send, {Enter} 

}




CenterImgSrchCoords(imagePath,ByRef FoundX,ByRef FoundY)
{
	FoundX += 20
	FoundY += 20
	
}









;********************************************************************SAVE VCF********************************************************************


;BEGIN:VCARD
;VERSION:3.0
;FN:15123 
;TEL;TYPE=VOICE,CELL;VALUE=text:+2313213131 
;END:VCARD

SaveContactInVCF(ByRef currentTelNumber, newContactOrderNumber)
{
    

StringReplace, currentTelNumber, currentTelNumber, %A_SPACE%, , All
FormatTime, CurrentDateTime,, MM_d ;formate the date
saveLocation = .\data\%CurrentDateTime%.vcf  ;where the file will be saved

buffer =
(
BEGIN:VCARD
VERSION:3.0
FN:%newContactOrderNumber%
TEL;TYPE=VOICE,CELL;VALUE=text:%currentTelNumber%
END:VCARD`n
)



FileAppend, %buffer%, %saveLocation%  

}









;___________________________________________________________SAVE CSV__________________________________________________________________
SaveContactInCSV(ByRef currentTelNumber, newContactOrderNumber)
{
    


buffer := ",,,,,,,,,,,,,,,,,,,,,,,,,,* My Contacts,,,Mobile," currentTelNumber ",,`n" 

FormatTime, CurrentDateTime,, MM_d ;format the date




saveLocation = .\data\%CurrentDateTime%.csv  ;file save location
AttributeString := FileExist(saveLocation)  ;TODO: check here for speed los

;If the file doesnt exist add a GOOGLE HEADER
if(AttributeString =="")
{
    FileAppend,
    (
    Name,Given Name,Additional Name,Family Name,Yomi Name,Given Name Yomi,Additional Name Yomi,Family Name Yomi,Name Prefix,Name Suffix,Initials,Nickname,Short Name,Maiden Name,Birthday,Gender,Location,Billing Information,Directory Server,Mileage,Occupation,Hobby,Sensitivity,Priority,Subject,Notes,Group Membership,E-mail 1 - Type,E-mail 1 - Value,E-mail 2 - Type,E-mail 2 - Value,Phone 1 - Type,Phone 1 - Value,Phone 2 - Type,Phone 2 - Value,Phone 3 - Type,Phone 3 - Value,Phone 4 - Type,Phone 4 - Value,Phone 5 - Type,Phone 5 - Value,Address 1 - Type,Address 1 - Formatted,Address 1 - Street,Address 1 - City,Address 1 - PO Box,Address 1 - Region,Address 1 - Postal Code,Address 1 - Country,Address 1 - Extended Address,Organization 1 - Type,Organization 1 - Name,Organization 1 - Yomi Name,Organization 1 - Title,Organization 1 - Department,Organization 1 - Symbol,Organization 1 - Location,Organization 1 - Job Description,Website 1 - Type,Website 1 - Value `n
    ),%saveLocation%
    

    
}



;!!!!!!!!!!!!!!!!!!!!!!!!!!!!FORMAT THE NUMBER!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
If newContactOrderNumber <= 9
{
    FileAppend, 0000%newContactOrderNumber%0000%buffer%, %saveLocation%
    Goto, Izlaz
}
If newContactOrderNumber <= 99
{
    FileAppend, 000%newContactOrderNumber%%buffer%, %saveLocation%
    Goto, Izlaz
}
If newContactOrderNumber <= 999
{
    FileAppend, 00%newContactOrderNumber%%buffer%, %saveLocation%
    Goto, Izlaz
}
If newContactOrderNumber <= 9999
{
    FileAppend, 0%newContactOrderNumber%%buffer%, %saveLocation%
    Goto, Izlaz
}
If newContactOrderNumber <= 99999
{
    FileAppend, %newContactOrderNumber%%buffer%, %saveLocation%
    Goto, Izlaz
}
Izlaz:


}



;***************************************************** WARNING: if using google you will need to TURN ON less secure aps ************************************
SendMailIfError()
{
    
    AttributeString := FileExist(".\data\mailPassword.dat")  ;does the file exist??

;if the file exists do the things down
if(AttributeString !="")
{

    pmsg 			:= ComObjCreate("CDO.Message")
    pmsg.From 		:= "sample@gmail.com"   ; """AHKUser"" <sample@gmail.com>"
    pmsg.To 		:= "sample@gmail.com"
    pmsg.BCC 		:= ""   ; Blind Carbon Copy, Invisable for all, same syntax as CC
    pmsg.CC 		:= ""   ;"Somebody@somewhere.com, Other-somebody@somewhere.com"
    pmsg.Subject 	:= "Error in program!!!"

    ;You can use either Text or HTML body like
    pmsg.TextBody 	:= "Whatsapp Bot has encountred an error please check the script"
    ;OR
    ;pmsg.HtmlBody := "<html><head><title>Hello</title></head><body><h2>Hello</h2><p>Testing!</p></body></html>"


    ;sAttach   		:= "Path_Of_Attachment" ; can add multiple attachments, the delimiter is |

    FileRead, mailPassword, .\data\mailPassword.dat ;take the password from the file

    fields := Object()
    fields.smtpserver   := "smtp.gmail.com" ; specify your SMTP server
    fields.smtpserverport     := 465 ; 25
    fields.smtpusessl      := True ; False
    fields.sendusing     := 2   ; cdoSendUsingPort
    fields.smtpauthenticate     := 1   ; cdoBasic
    fields.sendusername := "sample@gmail@gmail.com"
    fields.sendpassword := mailPassword  
    fields.smtpconnectiontimeout := 60
    schema := "http://schemas.microsoft.com/cdo/configuration/"


    pfld :=   pmsg.Configuration.Fields

    For field,value in fields
	pfld.Item(schema . field) := value
    pfld.Update()

    Loop, Parse, sAttach, |, %A_Space%%A_Tab%
    pmsg.AddAttachment(A_LoopField)
    pmsg.Send()
}
}








FindAStar()
{
	 Loop ;Check if a new message has a star in it
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, 1139, 8, 1373, 135, .\pictures\star.png
        CenterImgSrchCoords(".\pictures\star.jpg", FoundX, FoundY) 

    } Until ErrorLevel = 0
    
    Click, FoundX, FoundY Left, 1
}