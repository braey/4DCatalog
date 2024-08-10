//%attributes = {}
// -------------------------------------------------------------------------------------------------
// Method name   : UT_Catalog_View
// Description    
// 
//
// Parameters
//
// -------------------------------------------------------------------------------------------------
// All rights    : STC - Software, Training and Consultancy - Belgium
// -------------------------------------------------------------------------------------------------
// Created by    : Bruno Raeymaekers
// Date and time : 03/07/24, 9:42:40
// -------------------------------------------------------------------------------------------------
// ©2024 - STC bvba, All rights reserved.
// This software and source code is subject to copyright protection as literary work pursuant to the
// Belgian Copyright Laws and International Conventions. No part of this software may be reproduced
// or copied, in whole or in part, in any form or by any means. No part of this software may be used
// except under a valid licence agreement or without the prior written permission of STC bvba.
// Any infringement of the copyright in software and source code will be prosecuted to the full 
// extent permissible by law.
// -------------------------------------------------------------------------------------------------

C_OBJECT:C1216($1; $oParam)

var $colTables; $colFields; $colIndexes; $colRelations; $colTemp1; $colTemp2 : Collection
var $oCatalog; $oTable; $oField; $oIndex; $oRelation; $oFormLayout; $oForm; $oReturn; $oParam : Object
var $bStopProcessing; $bStopField; $bStopCompositeIndex; $bStopRelation; $bCompositeIndex; $bFormToPasteboard; $bHelpWindowIsOpen : Boolean
var $tXMLElementRefRelation; $tXMLElementRefRelationField; $tXMLElementRefRelationTable; $tXMLElementIndexTableName : Text
var $tDocument; $tXMLText; $tXMLRef; $tXMLElementRef; $tXMLElementFieldRef; $tXMLElementIndexField; $tXMLElementFieldExtraRef; $tHelpTxt : Text
var $tName; $tValue; $tChildName; $tChildValue; $tFieldExtraName; $tFieldExtraValue; $tIndexName; $tIndexType; $tKind; $tPKName; $tJSONText : Text
var $tTableName; $tFieldName; $tQueryString; $tMenuBarRef; $tCopyMenuBarRef; $tMenuBarMain; $tMenuBarFile; $tMenuBarEdit; $tMenuBarCatalog : Text
var $iAttributes; $iPosition; $iCntrAttrib; $iCol; $iRow; $iCntrTables; $iCntrRelations; $iCntrIndexes; $iProcessID; $iProgress; $iWindowRef : Integer
var $iLeft; $iTop; $iRight; $iBottom; $iScreen; $iCurrentWindowWidth; $iCurrentWindowHeight; $iCenterWidth; $iCenterHeight : Integer
var $iLeft2; $iTop2; $iRight2; $iBottom2; $iNewWindowWidth; $iNewWindowHeight; $iMaxWidth; $iMaxHeight : Integer
var $iCntr; $iNumScreens; $iLeftWR; $iTopWR; $iRightWR; $iBottomWR; $iLeftSC; $iTopSC; $iRightSC; $iBottomSC : Integer

var $pPtr : Pointer

$bFormToPasteboard:=True:C214

If ((Count parameters:C259=0) & (FORM Event:C1606=Null:C1517))  // this is the entry point in the method, like a "menu method" - no params
	// ++++++++++++++++++++++++++++++++++++++++++ begin create menu ++++++++++++++++++++++++++++++++++
	
	$tMenuBarFile:=Create menu:C408
	INSERT MENU ITEM:C412($tMenuBarFile; -1; "Load Catalog...")
	SET MENU ITEM PARAMETER:C1004($tMenuBarFile; 1; "LoadCatalog")
	SET MENU ITEM SHORTCUT:C423($tMenuBarFile; 1; Character code:C91("L"))
	INSERT MENU ITEM:C412($tMenuBarFile; -1; "(-")
	INSERT MENU ITEM:C412($tMenuBarFile; -1; Get indexed string:C510(131; 30))
	SET MENU ITEM PROPERTY:C973($tMenuBarFile; 3; Associated standard action:K56:1; ak cancel:K76:36)  //cancel
	SET MENU ITEM SHORTCUT:C423($tMenuBarFile; 3; Character code:C91("Q"))
	
	$tMenuBarEdit:=Create menu:C408
	APPEND MENU ITEM:C411($tMenuBarEdit; "Cut;Copy;Paste")
	SET MENU ITEM SHORTCUT:C423($tMenuBarEdit; 1; Character code:C91("X"))
	SET MENU ITEM PROPERTY:C973($tMenuBarEdit; 1; Associated standard action:K56:1; ak cut:K76:53)
	SET MENU ITEM SHORTCUT:C423($tMenuBarEdit; 2; Character code:C91("C"))
	SET MENU ITEM PROPERTY:C973($tMenuBarEdit; 2; Associated standard action:K56:1; ak copy:K76:54)
	SET MENU ITEM SHORTCUT:C423($tMenuBarEdit; 3; Character code:C91("V"))
	SET MENU ITEM PROPERTY:C973($tMenuBarEdit; 3; Associated standard action:K56:1; ak paste:K76:55)
	
	$tMenuBarCatalog:=Create menu:C408
	INSERT MENU ITEM:C412($tMenuBarCatalog; -1; "Tables")
	INSERT MENU ITEM:C412($tMenuBarCatalog; -1; "(-")
	INSERT MENU ITEM:C412($tMenuBarCatalog; -1; "Relations")
	INSERT MENU ITEM:C412($tMenuBarCatalog; -1; "(-")
	INSERT MENU ITEM:C412($tMenuBarCatalog; -1; "Indexes")
	INSERT MENU ITEM:C412($tMenuBarCatalog; -1; "(-")
	INSERT MENU ITEM:C412($tMenuBarCatalog; -1; "Fields")
	
	SET MENU ITEM SHORTCUT:C423($tMenuBarCatalog; 1; "T"; Command key mask:K16:1)
	SET MENU ITEM SHORTCUT:C423($tMenuBarCatalog; 3; "R"; Command key mask:K16:1)
	SET MENU ITEM SHORTCUT:C423($tMenuBarCatalog; 5; "I"; Command key mask:K16:1)
	SET MENU ITEM SHORTCUT:C423($tMenuBarCatalog; 7; "F"; Command key mask:K16:1)
	
	SET MENU ITEM PROPERTY:C973($tMenuBarCatalog; 1; Associated standard action:K56:1; ak first page:K76:45)
	SET MENU ITEM PARAMETER:C1004($tMenuBarCatalog; 3; "Relations")
	SET MENU ITEM PARAMETER:C1004($tMenuBarCatalog; 5; "Indexes")
	SET MENU ITEM PROPERTY:C973($tMenuBarCatalog; 7; Associated standard action:K56:1; ak last page:K76:46)
	
	$tMenuBarMain:=Create menu:C408
	INSERT MENU ITEM:C412($tMenuBarMain; -1; Get indexed string:C510(79; 1); $tMenuBarFile)
	APPEND MENU ITEM:C411($tMenuBarMain; "Edit"; $tMenuBarEdit)
	APPEND MENU ITEM:C411($tMenuBarMain; "Catalog"; $tMenuBarCatalog)
	
	$tMenuBarRef:=Get menu bar reference:C979(Frontmost process:C327)
	$tCopyMenuBarRef:=Create menu:C408($tMenuBarRef)
	
	SET MENU BAR:C67($tMenuBarMain)
	
	// +++++++++++++++++++++++++++++++++++++++++ end create menu ++++++++++++++++++++++++++++++++++++++
	// +++++++++++++++++++++++++++++++++++++++++ create Help text +++++++++++++++++++++++++++++++++++++
	
	
	$tHelpTxt:="<!DOCTYPE html><html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
	$tHelpTxt:=$tHelpTxt+"<style>* {box-sizing: border-box} body {font-family: \"Lato\", sans-serif;}"
	$tHelpTxt:=$tHelpTxt+"/* Style the tab */"
	$tHelpTxt:=$tHelpTxt+".tab { float: left; border: 1px solid #ccc; width: 20%; height: 550px;}"
	$tHelpTxt:=$tHelpTxt+"/* Style the buttons inside the tab */"
	$tHelpTxt:=$tHelpTxt+".tab button { display: block; background-color: inherit; color: black; padding: 22px 16px; width: 100%; border: none; outline: none; text-align: left; cursor: pointer; transition: 0.3s; font-size: 17px;}"
	$tHelpTxt:=$tHelpTxt+"/* Change background color of buttons on hover */"
	$tHelpTxt:=$tHelpTxt+".tab button:hover {  background-color: #ddd;}"
	$tHelpTxt:=$tHelpTxt+"/* Create an active/current \"tab button\" class */"
	$tHelpTxt:=$tHelpTxt+".tab button.active { background-color: #ccc;}"
	$tHelpTxt:=$tHelpTxt+"/* Style the tab content */"
	$tHelpTxt:=$tHelpTxt+".tabcontent { float: left; padding: 0px 12px; border: 1px solid #ccc; width: 80%; border-left: none; height: 550px;}"
	$tHelpTxt:=$tHelpTxt+"</style></head><body>"
	$tHelpTxt:=$tHelpTxt+"<div class=\"tab\">"
	$tHelpTxt:=$tHelpTxt+"<button class=\"tablinks\" onclick=\"openTab(event, 'Tables')\" id=\"defaultOpen\">Tab 1 - Tables</button>"
	$tHelpTxt:=$tHelpTxt+"<button class=\"tablinks\" onclick=\"openTab(event, 'Relations')\">Tab 2 - Relations</button>"
	$tHelpTxt:=$tHelpTxt+"<button class=\"tablinks\" onclick=\"openTab(event, 'Indexes')\">Tab 3 - Indexes</button>"
	$tHelpTxt:=$tHelpTxt+"<button class=\"tablinks\" onclick=\"openTab(event, 'Fields')\">Tab 4 - Fields</button>"
	$tHelpTxt:=$tHelpTxt+"<button class=\"tablinks\" onclick=\"openTab(event, 'Menu')\">Menu</button>"
	$tHelpTxt:=$tHelpTxt+"<button class=\"tablinks\" onclick=\"openTab(event, 'TableProps')\">Table properties</button>"
	$tHelpTxt:=$tHelpTxt+"<button class=\"tablinks\" onclick=\"openTab(event, 'FieldProps')\">Field properties</button></div>"
	$tHelpTxt:=$tHelpTxt+"<div id=\"Tables\" class=\"tabcontent\">"
	$tHelpTxt:=$tHelpTxt+"<h3>Tables</h3>"
	$tHelpTxt:=$tHelpTxt+"<p>You can reduce the selection of tables by typing in the filter box, filters on table ID and Name</p>"
	$tHelpTxt:=$tHelpTxt+"<p>Select a table to see the table's fields and relations</p>"
	$tHelpTxt:=$tHelpTxt+"<p>Double Click on a field to see the field's relations and composite indexes in Tab 4</p>"
	$tHelpTxt:=$tHelpTxt+"<p>Double Click on a relation to see the details of the relation in Tab 2</p>"
	$tHelpTxt:=$tHelpTxt+"<p>Double click on a table to see table's index information in Tab 3</p></div>"
	$tHelpTxt:=$tHelpTxt+"<div id=\"Relations\" class=\"tabcontent\">"
	$tHelpTxt:=$tHelpTxt+"<h3>Relations</h3>"
	$tHelpTxt:=$tHelpTxt+"<p>You can reduce the selection of relations by typing in the filter box, filters on the content of any column</p>"
	$tHelpTxt:=$tHelpTxt+"<p>Double Click on a relation to see the details of the relation</p>"
	$tHelpTxt:=$tHelpTxt+"<p>Click on the buttons above the field lists to return to Tab 1 with clicked table name selected</p>"
	$tHelpTxt:=$tHelpTxt+"<p>Double Click on a field in either field list to see the field's relations and composite indexes in Tab 4</p></div>"
	$tHelpTxt:=$tHelpTxt+"<div id=\"Indexes\" class=\"tabcontent\">"
	$tHelpTxt:=$tHelpTxt+"<h3>Indexes</h3>"
	$tHelpTxt:=$tHelpTxt+"<p>You can reduce the selection of indexes by typing in the filter box, filters on Ref, Table Name, Field Name and Index Name</p>"
	$tHelpTxt:=$tHelpTxt+"<p>Double Click on an index to see the details (single or composite) of the clicked index</p>"
	$tHelpTxt:=$tHelpTxt+"<p>Double Click on a table to see the details of the indexes (single or composite) of the table</p></div>"
	$tHelpTxt:=$tHelpTxt+"<div id=\"Fields\" class=\"tabcontent\">"
	$tHelpTxt:=$tHelpTxt+"<h3>Fields</h3>"
	$tHelpTxt:=$tHelpTxt+"<p>You can reduce the selection of fields by typing in the filter box, filters on Ref, Table Name, Field Name and Type</p>"
	$tHelpTxt:=$tHelpTxt+"<p>Select any field to see the field's relations and composite indexes of that field, if any</p>"
	$tHelpTxt:=$tHelpTxt+"<p>Double Click on any relation to see the details of the selected relation in Tab 2</p>"
	$tHelpTxt:=$tHelpTxt+"<p>Double Click on any composite index to show all index information of the table that the composite index belongs to</p></div>"
	$tHelpTxt:=$tHelpTxt+"<div id=\"Menu\" class=\"tabcontent\">"
	$tHelpTxt:=$tHelpTxt+"<h3>Menu and Shortcuts</h3>"
	$tHelpTxt:=$tHelpTxt+"<p>You can navigate between the different tabs using Shortcuts Cmd-T, Cmd-R, Cmd-I or Cmd-F</p>"
	$tHelpTxt:=$tHelpTxt+"<p>You can load a different catalog file in the same form using Cmd-L or selecting Load Catalog.. in the File menu</p>"
	$tHelpTxt:=$tHelpTxt+"<p>You can load a different catalog file in a new form holding down the Option-key while selecting Load Catalog.. in the File menu</p></div>"
	$tHelpTxt:=$tHelpTxt+"<div id=\"TableProps\" class=\"tabcontent\">"
	$tHelpTxt:=$tHelpTxt+"<h3>Table Properties</h3>"
	$tHelpTxt:=$tHelpTxt+"<table style=\"width:100%\">"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Primary Key</td><td>Name of the primary key field of the selected table</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Rest</td><td>Table is exposed as a rest resource or not</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Jour</td><td>Table is included in the log file or not</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Cryp</td><td>Table contents can be encrypted or not</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Del</td><td>Records for this table are definitively deleted or not</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Sync</td><td>Replication is enable for this table or not</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Vis</td><td>Table is set visible or not</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>TrI</td><td>Trigger on saving new record is set active or not</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>TrU</td><td>Trigger on updating record is set active or not</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>TrD</td><td>Trigger on deleting record is set active or not</td></tr></table>"
	$tHelpTxt:=$tHelpTxt+"<p>&nbsp</p><p>&nbsp</p><p>&nbsp</p><p>&nbsp</p><p>&nbsp</p>"
	$tHelpTxt:=$tHelpTxt+"<a href=https://doc.4d.com/4Dv20R5/4D/20-R5/Table-properties.300-6855121.en.html>See 4D Documentation</a>"
	$tHelpTxt:=$tHelpTxt+"</div>"
	$tHelpTxt:=$tHelpTxt+"<div id=\"FieldProps\" class=\"tabcontent\">"
	$tHelpTxt:=$tHelpTxt+"<h3>Field Properties</h3>"
	$tHelpTxt:=$tHelpTxt+"<table style=\"width:100%\">"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Type</td><td>The field type</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Len</td><td>The field length (for Alpha fields only)</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>PK</td><td>Checked if the field is the primnary key of the selected the table</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Uni</td><td>Field contents is mandatory unique for every row</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Auto</td><td>Field contents is auto generated (UUID fields)</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>UU</td><td>Field contents is </td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Incr</td><td>Field contents is automatically incremented for each row </td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Ind</td><td>Field is indexed</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Index</td><td>Index type</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>#Ind</td><td>Number of times the field is indexed (single + composite indexes)</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Rest</td><td>Field is exposed as a rest resource or not</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Style</td><td>Queries on this field will ignore multi style tags or not</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Vis</td><td>Field is visible or not</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Man</td><td>Field id mandatory or not</td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Ent</td><td>Field is enterable or not </td></tr>"
	$tHelpTxt:=$tHelpTxt+"<tr><td>Mod</td><td>Field is modifiable or not (#Display only)</td></tr></table>"
	$tHelpTxt:=$tHelpTxt+"<p>&nbsp</p><p>&nbsp</p>"
	$tHelpTxt:=$tHelpTxt+"<a href=https://doc.4d.com/4Dv20R5/4D/20-R5/Field-properties.300-6855112.en.html>See 4D Documentation</a>"
	$tHelpTxt:=$tHelpTxt+"</div>"
	$tHelpTxt:=$tHelpTxt+"<script>"
	$tHelpTxt:=$tHelpTxt+"function openTab(evt, tabName) {"
	$tHelpTxt:=$tHelpTxt+"var i, tabcontent, tablinks;"
	$tHelpTxt:=$tHelpTxt+"tabcontent = document.getElementsByClassName(\"tabcontent\");"
	$tHelpTxt:=$tHelpTxt+"for (i = 0; i < tabcontent.length; i++) {"
	$tHelpTxt:=$tHelpTxt+"tabcontent[i].style.display = \"none\";}"
	$tHelpTxt:=$tHelpTxt+"tablinks = document.getElementsByClassName(\"tablinks\");"
	$tHelpTxt:=$tHelpTxt+"for (i = 0; i < tablinks.length; i++) {"
	$tHelpTxt:=$tHelpTxt+"tablinks[i].className = tablinks[i].className.replace(\" active\", \"\");}"
	$tHelpTxt:=$tHelpTxt+"document.getElementById(tabName).style.display = \"block\";"
	$tHelpTxt:=$tHelpTxt+"evt.currentTarget.className += \" active\";}"
	$tHelpTxt:=$tHelpTxt+"// Get the element with id=\"defaultOpen\" and click on it"+Char:C90(Line feed:K15:40)
	$tHelpTxt:=$tHelpTxt+"document.getElementById(\"defaultOpen\").click();"
	$tHelpTxt:=$tHelpTxt+"</script>"
	$tHelpTxt:=$tHelpTxt+"</body></html> "
	
	// +++++++++++++++++++++++++++++++++++++++ end create Help text +++++++++++++++++++++++++++++++++++
	// +++++++++++++++++++++++++++++++++++++ begin create form layout +++++++++++++++++++++++++++++++++
	$oFormLayout:=New object:C1471
	UT_Catalog_View(New object:C1471("tSubroutine"; "CreateFormLayoutObject"; "oFormLayout"; $oFormLayout))
	
	// ++++++++++++++++++++++++
	If ($bFormToPasteboard)
		$tJSONText:=JSON Stringify:C1217($oFormLayout; *)
		SET TEXT TO PASTEBOARD:C523($tJSONText)  // to compare with original form object in text editor
		
	End if 
	
	// +++++++++++++++++++++++++++++++++++++++ end create form layout ++++++++++++++++++++++++++++++++++
	// ++++++++++++++++++++++++++++++++++++++++ populate FORM object +++++++++++++++++++++++++++++++++++
	
	$oForm:=New object:C1471
	$oForm.tFormName:=$oFormLayout.tMyFormName
	$oForm.tHelpText:=$tHelpTxt
	
	// ++++++++++++++++++++++++++++++++++++++ end populate FORM object +++++++++++++++++++++++++++++++++
	// +++++++++++++++++++++++++++++++++++++++++++ display Form ++++++++++++++++++++++++++++++++++++++++
	
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
	RELEASE MENU:C978($tMenuBarFile)
	RELEASE MENU:C978($tMenuBarEdit)
	RELEASE MENU:C978($tMenuBarCatalog)
	RELEASE MENU:C978($tMenuBarMain)
	
	SET MENU BAR:C67($tCopyMenuBarRef)
	
Else 
	// +++++++++++++++++++++ Beginning of Form event handling and subroutines +++++++++++++++++++++++++
	
	If (Count parameters:C259=0)  // form event handling starts here
		If (FORM Event:C1606.objectName=Null:C1517)  // -> this is the form method part
			If (Form:C1466.tFormName="UT_Catalog_View")
				Case of 
					: (FORM Event:C1606.code=On Load:K2:1)
						Form:C1466.iHelpWindowRef:=0
						POST OUTSIDE CALL:C329(Current process:C322)
						
					: (FORM Event:C1606.code=On Outside Call:K2:11)
						$oReturn:=New object:C1471
						UT_Catalog_View(New object:C1471("tSubroutine"; "SelectCatalog"; "oReturn"; $oReturn))
						
						If ($oReturn.ok=1)
							// +++++++++++++++++++++++++++++++++++++++ Begin parse catalog +++++++++++++++++++++++++++++++++++
							
							$oCatalog:=New object:C1471
							UT_Catalog_View(New object:C1471("tSubroutine"; "ProcessCatalogFile"; "document"; $oReturn.tDocument; "oCatalog"; $oCatalog; "oReturn"; $oReturn))
							If ($oReturn.ok#1)
								CANCEL:C270
								
							Else 
								Form:C1466.oCatalog:=$oCatalog
								
								UT_Catalog_View(New object:C1471("tSubroutine"; "InitFilterVariables"))
								UT_Catalog_View(New object:C1471("tSubroutine"; "InitCollections"))
								
							End if 
						End if 
						// +++++++++++++++++++++++++++++++++++++++ end parse catalog +++++++++++++++++++++++++++++++++++++
						
					: (FORM Event:C1606.code=On Menu Selected:K2:14)
						Case of 
							: (Get selected menu item parameter:C1005="Relations")
								FORM GOTO PAGE:C247(2)
							: (Get selected menu item parameter:C1005="Indexes")
								FORM GOTO PAGE:C247(3)
							: (Get selected menu item parameter:C1005="LoadCatalog")
								If ((Macintosh option down:C545) | (Windows Alt down:C563))
									// +++++++++++++++++++++++++++++++++++++++ Start new process +++++++++++++++++++++++++++++++++++
									$iProcessID:=New process:C317(Current method name:C684; 0)
									
								Else 
									$oReturn:=New object:C1471
									UT_Catalog_View(New object:C1471("tSubroutine"; "SelectCatalog"; "oReturn"; $oReturn))
									
									If ($oReturn.ok=1)
										// +++++++++++++++++++++++++++++++++++++++ Begin parse catalog +++++++++++++++++++++++++++++++++++
										$oCatalog:=New object:C1471
										UT_Catalog_View(New object:C1471("tSubroutine"; "ProcessCatalogFile"; "document"; $oReturn.tDocument; "oCatalog"; $oCatalog; "oReturn"; $oReturn))
										If ($oReturn.ok=1)
											Form:C1466.oCatalog:=$oCatalog
											
											UT_Catalog_View(New object:C1471("tSubroutine"; "InitFilterVariables"))
											UT_Catalog_View(New object:C1471("tSubroutine"; "InitCollections"))
											
											$pPtr:=OBJECT Get pointer:C1124(Object named:K67:5; "FilterValueTables")
											$pPtr->:=""
											$pPtr:=OBJECT Get pointer:C1124(Object named:K67:5; "FilterValueRelations")
											$pPtr->:=""
											$pPtr:=OBJECT Get pointer:C1124(Object named:K67:5; "FilterValueIndexes")
											$pPtr->:=""
											$pPtr:=OBJECT Get pointer:C1124(Object named:K67:5; "FilterValueFields")
											$pPtr->:=""
											
										End if 
									End if 
								End if 
								
						End case 
						
					: (FORM Event:C1606.code=On Page Change:K2:54)
						// do nothing
						
					: (FORM Event:C1606.code=On Unload:K2:2)
						// do nothing
						
					: (FORM Event:C1606.code=On Close Box:K2:21)
						CANCEL:C270
						
				End case 
			Else 
				Case of 
					: (FORM Event:C1606.code=On Close Box:K2:21)
						CANCEL:C270
						
				End case 
			End if 
			
		Else   // below are all the object methods
			Case of 
				: (FORM Event:C1606.objectName="btnClearTablesFilter")
					$pPtr:=OBJECT Get pointer:C1124(Object named:K67:5; "FilterValueTables")
					If ($pPtr->#"")
						$pPtr->:=""
						//Form.iFiltTables:=Form.oCatalog.iTotalTables
						Form:C1466.colTables:=Form:C1466.oCatalog.colTables
						LISTBOX SELECT ROW:C912(*; "lbTables"; 1)
						OBJECT SET SCROLL POSITION:C906(*; "lbTables"; 1)
						
						UT_Catalog_View(New object:C1471("tSubroutine"; "ShowTable"; "tTableToShow"; Form:C1466.colTables[0].name))
						
					End if 
					
					
				: (FORM Event:C1606.objectName="btnClearRelationsFilter")
					$pPtr:=OBJECT Get pointer:C1124(Object named:K67:5; "FilterValueRelations")
					If ($pPtr->#"")
						$pPtr->:=""
						Form:C1466.colRelationsAll:=Form:C1466.oCatalog.colRelations
						LISTBOX SELECT ROW:C912(*; "lbRelationsAll"; 1)
						OBJECT SET SCROLL POSITION:C906(*; "lbRelationsAll"; 1)
						
						If (Form:C1466.currentRelation=Null:C1517)
							Form:C1466.currentRelation:=Form:C1466.colRelationsAll[0]
						End if 
						
						$oParam:=New object:C1471
						$oParam.tSubroutine:="ShowRelations"
						$oParam.destinationTable:=Form:C1466.currentRelation.destinationTable
						$oParam.sourceTable:=Form:C1466.currentRelation.sourceTable
						$oParam.destinationField:=Form:C1466.currentRelation.destinationField
						$oParam.sourceField:=Form:C1466.currentRelation.sourceField
						$oParam.name_1toN:=Form:C1466.currentRelation.name_1toN
						$oParam.name_Nto1:=Form:C1466.currentRelation.name_Nto1
						$oParam.relationRef:=Form:C1466.currentRelation.ref
						UT_Catalog_View($oParam)
						
					End if 
					
					
				: (FORM Event:C1606.objectName="btnClearIndexesFilter")
					$pPtr:=OBJECT Get pointer:C1124(Object named:K67:5; "FilterValueIndexes")
					If ($pPtr->#"")
						$pPtr->:=""
						Form:C1466.iFiltIndexes:=Form:C1466.oCatalog.iTotalIndexes
						Form:C1466.colIndexesAll:=Form:C1466.oCatalog.colIndexes
						LISTBOX SELECT ROW:C912(*; "lbIndexesAll"; 1)
						OBJECT SET SCROLL POSITION:C906(*; "lbIndexesAll"; 1)
						
						UT_Catalog_View(New object:C1471("tSubroutine"; "ShowIndexes"; "tTableToShow"; Form:C1466.colIndexesAll[0].tableName))
						
					End if 
					
					
				: (FORM Event:C1606.objectName="btnClearFieldsFilter")
					$pPtr:=OBJECT Get pointer:C1124(Object named:K67:5; "FilterValueFields")
					If ($pPtr->#"")
						$pPtr->:=""
						Form:C1466.iFiltFields:=Form:C1466.oCatalog.iTotalFields
						Form:C1466.colFieldsAll:=Form:C1466.oCatalog.colFields
						
						If (Form:C1466.currentField=Null:C1517)
							Form:C1466.currentField:=Form:C1466.colFieldsAll[0]
						End if 
						
						$oParam:=New object:C1471
						$oParam.tSubroutine:="ShowFields"
						$oParam.ref:=Form:C1466.currentField.ref
						$oParam.tableName:=Form:C1466.currentField.tableName
						$oParam.fieldName:=Form:C1466.currentField.name
						UT_Catalog_View($oParam)
						
					End if 
					
					
				: (FORM Event:C1606.objectName="btnHelp")
					Case of 
						: (Form event code:C388=On Clicked:K2:4)
							
							$bHelpWindowIsOpen:=False:C215
							
							If (Form:C1466.iHelpWindowRef#0)
								ARRAY LONGINT:C221($aiWindowRefs; 0)
								WINDOW LIST:C442($aiWindowRefs)
								If (Find in array:C230($aiWindowRefs; Form:C1466.iHelpWindowRef)>0)
									$bHelpWindowIsOpen:=True:C214
								End if 
							End if 
							
							If (Not:C34($bHelpWindowIsOpen))
								$iScreen:=0
								$iNumScreens:=Count screens:C437
								GET WINDOW RECT:C443($iLeftWR; $iTopWR; $iRightWR; $iBottomWR; Frontmost window:C447)
								
								For ($iCntr; 1; $iNumScreens)
									SCREEN COORDINATES:C438($iLeftSC; $iTopSC; $iRightSC; $iBottomSC; $iCntr)
									If (($iLeftWR>=$iLeftSC) & ($iTopWR>=$iTopSC) & ($iRightWR<=$iRightSC) & ($iBottomWR<=$iBottomSC))
										$iScreen:=$iCntr  // this is the active monitor
									End if 
								End for 
								
								SCREEN COORDINATES:C438($iLeft; $iTop; $iRight; $iBottom; $iScreen)
								$iMaxWidth:=$iRight-$iLeft
								$iMaxHeight:=$iBottom-$iTop
								
								GET WINDOW RECT:C443($iLeft; $iTop; $iRight; $iBottom)
								$iCurrentWindowWidth:=$iRight-$iLeft
								$iCurrentWindowHeight:=$iBottom-$iTop
								$iCenterWidth:=$iLeft+($iCurrentWindowWidth/2)
								$iCenterHeight:=$iTop+($iCurrentWindowHeight/2)
								
								// +++++++++++++++++++++++++++++++++++++ create Help form layout +++++++++++++++++++++++++++++++++
								$oFormLayout:=New object:C1471
								UT_Catalog_View(New object:C1471("tSubroutine"; "CreateFormLayoutObjectHelp"; "oFormLayout"; $oFormLayout))
								
								// +++++++++++++++++++++++++++++++++++ create Help form FORM object ++++++++++++++++++++++++++++++
								$oForm:=New object:C1471
								$oForm.tHelpText:=Form:C1466.tHelpText
								$oForm.tFormName:=$oFormLayout.tMyFormName
								
								// +++++++++++++++++++++++++++++++++++++ display Help form ++++++++++++++++++++++++++++++++++++++++
								If ($oFormLayout.destination=Null:C1517)
									$iWindowRef:=Open form window:C675("UT_Catalog_Help"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
								Else 
									$iWindowRef:=Open form window:C675($oFormLayout; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
								End if 
								Form:C1466.iHelpWindowRef:=$iWindowRef
								
								GET WINDOW RECT:C443($iLeft2; $iTop2; $iRight2; $iBottom2; $iWindowRef)
								$iNewWindowWidth:=$iRight2-$iLeft2
								$iNewWindowHeight:=$iBottom2-$iTop2
								If ($iNewWindowWidth>$iMaxWidth)
									$iNewWindowWidth:=$iMaxWidth-40
								End if 
								If ($iNewWindowHeight>$iMaxHeight)
									$iNewWindowHeight:=$iMaxHeight-60
								End if 
								
								SET WINDOW RECT:C444($iCenterWidth-($iNewWindowWidth/2); $iCenterHeight-($iNewWindowHeight/2); $iCenterWidth-($iNewWindowWidth/2)+$iNewWindowWidth; $iCenterHeight-($iNewWindowHeight/2)+$iNewWindowHeight; $iWindowRef)
								
								If ($oFormLayout.destination=Null:C1517)
									$oForm.tFormName:="UT_Catalog_Help"
									DIALOG:C40("UT_Catalog_Help"; $oForm)
									
								Else 
									DIALOG:C40($oFormLayout; $oForm; *)
									
								End if 
								
							Else 
								SHOW WINDOW:C435(Form:C1466.iHelpWindowRef)
								BRING TO FRONT:C326(Current process:C322)
								
							End if 
							
					End case 
					
					
				: (FORM Event:C1606.objectName="helpText")
					DELAY PROCESS:C323(Current process:C322; 20)  // nothing shows if you remove this
					Case of 
						: (Form event code:C388=On Load:K2:1)
							WA SET PAGE CONTENT:C1037(*; "helpText"; Form:C1466.tHelpText; "file:///")
							
					End case 
					
					
				: (FORM Event:C1606.objectName="FilterValueTables")
					Case of 
						: (Form event code:C388=On After Keystroke:K2:26)
							Form:C1466.oFilterParam.tEditedText:=Get edited text:C655
							
							UT_Catalog_View(New object:C1471("tSubroutine"; "DoFilter"; "tFilterObjectName"; FORM Event:C1606.objectName))
							
					End case 
					
					
				: (FORM Event:C1606.objectName="lbTables")
					LISTBOX GET CELL POSITION:C971(*; "lbTables"; $iCol; $iRow)
					Case of 
						: (FORM Event:C1606.code=On Selection Change:K2:29)
							If ($iRow>0)
								Form:C1466.colTableFields:=Form:C1466.currentTable.colFields
								//Form.currentTable:=Form.oCatalog.colTables[$iRow-1]
								//Form.currentTablePos:=1
								//Form.currentTableSel:=Form.oCatalog.colTables[$iRow-1]
								If (Form:C1466.colTableFields.length>0)
									Form:C1466.currentField:=Form:C1466.colTableFields[0]
									Form:C1466.currentFieldPos:=1
									Form:C1466.currentFieldSel:=Form:C1466.colTableFields[0]
								End if 
								Form:C1466.colRelationsByTable:=Form:C1466.oCatalog.colRelations.query("destinationTable = :1 OR sourceTable = :2"; Form:C1466.currentTable.name; Form:C1466.currentTable.name)
								If (Form:C1466.colRelationsByTable.length>0)
									Form:C1466.currentRelationByTable:=Form:C1466.colRelationsByTable
									Form:C1466.currentRelationByTablePos:=1
									Form:C1466.currentRelationByTableSel:=Form:C1466.colRelationsByTable
								End if 
							End if 
							
							
						: (FORM Event:C1606.code=On Double Clicked:K2:5)
							If ($iRow>0)
								Form:C1466.colIndexesAll:=Form:C1466.oCatalog.colIndexes
								$pPtr:=OBJECT Get pointer:C1124(Object named:K67:5; "FilterValueIndexes")
								$pPtr->:=""
								Form:C1466.iFiltIndexes:=Form:C1466.oCatalog.iTotalIndexes
								
								$colTemp1:=Form:C1466.colTables3.indices("name = :1"; Form:C1466.currentTable.name)
								$iPosition:=$colTemp1[0]+1
								
								LISTBOX SELECT ROW:C912(*; "lbTables3"; $iPosition)
								OBJECT SET SCROLL POSITION:C906(*; "lbTables3"; $iPosition)
								
								UT_Catalog_View(New object:C1471("tSubroutine"; "ShowIndexes"; "tTableToShow"; Form:C1466.currentTable.name))
								
								LISTBOX SELECT ROW:C912(*; "lbIndexesAll"; 0; lk remove from selection:K53:3)
								OBJECT SET SCROLL POSITION:C906(*; "lbIndexesAll"; 0)
								
								FORM GOTO PAGE:C247(3)
								
							End if 
					End case 
					
					
				: ((FORM Event:C1606.objectName="lbTableFields") | (FORM Event:C1606.objectName="lbFieldsAll"))
					
					If (FORM Event:C1606.objectName="lbTableFields")
						LISTBOX GET CELL POSITION:C971(*; "lbTableFields"; $iCol; $iRow)
						Case of 
							: (Form event code:C388=On Double Clicked:K2:5)
								If ($iRow>0)
									$oParam:=New object:C1471
									$oParam.tSubroutine:="ShowFields"
									$oParam.ref:=Form:C1466.currentTableField.ref
									$oParam.tableName:=Form:C1466.currentTable.name
									$oParam.fieldName:=Form:C1466.currentTableField.name
									UT_Catalog_View($oParam)
									
								End if 
								
						End case 
						
					Else   //  FORM Event.objectName="lbFieldsAll"
						LISTBOX GET CELL POSITION:C971(*; "lbFieldsAll"; $iCol; $iRow)
						Case of 
							: (FORM Event:C1606.code=On Display Detail:K2:22)
								If (This:C1470.indexed)
									$colTemp1:=Form:C1466.colIndexesAll.query("tableName = :1 and fieldName = :2"; This:C1470.tableName; This:C1470.name)
									If ($colTemp1.length>=1)
										This:C1470.indexType:=$colTemp1[0].type
									Else 
										This:C1470.indexType:=""
									End if 
								Else 
									This:C1470.indexType:=""
								End if 
								
							: (FORM Event:C1606.code=On Selection Change:K2:29)
								If ($iRow>0)
									$tQueryString:="(destinationTable = :1 and destinationField = :2) or(sourceTable = :3 and sourceField = :4))"
									Form:C1466.relationsField:=Form:C1466.oCatalog.colRelations.query($tQueryString; Form:C1466.currentField.tableName; Form:C1466.currentField.name; Form:C1466.currentField.tableName; Form:C1466.currentField.name)
									Form:C1466.iRelationsForField:=Form:C1466.relationsField.length
									
									$tQueryString:="(tableName = :1 and fieldName = :2 and isCompositeIndex = :3)"
									Form:C1466.tableIndexesComposite2:=Form:C1466.oCatalog.colIndexes.query($tQueryString; Form:C1466.currentField.tableName; Form:C1466.currentField.name; True:C214)
									Form:C1466.iCompositeIdxForField:=Form:C1466.tableIndexesComposite2.length
									
								End if 
						End case 
						
					End if 
					
					
				: (FORM Event:C1606.objectName="lbRelationsByTable")
					LISTBOX GET CELL POSITION:C971(*; "lbRelationsByTable"; $iCol; $iRow)
					Case of 
						: (FORM Event:C1606.code=On Double Clicked:K2:5)
							If ($iRow>0)
								$oParam:=New object:C1471
								$oParam.tSubroutine:="ShowRelations"
								$oParam.destinationTable:=Form:C1466.currentRelationByTable.destinationTable
								$oParam.sourceTable:=Form:C1466.currentRelationByTable.sourceTable
								$oParam.destinationField:=Form:C1466.currentRelationByTable.destinationField
								$oParam.sourceField:=Form:C1466.currentRelationByTable.sourceField
								$oParam.name_1toN:=Form:C1466.currentRelationByTable.name_1toN
								$oParam.name_Nto1:=Form:C1466.currentRelationByTable.name_Nto1
								$oParam.relationRef:=Form:C1466.currentRelationByTable.ref
								UT_Catalog_View($oParam)
								
							End if 
					End case 
					
					
				: (FORM Event:C1606.objectName="FilterValueRelations")
					Case of 
						: (Form event code:C388=On After Keystroke:K2:26)
							Form:C1466.oFilterParam.tEditedText:=Get edited text:C655
							
							UT_Catalog_View(New object:C1471("tSubroutine"; "DoFilter"; "tFilterObjectName"; FORM Event:C1606.objectName))
							OBJECT SET TITLE:C194(*; "btnDestinationTable"; "")
							OBJECT SET TITLE:C194(*; "btnSourceTable"; "")
							
					End case 
					
					
				: (FORM Event:C1606.objectName="lbRelationsAll")
					LISTBOX GET CELL POSITION:C971(*; "lbRelationsAll"; $iCol; $iRow)
					Case of 
						: (FORM Event:C1606.code=On Selection Change:K2:29)
							If ($iRow>0)
								Form:C1466.tDestinationTable:=Form:C1466.currentRelation.destinationTable
								Form:C1466.tSourceTable:=Form:C1466.currentRelation.sourceTable
								Form:C1466.tRelationName_1toN:=Form:C1466.currentRelation.name_1toN
								Form:C1466.tRelationName_Nto1:=Form:C1466.currentRelation.name_Nto1
								OBJECT SET TITLE:C194(*; "btnDestinationTable"; Form:C1466.tDestinationTable)
								OBJECT SET TITLE:C194(*; "btnSourceTable"; Form:C1466.tSourceTable)
								
								$colTemp1:=Form:C1466.oCatalog.colTables.query("name = :1"; Form:C1466.tSourceTable)
								Form:C1466.sourceFields:=$colTemp1[0].colFields
								$colTemp2:=Form:C1466.sourceFields.indices("name = :1"; Form:C1466.currentRelation.sourceField)
								$iPosition:=$colTemp2[0]+1
								LISTBOX SELECT ROW:C912(*; "lbSourceFields"; $iPosition)
								OBJECT SET SCROLL POSITION:C906(*; "lbSourceFields"; $iPosition)
								
								$colTemp1:=Form:C1466.oCatalog.colTables.query("name = :1"; Form:C1466.tDestinationTable)
								Form:C1466.destinationFields:=$colTemp1[0].colFields
								$colTemp2:=Form:C1466.destinationFields.indices("name = :1"; Form:C1466.currentRelation.destinationField)
								$iPosition:=$colTemp2[0]+1
								LISTBOX SELECT ROW:C912(*; "lbDestinationFields"; $iPosition)
								OBJECT SET SCROLL POSITION:C906(*; "lbDestinationFields"; $iPosition)
								
							End if 
					End case 
					
					Form:C1466.sourceFields:=Form:C1466.sourceFields  // to force the update of the list of fields
					Form:C1466.destinationFields:=Form:C1466.destinationFields  // to force the update of the list of fields
					
					
				: (FORM Event:C1606.objectName="btnDestinationTable") | (FORM Event:C1606.objectName="btnSourceTable")
					If (FORM Event:C1606.code=On Clicked:K2:4)
						If (FORM Event:C1606.objectName="btnDestinationTable")
							UT_Catalog_View(New object:C1471("tSubroutine"; "ShowTable"; "tTableToShow"; Form:C1466.tDestinationTable))
						Else 
							UT_Catalog_View(New object:C1471("tSubroutine"; "ShowTable"; "tTableToShow"; Form:C1466.tSourceTable))
						End if 
					End if 
					
					
				: (FORM Event:C1606.objectName="lbDestinationFields")
					LISTBOX GET CELL POSITION:C971(*; "lbDestinationFields"; $iCol; $iRow)
					Case of 
						: (FORM Event:C1606.code=On Double Clicked:K2:5)
							If ($iRow>0)
								$oParam:=New object:C1471
								$oParam.tSubroutine:="ShowFields"
								$oParam.ref:=Form:C1466.currentDestinationField.ref
								$oParam.tableName:=Form:C1466.tDestinationTable
								$oParam.fieldName:=Form:C1466.currentDestinationField.name
								UT_Catalog_View($oParam)
								
							End if 
					End case 
					
					
				: (FORM Event:C1606.objectName="lbSourceFields")
					LISTBOX GET CELL POSITION:C971(*; "lbSourceFields"; $iCol; $iRow)
					Case of 
						: (FORM Event:C1606.code=On Double Clicked:K2:5)
							If ($iRow>0)
								$oParam:=New object:C1471
								$oParam.tSubroutine:="ShowFields"
								$oParam.ref:=Form:C1466.currentSourceField.ref
								$oParam.tableName:=Form:C1466.tSourceTable
								$oParam.fieldName:=Form:C1466.currentSourceField.name
								UT_Catalog_View($oParam)
								
							End if 
					End case 
					
					
				: (FORM Event:C1606.objectName="lbTables3")
					LISTBOX GET CELL POSITION:C971(*; "lbTables3"; $iCol; $iRow)
					Case of 
						: (FORM Event:C1606.code=On Selection Change:K2:29)
							If ($iRow>0)
								Form:C1466.colIndexesAll:=Form:C1466.oCatalog.colIndexes
								$pPtr:=OBJECT Get pointer:C1124(Object named:K67:5; "FilterValueIndexes")
								$pPtr->:=""
								Form:C1466.iFiltIndexes:=Form:C1466.oCatalog.iTotalIndexes
								
								UT_Catalog_View(New object:C1471("tSubroutine"; "ShowIndexes"; "tTableToShow"; Form:C1466.currentTable3.name))
							End if 
							
						: (FORM Event:C1606.code=On Double Clicked:K2:5)
							If ($iRow>0)
								UT_Catalog_View(New object:C1471("tSubroutine"; "ShowTable"; "tTableToShow"; Form:C1466.currentTable3.name))
							End if 
							
					End case 
					
					
				: (FORM Event:C1606.objectName="lbTableIndexesSingle")
					LISTBOX GET CELL POSITION:C971(*; "lbTableIndexesSingle"; $iCol; $iRow)
					Case of 
						: (FORM Event:C1606.code=On Clicked:K2:4)
							If ($iRow>0)
								$colTemp1:=Form:C1466.tableIndexesComposite.query("fieldName = :1"; Form:C1466.currentTableIndexSingle.fieldName)
								LISTBOX SELECT ROWS:C1715(*; "lbtableIndexesComposite"; $colTemp1; lk replace selection:K53:1)
								
							End if 
					End case 
					
					
				: (FORM Event:C1606.objectName="FilterValueIndexes")
					Case of 
						: (Form event code:C388=On After Keystroke:K2:26)
							Form:C1466.oFilterParam.tEditedText:=Get edited text:C655
							UT_Catalog_View(New object:C1471("tSubroutine"; "DoFilter"; "tFilterObjectName"; FORM Event:C1606.objectName))
							
					End case 
					
					
				: (FORM Event:C1606.objectName="lbIndexesAll")
					LISTBOX GET CELL POSITION:C971(*; "lbIndexesAll"; $iCol; $iRow)
					Case of 
						: (FORM Event:C1606.code=On Selection Change:K2:29)
							If ($iRow>0)
								$colTemp1:=Form:C1466.colTables3.indices("name = :1"; Form:C1466.currentIndex.tableName)
								$iPosition:=$colTemp1[0]+1
								
								Form:C1466.currentTable3:=Form:C1466.oCatalog.colTables[$colTemp1[0]]
								Form:C1466.currentTable3Pos:=$iPosition
								Form:C1466.currentTable3Sel:=Form:C1466.oCatalog.colTables[$colTemp1[0]]
								
								LISTBOX SELECT ROW:C912(*; "lbTables3"; $iPosition)
								OBJECT SET SCROLL POSITION:C906(*; "lbTables3"; $iPosition)
								
								UT_Catalog_View(New object:C1471("tSubroutine"; "ShowIndexes"; "tTableToShow"; Form:C1466.currentTable3.name))
								
							End if 
					End case 
					
					
				: (FORM Event:C1606.objectName="FilterValueFields")
					Case of 
						: (Form event code:C388=On After Keystroke:K2:26)
							Form:C1466.oFilterParam.tEditedText:=Get edited text:C655
							UT_Catalog_View(New object:C1471("tSubroutine"; "DoFilter"; "tFilterObjectName"; FORM Event:C1606.objectName))
							
					End case 
					
					
				: (FORM Event:C1606.objectName="lbRelationsField")
					LISTBOX GET CELL POSITION:C971(*; "lbRelationsField"; $iCol; $iRow)
					Case of 
						: (FORM Event:C1606.code=On Double Clicked:K2:5)
							If ($iRow>0)
								$oParam:=New object:C1471
								$oParam.tSubroutine:="ShowRelations"
								$oParam.destinationTable:=Form:C1466.currentRelationField.destinationTable
								$oParam.sourceTable:=Form:C1466.currentRelationField.sourceTable
								$oParam.destinationField:=Form:C1466.currentRelationField.destinationField
								$oParam.sourceField:=Form:C1466.currentRelationField.sourceField
								$oParam.name_1toN:=Form:C1466.currentRelationField.name_1toN
								$oParam.name_Nto1:=Form:C1466.currentRelationField.name_Nto1
								$oParam.relationRef:=Form:C1466.currentRelationField.ref
								UT_Catalog_View($oParam)
								
							End if 
					End case 
					
					
				: (FORM Event:C1606.objectName="lbtableIndexesComposite2")
					LISTBOX GET CELL POSITION:C971(*; "lbtableIndexesComposite2"; $iCol; $iRow)
					Case of 
						: (FORM Event:C1606.code=On Double Clicked:K2:5)
							Form:C1466.colTables3:=Form:C1466.oCatalog.colTables
							
							$colTemp1:=Form:C1466.oCatalog.colIndexes.query("indexName = :1"; Form:C1466.currentTableIndexComposite2.indexName)
							$colTemp2:=Form:C1466.colTables3.indices("name = :1"; $colTemp1[0].tableName)
							$iPosition:=$colTemp2[0]+1
							
							Form:C1466.currentTable3:=Form:C1466.colTables3[$colTemp2[0]]
							Form:C1466.currentTable3Pos:=$iPosition
							Form:C1466.currentTable3Sel:=Form:C1466.colTables3[$colTemp2[0]]
							
							LISTBOX SELECT ROW:C912(*; "lbTables3"; $iPosition)
							OBJECT SET SCROLL POSITION:C906(*; "lbTables3"; $iPosition)
							
							UT_Catalog_View(New object:C1471("tSubroutine"; "ShowIndexes"; "tTableToShow"; Form:C1466.currentTable3.name))
							
							FORM GOTO PAGE:C247(3)
							
					End case 
			End case 
			
		End if 
		
	Else   // start of all the sub-routines - method has been called from within - parameters + return values in $oParam
		$oParam:=$1
		
		If ($oParam.tSubroutine#Null:C1517)
			Case of 
				: ($oParam.tSubroutine="SelectCatalog")
					$tDocument:=Select document:C905(""; ".4DCATALOG"; "Select catalog file"; Package open:K24:8)
					If (ok=1)
						$oParam.oReturn.ok:=1
						$oParam.oReturn.tDocument:=document
						
					Else 
						$oParam.oReturn.ok:=0
						$oParam.oReturn.tError:="No document selected"
						
					End if 
					
				: ($oParam.tSubroutine="ProcessCatalogFile")
					GET WINDOW RECT:C443($iLeft; $iTop; $iRight; $iBottom)
					
					$iProgress:=Progress New
					Progress SET WINDOW VISIBLE(True:C214; ($iLeft+((($iRight-$iLeft)/2)-150)); ($iTop+((($iBottom-$iTop))/2)-30); True:C214)
					Progress SET TITLE($iProgress; "Processing Catalog XML"; -1; ""; True:C214)
					
					$oParam.oReturn.ok:=1
					$oCatalog:=$oParam.oCatalog
					$tXMLText:=Document to text:C1236($oParam.document)
					
					$tXMLRef:=DOM Parse XML variable:C720($tXMLText)
					$iAttributes:=DOM Count XML attributes:C727($tXMLRef)
					ARRAY TEXT:C222($atAttribName; $iAttributes)
					ARRAY TEXT:C222($atAttribVal; $iAttributes)
					
					For ($iCntrAttrib; 1; $iAttributes)
						DOM GET XML ATTRIBUTE BY INDEX:C729($tXMLRef; $iCntrAttrib; $atAttribName{$iCntrAttrib}; $atAttribVal{$iCntrAttrib})
					End for 
					
					$iPosition:=Find in array:C230($atAttribName; "name")
					$oCatalog.nameCatalog:=$atAttribVal{$iPosition}
					$oCatalog.iTotalTables:=DOM Count XML elements:C726($tXMLRef; "table")
					$oCatalog.iTotalIndexes:=DOM Count XML elements:C726($tXMLRef; "index")
					$oCatalog.iTotalRelations:=DOM Count XML elements:C726($tXMLRef; "relation")
					
					$iCntrTables:=0
					$iCntrRelations:=0
					$iCntrIndexes:=0
					
					$colTables:=New collection:C1472
					$colRelations:=New collection:C1472
					$colIndexes:=New collection:C1472
					$colFields:=New collection:C1472
					
					$tXMLElementRef:=DOM Get first child XML element:C723($tXMLRef; $tName; $tValue)  // this is "schema", but we skip it
					
					$bStopProcessing:=False:C215
					Repeat 
						$tXMLElementRef:=DOM Get next sibling XML element:C724($tXMLElementRef; $tName; $tValue)
						If (Ok=0)
							$bStopProcessing:=True:C214
							
						Else 
							Case of 
									// +++++++++++++++++++++++++++++++++++++++ begin processing tables +++++++++++++++++++++++++++++++++++
								: ($tName="table")
									$oTable:=New object:C1471
									$iAttributes:=DOM Count XML attributes:C727($tXMLElementRef)
									ARRAY TEXT:C222($atAttribTableName; $iAttributes)
									ARRAY TEXT:C222($atAttribTableVal; $iAttributes)
									
									For ($iCntrAttrib; 1; $iAttributes)
										DOM GET XML ATTRIBUTE BY INDEX:C729($tXMLElementRef; $iCntrAttrib; $atAttribTableName{$iCntrAttrib}; $atAttribTableVal{$iCntrAttrib})
									End for 
									
									$iPosition:=Find in array:C230($atAttribTableName; "name")
									$oTable.name:=$atAttribTableVal{$iPosition}
									$iPosition:=Find in array:C230($atAttribTableName; "id")
									$oTable.id:=Num:C11($atAttribTableVal{$iPosition})
									
									$oTable.primaryKey:=""
									$oTable.restAccess:=True:C214
									$oTable.inJournal:=True:C214
									$oTable.syncInfo:=False:C215
									$oTable.encryptable:=False:C215
									$oTable.deleteTag:=False:C215
									
									$oTable.visible:=True:C214  // in table extra
									$oTable.triggerLoad:=False:C215  // in table extra
									$oTable.triggerInsert:=False:C215  // in table extra
									$oTable.triggerUpdate:=False:C215  // in table extra
									$oTable.triggerDelete:=False:C215  // in table extra
									
									$iPosition:=Find in array:C230($atAttribTableName; "hide_in_REST")
									If ($iPosition>0)
										If ($atAttribTableVal{$iPosition}="True")
											$oTable.restAccess:=False:C215
										End if 
									End if 
									
									$iPosition:=Find in array:C230($atAttribTableName; "prevent_journaling")
									If ($iPosition>0)
										If ($atAttribTableVal{$iPosition}="True")
											$oTable.inJournal:=False:C215
										End if 
									End if 
									
									$iPosition:=Find in array:C230($atAttribTableName; "keep_record_sync_info")
									If ($iPosition>0)
										If ($atAttribTableVal{$iPosition}="True")
											$oTable.syncInfo:=True:C214
										End if 
									End if 
									
									$iPosition:=Find in array:C230($atAttribTableName; "encryptable")
									If ($iPosition>0)
										If ($atAttribTableVal{$iPosition}="True")
											$oTable.encryptable:=True:C214
										End if 
									End if 
									
									$iPosition:=Find in array:C230($atAttribTableName; "leave_tag_on_delete")
									If ($iPosition>0)
										If ($atAttribTableVal{$iPosition}="True")
											$oTable.deleteTag:=False:C215
										End if 
									End if 
									
									$tXMLElementFieldRef:=DOM Get first child XML element:C723($tXMLElementRef; $tChildName; $tChildValue)
									If (Ok=1)
										
										Case of 
											: ($tChildName="field")
												$oTable.colFields:=New collection:C1472
												
												UT_Catalog_View(New object:C1471("tSubroutine"; "ProcessField"; "node"; $tXMLElementFieldRef; "collection"; $oTable.colFields; "collectionAllFields"; $colFields; "tableName"; $oTable.name; "tableID"; $oTable.id))
												
												$bStopField:=False:C215
												Repeat 
													$tXMLElementFieldRef:=DOM Get next sibling XML element:C724($tXMLElementFieldRef; $tChildName; $tChildValue)
													If (Ok=0)
														$bStopField:=True:C214
														
													Else 
														Case of 
															: ($tChildName="field")
																UT_Catalog_View(New object:C1471("tSubroutine"; "ProcessField"; "node"; $tXMLElementFieldRef; "collection"; $oTable.colFields; "collectionAllFields"; $colFields; "tableName"; $oTable.name; "tableID"; $oTable.id))
																
															: ($tChildName="primary_key")
																$tPKName:=""
																DOM GET XML ATTRIBUTE BY NAME:C728($tXMLElementFieldRef; "field_name"; $tPKName)
																$oTable.primaryKey:=$tPKName
																
																// set checkbox for Primary Key field
																$colTemp1:=$oTable.colFields.query("name = :1"; $tPKName)
																If ($colTemp1.length=1)
																	$colTemp1[0].primaryKey:=True:C214
																End if 
																
															: ($tChildName="table_extra")
																$iAttributes:=DOM Count XML attributes:C727($tXMLElementFieldRef)
																ARRAY TEXT:C222($atAttribName; $iAttributes)
																ARRAY TEXT:C222($atAttribValue; $iAttributes)
																
																For ($iCntrAttrib; 1; $iAttributes)
																	DOM GET XML ATTRIBUTE BY INDEX:C729($tXMLElementFieldRef; $iCntrAttrib; $atAttribName{$iCntrAttrib}; $atAttribValue{$iCntrAttrib})
																End for 
																
																$iPosition:=Find in array:C230($atAttribName; "visible")
																If ($iPosition>0)
																	If ($atAttribValue{$iPosition}="False")
																		$oTable.visible:=False:C215
																	End if 
																End if 
																
																$iPosition:=Find in array:C230($atAttribName; "trigger_insert")
																If ($iPosition>0)
																	If ($atAttribValue{$iPosition}="True")
																		$oTable.triggerInsert:=True:C214
																	End if 
																End if 
																
																$iPosition:=Find in array:C230($atAttribName; "trigger_delete")
																If ($iPosition>0)
																	If ($atAttribValue{$iPosition}="True")
																		$oTable.triggerDelete:=True:C214
																	End if 
																End if 
																
																$iPosition:=Find in array:C230($atAttribName; "trigger_update")
																If ($iPosition>0)
																	If ($atAttribValue{$iPosition}="True")
																		$oTable.triggerUpdate:=True:C214
																	End if 
																End if 
																
															Else 
																TRACE:C157
																
														End case 
													End if 
													
												Until ($bStopField=True:C214)
												
											Else 
												TRACE:C157
												
										End case 
										
										$colTables.push($oTable)
										$iCntrTables:=$iCntrTables+1
										
									End if 
									
									// +++++++++++++++++++++++++++++++++++++++ end processing tables +++++++++++++++++++++++++++++++++++++
									// ++++++++++++++++++++++++++++++++++++ begin processing relations +++++++++++++++++++++++++++++++++++
								: ($tName="relation")
									UT_Catalog_View(New object:C1471("tSubroutine"; "ProcessRelation"; "node"; $tXMLElementRef; "collection"; $colRelations))
									
									$iCntrRelations:=$iCntrRelations+1
									
									// +++++++++++++++++++++++++++++++++++++ end processing relations +++++++++++++++++++++++++++++++++++++
									// +++++++++++++++++++++++++++++++++++++ begin processing indexes +++++++++++++++++++++++++++++++++++++
								: ($tName="index")
									$bCompositeIndex:=False:C215
									
									$iAttributes:=DOM Count XML attributes:C727($tXMLElementRef)
									ARRAY TEXT:C222($atAttribIndexName; $iAttributes)
									ARRAY TEXT:C222($atAttribIndexValue; $iAttributes)
									
									For ($iCntrAttrib; 1; $iAttributes)
										DOM GET XML ATTRIBUTE BY INDEX:C729($tXMLElementRef; $iCntrAttrib; $atAttribIndexName{$iCntrAttrib}; $atAttribIndexValue{$iCntrAttrib})
									End for 
									
									$iPosition:=Find in array:C230($atAttribIndexName; "name")
									If ($iPosition>0)
										$tIndexName:=$atAttribIndexValue{$iPosition}
									Else 
										$tIndexName:=""
									End if 
									
									$iPosition:=Find in array:C230($atAttribIndexName; "type")
									If ($iPosition>0)
										$tIndexType:=$atAttribIndexValue{$iPosition}
									Else 
										$tIndexType:=""
									End if 
									Case of 
										: ($tIndexType="1")
											$tIndexType:="B-Tree"
										: ($tIndexType="3")
											$tIndexType:="Cluster"
										: ($tIndexType="7")
											$tIndexType:="Auto"
									End case 
									
									$tXMLElementIndexField:=DOM Get first child XML element:C723($tXMLElementRef; $tName; $tValue)
									If ($tName="field_ref")
										UT_Catalog_View(New object:C1471("tSubroutine"; "ProcessIndex"; "node"; $tXMLElementIndexField; "collection"; $colIndexes; "isCompositeIndex"; False:C215; "indexName"; $tIndexName; "indexType"; $tIndexType))
										
										// update table.field with index info
										$colTemp1:=$colTables.query("name = :1"; $colIndexes[$colIndexes.length-1].tableName)
										If ($colTemp1.length=1)
											$colTemp2:=$colTemp1[0].colFields.query("name = :1"; $colIndexes[$colIndexes.length-1].fieldName)
											If ($colTemp2.length=1)
												$colTemp2[0].indexed:=True:C214
												$colTemp2[0].inIndex:=$colTemp2[0].inIndex+1
											End if 
										End if 
										
										// check if composite index
										$tXMLElementIndexField:=DOM Get next sibling XML element:C724($tXMLElementIndexField; $tName; $tValue)
										If ((OK#0) & ($tName="field_ref"))  // this is a composite index, so mark as such in last saved element
											$colIndexes[$colIndexes.length-1].isCompositeIndex:=True:C214
											$tXMLElementIndexField:=DOM Get previous sibling XML element:C924($tXMLElementIndexField; $tName; $tValue)
											$bCompositeIndex:=True:C214
										End if 
										
										If ($bCompositeIndex)
											$bStopCompositeIndex:=False:C215
											Repeat 
												$tXMLElementIndexField:=DOM Get next sibling XML element:C724($tXMLElementIndexField; $tName; $tValue)
												If ((OK=0) | ($tName#"field_ref"))
													$bStopCompositeIndex:=True:C214
													
												Else 
													UT_Catalog_View(New object:C1471("tSubroutine"; "ProcessIndex"; "node"; $tXMLElementIndexField; "collection"; $colIndexes; "isCompositeIndex"; True:C214; "indexName"; $tIndexName; "indexType"; $tIndexType))
													
													// update table.field with index info
													$colTemp1:=$colTables.query("name = :1"; $colIndexes[$colIndexes.length-1].tableName)
													If ($colTemp1.length=1)
														$colTemp2:=$colTemp1[0].colFields.query("name = :1"; $colIndexes[$colIndexes.length-1].fieldName)
														If ($colTemp2.length=1)
															$colTemp2[0].indexed:=True:C214
															$colTemp2[0].inIndex:=$colTemp2[0].inIndex+1
														End if 
													End if 
													
												End if 
												
											Until $bStopCompositeIndex=True:C214
											
										End if 
									End if 
									
									$iCntrIndexes:=$iCntrIndexes+1
									// +++++++++++++++++++++++++++++++++++++++ end processing indexes +++++++++++++++++++++++++++++++++++++
									
								: ($tName="base_extra")
									// not implemented
									
								Else 
									$oParam.oReturn.errMsg:="Un-anticipated node: "+$tName+" in CATALOG XML file"
									ALERT:C41($oParam.oReturn.errMsg)
									TRACE:C157
									
							End case 
						End if 
						
					Until $bStopProcessing=True:C214
					
					Progress QUIT($iProgress)
					
					If (($iCntrTables=$oCatalog.iTotalTables) & ($iCntrRelations=$oCatalog.iTotalRelations) & ($iCntrIndexes=$oCatalog.iTotalIndexes))
						// OK, this is how it should be
						$oCatalog.iTotalFields:=$colFields.length
						$oCatalog.colTables:=$colTables
						$oCatalog.colRelations:=$colRelations
						$oCatalog.colIndexes:=$colIndexes
						$oCatalog.colFields:=$colFields
					Else 
						$oParam.oReturn.ok:=0
						If ($iCntrTables#$oCatalog.iTotalTables)
							$oParam.oReturn.errMsg:="It appears not all tables were processed!!!"+Char:C90(Carriage return:K15:38)
						End if 
						If ($iCntrRelations#$oCatalog.iTotalRelations)
							$oParam.oReturn.errMsg:=$oParam.oReturn.errMsg+"It appears not all relations were processed!!!"+Char:C90(Carriage return:K15:38)
						End if 
						If ($iCntrIndexes#$oCatalog.iTotalIndexes)
							$oParam.oReturn.errMsg:=$oParam.oReturn.errMsg+"It appears not all indexes were processed!!!"
						End if 
						ALERT:C41($oParam.oReturn.errMsg)
					End if 
					
					
				: ($oParam.tSubroutine="ProcessField")
					$oField:=New object:C1471
					
					$iAttributes:=DOM Count XML attributes:C727($oParam.node)
					ARRAY TEXT:C222($atAttribFieldName; $iAttributes)
					ARRAY TEXT:C222($atAttribFieldVal; $iAttributes)
					
					For ($iCntrAttrib; 1; $iAttributes)
						DOM GET XML ATTRIBUTE BY INDEX:C729($oParam.node; $iCntrAttrib; $atAttribFieldName{$iCntrAttrib}; $atAttribFieldVal{$iCntrAttrib})
					End for 
					$oField.visible:=True:C214
					$oField.unique:=False:C215
					$oField.autoGenerate:=False:C215
					$oField.autoSequence:=False:C215
					$oField.UUID:=False:C215
					$oField.mandatory:=False:C215
					$oField.enterable:=True:C214
					$oField.modifiable:=True:C214
					$oField.primaryKey:=False:C215
					$oField.indexed:=False:C215
					$oField.restAccess:=False:C215
					$oField.styledText:=False:C215
					$oField.inIndex:=0
					$oField.limitingLength:=0
					$oField.typeString:=""
					
					$iPosition:=Find in array:C230($atAttribFieldName; "name")
					$oField.name:=$atAttribFieldVal{$iPosition}
					$iPosition:=Find in array:C230($atAttribFieldName; "id")
					$oField.id:=Num:C11($atAttribFieldVal{$iPosition})
					$iPosition:=Find in array:C230($atAttribFieldName; "type")
					$oField.type:=Num:C11($atAttribFieldVal{$iPosition})
					
					$iPosition:=Find in array:C230($atAttribFieldName; "unique")
					If ($iPosition>0)
						If ($atAttribFieldVal{$iPosition}="True")
							$oField.unique:=True:C214
							
						End if 
					End if 
					
					$iPosition:=Find in array:C230($atAttribFieldName; "autogenerate")
					If ($iPosition>0)
						If ($atAttribFieldVal{$iPosition}="True")
							$oField.autoGenerate:=True:C214
						End if 
					End if 
					
					$iPosition:=Find in array:C230($atAttribFieldName; "autosequence")
					If ($iPosition>0)
						If ($atAttribFieldVal{$iPosition}="True")
							$oField.autoSequence:=True:C214
						End if 
					End if 
					
					$iPosition:=Find in array:C230($atAttribFieldName; "store_as_UUID")
					If ($iPosition>0)
						If ($atAttribFieldVal{$iPosition}="True")
							$oField.UUID:=True:C214
						End if 
					End if 
					
					$iPosition:=Find in array:C230($atAttribFieldName; "styled_text")
					If ($iPosition>0)
						If ($atAttribFieldVal{$iPosition}="True")
							$oField.styledText:=True:C214
						End if 
					End if 
					
					$iPosition:=Find in array:C230($atAttribFieldName; "hide_in_REST")
					If ($iPosition>0)
						If ($atAttribFieldVal{$iPosition}="False")
							$oField.restAccess:=True:C214
						End if 
					End if 
					
					$iPosition:=Find in array:C230($atAttribFieldName; "visible")
					If ($iPosition>0)
						If ($atAttribFieldVal{$iPosition}="False")
							$oField.visible:=False:C215
						End if 
					End if 
					
					$iPosition:=Find in array:C230($atAttribFieldName; "limiting_length")
					If ($iPosition>0)
						$oField.limitingLength:=Num:C11($atAttribFieldVal{$iPosition})
					End if 
					
					Case of 
						: ($oField.type=10)
							If ($oField.limitingLength>0)
								$oField.typeString:="Alpha"
							Else 
								If ($oField.UUID)
									$oField.typeString:="Alpha"
								Else 
									$oField.typeString:="Text"
								End if 
							End if 
						: ($oField.type=1)
							$oField.typeString:="Boolean"
						: ($oField.type=3)
							$oField.typeString:="Integer"
						: ($oField.type=4)
							$oField.typeString:="Long"
						: ($oField.type=5)
							$oField.typeString:="Long64"
						: ($oField.type=6)
							$oField.typeString:="Real"
						: ($oField.type=8)
							$oField.typeString:="Date"
						: ($oField.type=9)
							$oField.typeString:="Time"
						: ($oField.type=12)
							$oField.typeString:="Pict"
						: ($oField.type=18)
							$oField.typeString:="Blob"
						: ($oField.type=21)
							$oField.typeString:="Object"
						Else 
							$oField.typeString:="?????"
					End case 
					
					$tXMLElementFieldExtraRef:=DOM Get first child XML element:C723($oParam.node; $tFieldExtraName; $tFieldExtraValue)
					If (Ok=1)
						If ($tFieldExtraName="field_extra")
							$iAttributes:=DOM Count XML attributes:C727($tXMLElementFieldExtraRef)
							ARRAY TEXT:C222($atAttribFieldExtraName; $iAttributes)
							ARRAY TEXT:C222($atAttribFieldExtraVal; $iAttributes)
							
							For ($iCntrAttrib; 1; $iAttributes)
								DOM GET XML ATTRIBUTE BY INDEX:C729($tXMLElementFieldExtraRef; $iCntrAttrib; $atAttribFieldExtraName{$iCntrAttrib}; $atAttribFieldExtraVal{$iCntrAttrib})
							End for 
							
							$iPosition:=Find in array:C230($atAttribFieldExtraName; "mandatory")
							If ($iPosition>0)
								If ($atAttribFieldExtraVal{$iPosition}="True")
									$oField.mandatory:=True:C214
								Else 
									$oField.mandatory:=False:C215
								End if 
							End if 
							
							$iPosition:=Find in array:C230($atAttribFieldExtraName; "modifiable")
							If ($iPosition>0)
								If ($atAttribFieldExtraVal{$iPosition}="True")
									$oField.modifiable:=True:C214
								Else 
									$oField.modifiable:=False:C215
								End if 
							End if 
							
							$iPosition:=Find in array:C230($atAttribFieldExtraName; "enterable")
							If ($iPosition>0)
								If ($atAttribFieldExtraVal{$iPosition}="True")
									$oField.enterable:=True:C214
								Else 
									$oField.enterable:=False:C215
								End if 
							End if 
							
						End if 
					End if 
					
					$oField.ref:=$oParam.collectionAllFields.length+1
					$oParam.collection.push($oField)
					$oField.tableName:=$oParam.tableName
					$oField.tableID:=$oParam.tableID
					$oParam.collectionAllFields.push($oField)
					
					
				: ($oParam.tSubroutine="ProcessIndex")
					$oIndex:=New object:C1471
					$oIndex.isCompositeIndex:=$oParam.isCompositeIndex
					$oIndex.indexName:=$oParam.indexName
					$oIndex.type:=$oParam.indexType
					$oIndex.fieldName:=""
					$oIndex.tableName:=""
					
					$iAttributes:=DOM Count XML attributes:C727($oParam.node)
					ARRAY TEXT:C222($atAttribIndexFieldName; $iAttributes)
					ARRAY TEXT:C222($atAttribIndexFieldValue; $iAttributes)
					
					For ($iCntrAttrib; 1; $iAttributes)
						DOM GET XML ATTRIBUTE BY INDEX:C729($oParam.node; $iCntrAttrib; $atAttribIndexFieldName{$iCntrAttrib}; $atAttribIndexFieldValue{$iCntrAttrib})
					End for 
					
					$iPosition:=Find in array:C230($atAttribIndexFieldName; "name")
					$oIndex.fieldName:=$atAttribIndexFieldValue{$iPosition}
					
					$tXMLElementIndexTableName:=DOM Get first child XML element:C723($oParam.node; $tName; $tValue)
					If ($tName="table_ref")
						
						$iAttributes:=DOM Count XML attributes:C727($tXMLElementIndexTableName)
						ARRAY TEXT:C222($atAttribIndexTableName; $iAttributes)
						ARRAY TEXT:C222($atAttribIndexTableValue; $iAttributes)
						
						For ($iCntrAttrib; 1; $iAttributes)
							DOM GET XML ATTRIBUTE BY INDEX:C729($tXMLElementIndexTableName; $iCntrAttrib; $atAttribIndexTableName{$iCntrAttrib}; $atAttribIndexTableValue{$iCntrAttrib})
						End for 
						
						$iPosition:=Find in array:C230($atAttribIndexTableName; "name")
						$oIndex.tableName:=$atAttribIndexTableValue{$iPosition}
						
						// too slow
						//$colTemp2:=$oParam.collectionAllFields.query("tableName = :1 and name = :2"; $oIndex.tableName; $oIndex.fieldName)
						//If ($colTemp2.length=1)
						//$oIndex.tableID:=$colTemp2[0].tableID
						//$oIndex.fieldID:=$colTemp2[0].id
						//$oIndex.fieldRef:=$colTemp2[0].ref
						//End if 
						
					End if 
					
					$oIndex.ref:=$oParam.collection.length+1
					$oParam.collection.push($oIndex)
					
					
				: ($oParam.tSubroutine="ProcessRelation")
					$oRelation:=New object:C1471
					
					$iAttributes:=DOM Count XML attributes:C727($oParam.node)
					ARRAY TEXT:C222($atAttribRelationName; $iAttributes)
					ARRAY TEXT:C222($atAttribRelationValue; $iAttributes)
					
					For ($iCntrAttrib; 1; $iAttributes)
						DOM GET XML ATTRIBUTE BY INDEX:C729($oParam.node; $iCntrAttrib; $atAttribRelationName{$iCntrAttrib}; $atAttribRelationValue{$iCntrAttrib})
					End for 
					
					$iPosition:=Find in array:C230($atAttribRelationName; "name_Nto1")
					$oRelation.name_Nto1:=$atAttribRelationValue{$iPosition}
					$iPosition:=Find in array:C230($atAttribRelationName; "name_1toN")
					$oRelation.name_1toN:=$atAttribRelationValue{$iPosition}
					
					$tXMLElementRefRelation:=DOM Get first child XML element:C723($oParam.node; $tName; $tValue)
					If ($tName="related_field")
						
						DOM GET XML ATTRIBUTE BY NAME:C728($tXMLElementRefRelation; "kind"; $tKind)
						$tFieldName:=""
						$tTableName:=""
						
						$tXMLElementRefRelationField:=DOM Get first child XML element:C723($tXMLElementRefRelation; $tName; $tValue)
						If ($tName="field_ref")
							DOM GET XML ATTRIBUTE BY NAME:C728($tXMLElementRefRelationField; "name"; $tFieldName)
							
							$tXMLElementRefRelationTable:=DOM Get first child XML element:C723($tXMLElementRefRelationField; $tName; $tValue)
							If ($tName="table_ref")
								DOM GET XML ATTRIBUTE BY NAME:C728($tXMLElementRefRelationTable; "name"; $tTableName)
							End if 
						End if 
						
						$oRelation[$tKind+"Table"]:=$tTableName
						$oRelation[$tKind+"Field"]:=$tFieldName
						
					End if 
					
					$bStopRelation:=False:C215
					Repeat 
						$tXMLElementRefRelation:=DOM Get next sibling XML element:C724($tXMLElementRefRelation; $tName; $tValue)
						If (Ok=0)
							$bStopRelation:=True:C214
							
						Else 
							If ($tName="related_field")
								DOM GET XML ATTRIBUTE BY NAME:C728($tXMLElementRefRelation; "kind"; $tKind)
								$tFieldName:=""
								$tTableName:=""
								
								$tXMLElementRefRelationField:=DOM Get first child XML element:C723($tXMLElementRefRelation; $tName; $tValue)
								If ($tName="field_ref")
									DOM GET XML ATTRIBUTE BY NAME:C728($tXMLElementRefRelationField; "name"; $tFieldName)
									
									$tXMLElementRefRelationTable:=DOM Get first child XML element:C723($tXMLElementRefRelationField; $tName; $tValue)
									If ($tName="table_ref")
										DOM GET XML ATTRIBUTE BY NAME:C728($tXMLElementRefRelationTable; "name"; $tTableName)
									End if 
								End if 
								
								$oRelation[$tKind+"Table"]:=$tTableName
								$oRelation[$tKind+"Field"]:=$tFieldName
								
							End if 
						End if 
					Until $bStopRelation=True:C214
					
					$oRelation.ref:=$oParam.collection.length+1
					$oParam.collection.push($oRelation)
					
					
				: ($oParam.tSubroutine="InitFilterVariables")
					// Init filter object
					Form:C1466.oFilterParam:=New object:C1471
					Form:C1466.oFilterParam.tEditedText:=""
					Form:C1466.oFilterParam.colTextAttr:=Null:C1517
					Form:C1466.oFilterParam.colNumAttr:=Null:C1517
					Form:C1466.oFilterParam.colBoolAttr:=Null:C1517
					Form:C1466.oFilterParam.colDateAttr:=Null:C1517
					
					// Init filter values
					Form:C1466.iFiltTables:=Form:C1466.oCatalog.iTotalTables
					Form:C1466.iFiltRelations:=Form:C1466.oCatalog.iTotalRelations
					Form:C1466.iFiltIndexes:=Form:C1466.oCatalog.iTotalIndexes
					Form:C1466.iFiltFields:=Form:C1466.oCatalog.iTotalFields
					
					
				: ($oParam.tSubroutine="InitCollections")
					// Prep collections page 1
					Form:C1466.colTables:=Form:C1466.oCatalog.colTables
					If (Form:C1466.colTables.length>0)
						Form:C1466.currentTable:=Form:C1466.oCatalog.colTables[0]
						Form:C1466.currentTablePos:=1
						Form:C1466.currentTableSel:=Form:C1466.oCatalog.colTables[0]
						
						Form:C1466.colTableFields:=Form:C1466.oCatalog.colTables[0].colFields
						If (Form:C1466.colTableFields.length>0)
							Form:C1466.currentField:=Form:C1466.colTableFields[0]
							Form:C1466.currentFieldPos:=1
							Form:C1466.currentFieldSel:=Form:C1466.colTableFields[0]
						End if 
						
						Form:C1466.colRelationsByTable:=Form:C1466.oCatalog.colRelations.query("destinationTable = :1 OR sourceTable = :2"; Form:C1466.currentTable.name; Form:C1466.currentTable.name)
						If (Form:C1466.colRelationsByTable.length>0)
							Form:C1466.currentRelationByTable:=Form:C1466.colRelationsByTable[0]
							Form:C1466.currentRelationByTablePos:=1
							Form:C1466.currentRelationByTableSel:=Form:C1466.colRelationsByTable[0]
						End if 
						
						// Prep collections page 2
						Form:C1466.colRelationsAll:=Form:C1466.oCatalog.colRelations
						Form:C1466.currentRelation:=Form:C1466.colRelationsAll[0]
						Form:C1466.currentRelationPos:=1
						Form:C1466.currentRelationSel:=Form:C1466.colRelationsAll[0]
						
						// Prep collections page 3
						Form:C1466.colIndexesAll:=Form:C1466.oCatalog.colIndexes
						Form:C1466.iIndexesSingle:=0
						Form:C1466.iIndexesComposite:=0
						Form:C1466.iIndexesDistinct:=0
						
						Form:C1466.colTables3:=Form:C1466.oCatalog.colTables
						Form:C1466.currentTable3:=Form:C1466.oCatalog.colTables[0]
						Form:C1466.currentTable3Pos:=1
						Form:C1466.currentTable3Sel:=Form:C1466.oCatalog.colTables[0]
						
						// Prep collections page 4
						Form:C1466.colFieldsAll:=Form:C1466.oCatalog.colFields
						
						LISTBOX SELECT ROW:C912(*; "lbTables"; 1)
						LISTBOX SELECT ROW:C912(*; "lbTableFields"; 1)
						If (Form:C1466.colRelationsByTable.length>0)
							LISTBOX SELECT ROW:C912(*; "lbRelationsByTable"; 1)
						End if 
						
						FORM GOTO PAGE:C247(1)
						GOTO OBJECT:C206(*; "lbTables")
						
						SET WINDOW TITLE:C213("Catalog File Browser: "+Form:C1466.oCatalog.nameCatalog)
						
					Else 
						ALERT:C41("No tables available in Catalog file")
						CANCEL:C270
						
					End if 
					
					
				: ($oParam.tSubroutine="DoFilter")
					var $colDateParts; $colBoolParts : Collection
					var $tComparison; $tComparison2; $tResultAttributeName; $tFilterParam : Text
					var $tSearchString; $tSearchValue; $tPart1; $tPart2 : Text
					var $iCntr; $iPosition : Integer
					var $rSearchValue : Real
					var $dSearchValue : Date
					var $bIsABoolean; $bSearchValue : Boolean
					var $varResult : Variant
					
					Case of 
						: $oParam.tFilterObjectName="FilterValueTables"
							Form:C1466.oFilterParam.toQuery:=Form:C1466.oCatalog.colTables
							Form:C1466.oFilterParam.tNameResultAttrib:="colTables"
							Form:C1466.oFilterParam.colTextAttr:=New collection:C1472("name")
							Form:C1466.oFilterParam.colNumAttr:=New collection:C1472("id")
							
							Form:C1466.colTableFields:=Null:C1517
							Form:C1466.colRelationsByTable:=Null:C1517
							
						: $oParam.tFilterObjectName="FilterValueRelations"
							Form:C1466.oFilterParam.toQuery:=Form:C1466.oCatalog.colRelations
							Form:C1466.oFilterParam.tNameResultAttrib:="colRelationsAll"
							Form:C1466.oFilterParam.colTextAttr:=New collection:C1472("destinationTable"; "destinationField"; "sourceTable"; "sourceField"; "name_1toN"; "name_Nto1")
							Form:C1466.oFilterParam.colNumAttr:=New collection:C1472("ref")
							
							Form:C1466.destinationFields:=Null:C1517
							Form:C1466.sourceFields:=Null:C1517
							Form:C1466.tDestinationTable:=""
							Form:C1466.tSourceTable:=""
							Form:C1466.tRelationName_Nto1:=""
							Form:C1466.tRelationName_1toN:=""
							
						: $oParam.tFilterObjectName="FilterValueIndexes"
							Form:C1466.oFilterParam.toQuery:=Form:C1466.oCatalog.colIndexes
							Form:C1466.oFilterParam.tNameResultAttrib:="colIndexesAll"
							Form:C1466.oFilterParam.colTextAttr:=New collection:C1472("tableName"; "fieldName"; "indexName"; "type")
							Form:C1466.oFilterParam.colNumAttr:=New collection:C1472("ref")
							
							Form:C1466.TableIndexesSingle:=Null:C1517
							Form:C1466.tableIndexesComposite:=Null:C1517
							Form:C1466.iIndexesSingle:=0
							Form:C1466.iIndexesDistinct:=0
							Form:C1466.iIndexesComposite:=0
							
						: $oParam.tFilterObjectName="FilterValueFields"
							Form:C1466.oFilterParam.toQuery:=Form:C1466.oCatalog.colFields
							Form:C1466.oFilterParam.tNameResultAttrib:="colFieldsAll"
							Form:C1466.oFilterParam.colTextAttr:=New collection:C1472("tableName"; "name"; "typeString")
							Form:C1466.oFilterParam.colNumAttr:=New collection:C1472("ref")
							
							Form:C1466.relationsField:=Null:C1517
							Form:C1466.tableIndexesComposite2:=Null:C1517
							Form:C1466.iRelationsForField:=0
							Form:C1466.iCompositeIdxForField:=0
							
					End case 
					
					$tSearchValue:=Form:C1466.oFilterParam.tEditedText
					$tResultAttributeName:=Form:C1466.oFilterParam.tNameResultAttrib
					
					If (Form:C1466.oFilterParam.toQuery=Null:C1517)
						ALERT:C41("Error - No query collection provided")
						
					Else 
						If ($tSearchValue="")
							$varResult:=Form:C1466.oFilterParam.toQuery
							
						Else 
							If (Form:C1466.oFilterParam.colBoolAttr#Null:C1517)  // for bool attribute (only 1 for now)
								$colBoolParts:=Split string:C1554(Form:C1466.oFilterParam.colBoolAttr[0]; ",")
								If ($colBoolParts.length#1)
									$tComparison:=$colBoolParts[1]
									$tComparison2:=$colBoolParts[2]
								Else 
									$tComparison:="True"
									$tComparison2:="False"
								End if 
								$tSearchString:=$colBoolParts[0]+" = :1"
								
								Case of 
									: (Uppercase:C13($tSearchValue)=Uppercase:C13($tComparison))
										$bIsABoolean:=True:C214
										$bSearchValue:=True:C214
									: (Uppercase:C13($tSearchValue)=Uppercase:C13($tComparison2))
										$bIsABoolean:=True:C214
										$bSearchValue:=False:C215
								End case 
							End if 
							
							Case of 
								: ($bIsABoolean)
									$varResult:=Form:C1466.oFilterParam.toQuery.query($tSearchString; $bSearchValue)
									
								: (Position:C15("/"; $tSearchValue)>0) & (Position:C15("/"; $tSearchValue)<=3)  // its a date
									If ((Form:C1466.oFilterParam.colDateAttr#Null:C1517) & (Length:C16($tSearchValue)>=3))
										$colDateParts:=Split string:C1554($tSearchValue; "/")
										
										Case of 
											: ($colDateParts.length=2)
												If (Length:C16($colDateParts[1])<2)
													// do nothing
												Else 
													If ($colDateParts[0]="")
														$dSearchValue:=Date:C102("01/01/"+$colDateParts[1])
													Else 
														$dSearchValue:=Date:C102("01/"+$colDateParts[0]+"/"+$colDateParts[1])
													End if 
												End if 
												
											: ($colDateParts.length=3)
												$dSearchValue:=Date:C102($tSearchValue)
												
										End case 
										
										For ($iCntr; 0; Form:C1466.oFilterParam.colDateAttr.length-1)
											$iPosition:=Position:C15(","; Form:C1466.oFilterParam.colDateAttr[$iCntr])
											If ($iPosition<=0)
												$tComparison:=" >= "
												$tFilterParam:=Form:C1466.oFilterParam.colDateAttr[$iCntr]
												
											Else 
												$tComparison:=" "+Substring:C12(Form:C1466.oFilterParam.colDateAttr[$iCntr]; $iPosition+1)+" "
												$tFilterParam:=Substring:C12(Form:C1466.oFilterParam.colDateAttr[$iCntr]; 1; $iPosition-1)
											End if 
											
											If ($iCntr=0)
												$tSearchString:=$tFilterParam+$tComparison+" :1"
											Else 
												$tSearchString:=$tSearchString+" or "+$tFilterParam+$tComparison+" :1"
											End if 
										End for 
										
										$varResult:=Form:C1466.oFilterParam.toQuery.query($tSearchString; $dSearchValue)
										
									End if 
									
								: (String:C10(Num:C11($tSearchValue))=$tSearchValue)  // its a number
									If (Form:C1466.oFilterParam.colNumAttr#Null:C1517)
										$rSearchValue:=Num:C11($tSearchValue)
										
										For ($iCntr; 0; Form:C1466.oFilterParam.colNumAttr.length-1)
											$iPosition:=Position:C15(","; Form:C1466.oFilterParam.colNumAttr[$iCntr])
											If ($iPosition<=0)
												$tComparison:=" = "
												$tFilterParam:=Form:C1466.oFilterParam.colNumAttr[$iCntr]
											Else 
												$tComparison:=" "+Substring:C12(Form:C1466.oFilterParam.colNumAttr[$iCntr]; $iPosition+1)+" "
												$tFilterParam:=Substring:C12(Form:C1466.oFilterParam.colNumAttr[$iCntr]; 1; $iPosition-1)
											End if 
											
											If ($iCntr=0)
												$tSearchString:=$tFilterParam+$tComparison+" :1"
											Else 
												$tSearchString:=$tSearchString+" or "+$tFilterParam+$tComparison+" :1"
											End if 
										End for 
										
										$varResult:=Form:C1466.oFilterParam.toQuery.query($tSearchString; $rSearchValue)
										
									End if 
									
								Else   // its a string
									If (Form:C1466.oFilterParam.colTextAttr#Null:C1517)
										If (Substring:C12($tSearchValue; 1; 1)=" ")  // space used to force a text lookup in string attribute only containing numbers
											$tSearchValue:="@"+Substring:C12($tSearchValue; 2)+"@"
										Else 
											$tSearchValue:="@"+$tSearchValue+"@"
										End if 
										
										For ($iCntr; 0; Form:C1466.oFilterParam.colTextAttr.length-1)
											$iPosition:=Position:C15(","; Form:C1466.oFilterParam.colTextAttr[$iCntr])
											If ($iPosition<=0)
												$tComparison:=" = "
												$tFilterParam:=Form:C1466.oFilterParam.colTextAttr[$iCntr]
											Else 
												$tComparison:=" "+Substring:C12(Form:C1466.oFilterParam.colTextAttr[$iCntr]; $iPosition+1)+" "
												$tFilterParam:=Substring:C12(Form:C1466.oFilterParam.colTextAttr[$iCntr]; 1; $iPosition-1)
											End if 
											
											If ($iCntr=0)
												$tSearchString:=$tFilterParam+$tComparison+" :1"
											Else 
												$tSearchString:=$tSearchString+" or "+$tFilterParam+$tComparison+" :1"
											End if 
										End for 
										
										$varResult:=Form:C1466.oFilterParam.toQuery.query($tSearchString; $tSearchValue)
										
									End if 
							End case 
							
						End if 
					End if 
					
					$iPosition:=Position:C15("."; $tResultAttributeName)
					If ($iPosition<=0)
						Form:C1466[$tResultAttributeName]:=$varResult
						
					Else 
						$tPart1:=Substring:C12($tResultAttributeName; 1; $iPosition-1)
						$tPart2:=Substring:C12($tResultAttributeName; $iPosition+1)
						Form:C1466[$tPart1][$tPart2]:=$varResult
						
					End if 
					
					Case of 
						: $oParam.tFilterObjectName="FilterValueTables"
							Form:C1466.iFiltTables:=$varResult.length
						: $oParam.tFilterObjectName="FilterValueRelations"
							Form:C1466.iFiltRelations:=$varResult.length
						: $oParam.tFilterObjectName="FilterValueIndexes"
							Form:C1466.iFiltIndexes:=$varResult.length
						: $oParam.tFilterObjectName="FilterValueFields"
							Form:C1466.iFiltFields:=$varResult.length
					End case 
					
				: ($oParam.tSubroutine="ShowTable")
					If ($oParam.tTableToShow#"")
						Form:C1466.colTables:=Form:C1466.oCatalog.colTables
						$pPtr:=OBJECT Get pointer:C1124(Object named:K67:5; "FilterValueTables")
						$pPtr->:=""
						Form:C1466.iFiltTables:=Form:C1466.oCatalog.iTotalTables
						
						$colTemp1:=Form:C1466.colTables.indices("name = :1"; $oParam.tTableToShow)
						$iPosition:=$colTemp1[0]+1
						
						Form:C1466.currentTable:=Form:C1466.colTables[$colTemp1[0]]
						Form:C1466.currentTablePos:=$iPosition
						Form:C1466.currentTableSel:=Form:C1466.colTables[$colTemp1[0]]
						
						Form:C1466.colTableFields:=Form:C1466.currentTable.colFields
						If (Form:C1466.colTableFields.length>0)
							Form:C1466.currentField:=Form:C1466.colTableFields[0]
							Form:C1466.currentFieldPos:=1
							Form:C1466.currentFieldSel:=Form:C1466.colTableFields[0]
						End if 
						
						Form:C1466.colRelationsByTable:=Form:C1466.oCatalog.colRelations.query("destinationTable = :1 OR sourceTable = :2"; $oParam.tTableToShow; $oParam.tTableToShow)
						If (Form:C1466.colRelationsByTable.length>0)
							Form:C1466.currentRelationByTable:=Form:C1466.colRelationsByTable[0]
							Form:C1466.currentRelationByTablePos:=1
							Form:C1466.currentRelationByTableSel:=Form:C1466.colRelationsByTable[0]
						End if 
						
						LISTBOX SELECT ROW:C912(*; "lbTables"; $iPosition)
						OBJECT SET SCROLL POSITION:C906(*; "lbTables"; $iPosition)
						
						FORM GOTO PAGE:C247(1)
					End if 
					
					
				: ($oParam.tSubroutine="ShowIndexes")
					If ($oParam.tTableToShow#"")
						$tQueryString:="tableName = :1 AND isCompositeIndex = :2"
						Form:C1466.TableIndexesSingle:=Form:C1466.colIndexesAll.query($tQueryString; $oParam.tTableToShow; False:C215).orderBy("ref asc")
						Form:C1466.tableIndexesComposite:=Form:C1466.colIndexesAll.query($tQueryString; $oParam.tTableToShow; True:C214).orderBy("ref asc")
						Form:C1466.iIndexesSingle:=Form:C1466.TableIndexesSingle.length
						Form:C1466.iIndexesComposite:=Form:C1466.tableIndexesComposite.length
						If (Form:C1466.iIndexesComposite>0)
							$colTemp1:=Form:C1466.tableIndexesComposite.distinct("indexName")
							Form:C1466.iIndexesDistinct:=$colTemp1.length
						Else 
							Form:C1466.iIndexesDistinct:=0
						End if 
					End if 
					
					
				: ($oParam.tSubroutine="ShowRelations")
					Form:C1466.colRelationsAll:=Form:C1466.oCatalog.colRelations
					$pPtr:=OBJECT Get pointer:C1124(Object named:K67:5; "FilterValueRelations")
					$pPtr->:=""
					Form:C1466.iFiltRelations:=Form:C1466.oCatalog.iTotalRelations
					
					Form:C1466.tDestinationTable:=$oParam.destinationTable
					Form:C1466.tSourceTable:=$oParam.sourceTable
					Form:C1466.tRelationName_1toN:=$oParam.name_1toN
					Form:C1466.tRelationName_Nto1:=$oParam.name_Nto1
					
					OBJECT SET TITLE:C194(*; "btnDestinationTable"; Form:C1466.tDestinationTable)
					OBJECT SET TITLE:C194(*; "btnSourceTable"; Form:C1466.tSourceTable)
					
					$colTemp1:=Form:C1466.oCatalog.colTables.query("name = :1"; $oParam.destinationTable)
					Form:C1466.destinationFields:=$colTemp1[0].colFields
					$colTemp2:=Form:C1466.destinationFields.indices("name = :1"; $oParam.destinationField)
					$iPosition:=$colTemp2[0]+1
					LISTBOX SELECT ROW:C912(*; "lbDestinationFields"; $iPosition)
					OBJECT SET SCROLL POSITION:C906(*; "lbDestinationFields"; $iPosition)
					
					$colTemp1:=Form:C1466.oCatalog.colTables.query("name = :1"; $oParam.sourceTable)
					Form:C1466.sourceFields:=$colTemp1[0].colFields
					$colTemp2:=Form:C1466.sourceFields.indices("name = :1"; $oParam.sourceField)
					$iPosition:=$colTemp2[0]+1
					LISTBOX SELECT ROW:C912(*; "lbSourceFields"; $iPosition)
					OBJECT SET SCROLL POSITION:C906(*; "lbSourceFields"; $iPosition)
					
					Form:C1466.colRelationsAll:=Form:C1466.oCatalog.colRelations
					$colTemp1:=Form:C1466.colRelationsAll.indices("ref = :1 "; $oParam.relationRef)
					$iPosition:=$colTemp1[0]+1
					LISTBOX SELECT ROW:C912(*; "lbRelationsAll"; $iPosition)
					OBJECT SET SCROLL POSITION:C906(*; "lbRelationsAll"; $iPosition)
					
					FORM GOTO PAGE:C247(2)
					
					
				: ($oParam.tSubroutine="ShowFields")
					Form:C1466.colFieldsAll:=Form:C1466.oCatalog.colFields
					$pPtr:=OBJECT Get pointer:C1124(Object named:K67:5; "FilterValueFields")
					$pPtr->:=""
					Form:C1466.iFiltFields:=Form:C1466.oCatalog.iTotalFields
					
					$colTemp1:=Form:C1466.colFieldsAll.indices("ref = :1"; $oParam.ref)
					$iPosition:=$colTemp1[0]+1
					LISTBOX SELECT ROW:C912(*; "lbFieldsAll"; $iPosition)
					OBJECT SET SCROLL POSITION:C906(*; "lbFieldsAll"; $iPosition; *)
					
					$tQueryString:="(destinationTable = :1 and destinationField = :2) or (sourceTable = :3 and sourceField = :4))"
					Form:C1466.relationsField:=Form:C1466.oCatalog.colRelations.query($tQueryString; $oParam.tableName; $oParam.fieldName; $oParam.tableName; $oParam.fieldName)
					Form:C1466.iRelationsForField:=Form:C1466.relationsField.length
					
					$tQueryString:="(tableName = :1 and fieldName = :2 and isCompositeIndex = :3)"
					Form:C1466.tableIndexesComposite2:=Form:C1466.oCatalog.colIndexes.query($tQueryString; $oParam.tableName; $oParam.fieldName; True:C214)
					Form:C1466.iCompositeIdxForField:=Form:C1466.tableIndexesComposite2.length
					
					FORM GOTO PAGE:C247(4)
					GOTO OBJECT:C206(*; "lbFieldsAll")
					
					
				: ($oParam.tSubroutine="CreateFormLayoutObject")
					If (True:C214)
						var $colColumns; $colEntryOrder : Collection
						var $oFormObject; $oFormSubObject; $oPageObject; $oObjects; $oColumns; $oColumnObj; $oObjectTemp : Object
						
						//+++++++++++++++++++++++++++
						//Processing main form object
						//+++++++++++++++++++++++++++
						$oFormObject:=$oParam.oFormLayout
						$oFormObject.destination:="detailScreen"
						$oFormObject.windowTitle:=""
						$oFormObject.windowSizingX:="variable"
						$oFormObject.windowMinHeight:=550
						$oFormObject.rightMargin:=10
						$oFormObject.bottomMargin:=10
						$oFormObject.markerHeader:=15
						$oFormObject.markerBody:=200
						$oFormObject.markerBreak:=220
						$oFormObject.markerFooter:=240
						$oFormObject.events:=New collection:C1472("onLoad"; "onOutsideCall"; "onDoubleClick"; "onMenuSelect"; "onCloseBox"; "onAfterKeystroke"; "onBoundVariableChange")
						$oFormObject.method:="UT_Catalog_View"
						$oFormObject.pageFormat:=New object:C1471()
						$oFormObject.pages:=New collection:C1472()
						$oFormObject.$4d:=New object:C1471()
						$oFormObject.editor:=New object:C1471()
						$oFormObject.geometryStamp:=777
						$oFormObject.windowMinWidth:=1140
						
						$oFormSubObject:=New object:C1471
						$oFormSubObject.paperName:="A4"
						$oFormSubObject.paperWidth:="842pt"
						$oFormSubObject.paperHeight:="595pt"
						$oFormObject.pageFormat:=$oFormSubObject
						
						$oFormSubObject:=New object:C1471
						$oFormSubObject.version:="1"
						$oFormSubObject.kind:="form"
						$oFormObject.$4d:=$oFormSubObject
						
						$oFormSubObject:=New object:C1471
						$oFormSubObject.activeView:="View 1"
						$oFormSubObject.defaultView:="View 1"
						$oFormObject.editor:=$oFormSubObject
						
						//+++++++++++++++++++++++++++
						//Processing form pages
						//+++++++++++++++++++++++++++
						//+++++++++++++++++++++++++++
						//Processing form page 0
						//+++++++++++++++++++++++++++
						$oObjects:=New object:C1471
						$oPageObject:=New object:C1471
						$oPageObject.type:="tab"
						$oPageObject.top:=6
						$oPageObject.left:=10
						$oPageObject.width:=1132
						$oPageObject.height:=695
						$oPageObject.sizingX:="grow"
						$oPageObject.sizingY:="grow"
						$oPageObject.dataSourceTypeHint:="arrayText"
						$oPageObject.labels:=New collection:C1472("Tables"; "Relations"; "Indexes"; "Fields")
						$oPageObject.action:="GotoPage"
						$oPageObject.events:=New collection:C1472("onClick")
						$oObjects.tabControl:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="button"
						$oPageObject.text:="?"
						$oPageObject.top:=27
						$oPageObject.left:=1093
						$oPageObject.width:=37
						$oPageObject.height:=20
						$oPageObject.events:=New collection:C1472("onClick")
						$oPageObject.fontWeight:="bold"
						$oPageObject.stroke:="#6495ed"
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.style:="help"
						$oPageObject.focusable:=True:C214
						$oPageObject.borderStyle:="none"
						$oPageObject.sizingX:="move"
						$oObjects.btnHelp:=$oPageObject
						
						$oFormObject.pages.push(New object:C1471("objects"; $oObjects))
						//+++++++++++++++++++++++++++
						//Processing form page 1
						//+++++++++++++++++++++++++++
						$oObjects:=New object:C1471
						$oPageObject:=New object:C1471
						$oPageObject.type:="rectangle"
						$oPageObject.top:=26
						$oPageObject.left:=20
						$oPageObject.width:=197
						$oPageObject.height:=26
						$oPageObject.stroke:="#CCCCCC"
						$oPageObject.borderRadius:=10
						$oObjects.Round_Rectangle1:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=30
						$oPageObject.left:=32
						$oPageObject.width:=158
						$oPageObject.height:=17
						$oPageObject.borderStyle:="none"
						$oPageObject.hideFocusRing:=True:C214
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.events:=New collection:C1472("onAfterKeystroke")
						$oPageObject.placeholder:="Enter table filter here"
						$oObjects.FilterValueTables:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="listbox"
						$oPageObject.top:=60
						$oPageObject.left:=20
						$oPageObject.width:=279
						$oPageObject.height:=632
						$oPageObject.sizingY:="grow"
						$oPageObject.resizingMode:="legacy"
						$oPageObject.listboxType:="collection"
						$oPageObject.movableRows:=False:C215
						$oPageObject.dataSource:="Form:C1466.colTables"
						$oPageObject.currentItemSource:="Form:C1466.currentTable"
						$oPageObject.currentItemPositionSource:="Form:C1466.currentTablePos"
						$oPageObject.selectedItemsSource:="Form:C1466.currentTableSel"
						$oPageObject.selectionMode:="single"
						$oPageObject.scrollbarHorizontal:="automatic"
						$oPageObject.events:=New collection:C1472("onClick"; "onDisplayDetail"; "onDoubleClick"; "onSelectionChange"; "onHeaderClick")
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.sizingX:="grow"
						$oPageObject.lockedColumnCount:=1
						$oPageObject.columns:=New collection:C1472
						//+++++++++++++++++++++++++++
						//Start list box columns
						//+++++++++++++++++++++++++++
						$colColumns:=New collection:C1472
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="tableID"
						$oColumnObj.dataSource:="This:C1470.id"
						$oColumnObj.dataSourceTypeHint:="number"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oColumnObj.events:=New collection:C1472("onClick"; "onDataChange")
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="tableHdr1"
						$oObjectTemp.text:="ID"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer1"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="tableName"
						$oColumnObj.dataSource:="This:C1470.name"
						$oColumnObj.width:=225
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oColumnObj.events:=New collection:C1472("onClick"; "onDataChange")
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="tableHdr2"
						$oObjectTemp.text:="Name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer2"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="tablePK"
						$oColumnObj.dataSource:="This:C1470.primaryKey"
						$oColumnObj.width:=150
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="tableHdr3"
						$oObjectTemp.text:="Primary Key"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer23"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="tableRestAccess"
						$oColumnObj.dataSource:="This:C1470.restAccess"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="tableHdr5"
						$oObjectTemp.text:="Rest"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer89"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="tableInJournal"
						$oColumnObj.dataSource:="This:C1470.inJournal"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="tableHdr6"
						$oObjectTemp.text:="Jour"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer90"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="tableSyncInfo"
						$oColumnObj.dataSource:="This:C1470.syncInfo"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="tableHdr7"
						$oObjectTemp.text:="Sync"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer91"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="tableEncryptable"
						$oColumnObj.dataSource:="This:C1470.encryptable"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="tableHdr8"
						$oObjectTemp.text:="Cryp"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer92"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="tableDeleteTag"
						$oColumnObj.dataSource:="This:C1470.deleteTag"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="tableHdr4"
						$oObjectTemp.text:="Del"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer88"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="tableVisible"
						$oColumnObj.dataSource:="This:C1470.visible"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="tableHdr9"
						$oObjectTemp.text:="Vis"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer24"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="tableTrigInsert"
						$oColumnObj.dataSource:="This:C1470.triggerInsert"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="tableHdr10"
						$oObjectTemp.text:="TrI"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer26"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="tableTrigUpdate"
						$oColumnObj.dataSource:="This:C1470.triggerUpdate"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="tableHdr11"
						$oObjectTemp.text:="TrU"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer27"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="tableTrigDelete"
						$oColumnObj.dataSource:="This:C1470.triggerDelete"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="tableHdr12"
						$oObjectTemp.text:="TrD"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer28"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oPageObject.columns:=$colColumns
						//+++++++++++++++++++++++++++
						//End list box columns
						//+++++++++++++++++++++++++++
						$oObjects.lbTables:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="listbox"
						$oPageObject.top:=60
						$oPageObject.left:=317
						$oPageObject.width:=815
						$oPageObject.height:=456
						$oPageObject.sizingY:="grow"
						$oPageObject.resizingMode:="rightToLeft"
						$oPageObject.listboxType:="collection"
						$oPageObject.movableRows:=False:C215
						$oPageObject.dataSource:="Form:C1466.colTableFields"
						$oPageObject.currentItemSource:="Form:C1466.currentTableField"
						$oPageObject.currentItemPositionSource:="Form:C1466.currentTableFieldPos"
						$oPageObject.selectedItemsSource:="Form:C1466.currentTableFieldSel"
						$oPageObject.scrollbarHorizontal:="hidden"
						$oPageObject.events:=New collection:C1472("onLoad"; "onClick"; "onDisplayDetail"; "onDoubleClick")
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.sizingX:="grow"
						$oPageObject.lockedColumnCount:=0
						$oPageObject.columns:=New collection:C1472
						//+++++++++++++++++++++++++++
						//Start list box columns
						//+++++++++++++++++++++++++++
						$colColumns:=New collection:C1472
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldID"
						$oColumnObj.dataSource:="This:C1470.id"
						$oColumnObj.dataSourceTypeHint:="number"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=55
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldHdr1"
						$oObjectTemp.text:="ID"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer3"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldName"
						$oColumnObj.dataSource:="This:C1470.name"
						$oColumnObj.width:=230
						$oColumnObj.minWidth:=220
						$oColumnObj.maxWidth:=500
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldHdr2"
						$oObjectTemp.text:="Name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer4"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldType"
						$oColumnObj.dataSource:="This:C1470.typeString"
						$oColumnObj.width:=60
						$oColumnObj.minWidth:=60
						$oColumnObj.maxWidth:=90
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oColumnObj.events:=New collection:C1472("onClick"; "onDataChange")
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldHdr3"
						$oObjectTemp.text:="Type"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer5"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldLength"
						$oColumnObj.dataSource:="This:C1470.limitingLength"
						$oColumnObj.dataSourceTypeHint:="number"
						$oColumnObj.width:=34
						$oColumnObj.minWidth:=34
						$oColumnObj.maxWidth:=34
						$oColumnObj.enterable:=False:C215
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldHdr4"
						$oObjectTemp.text:="Len"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer6"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldPK"
						$oColumnObj.dataSource:="This:C1470.primaryKey"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=40
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldHdr5"
						$oObjectTemp.text:="PK"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer7"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldUnique"
						$oColumnObj.dataSource:="This:C1470.unique"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=40
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldHdr6"
						$oObjectTemp.text:="Uni"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer8"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldAutoGen"
						$oColumnObj.dataSource:="This:C1470.autoGenerate"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=40
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldHdr7"
						$oObjectTemp.text:="Auto"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer9"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldUUID"
						$oColumnObj.dataSource:="This:C1470.UUID"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=40
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldHdr8"
						$oObjectTemp.text:="UU"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer10"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldHdr15"
						$oObjectTemp.text:="Incr"
						$oColumnObj.header:=$oObjectTemp
						$oColumnObj.name:="fieldIncr"
						$oColumnObj.width:=40
						$oColumnObj.textAlign:="center"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer83"
						$oColumnObj.footer:=$oObjectTemp
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.dataSource:="This:C1470.autoSequence"
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=40
						$oColumnObj.enterable:=False:C215
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldIndexed"
						$oColumnObj.dataSource:="This:C1470.indexed"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=40
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldHdr9"
						$oObjectTemp.text:="Ind"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer16"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldInIndex"
						$oColumnObj.dataSource:="This:C1470.inIndex"
						$oColumnObj.dataSourceTypeHint:="number"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=40
						$oColumnObj.enterable:=False:C215
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldHdr10"
						$oObjectTemp.text:="#Ind"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer15"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldVisible"
						$oColumnObj.dataSource:="This:C1470.visible"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=40
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldHdr11"
						$oObjectTemp.text:="Vis"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer11"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldMandatory"
						$oColumnObj.dataSource:="This:C1470.mandatory"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=40
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldHdr12"
						$oObjectTemp.text:="Man"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer12"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldEnterable"
						$oColumnObj.dataSource:="This:C1470.enterable"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=40
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldHdr13"
						$oObjectTemp.text:="Ent"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer13"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldModif"
						$oColumnObj.dataSource:="This:C1470.modifiable"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=40
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldHdr14"
						$oObjectTemp.text:="Mod"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer14"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oPageObject.columns:=$colColumns
						//+++++++++++++++++++++++++++
						//End list box columns
						//+++++++++++++++++++++++++++
						$oObjects.lbTableFields:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="splitter"
						$oPageObject.top:=526
						$oPageObject.left:=313
						$oPageObject.width:=824
						$oPageObject.height:=5
						$oPageObject.events:=New collection:C1472("onClick")
						$oPageObject.sizingX:="grow"
						$oObjects.SplitterH1:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="listbox"
						$oPageObject.top:=537
						$oPageObject.left:=317
						$oPageObject.width:=815
						$oPageObject.height:=155
						$oPageObject.sizingY:="grow"
						$oPageObject.resizingMode:="rightToLeft"
						$oPageObject.listboxType:="collection"
						$oPageObject.movableRows:=False:C215
						$oPageObject.dataSource:="Form:C1466.colRelationsByTable"
						$oPageObject.currentItemSource:="Form:C1466.currentRelationByTable"
						$oPageObject.currentItemPositionSource:="Form:C1466.currentRelationByTablePos"
						$oPageObject.selectedItemsSource:="Form:C1466.currentRelationByTableSel"
						$oPageObject.selectionMode:="single"
						$oPageObject.scrollbarHorizontal:="automatic"
						$oPageObject.events:=New collection:C1472("onLoad"; "onClick"; "onDisplayDetail"; "onSelectionChange")
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.sizingX:="grow"
						$oPageObject.columns:=New collection:C1472
						//+++++++++++++++++++++++++++
						//Start list box columns
						//+++++++++++++++++++++++++++
						$colColumns:=New collection:C1472
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relationRef1"
						$oColumnObj.dataSource:="This:C1470.ref"
						$oColumnObj.width:=30
						$oColumnObj.minWidth:=30
						$oColumnObj.maxWidth:=40
						$oColumnObj.enterable:=False:C215
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationBTblHdr0"
						$oObjectTemp.text:="Ref"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer46"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relation1toN"
						$oColumnObj.dataSource:="This:C1470.name_1toN"
						$oColumnObj.width:=130
						$oColumnObj.minWidth:=130
						$oColumnObj.maxWidth:=200
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationBTblHdr1"
						$oObjectTemp.text:="1 to N name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer17"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relationNto1"
						$oColumnObj.dataSource:="This:C1470.name_Nto1"
						$oColumnObj.width:=130
						$oColumnObj.minWidth:=130
						$oColumnObj.maxWidth:=200
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationBTblHdr2"
						$oObjectTemp.text:="N to 1 name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer18"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relationDestTable"
						$oColumnObj.dataSource:="This:C1470.destinationTable"
						$oColumnObj.width:=130
						$oColumnObj.minWidth:=130
						$oColumnObj.maxWidth:=200
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationBTblHdr3"
						$oObjectTemp.text:="Destination Table"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer19"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relationDestField"
						$oColumnObj.dataSource:="This:C1470.destinationField"
						$oColumnObj.width:=130
						$oColumnObj.minWidth:=130
						$oColumnObj.maxWidth:=200
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationBTblHdr4"
						$oObjectTemp.text:="Destination Field"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer20"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relationSourceTable"
						$oColumnObj.dataSource:="This:C1470.sourceTable"
						$oColumnObj.width:=130
						$oColumnObj.minWidth:=130
						$oColumnObj.maxWidth:=200
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationBTblHdr5"
						$oObjectTemp.text:="Source Table"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer21"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relationSourceField"
						$oColumnObj.dataSource:="This:C1470.sourceField"
						$oColumnObj.width:=130
						$oColumnObj.minWidth:=130
						$oColumnObj.maxWidth:=200
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationBTblHdr6"
						$oObjectTemp.text:="Source Field"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer22"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oPageObject.columns:=$colColumns
						//+++++++++++++++++++++++++++
						//End list box columns
						//+++++++++++++++++++++++++++
						$oObjects.lbRelationsByTable:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=30
						$oPageObject.left:=268
						$oPageObject.width:=40
						$oPageObject.height:=17
						$oPageObject.dataSource:="Form:C1466.oCatalog.iTotalTables"
						$oPageObject.dataSourceTypeHint:="number"
						$oPageObject.textAlign:="left"
						$oPageObject.focusable:=False:C215
						$oPageObject.fill:="transparent"
						$oPageObject.borderStyle:="none"
						$oPageObject.enterable:=False:C215
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oObjects.totalTables:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="text"
						$oPageObject.top:=30
						$oPageObject.left:=262
						$oPageObject.width:=5
						$oPageObject.height:=17
						$oPageObject.text:="/"
						$oObjects.Text6:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=30
						$oPageObject.left:=220
						$oPageObject.width:=40
						$oPageObject.height:=17
						$oPageObject.dataSource:="Form:C1466.iFiltTables"
						$oPageObject.dataSourceTypeHint:="number"
						$oPageObject.textAlign:="right"
						$oPageObject.focusable:=False:C215
						$oPageObject.fill:="transparent"
						$oPageObject.borderStyle:="none"
						$oPageObject.enterable:=False:C215
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oObjects.filterTables:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="splitter"
						$oPageObject.top:=51
						$oPageObject.left:=307
						$oPageObject.width:=5
						$oPageObject.height:=646
						$oPageObject.events:=New collection:C1472("onClick")
						$oPageObject.sizingX:="fixed"
						$oPageObject.splitterMode:="resize"
						$oPageObject.sizingY:="grow"
						$oObjects.SplitterV1:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="button"
						$oPageObject.text:="X"
						$oPageObject.top:=31
						$oPageObject.left:=194
						$oPageObject.width:=16
						$oPageObject.height:=16
						$oPageObject.events:=New collection:C1472("onClick")
						$oPageObject.style:="custom"
						$oPageObject.stroke:="#c0c0c0"
						$oPageObject.textPlacement:="center"
						$oPageObject.focusable:=False:C215
						$oPageObject.shortcutAccel:=False:C215
						$oPageObject.shortcutControl:=False:C215
						$oPageObject.shortcutShift:=False:C215
						$oPageObject.shortcutAlt:=False:C215
						$oPageObject.shortcutKey:="[Del]"
						$oPageObject.method:="UT_Catalog_View"
						$oObjects.btnClearTablesFilter:=$oPageObject
						
						$oFormObject.pages.push(New object:C1471("objects"; $oObjects))
						//+++++++++++++++++++++++++++
						//Processing form page 2
						//+++++++++++++++++++++++++++
						$oObjects:=New object:C1471
						$oPageObject:=New object:C1471
						$oPageObject.type:="rectangle"
						$oPageObject.top:=26
						$oPageObject.left:=20
						$oPageObject.width:=197
						$oPageObject.height:=26
						$oPageObject.stroke:="#CCCCCC"
						$oPageObject.borderRadius:=10
						$oObjects.Round_Rectangle2:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=30
						$oPageObject.left:=32
						$oPageObject.width:=171
						$oPageObject.height:=17
						$oPageObject.borderStyle:="none"
						$oPageObject.hideFocusRing:=True:C214
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.events:=New collection:C1472("onAfterKeystroke")
						$oPageObject.placeholder:="Enter relations filter here"
						$oObjects.FilterValueRelations:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="listbox"
						$oPageObject.top:=60
						$oPageObject.left:=20
						$oPageObject.width:=1112
						$oPageObject.height:=256
						$oPageObject.sizingY:="grow"
						$oPageObject.resizingMode:="rightToLeft"
						$oPageObject.listboxType:="collection"
						$oPageObject.movableRows:=False:C215
						$oPageObject.dataSource:="Form:C1466.colRelationsAll"
						$oPageObject.currentItemSource:="Form:C1466.currentRelation"
						$oPageObject.currentItemPositionSource:="Form:C1466.currentRelationPos"
						$oPageObject.selectedItemsSource:="Form:C1466.currentRelationSel"
						$oPageObject.selectionMode:="single"
						$oPageObject.scrollbarHorizontal:="hidden"
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.events:=New collection:C1472("onLoad"; "onClick"; "onDisplayDetail"; "onSelectionChange")
						$oPageObject.sizingX:="grow"
						$oPageObject.columns:=New collection:C1472
						//+++++++++++++++++++++++++++
						//Start list box columns
						//+++++++++++++++++++++++++++
						$colColumns:=New collection:C1472
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relationRef"
						$oColumnObj.dataSource:="This:C1470.ref"
						$oColumnObj.width:=45
						$oColumnObj.minWidth:=45
						$oColumnObj.maxWidth:=65
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oColumnObj.events:=New collection:C1472("onClick"; "onDataChange")
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationHdr0"
						$oObjectTemp.text:="Ref"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer47"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relation1toN1"
						$oColumnObj.dataSource:="This:C1470.name_1toN"
						$oColumnObj.width:=178
						$oColumnObj.minWidth:=178
						$oColumnObj.maxWidth:=250
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationHdr1"
						$oObjectTemp.text:="1 to N name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer25"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relationNto2"
						$oColumnObj.dataSource:="This:C1470.name_Nto1"
						$oColumnObj.width:=178
						$oColumnObj.minWidth:=178
						$oColumnObj.maxWidth:=250
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationHd2"
						$oObjectTemp.text:="N to 1 name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer29"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relationDestTable1"
						$oColumnObj.dataSource:="This:C1470.destinationTable"
						$oColumnObj.width:=178
						$oColumnObj.minWidth:=178
						$oColumnObj.maxWidth:=250
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationHdr3"
						$oObjectTemp.text:="Dest. Table"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer30"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relationDestField1"
						$oColumnObj.dataSource:="This:C1470.destinationField"
						$oColumnObj.width:=178
						$oColumnObj.minWidth:=178
						$oColumnObj.maxWidth:=250
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationHdr4"
						$oObjectTemp.text:="Destination Field"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer31"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relationSourceTable1"
						$oColumnObj.dataSource:="This:C1470.sourceTable"
						$oColumnObj.width:=178
						$oColumnObj.minWidth:=178
						$oColumnObj.maxWidth:=250
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationHdr5"
						$oObjectTemp.text:="Source Table"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer32"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relationSourceField1"
						$oColumnObj.dataSource:="This:C1470.sourceField"
						$oColumnObj.width:=178
						$oColumnObj.minWidth:=178
						$oColumnObj.maxWidth:=250
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationHdr6"
						$oObjectTemp.text:="Source Field"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer33"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oPageObject.columns:=$colColumns
						//+++++++++++++++++++++++++++
						//End list box columns
						//+++++++++++++++++++++++++++
						$oObjects.lbRelationsAll:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="listbox"
						$oPageObject.top:=367
						$oPageObject.left:=43
						$oPageObject.width:=220
						$oPageObject.height:=316
						$oPageObject.sizingY:="grow"
						$oPageObject.resizingMode:="legacy"
						$oPageObject.listboxType:="collection"
						$oPageObject.movableRows:=False:C215
						$oPageObject.dataSource:="Form:C1466.destinationFields"
						$oPageObject.currentItemSource:="Form:C1466.currentDestinationField"
						$oPageObject.currentItemPositionSource:="Form:C1466.currentDestinationFieldPos"
						$oPageObject.selectedItemsSource:="Form:C1466.currentDestinationFieldSel"
						$oPageObject.selectionMode:="single"
						$oPageObject.scrollbarHorizontal:="hidden"
						$oPageObject.events:=New collection:C1472("onLoad"; "onClick"; "onDisplayDetail")
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.columns:=New collection:C1472
						//+++++++++++++++++++++++++++
						//Start list box columns
						//+++++++++++++++++++++++++++
						$colColumns:=New collection:C1472
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="destinationFieldIDs"
						$oColumnObj.dataSource:="This:C1470.id"
						$oColumnObj.width:=30
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="destinationFieldsHdr1"
						$oObjectTemp.text:="Id"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer48"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="destinationFieldNames"
						$oColumnObj.dataSource:="This:C1470.name"
						$oColumnObj.width:=188
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="destinationFieldsHdr2"
						$oObjectTemp.text:="Field names"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer34"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oPageObject.columns:=$colColumns
						//+++++++++++++++++++++++++++
						//End list box columns
						//+++++++++++++++++++++++++++
						$oObjects.lbDestinationFields:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="listbox"
						$oPageObject.top:=367
						$oPageObject.left:=889
						$oPageObject.width:=220
						$oPageObject.height:=316
						$oPageObject.sizingY:="grow"
						$oPageObject.resizingMode:="legacy"
						$oPageObject.listboxType:="collection"
						$oPageObject.movableRows:=False:C215
						$oPageObject.dataSource:="Form:C1466.sourceFields"
						$oPageObject.currentItemSource:="Form:C1466.currentSourceField"
						$oPageObject.currentItemPositionSource:="Form:C1466.currentSourceFieldPos"
						$oPageObject.selectedItemsSource:="Form:C1466.currentSourceFieldSel"
						$oPageObject.selectionMode:="single"
						$oPageObject.scrollbarHorizontal:="hidden"
						$oPageObject.events:=New collection:C1472("onLoad"; "onClick"; "onDisplayDetail")
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.sizingX:="move"
						$oPageObject.columns:=New collection:C1472
						//+++++++++++++++++++++++++++
						//Start list box columns
						//+++++++++++++++++++++++++++
						$colColumns:=New collection:C1472
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="sourceFieldIDs"
						$oColumnObj.dataSource:="This:C1470.id"
						$oColumnObj.width:=30
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="sourceFieldsHdr1"
						$oObjectTemp.text:="Id"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer49"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="sourceFieldNames"
						$oColumnObj.dataSource:="This:C1470.name"
						$oColumnObj.width:=188
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="sourceFieldsHdr2"
						$oObjectTemp.text:="Field Names"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer35"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oPageObject.columns:=$colColumns
						//+++++++++++++++++++++++++++
						//End list box columns
						//+++++++++++++++++++++++++++
						$oObjects.lbSourceFields:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=485
						$oPageObject.left:=292
						$oPageObject.width:=270
						$oPageObject.height:=17
						$oPageObject.sizingY:="fixed"
						$oPageObject.dataSource:="Form:C1466.tRelationName_Nto1"
						$oPageObject.textAlign:="center"
						$oPageObject.focusable:=False:C215
						$oPageObject.enterable:=False:C215
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oObjects.relationName_Nto1:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=485
						$oPageObject.left:=579
						$oPageObject.width:=270
						$oPageObject.height:=17
						$oPageObject.sizingY:="fixed"
						$oPageObject.dataSource:="Form:C1466.tRelationName_1toN"
						$oPageObject.textAlign:="center"
						$oPageObject.focusable:=False:C215
						$oPageObject.enterable:=False:C215
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oPageObject.sizingX:="move"
						$oObjects.relationName_1toN:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="text"
						$oPageObject.top:=485
						$oPageObject.left:=265
						$oPageObject.width:=18
						$oPageObject.height:=17
						$oPageObject.sizingY:="fixed"
						$oPageObject.textAlign:="center"
						$oPageObject.text:="1"
						$oObjects.Text1:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="text"
						$oPageObject.top:=485
						$oPageObject.left:=857
						$oPageObject.width:=18
						$oPageObject.height:=17
						$oPageObject.sizingY:="fixed"
						$oPageObject.textAlign:="center"
						$oPageObject.text:="N"
						$oPageObject.sizingX:="move"
						$oObjects.TextN:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=30
						$oPageObject.left:=268
						$oPageObject.width:=40
						$oPageObject.height:=17
						$oPageObject.dataSource:="Form:C1466.oCatalog.iTotalRelations"
						$oPageObject.dataSourceTypeHint:="number"
						$oPageObject.textAlign:="left"
						$oPageObject.focusable:=False:C215
						$oPageObject.fill:="transparent"
						$oPageObject.borderStyle:="none"
						$oPageObject.enterable:=False:C215
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oObjects.totalRelations:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="text"
						$oPageObject.top:=30
						$oPageObject.left:=262
						$oPageObject.width:=5
						$oPageObject.height:=17
						$oPageObject.text:="/"
						$oObjects.Text7:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=30
						$oPageObject.left:=220
						$oPageObject.width:=40
						$oPageObject.height:=17
						$oPageObject.dataSource:="Form:C1466.iFiltRelations"
						$oPageObject.dataSourceTypeHint:="number"
						$oPageObject.textAlign:="right"
						$oPageObject.focusable:=False:C215
						$oPageObject.fill:="transparent"
						$oPageObject.borderStyle:="none"
						$oPageObject.enterable:=False:C215
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oObjects.filterRelations:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="button"
						$oPageObject.text:=""
						$oPageObject.top:=336
						$oPageObject.left:=43
						$oPageObject.width:=220
						$oPageObject.height:=22
						$oPageObject.events:=New collection:C1472("onClick")
						$oPageObject.style:="bevel"
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.focusable:=False:C215
						$oPageObject.shortcutAccel:=False:C215
						$oPageObject.shortcutControl:=True:C214
						$oPageObject.shortcutShift:=False:C215
						$oPageObject.shortcutAlt:=False:C215
						$oPageObject.shortcutKey:="d"
						$oPageObject.sizingY:="fixed"
						$oObjects.btnDestinationTable:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="button"
						$oPageObject.text:=""
						$oPageObject.top:=336
						$oPageObject.left:=889
						$oPageObject.width:=220
						$oPageObject.height:=22
						$oPageObject.events:=New collection:C1472("onClick")
						$oPageObject.style:="bevel"
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.focusable:=False:C215
						$oPageObject.shortcutAccel:=False:C215
						$oPageObject.shortcutControl:=True:C214
						$oPageObject.shortcutShift:=False:C215
						$oPageObject.shortcutAlt:=False:C215
						$oPageObject.shortcutKey:="s"
						$oPageObject.sizingY:="fixed"
						$oPageObject.sizingX:="move"
						$oObjects.btnSourceTable:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="button"
						$oPageObject.text:="X"
						$oPageObject.top:=31
						$oPageObject.left:=194
						$oPageObject.width:=16
						$oPageObject.height:=16
						$oPageObject.events:=New collection:C1472("onClick")
						$oPageObject.style:="custom"
						$oPageObject.stroke:="#c0c0c0"
						$oPageObject.textPlacement:="center"
						$oPageObject.focusable:=False:C215
						$oPageObject.shortcutAccel:=False:C215
						$oPageObject.shortcutControl:=False:C215
						$oPageObject.shortcutShift:=False:C215
						$oPageObject.shortcutAlt:=False:C215
						$oPageObject.shortcutKey:="[Del]"
						$oPageObject.method:="UT_Catalog_View"
						$oObjects.btnClearRelationsFilter:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="splitter"
						$oPageObject.top:=325
						$oPageObject.left:=17
						$oPageObject.width:=1118
						$oPageObject.height:=7
						$oPageObject.events:=New collection:C1472("onClick")
						$oPageObject.sizingX:="grow"
						$oObjects.SplitterH2:=$oPageObject
						
						$oFormObject.pages.push(New object:C1471("objects"; $oObjects))
						//+++++++++++++++++++++++++++
						//Processing form page 3
						//+++++++++++++++++++++++++++
						$oObjects:=New object:C1471
						$oPageObject:=New object:C1471
						$oPageObject.type:="rectangle"
						$oPageObject.top:=26
						$oPageObject.left:=20
						$oPageObject.width:=197
						$oPageObject.height:=26
						$oPageObject.stroke:="#CCCCCC"
						$oPageObject.borderRadius:=10
						$oObjects.Round_Rectangle3:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=30
						$oPageObject.left:=32
						$oPageObject.width:=171
						$oPageObject.height:=17
						$oPageObject.borderStyle:="none"
						$oPageObject.hideFocusRing:=True:C214
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.events:=New collection:C1472("onAfterKeystroke")
						$oPageObject.placeholder:="Enter indexes filter here"
						$oObjects.FilterValueIndexes:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="listbox"
						$oPageObject.top:=60
						$oPageObject.left:=20
						$oPageObject.width:=1112
						$oPageObject.height:=276
						$oPageObject.sizingY:="grow"
						$oPageObject.resizingMode:="rightToLeft"
						$oPageObject.listboxType:="collection"
						$oPageObject.movableRows:=False:C215
						$oPageObject.dataSource:="Form:C1466.colIndexesAll"
						$oPageObject.currentItemSource:="Form:C1466.currentIndex"
						$oPageObject.currentItemPositionSource:="Form:C1466.currentIndexPos"
						$oPageObject.selectedItemsSource:="Form:C1466.currentIndexSel"
						$oPageObject.scrollbarHorizontal:="automatic"
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.events:=New collection:C1472("onLoad"; "onClick"; "onDisplayDetail"; "onSelectionChange")
						$oPageObject.sizingX:="grow"
						$oPageObject.columns:=New collection:C1472
						//+++++++++++++++++++++++++++
						//Start list box columns
						//+++++++++++++++++++++++++++
						$colColumns:=New collection:C1472
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="indexAllRef"
						$oColumnObj.dataSource:="This:C1470.ref"
						$oColumnObj.dataSourceTypeHint:="number"
						$oColumnObj.width:=41
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=65
						$oColumnObj.enterable:=False:C215
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="indexAllHdr1"
						$oObjectTemp.text:="Ref"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer66"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="indexAllTableName"
						$oColumnObj.dataSource:="This:C1470.tableName"
						$oColumnObj.width:=250
						$oColumnObj.minWidth:=230
						$oColumnObj.maxWidth:=450
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="indexAllHdr2"
						$oObjectTemp.text:="Table Name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer67"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="indexAllFieldName"
						$oColumnObj.dataSource:="This:C1470.fieldName"
						$oColumnObj.width:=250
						$oColumnObj.minWidth:=230
						$oColumnObj.maxWidth:=450
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="indexAllHdr3"
						$oObjectTemp.text:="Field Name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer68"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="indexAllIsComposite"
						$oColumnObj.dataSource:="This:C1470.isCompositeIndex"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=80
						$oColumnObj.minWidth:=60
						$oColumnObj.maxWidth:=90
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="indexAllHdr4"
						$oObjectTemp.text:="Composite"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer69"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="indexAllCompositeIndexName"
						$oColumnObj.dataSource:="This:C1470.indexName"
						$oColumnObj.width:=355
						$oColumnObj.minWidth:=355
						$oColumnObj.maxWidth:=400
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="indexAllHdr5"
						$oObjectTemp.text:="Index Name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer70"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="indexAllType"
						$oColumnObj.dataSource:="This:C1470.type"
						$oColumnObj.width:=121
						$oColumnObj.minWidth:=121
						$oColumnObj.maxWidth:=170
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oColumnObj.events:=New collection:C1472("onClick"; "onDataChange")
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="indexAllHdr6"
						$oObjectTemp.text:="Type"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer71"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oPageObject.columns:=$colColumns
						//+++++++++++++++++++++++++++
						//End list box columns
						//+++++++++++++++++++++++++++
						$oObjects.lbIndexesAll:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="splitter"
						$oPageObject.top:=349
						$oPageObject.left:=17
						$oPageObject.width:=1118
						$oPageObject.height:=7
						$oPageObject.events:=New collection:C1472("onClick")
						$oPageObject.sizingX:="grow"
						$oObjects.SplitterH3:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="listbox"
						$oPageObject.top:=361
						$oPageObject.left:=20
						$oPageObject.width:=225
						$oPageObject.height:=331
						$oPageObject.sizingY:="grow"
						$oPageObject.resizingMode:="legacy"
						$oPageObject.listboxType:="collection"
						$oPageObject.movableRows:=False:C215
						$oPageObject.dataSource:="Form:C1466.colTables3"
						$oPageObject.currentItemSource:="Form:C1466.currentTable3"
						$oPageObject.currentItemPositionSource:="Form:C1466.currentTable3Pos"
						$oPageObject.selectedItemsSource:="Form:C1466.currentTable3Sel"
						$oPageObject.selectionMode:="single"
						$oPageObject.scrollbarHorizontal:="automatic"
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.events:=New collection:C1472("onLoad"; "onClick"; "onDisplayDetail"; "onDoubleClick"; "onSelectionChange")
						$oPageObject.columns:=New collection:C1472
						//+++++++++++++++++++++++++++
						//Start list box columns
						//+++++++++++++++++++++++++++
						$colColumns:=New collection:C1472
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="table3ID"
						$oColumnObj.dataSource:="This:C1470.id"
						$oColumnObj.dataSourceTypeHint:="number"
						$oColumnObj.width:=35
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oColumnObj.events:=New collection:C1472("onClick"; "onDataChange")
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="table3Hdr1"
						$oObjectTemp.text:="ID"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer36"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="table3Name"
						$oColumnObj.dataSource:="This:C1470.name"
						$oColumnObj.width:=180
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oColumnObj.events:=New collection:C1472("onClick"; "onDataChange")
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="table3Hdr2"
						$oObjectTemp.text:="Name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer37"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="table3PK"
						$oColumnObj.dataSource:="This:C1470.primaryKey"
						$oColumnObj.width:=150
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="table3Hdr3"
						$oObjectTemp.text:="Primary Key"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer38"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="table3Visible"
						$oColumnObj.dataSource:="This:C1470.visible"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="table3Hdr4"
						$oObjectTemp.text:="Vis"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer39"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="table3TrigInsert"
						$oColumnObj.dataSource:="This:C1470.triggerInsert"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="table3Hdr5"
						$oObjectTemp.text:="TrI"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer40"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="table3TrigUpdate"
						$oColumnObj.dataSource:="This:C1470.triggerUpdate"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="table3Hdr6"
						$oObjectTemp.text:="TrU"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer41"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="table3TrigDelete"
						$oColumnObj.dataSource:="This:C1470.triggerDelete"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="table3Hdr7"
						$oObjectTemp.text:="TrD"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer42"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oPageObject.columns:=$colColumns
						//+++++++++++++++++++++++++++
						//End list box columns
						//+++++++++++++++++++++++++++
						$oObjects.lbTables3:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="listbox"
						$oPageObject.top:=376
						$oPageObject.left:=257
						$oPageObject.width:=320
						$oPageObject.height:=316
						$oPageObject.sizingY:="grow"
						$oPageObject.resizingMode:="legacy"
						$oPageObject.listboxType:="collection"
						$oPageObject.movableRows:=False:C215
						$oPageObject.dataSource:="Form:C1466.TableIndexesSingle"
						$oPageObject.currentItemSource:="Form:C1466.currentTableIndexSingle"
						$oPageObject.currentItemPositionSource:="Form:C1466.currentTableIndexSinglePos"
						$oPageObject.selectedItemsSource:="Form:C1466.currentTableIndexSingleSel"
						$oPageObject.scrollbarHorizontal:="hidden"
						$oPageObject.events:=New collection:C1472("onLoad"; "onClick"; "onDisplayDetail")
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.columns:=New collection:C1472
						//+++++++++++++++++++++++++++
						//Start list box columns
						//+++++++++++++++++++++++++++
						$colColumns:=New collection:C1472
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="indexRefSingle"
						$oColumnObj.dataSource:="This:C1470.ref"
						$oColumnObj.dataSourceTypeHint:="number"
						$oColumnObj.width:=45
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="indexTableHdr1"
						$oObjectTemp.text:="Ref"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer43"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="indexFieldNameSingle"
						$oColumnObj.dataSource:="This:C1470.fieldName"
						$oColumnObj.width:=200
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="indexTableHdr2"
						$oObjectTemp.text:="Field Name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer45"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="indexTypeSingle"
						$oColumnObj.dataSource:="This:C1470.type"
						$oColumnObj.width:=60
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="indexTableHdr3"
						$oObjectTemp.text:="Type"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer72"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oPageObject.columns:=$colColumns
						//+++++++++++++++++++++++++++
						//End list box columns
						//+++++++++++++++++++++++++++
						$oObjects.lbTableIndexesSingle:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="listbox"
						$oPageObject.top:=376
						$oPageObject.left:=590
						$oPageObject.width:=542
						$oPageObject.height:=316
						$oPageObject.sizingY:="grow"
						$oPageObject.resizingMode:="rightToLeft"
						$oPageObject.listboxType:="collection"
						$oPageObject.movableRows:=False:C215
						$oPageObject.dataSource:="Form:C1466.tableIndexesComposite"
						$oPageObject.currentItemSource:="Form:C1466.currentTableIndexComposite"
						$oPageObject.currentItemPositionSource:="Form:C1466.currentTableIndexCompositePos"
						$oPageObject.selectedItemsSource:="Form:C1466.currentTableIndexCompositeSel"
						$oPageObject.scrollbarHorizontal:="hidden"
						$oPageObject.events:=New collection:C1472("onLoad"; "onClick"; "onDisplayDetail")
						$oPageObject.right:=1132
						$oPageObject.sizingX:="grow"
						$oPageObject.columns:=New collection:C1472
						//+++++++++++++++++++++++++++
						//Start list box columns
						//+++++++++++++++++++++++++++
						$colColumns:=New collection:C1472
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="indexRefComposite"
						$oColumnObj.dataSource:="This:C1470.ref"
						$oColumnObj.dataSourceTypeHint:="number"
						$oColumnObj.width:=45
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=70
						$oColumnObj.enterable:=False:C215
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="indexTableHdr4"
						$oObjectTemp.text:="Ref"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer44"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="indexNameComposite"
						$oColumnObj.dataSource:="This:C1470.indexName"
						$oColumnObj.width:=210
						$oColumnObj.minWidth:=205
						$oColumnObj.maxWidth:=350
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oColumnObj.events:=New collection:C1472("onClick"; "onDataChange")
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="indexTableHdr5"
						$oObjectTemp.text:="Index Name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer73"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="indexFieldNameComposite"
						$oColumnObj.dataSource:="This:C1470.fieldName"
						$oColumnObj.width:=212
						$oColumnObj.minWidth:=205
						$oColumnObj.maxWidth:=350
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oColumnObj.events:=New collection:C1472("onClick"; "onDataChange")
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="indexTableHdr6"
						$oObjectTemp.text:="Field name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer74"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="indexTypeComposite"
						$oColumnObj.dataSource:="This:C1470.type"
						$oColumnObj.width:=60
						$oColumnObj.minWidth:=60
						$oColumnObj.maxWidth:=100
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oColumnObj.events:=New collection:C1472("onClick"; "onDataChange")
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="indexTableHdr7"
						$oObjectTemp.text:="Type"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer75"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oPageObject.columns:=$colColumns
						//+++++++++++++++++++++++++++
						//End list box columns
						//+++++++++++++++++++++++++++
						$oObjects.lbtableIndexesComposite:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=356
						$oPageObject.left:=384
						$oPageObject.width:=57
						$oPageObject.height:=17
						$oPageObject.dataSource:="Form:C1466.iIndexesSingle"
						$oPageObject.dataSourceTypeHint:="number"
						$oPageObject.textAlign:="left"
						$oPageObject.focusable:=False:C215
						$oPageObject.fill:="transparent"
						$oPageObject.borderStyle:="none"
						$oPageObject.enterable:=False:C215
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oObjects.SingleIndexes:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="text"
						$oPageObject.top:=356
						$oPageObject.left:=263
						$oPageObject.width:=120
						$oPageObject.height:=17
						$oPageObject.text:="Single field indexes"
						$oObjects.Text:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="text"
						$oPageObject.top:=356
						$oPageObject.left:=593
						$oPageObject.width:=120
						$oPageObject.height:=17
						$oPageObject.text:="Composite indexes"
						$oObjects.Text2:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=356
						$oPageObject.left:=752
						$oPageObject.width:=57
						$oPageObject.height:=17
						$oPageObject.dataSource:="Form:C1466.iIndexesComposite"
						$oPageObject.dataSourceTypeHint:="number"
						$oPageObject.textAlign:="left"
						$oPageObject.focusable:=False:C215
						$oPageObject.fill:="transparent"
						$oPageObject.borderStyle:="none"
						$oPageObject.enterable:=False:C215
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oObjects.CompositeIndexes:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=356
						$oPageObject.left:=718
						$oPageObject.width:=25
						$oPageObject.height:=17
						$oPageObject.dataSource:="Form:C1466.iIndexesDistinct"
						$oPageObject.dataSourceTypeHint:="number"
						$oPageObject.focusable:=False:C215
						$oPageObject.fill:="transparent"
						$oPageObject.borderStyle:="none"
						$oPageObject.enterable:=False:C215
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oObjects.CompositeIndexesDistinct:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="text"
						$oPageObject.top:=356
						$oPageObject.left:=745
						$oPageObject.width:=8
						$oPageObject.height:=17
						$oPageObject.text:="/"
						$oObjects.Text3:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=30
						$oPageObject.left:=268
						$oPageObject.width:=40
						$oPageObject.height:=17
						$oPageObject.dataSource:="Form:C1466.oCatalog.iTotalIndexes"
						$oPageObject.dataSourceTypeHint:="number"
						$oPageObject.textAlign:="left"
						$oPageObject.focusable:=False:C215
						$oPageObject.fill:="transparent"
						$oPageObject.borderStyle:="none"
						$oPageObject.enterable:=False:C215
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oObjects.totalIndexes:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="text"
						$oPageObject.top:=30
						$oPageObject.left:=262
						$oPageObject.width:=5
						$oPageObject.height:=17
						$oPageObject.text:="/"
						$oObjects.Text8:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=30
						$oPageObject.left:=220
						$oPageObject.width:=40
						$oPageObject.height:=17
						$oPageObject.dataSource:="Form:C1466.iFiltIndexes"
						$oPageObject.dataSourceTypeHint:="number"
						$oPageObject.textAlign:="right"
						$oPageObject.focusable:=False:C215
						$oPageObject.fill:="transparent"
						$oPageObject.borderStyle:="none"
						$oPageObject.enterable:=False:C215
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oObjects.filterIndexes:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="button"
						$oPageObject.text:="X"
						$oPageObject.top:=31
						$oPageObject.left:=194
						$oPageObject.width:=16
						$oPageObject.height:=16
						$oPageObject.events:=New collection:C1472("onClick")
						$oPageObject.style:="custom"
						$oPageObject.stroke:="#c0c0c0"
						$oPageObject.textPlacement:="center"
						$oPageObject.focusable:=False:C215
						$oPageObject.shortcutAccel:=False:C215
						$oPageObject.shortcutControl:=False:C215
						$oPageObject.shortcutShift:=False:C215
						$oPageObject.shortcutAlt:=False:C215
						$oPageObject.shortcutKey:="[Del]"
						$oPageObject.method:="UT_Catalog_View"
						$oObjects.btnClearIndexesFilter:=$oPageObject
						
						$oFormObject.pages.push(New object:C1471("objects"; $oObjects))
						//+++++++++++++++++++++++++++
						//Processing form page 4
						//+++++++++++++++++++++++++++
						$oObjects:=New object:C1471
						$oPageObject:=New object:C1471
						$oPageObject.type:="rectangle"
						$oPageObject.top:=26
						$oPageObject.left:=20
						$oPageObject.width:=197
						$oPageObject.height:=26
						$oPageObject.stroke:="#CCCCCC"
						$oPageObject.borderRadius:=10
						$oObjects.Round_Rectangle4:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=30
						$oPageObject.left:=32
						$oPageObject.width:=171
						$oPageObject.height:=17
						$oPageObject.borderStyle:="none"
						$oPageObject.hideFocusRing:=True:C214
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.events:=New collection:C1472("onAfterKeystroke")
						$oPageObject.placeholder:="Enter fields filter here"
						$oObjects.FilterValueFields:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="listbox"
						$oPageObject.top:=60
						$oPageObject.left:=20
						$oPageObject.width:=1112
						$oPageObject.height:=276
						$oPageObject.sizingY:="grow"
						$oPageObject.resizingMode:="rightToLeft"
						$oPageObject.listboxType:="collection"
						$oPageObject.movableRows:=False:C215
						$oPageObject.dataSource:="Form:C1466.colFieldsAll"
						$oPageObject.currentItemSource:="Form:C1466.currentField"
						$oPageObject.currentItemPositionSource:="Form:C1466.currentFieldPos"
						$oPageObject.selectedItemsSource:="Form:C1466.currentFieldSel"
						$oPageObject.scrollbarHorizontal:="automatic"
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.events:=New collection:C1472("onLoad"; "onClick"; "onDisplayDetail"; "onSelectionChange")
						$oPageObject.selectionMode:="single"
						$oPageObject.sizingX:="grow"
						$oPageObject.columns:=New collection:C1472
						//+++++++++++++++++++++++++++
						//Start list box columns
						//+++++++++++++++++++++++++++
						$colColumns:=New collection:C1472
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldsAllRef"
						$oColumnObj.dataSource:="This:C1470.ref"
						$oColumnObj.dataSourceTypeHint:="number"
						$oColumnObj.width:=45
						$oColumnObj.minWidth:=45
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr1"
						$oObjectTemp.text:="Ref"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer65"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldsAllTableName"
						$oColumnObj.dataSource:="This:C1470.tableName"
						$oColumnObj.width:=215
						$oColumnObj.minWidth:=200
						$oColumnObj.maxWidth:=300
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oColumnObj.events:=New collection:C1472("onClick"; "onDataChange")
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr2"
						$oObjectTemp.text:="Table Name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer64"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldsAllFieldID1"
						$oColumnObj.dataSource:="This:C1470.id"
						$oColumnObj.dataSourceTypeHint:="number"
						$oColumnObj.width:=30
						$oColumnObj.minWidth:=30
						$oColumnObj.maxWidth:=40
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr3"
						$oObjectTemp.text:="ID"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer50"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldsAllFieldName"
						$oColumnObj.dataSource:="This:C1470.name"
						$oColumnObj.width:=215
						$oColumnObj.minWidth:=200
						$oColumnObj.maxWidth:=300
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr4"
						$oObjectTemp.text:="Field Name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer51"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$oColumnObj.truncateMode:="none"
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldsAllType"
						$oColumnObj.dataSource:="This:C1470.typeString"
						$oColumnObj.width:=60
						$oColumnObj.minWidth:=60
						$oColumnObj.maxWidth:=90
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oColumnObj.events:=New collection:C1472("onClick"; "onDataChange")
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr5"
						$oObjectTemp.text:="Type"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer52"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldsAllLength"
						$oColumnObj.dataSource:="This:C1470.limitingLength"
						$oColumnObj.dataSourceTypeHint:="number"
						$oColumnObj.width:=34
						$oColumnObj.minWidth:=34
						$oColumnObj.maxWidth:=50
						$oColumnObj.enterable:=False:C215
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr6"
						$oObjectTemp.text:="Len"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer53"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldsAllPK"
						$oColumnObj.dataSource:="This:C1470.primaryKey"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=50
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr7"
						$oObjectTemp.text:="PK"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer54"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldsAllUnique"
						$oColumnObj.dataSource:="This:C1470.unique"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=50
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr8"
						$oObjectTemp.text:="Uni"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer55"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldsAllAutoGen"
						$oColumnObj.dataSource:="This:C1470.autoGenerate"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=50
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr9"
						$oObjectTemp.text:="Auto"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer56"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldsAllUUID"
						$oColumnObj.dataSource:="This:C1470.UUID"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=50
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr10"
						$oObjectTemp.text:="UU"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer57"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr11"
						$oObjectTemp.text:="Incr"
						$oColumnObj.header:=$oObjectTemp
						$oColumnObj.name:="fieldsAllIncr"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.textAlign:="center"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer85"
						$oColumnObj.footer:=$oObjectTemp
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.dataSource:="This:C1470.autoSequence"
						$oColumnObj.maxWidth:=50
						$oColumnObj.enterable:=False:C215
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldsAllIndexed"
						$oColumnObj.dataSource:="This:C1470.indexed"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=50
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr12"
						$oObjectTemp.text:="Ind"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer58"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldsAllIndexType"
						$oColumnObj.dataSource:="This:C1470.indexType"
						$oColumnObj.width:=60
						$oColumnObj.minWidth:=60
						$oColumnObj.maxWidth:=85
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr13"
						$oObjectTemp.text:="Index"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer82"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldsAllInIndex"
						$oColumnObj.dataSource:="This:C1470.inIndex"
						$oColumnObj.dataSourceTypeHint:="number"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=50
						$oColumnObj.enterable:=False:C215
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr14"
						$oObjectTemp.text:="#Ind"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer59"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr15"
						$oObjectTemp.text:="Rest"
						$oObjectTemp.textAlign:="center"
						$oColumnObj.header:=$oObjectTemp
						$oColumnObj.name:="fieldsAllRest"
						$oColumnObj.width:=40
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer86"
						$oColumnObj.footer:=$oObjectTemp
						$oColumnObj.verticalAlign:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.dataSource:="This:C1470.restAccess"
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=50
						$oColumnObj.enterable:=False:C215
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr16"
						$oObjectTemp.text:="Style"
						$oColumnObj.header:=$oObjectTemp
						$oColumnObj.name:="fieldsAllStyle"
						$oColumnObj.width:=40
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer87"
						$oColumnObj.footer:=$oObjectTemp
						$oColumnObj.textAlign:="center"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.dataSource:="This:C1470.styledText"
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=50
						$oColumnObj.enterable:=False:C215
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldsAllVisible"
						$oColumnObj.dataSource:="This:C1470.visible"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=50
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr17"
						$oObjectTemp.text:="Vis"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer60"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldsAllMandatory"
						$oColumnObj.dataSource:="This:C1470.mandatory"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=50
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr18"
						$oObjectTemp.text:="Man"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer61"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldsAllEnterable"
						$oColumnObj.dataSource:="This:C1470.enterable"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=50
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr19"
						$oObjectTemp.text:="Ent"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer62"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="fieldsAllModif"
						$oColumnObj.dataSource:="This:C1470.modifiable"
						$oColumnObj.dataSourceTypeHint:="boolean"
						$oColumnObj.width:=40
						$oColumnObj.minWidth:=40
						$oColumnObj.maxWidth:=50
						$oColumnObj.enterable:=False:C215
						$oColumnObj.controlType:="checkbox"
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="center"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="fieldsAllHdr20"
						$oObjectTemp.text:="Mod"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer63"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oPageObject.columns:=$colColumns
						//+++++++++++++++++++++++++++
						//End list box columns
						//+++++++++++++++++++++++++++
						$oObjects.lbFieldsAll:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="listbox"
						$oPageObject.top:=376
						$oPageObject.left:=20
						$oPageObject.width:=781
						$oPageObject.height:=316
						$oPageObject.sizingY:="grow"
						$oPageObject.resizingMode:="rightToLeft"
						$oPageObject.listboxType:="collection"
						$oPageObject.movableRows:=False:C215
						$oPageObject.dataSource:="Form:C1466.relationsField"
						$oPageObject.currentItemSource:="Form:C1466.currentRelationField"
						$oPageObject.currentItemPositionSource:="Form:C1466.currentRelationFieldPos"
						$oPageObject.selectedItemsSource:="Form:C1466.currentRelationFieldSel"
						$oPageObject.selectionMode:="single"
						$oPageObject.scrollbarHorizontal:="automatic"
						$oPageObject.method:="UT_Catalog_View"
						$oPageObject.events:=New collection:C1472("onLoad"; "onClick"; "onDisplayDetail"; "onSelectionChange")
						$oPageObject.sizingX:="grow"
						$oPageObject.columns:=New collection:C1472
						//+++++++++++++++++++++++++++
						//Start list box columns
						//+++++++++++++++++++++++++++
						$colColumns:=New collection:C1472
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relationsFieldRef"
						$oColumnObj.dataSource:="This:C1470.ref"
						$oColumnObj.width:=45
						$oColumnObj.minWidth:=45
						$oColumnObj.maxWidth:=60
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oColumnObj.events:=New collection:C1472("onClick"; "onDataChange")
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationHdr2"
						$oObjectTemp.text:="Ref"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer78"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relationsField1toN2"
						$oColumnObj.dataSource:="This:C1470.name_1toN"
						$oColumnObj.width:=190
						$oColumnObj.minWidth:=190
						$oColumnObj.maxWidth:=300
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationHdr7"
						$oObjectTemp.text:="1 to N name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer79"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relationsFieldNto3"
						$oColumnObj.dataSource:="This:C1470.name_Nto1"
						$oColumnObj.width:=190
						$oColumnObj.minWidth:=190
						$oColumnObj.maxWidth:=300
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationHd1"
						$oObjectTemp.text:="N to 1 name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer80"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relationsFieldDestTable"
						$oColumnObj.dataSource:="This:C1470.destinationTable"
						$oColumnObj.width:=170
						$oColumnObj.minWidth:=170
						$oColumnObj.maxWidth:=280
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationHdr8"
						$oObjectTemp.text:="Dest. Table"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer81"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="relationsFieldSourceTable2"
						$oColumnObj.dataSource:="This:C1470.sourceTable"
						$oColumnObj.width:=170
						$oColumnObj.minWidth:=170
						$oColumnObj.maxWidth:=280
						$oColumnObj.enterable:=False:C215
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="relationHdr10"
						$oObjectTemp.text:="Source Table"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer84"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oPageObject.columns:=$colColumns
						//+++++++++++++++++++++++++++
						//End list box columns
						//+++++++++++++++++++++++++++
						$oObjects.lbRelationsField:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="listbox"
						$oPageObject.top:=376
						$oPageObject.left:=815
						$oPageObject.width:=317
						$oPageObject.height:=316
						$oPageObject.sizingY:="grow"
						$oPageObject.resizingMode:="legacy"
						$oPageObject.listboxType:="collection"
						$oPageObject.movableRows:=False:C215
						$oPageObject.dataSource:="Form:C1466.tableIndexesComposite2"
						$oPageObject.currentItemSource:="Form:C1466.currentTableIndexComposite2"
						$oPageObject.currentItemPositionSource:="Form:C1466.currentTableIndexComposite2Pos"
						$oPageObject.selectedItemsSource:="Form:C1466.currentTableIndexComposite2Sel"
						$oPageObject.scrollbarHorizontal:="automatic"
						$oPageObject.events:=New collection:C1472("onLoad"; "onClick"; "onDisplayDetail"; "onDoubleClick")
						$oPageObject.sizingX:="move"
						$oPageObject.columns:=New collection:C1472
						//+++++++++++++++++++++++++++
						//Start list box columns
						//+++++++++++++++++++++++++++
						$colColumns:=New collection:C1472
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="indexRefComposite1"
						$oColumnObj.dataSource:="This:C1470.ref"
						$oColumnObj.dataSourceTypeHint:="number"
						$oColumnObj.width:=45
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.enterable:=False:C215
						$oColumnObj.truncateMode:="none"
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="indexTableHdr8"
						$oObjectTemp.text:="Ref"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer76"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oColumnObj:=New object:C1471
						$oColumnObj.name:="indexNameComposite1"
						$oColumnObj.dataSource:="This:C1470.indexName"
						$oColumnObj.width:=257
						$oColumnObj.minWidth:=10
						$oColumnObj.maxWidth:=32000
						$oColumnObj.stroke:="automatic"
						$oColumnObj.fill:="automatic"
						$oColumnObj.alternateFill:="automatic"
						$oColumnObj.textAlign:="automatic"
						$oColumnObj.verticalAlign:="automatic"
						$oColumnObj.events:=New collection:C1472("onClick"; "onDataChange")
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="indexTableHdr9"
						$oObjectTemp.text:="Index Name"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.header:=$oObjectTemp
						$oObjectTemp:=New object:C1471
						$oObjectTemp.name:="Footer77"
						$oObjectTemp.stroke:="automatic"
						$oObjectTemp.fill:="automatic"
						$oObjectTemp.textAlign:="automatic"
						$oObjectTemp.verticalAlign:="automatic"
						$oColumnObj.footer:=$oObjectTemp
						$colColumns.push($oColumnObj)
						$oPageObject.columns:=$colColumns
						//+++++++++++++++++++++++++++
						//End list box columns
						//+++++++++++++++++++++++++++
						$oObjects.lbtableIndexesComposite2:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="text"
						$oPageObject.top:=354
						$oPageObject.left:=819
						$oPageObject.width:=225
						$oPageObject.height:=16
						$oPageObject.sizingY:="fixed"
						$oPageObject.text:="Composite indexes for selected table"
						$oPageObject.sizingX:="move"
						$oObjects.Text5:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=354
						$oPageObject.left:=1051
						$oPageObject.width:=57
						$oPageObject.height:=17
						$oPageObject.sizingY:="fixed"
						$oPageObject.dataSource:="Form:C1466.iCompositeIdxForField"
						$oPageObject.dataSourceTypeHint:="number"
						$oPageObject.textAlign:="left"
						$oPageObject.focusable:=False:C215
						$oPageObject.fill:="transparent"
						$oPageObject.borderStyle:="none"
						$oPageObject.enterable:=False:C215
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oPageObject.sizingX:="move"
						$oObjects.CompositeIndexes1:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="text"
						$oPageObject.top:=354
						$oPageObject.left:=24
						$oPageObject.width:=165
						$oPageObject.height:=17
						$oPageObject.sizingY:="fixed"
						$oPageObject.text:="Relations for selected field"
						$oPageObject.sizingX:="fixed"
						$oObjects.Text4:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=354
						$oPageObject.left:=190
						$oPageObject.width:=47
						$oPageObject.height:=17
						$oPageObject.sizingY:="fixed"
						$oPageObject.dataSource:="Form:C1466.iRelationsForField"
						$oPageObject.dataSourceTypeHint:="number"
						$oPageObject.textAlign:="left"
						$oPageObject.focusable:=False:C215
						$oPageObject.fill:="transparent"
						$oPageObject.borderStyle:="none"
						$oPageObject.enterable:=False:C215
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oPageObject.sizingX:="fixed"
						$oObjects.CompositeIndexesDistinct2:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=30
						$oPageObject.left:=268
						$oPageObject.width:=40
						$oPageObject.height:=17
						$oPageObject.dataSource:="Form:C1466.oCatalog.iTotalFields"
						$oPageObject.dataSourceTypeHint:="number"
						$oPageObject.textAlign:="left"
						$oPageObject.focusable:=False:C215
						$oPageObject.fill:="transparent"
						$oPageObject.borderStyle:="none"
						$oPageObject.enterable:=False:C215
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oObjects.totalFields:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="text"
						$oPageObject.top:=30
						$oPageObject.left:=262
						$oPageObject.width:=5
						$oPageObject.height:=17
						$oPageObject.text:="/"
						$oObjects.Text9:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="input"
						$oPageObject.top:=30
						$oPageObject.left:=220
						$oPageObject.width:=40
						$oPageObject.height:=17
						$oPageObject.dataSource:="Form:C1466.iFiltFields"
						$oPageObject.dataSourceTypeHint:="number"
						$oPageObject.textAlign:="right"
						$oPageObject.focusable:=False:C215
						$oPageObject.fill:="transparent"
						$oPageObject.borderStyle:="none"
						$oPageObject.enterable:=False:C215
						$oPageObject.contextMenu:="none"
						$oPageObject.dragging:="none"
						$oPageObject.dropping:="none"
						$oObjects.filterFields:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="button"
						$oPageObject.text:="X"
						$oPageObject.top:=31
						$oPageObject.left:=194
						$oPageObject.width:=16
						$oPageObject.height:=16
						$oPageObject.events:=New collection:C1472("onClick")
						$oPageObject.style:="custom"
						$oPageObject.stroke:="#c0c0c0"
						$oPageObject.textPlacement:="center"
						$oPageObject.focusable:=False:C215
						$oPageObject.shortcutAccel:=False:C215
						$oPageObject.shortcutControl:=False:C215
						$oPageObject.shortcutShift:=False:C215
						$oPageObject.shortcutAlt:=False:C215
						$oPageObject.shortcutKey:="[Del]"
						$oPageObject.method:="UT_Catalog_View"
						$oObjects.btnClearFieldsFilter:=$oPageObject
						
						$oPageObject:=New object:C1471
						$oPageObject.type:="splitter"
						$oPageObject.top:=346
						$oPageObject.left:=17
						$oPageObject.width:=1118
						$oPageObject.height:=5
						$oPageObject.events:=New collection:C1472("onClick")
						$oPageObject.sizingX:="grow"
						$oObjects.SplitterH4:=$oPageObject
						
						$oFormObject.pages.push(New object:C1471("objects"; $oObjects))
						$oFormObject.tMyFormName:="UT_Catalog_View"
					End if 
					
					
					
				: ($oParam.tSubroutine="CreateFormLayoutObjectHelp")
					If (True:C214)
						var $colColumns; $colEntryOrder : Collection
						var $oFormObject; $oFormSubObject; $oPageObject; $oObjects; $oColumns; $oColumnObj; $oObjectTemp : Object
						
						//+++++++++++++++++++++++++++
						//Processing main form object
						//+++++++++++++++++++++++++++
						$oFormObject:=$oParam.oFormLayout
						$oFormObject.$4d:=New object:C1471()
						$oFormObject.windowSizingX:="variable"
						$oFormObject.windowSizingY:="variable"
						$oFormObject.windowMinWidth:=0
						$oFormObject.windowMinHeight:=0
						$oFormObject.windowMaxWidth:=32767
						$oFormObject.windowMaxHeight:=32767
						$oFormObject.rightMargin:=10
						$oFormObject.bottomMargin:=10
						$oFormObject.events:=New collection:C1472("onLoad"; "onCloseBox")
						$oFormObject.windowTitle:="Catalog Viewer Help"
						$oFormObject.destination:="detailScreen"
						$oFormObject.pages:=New collection:C1472()
						$oFormObject.geometryStamp:=80
						$oFormObject.editor:=New object:C1471()
						$oFormObject.method:="UT_Catalog_View"
						
						$oFormSubObject:=New object:C1471
						$oFormSubObject.version:="1"
						$oFormSubObject.kind:="form"
						$oFormObject.$4d:=$oFormSubObject
						
						$oFormSubObject:=New object:C1471
						$oFormSubObject.activeView:="View 1"
						$oFormSubObject.defaultView:="View 1"
						$oFormObject.editor:=$oFormSubObject
						
						//+++++++++++++++++++++++++++
						//Processing form pages
						//+++++++++++++++++++++++++++
						//+++++++++++++++++++++++++++
						//Processing form page 0
						//+++++++++++++++++++++++++++
						$oObjects:=New object:C1471
						$oFormObject.pages.push(New object:C1471("objects"; $oObjects))
						//+++++++++++++++++++++++++++
						//Processing form page 1
						//+++++++++++++++++++++++++++
						$oObjects:=New object:C1471
						$oPageObject:=New object:C1471
						$oPageObject.type:="webArea"
						$oPageObject.left:=10
						$oPageObject.top:=10
						$oPageObject.width:=1000
						$oPageObject.height:=564
						$oPageObject.sizingX:="grow"
						$oPageObject.sizingY:="grow"
						$oPageObject.contextMenu:="none"
						$oPageObject.webEngine:="embedded"
						$oPageObject.events:=New collection:C1472("onLoad")
						$oPageObject.method:="UT_Catalog_View"
						$oObjects.helpText:=$oPageObject
						
						$oFormObject.pages.push(New object:C1471("objects"; $oObjects))
						$oFormObject.tMyFormName:="UT_Catalog_Help"
					End if 
					
			End case 
		End if 
	End if 
End if 



