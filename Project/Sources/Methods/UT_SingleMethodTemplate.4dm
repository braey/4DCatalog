//%attributes = {}

C_OBJECT:C1216($1; $oParam)

var $oFormLayout; $oForm; $oReturn : Object
var $tJSONText; $tMenuBarMain; $tMenuBarRef; $tCopyMenuBarRef : Text
var $iWindowRef : Integer
var $bFormToPasteboard : Boolean

var $oCatalog : Object

If ((Count parameters:C259=0) & (FORM Event:C1606=Null:C1517))
	// this is the entry point in the method, like a "menu method" - no params
	
	$bFormToPasteboard:=False:C215
	
	// ++++++++++++++++++++++++++++++++++++++++++ begin create menu ++++++++++++++++++++++++++++++++++
	$tMenuBarMain:=Create menu:C408
	
	$tMenuBarRef:=Get menu bar reference:C979(Frontmost process:C327)
	$tCopyMenuBarRef:=Create menu:C408($tMenuBarRef)
	
	SET MENU BAR:C67($tMenuBarMain)
	
	// +++++++++++++++++++++++++++++++++++++++++ end create menu ++++++++++++++++++++++++++++++++++++++
	// ++++++++++++++++++++++++++++++++++++ begin create form layout +++++++++++++++++++++++++++++++++
	$oFormLayout:=New object:C1471
	UT_SingleMethodTemplate(New object:C1471("tSubroutine"; "CreateFormLayoutObject"; "oFormLayout"; $oFormLayout))
	
	// ++++++++++++++++++++++++
	If ($bFormToPasteboard)
		$tJSONText:=JSON Stringify:C1217($oFormLayout; *)
		SET TEXT TO PASTEBOARD:C523($tJSONText)  // to compare with original form object in text editor
		
	End if 
	
	// +++++++++++++++++++++++++++++++++++++++ end create form layout ++++++++++++++++++++++++++++++++
	// ++++++++++++++++++++++++++++++++++++++ populate FORM object +++++++++++++++++++++++++++++++++++
	
	$oForm:=New object:C1471
	$oForm.tFormName:=$oFormLayout.tMyFormName
	
	// +++++++++++++++++++++++++++++++++++ end populate FORM object +++++++++++++++++++++++++++++++++++
	// +++++++++++++++++++++++++++++++++++++++ Display Form +++++++++++++++++++++++++++++++++++++++++++
	
	If ($oFormLayout.destination=Null:C1517)
		$iWindowRef:=Open form window:C675("UT_Catalog_View")
		$oForm.iMainWindowRef:=$iWindowRef
		$oForm.tFormName:="UT_Catalog_View"
		DIALOG:C40("UT_Catalog_View"; $oForm)
	Else 
		$iWindowRef:=Open form window:C675($oFormLayout)
		$oForm.iMainWindowRef:=$iWindowRef
		DIALOG:C40($oFormLayout; $oForm)
	End if 
	
	// Clean up
	RELEASE MENU:C978($tMenuBarMain)
	SET MENU BAR:C67($tCopyMenuBarRef)
	
Else 
	If (Count parameters:C259=0)
		// form event handling starts here
		If (FORM Event:C1606.objectName=Null:C1517)
			// -> this is the form method
			Case of 
				: (Form:C1466.tFormName="UT_Catalog_View")  // In case you have more than 1 form
					Case of 
						: (FORM Event:C1606.code=On Load:K2:1)
							
							POST OUTSIDE CALL:C329(Current process:C322)
							
							
						: (FORM Event:C1606.code=On Outside Call:K2:11)
							$oReturn:=New object:C1471
							UT_SingleMethodTemplate(New object:C1471("tSubroutine"; "SelectCatalog"; "oReturn"; $oReturn))
							
							If ($oReturn.ok=1)
								$oCatalog:=New object:C1471
								UT_SingleMethodTemplate(New object:C1471("tSubroutine"; "ProcessCatalogFile"; "document"; $oReturn.tDocument; "oCatalog"; $oCatalog; "oReturn"; $oReturn))
								If ($oReturn.ok#1)
									CANCEL:C270
									
								Else 
									Form:C1466.oCatalog:=$oCatalog
									
									UT_SingleMethodTemplate(New object:C1471("tSubroutine"; "............."))
									UT_SingleMethodTemplate(New object:C1471("tSubroutine"; "............."))
									
								End if 
							End if 
							
						: (FORM Event:C1606.code=On Menu Selected:K2:14)
							
							
					End case 
					
				: (Form:C1466.tFormName="UT_Catalog_Help")  // In case you have more than 1 form
					
					
					
				Else 
					ALERT:C41("Un-supported Form Name")
					
			End case 
		Else 
			// below are all the object methods
			
			Case of 
				: (Form:C1466.tFormName="UT_Catalog_View")  // In case you have more than 1 form
					Case of 
						: (FORM Event:C1606.objectName="btnHelp")
							Case of 
								: (FORM Event:C1606.code=On Clicked:K2:4)
									
							End case 
					End case 
					
				: (Form:C1466.tFormName="UT_Catalog_Test")  // In case you have more than 1 form
					
					
				Else 
					ALERT:C41("Un-supported Form Name")
					
			End case 
		End if 
		
	Else 
		// start of all the sub-routines - method has been called from within 
		// parameters + return values in $oParam
		
		$oParam:=$1
		If ($oParam.tSubroutine#Null:C1517)
			Case of 
				: ($oParam.tSubroutine="SelectCatalog")
					
				: ($oParam.tSubroutine="ProcessCatalogFile")
					
				: ($oParam.tSubroutine=".................")
					
				: ($oParam.tSubroutine=".................")
					
				: ($oParam.tSubroutine="CreateFormLayoutObject")
					
				Else 
					ALERT:C41("Un-supported sub-routine")
					
			End case 
		End if 
	End if 
End if 



