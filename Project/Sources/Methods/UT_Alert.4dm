//%attributes = {}
// -------------------------------------------------------------------------------------------------
// Method name   : UT_Alert
// Description
// 
//
// Parameters: Object
//       Attributes: 
//                   iWidth       - dft 500 - Min=300
//                   iHeight      - dft 120 - Min=90
//                   tFont        - dft "System Font Regular"
//                   iFontSize    - dft 16
//                   bFontBold    - dft False
//                   bFontCenter  - dft True
//                   tWindowTitle - dft "Alert" 
//                   tMessage 
//  
// -------------------------------------------------------------------------------------------------
// Created by    : Bruno Raeymaekers
// Date and time : 10/10/23, 11:15:22
// -------------------------------------------------------------------------------------------------
C_OBJECT:C1216($1; $oMessageParam)

$oMessageParam:=$1

var $oFormLayout; $oFormObject; $oPage; $oMessage; $oBtnAccept; $oRectangle : Object
var $iLeft; $iTop; $iRight; $iBottom; $iFormWidth; $iFormHeight; $iWindowRef; $iTextSize : Integer
var $iWindowWidth; $iWindowHeight; $iNewLeft; $iNewRight; $iNewTop; $iNewBottom : Integer
var $tWindowTitle; $tMessage; $tTextFont : Text
var $bTextBold; $bTextCenter : Boolean

$iFormWidth:=500
$iFormHeight:=120
$tWindowTitle:="Alert"
$tTextFont:="System Font Regular"
$iTextSize:=16
$bTextBold:=False:C215
$bTextCenter:=True:C214

If ($oMessageParam.tMessage=Null:C1517)
	$tMessage:=""
Else 
	$tMessage:=$oMessageParam.tMessage
End if 
If ($oMessageParam.tWindowTitle#Null:C1517)
	$tWindowTitle:=$oMessageParam.tWindowTitle
End if 
If ($oMessageParam.iWidth#Null:C1517)
	$iFormWidth:=$oMessageParam.iWidth
	If ($iFormWidth<300)
		$iFormWidth:=300
	End if 
End if 
If ($oMessageParam.iHeight#Null:C1517)
	$iFormHeight:=$oMessageParam.iHeight
	If ($iFormHeight<90)
		$iFormHeight:=90
	End if 
End if 
If ($oMessageParam.tFont#Null:C1517)
	$tTextFont:=$oMessageParam.tFont
End if 
If ($oMessageParam.iFontSize#Null:C1517)
	$iTextSize:=$oMessageParam.iFontSize
End if 
If ($oMessageParam.bFontBold#Null:C1517)
	$bTextBold:=$oMessageParam.bFontBold
End if 
If ($oMessageParam.bFontCenter#Null:C1517)
	$bTextCenter:=$oMessageParam.bFontCenter
End if 

$oFormObject:=New object:C1471
$oFormObject.tMessage:=$tMessage

$oRectangle:=New object:C1471  // 
OB SET:C1220($oRectangle; "type"; "rectangle")
OB SET:C1220($oRectangle; "top"; 10)
OB SET:C1220($oRectangle; "left"; 10)
OB SET:C1220($oRectangle; "width"; $iFormWidth-20)
OB SET:C1220($oRectangle; "height"; $iFormHeight-46)  // = 10+8+20+8
OB SET:C1220($oRectangle; "sizingX"; "grow")
OB SET:C1220($oRectangle; "sizingY"; "grow")
OB SET:C1220($oRectangle; "borderRadius"; 5)
//OB SET($oRectangle; "stroke"; "transparent")

$oMessage:=New object:C1471  // "tMessage"
OB SET:C1220($oMessage; "type"; "input")
OB SET:C1220($oMessage; "top"; 15)
OB SET:C1220($oMessage; "left"; 12)
OB SET:C1220($oMessage; "width"; $iFormWidth-24)
OB SET:C1220($oMessage; "height"; $iFormHeight-55)
OB SET:C1220($oMessage; "sizingX"; "grow")
OB SET:C1220($oMessage; "sizingY"; "grow")
OB SET:C1220($oMessage; "focusable"; False:C215)
OB SET:C1220($oMessage; "hideFocusRing"; True:C214)
OB SET:C1220($oMessage; "borderStyle"; "none")
OB SET:C1220($oMessage; "dataSource"; "Form:C1466.tMessage")
OB SET:C1220($oMessage; "fontFamily"; $tTextFont)
OB SET:C1220($oMessage; "fontSize"; $iTextSize)
If ($bTextCenter)
	OB SET:C1220($oMessage; "textAlign"; "center")
Else 
	OB SET:C1220($oMessage; "textAlign"; "left")
End if 
OB SET:C1220($oMessage; "multiline"; "yes")
OB SET:C1220($oMessage; "enterable"; False:C215)
OB SET:C1220($oMessage; "verticalAlign"; "automatic")

If ($iFormHeight>120)
	OB SET:C1220($oMessage; "scrollbarVertical"; "visible")
	OB SET:C1220($oMessage; "width"; $iFormWidth-44)
	
End if 

$oBtnAccept:=New object:C1471  // "btnAccept"
OB SET:C1220($oBtnAccept; "type"; "button")
OB SET:C1220($oBtnAccept; "top"; $iFormHeight-(20+8))
OB SET:C1220($oBtnAccept; "left"; $iFormWidth-80)
OB SET:C1220($oBtnAccept; "width"; 70)
OB SET:C1220($oBtnAccept; "height"; 20)
OB SET:C1220($oBtnAccept; "sizingX"; "none")
OB SET:C1220($oBtnAccept; "sizingY"; "move")
OB SET:C1220($oBtnAccept; "action"; "accept")
OB SET:C1220($oBtnAccept; "text"; "Ok")
OB SET:C1220($oBtnAccept; "class"; "")
OB SET:C1220($oBtnAccept; "focusable"; False:C215)
OB SET:C1220($oBtnAccept; "defaultButton"; True:C214)
OB SET:C1220($oBtnAccept; "events"; New collection:C1472("onClick"))

$oPage:=New object:C1471
OB SET:C1220($oPage; "objects"; New object:C1471("rectangle"; $oRectangle; "tMessage"; $oMessage; "btnAccept"; $oBtnAccept))

$oFormLayout:=New object:C1471
OB SET:C1220($oFormLayout; "destination"; "detailScreen")
OB SET:C1220($oFormLayout; "rightMargin"; 10)
OB SET:C1220($oFormLayout; "bottomMargin"; 8)
OB SET:C1220($oFormLayout; "events"; New collection:C1472("onLoad"; "onClick"))
OB SET:C1220($oFormLayout; "pages"; New collection:C1472(Null:C1517; $oPage))

GET WINDOW RECT:C443($iLeft; $iTop; $iRight; $iBottom; Frontmost window:C447)

$iWindowWidth:=$iRight-$iLeft
$iWindowHeight:=$iBottom-$iTop

If ($iWindowWidth>$iFormWidth)
	$iNewLeft:=$iLeft+(($iWindowWidth-$iFormWidth)/2)
	$iNewRight:=$iNewLeft+$iFormWidth
	If ($iWindowHeight>$iFormHeight)
		$iNewTop:=$iTop+(($iWindowHeight-$iFormHeight)/2)
		$iNewBottom:=$iNewTop+$iFormHeight
		
		$iNewLeft:=$iLeft+(($iWindowWidth-$iFormWidth)/2)
		$iWindowRef:=Open window:C153($iNewLeft; $iNewTop; $iNewRight; $iNewBottom; Movable dialog box:K34:7; $tWindowTitle)
		
	Else 
		$iNewTop:=$iTop-(($iFormHeight-$iWindowHeight)/2)
		$iNewBottom:=$iNewTop+$iFormHeight
		
		$iNewLeft:=$iLeft+(($iWindowWidth-$iFormWidth)/2)
		$iWindowRef:=Open window:C153($iNewLeft; $iNewTop; $iNewRight; $iNewBottom; Movable dialog box:K34:7; $tWindowTitle)
		
	End if 
	
Else 
	$iNewLeft:=$iLeft-(($iFormWidth-$iWindowWidth)/2)
	$iNewRight:=$iNewLeft+$iFormWidth
	If ($iWindowHeight>$iFormHeight)
		$iNewTop:=$iTop+(($iWindowHeight-$iFormHeight)/2)
		$iNewBottom:=$iNewTop+$iFormHeight
		
		$iNewLeft:=$iLeft+(($iWindowWidth-$iFormWidth)/2)
		$iWindowRef:=Open window:C153($iNewLeft; $iNewTop; $iNewRight; $iNewBottom; Movable dialog box:K34:7; $tWindowTitle)
		
	Else 
		$iNewTop:=$iTop-(($iFormHeight-$iWindowHeight)/2)
		$iNewBottom:=$iNewTop+$iFormHeight
		
		$iNewLeft:=$iLeft+(($iWindowWidth-$iFormWidth)/2)
		$iWindowRef:=Open window:C153($iNewLeft; $iNewTop; $iNewRight; $iNewBottom; Movable dialog box:K34:7; $tWindowTitle)
		
	End if 
End if 

DIALOG:C40($oFormLayout; $oFormObject)

