//%attributes = {"shared":true}

var $oParam; $oFormLayout; $oFormObject : Object
var $tJSONText; $tDesktopPath; $tGeneratedFile; $tCommand; $tIn; $tOut; $tError : Text

$oFormObject:=New object:C1471
$oFormLayout:=New object:C1471
$oParam:=New object:C1471
$oParam.oFormLayout:=$oFormLayout

//////////// Paste generated code here




/////////// save the generated file

$tJSONText:=JSON Stringify:C1217($oFormObject; *)
$tDesktopPath:=System folder:C487(Desktop:K41:16)+"Compare4DForms"
$tGeneratedFile:=$tDesktopPath+Folder separator:K24:12+"GeneratedForm.4DForm"
TEXT TO DOCUMENT:C1237($tGeneratedFile; $tJSONText)

$tCommand:="/usr/local/bin/bbdiff /Users/braey/Desktop/Compare4DForms/GeneratedForm.4DForm /Users/braey/Desktop/Compare4DForms/"+$oFormObject.tMyFormName+".4DForm"
SET TEXT TO PASTEBOARD:C523($tCommand)

ALERT:C41("Done")

/////////// build and save the schell script
//$tCommand:="/usr/local/bin/bbdiff /Users/braey/Desktop/Compare4DForms/GeneratedForm.4DForm /Users/braey/Desktop/Compare4DForms/"+$oFormObject.tMyFormName+".4DForm"
//$tScriptContents:="#!/bin/bash"+Char(Carriage return)
//$tScriptContents:=$tScriptContents+$tCommand
//$tScript:=$tDesktopPath+Folder separator+"bbdiff.sh"
//$tScript:="Ventura:Users:braey:Applications:bbdiff.sh"
//$hDocref:=Create document($tScript; ".sh")
//If (OK=1)
//CLOSE DOCUMENT($hDocref)
//TEXT TO DOCUMENT(document; $tScriptContents)
//LAUNCH EXTERNAL PROCESS("chmod +x /Users/braey/Applications/bbdiff.sh")
//End if 
///////////// execute shell script
//$tCommand:="/Users/braey/Applications/bbdiff.sh"
////LAUNCH EXTERNAL PROCESS($tCommand; $tIn; $tOut; $tError)


//LAUNCH EXTERNAL PROCESS("open /Users/braey/applications/bbdiff.sh"; $tIn; $tOut; $tError)


