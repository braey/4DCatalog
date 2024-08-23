//%attributes = {"shared":true}
// -------------------------------------------------------------------------------------------------
// Method name   : UT_JSONformTo4DCode
// Description.  : Converts a JSON 4D Form document into 4D Code to create to form in code
//
//               !!!!! ATTENTION - every "Trace"-cmd you find is still an unresolved case !!!!!
//
// Parameters
//
// -------------------------------------------------------------------------------------------------
// Created by    : Bruno Raeymaekers
// Date and time : 04/10/24, 09:05:39
// -------------------------------------------------------------------------------------------------
C_OBJECT:C1216($1; $oParam)

var $colPages; $colColumns; $colPathElements : Collection
var $oObjects; $oPageObject; $oPage : Object
var $oFormObjectOrig; $oPage; $oColumn; $oObjectTemp; $oObjectTemp2; $oFormLayout; $oFormObject : Object
var $iCntrAttr; $iCntrObj; $iCntrPages; $iCntrGroup; $iCntrColumnAttr; $iCntrColumnObjAttr : Integer
var $iWindowRef; $iStartPosition; $iEndPosition : Integer
var $tDesktopPath; $tGeneratedFile; $tFormName; $tFormPath; $tMethodName; $tMessage : Text
var $tColumnAttributeName; $tEventList; $tElement; $tResultText; $tMethodLastPart : Text
var $tDocument; $tJSONText; $tAttributeName; $tAttributeName2; $tAttributeName3; $tMethodFirstPart : Text
var $tMethodPath; $tMethodText; $tMethodMarkerStart; $tMethodMarkerEnd; $tMethodMarkerStart2; $tMethodMarkerEnd2 : Text
var $bContinue; $bCodePasted; $bCompareCodePasted : Boolean

If ((Count parameters:C259=0) & (FORM Event:C1606=Null:C1517))
	// ++++++++++++++++++++++++++++++++++++ begin create form layout +++++++++++++++++++++++++++++++++
	$oFormLayout:=New object:C1471("windowTitle"; "Enter parameters to generate the code"; "destination"; "detailScreen"; \
		"rightMargin"; 20; "bottomMargin"; 20; "tMyFormName"; "InputParameters"; "pages"; New collection:C1472(Null:C1517))
	
	$oObjects:=New object:C1471
	
	$oPageObject:=New object:C1471("type"; "text"; "text"; "Use 'Current method name' for method name: "; "top"; 20; "left"; 20; \
		"width"; 300; "height"; 14; "FontSize"; 14; "fontFamily"; "Arial")
	$oObjects.label1:=$oPageObject
	
	$oPageObject:=New object:C1471("type"; "checkbox"; "text"; ""; "top"; 19; "left"; 307; "width"; 20; "height"; 20; "dataSource"; "Form.iGenericName"; \
		"events"; New collection:C1472("onClick"))
	$oObjects.cbGeneric:=$oPageObject
	
	$oPageObject:=New object:C1471("type"; "text"; "text"; "Method name to copy code into: "; "top"; 50; "left"; 20; "width"; 300; "height"; 14; \
		"FontSize"; 14; "fontFamily"; "Arial")
	$oObjects.label2:=$oPageObject
	
	$oPageObject:=New object:C1471("type"; "input"; "top"; 50; "left"; 310; "width"; 250; "height"; 14; "dataSource"; "Form.tMethodName")
	$oObjects.methodName:=$oPageObject
	
	$oPageObject:=New object:C1471("type"; "text"; "text"; "Automatically paste generated code in method: "; "top"; 90; "left"; 20; "width"; 300; "height"; 14; \
		"FontSize"; 14; "fontFamily"; "Arial")
	$oObjects.label3:=$oPageObject
	
	$oPageObject:=New object:C1471("type"; "checkbox"; "text"; ""; "top"; 89; "left"; 307; "width"; 20; "height"; 20; "dataSource"; "Form.iAutoPaste"; \
		"events"; New collection:C1472("onClick"))
	$oObjects.cbAutoPaste:=$oPageObject
	
	$oPageObject:=New object:C1471("type"; "text"; "text"; "Automatically compare forms: "; "top"; 120; "left"; 20; "width"; 300; "height"; 14; \
		"FontSize"; 14; "fontFamily"; "Arial")
	$oObjects.label4:=$oPageObject
	
	$oPageObject:=New object:C1471("type"; "checkbox"; "text"; ""; "top"; 119; "left"; 307; "width"; 20; "height"; 20; "dataSource"; "Form.iAutoCompare"; \
		"events"; New collection:C1472("onClick"))
	$oObjects.cbAutoCompare:=$oPageObject
	
	$oPageObject:=New object:C1471("type"; "line"; "top"; 150; "left"; 20; "width"; 540; "height"; 2)
	$oObjects.line:=$oPageObject
	
	$oPageObject:=New object:C1471("type"; "text"; "text"; "Copy code to pasteboard: "; "top"; 160; "left"; 20; "width"; 300; "height"; 14; \
		"FontSize"; 14; "fontFamily"; "Arial")
	$oObjects.label5:=$oPageObject
	
	$oPageObject:=New object:C1471("type"; "checkbox"; "text"; ""; "top"; 159; "left"; 307; "width"; 20; "height"; 20; "dataSource"; "Form.iCodeToPasteboard"; \
		"events"; New collection:C1472("onClick"))
	$oObjects.cbCodeToPasteboard:=$oPageObject
	
	$oPageObject:=New object:C1471("type"; "text"; "text"; "Desktop Folder Name to copy code into: "; "top"; 190; "left"; 20; "width"; 300; "height"; 14; \
		"FontSize"; 14; "fontFamily"; "Arial")
	$oObjects.label6:=$oPageObject
	
	$oPageObject:=New object:C1471("type"; "input"; "top"; 190; "left"; 310; "width"; 250; "height"; 14; "dataSource"; "Form.tFolderNameCompare")
	$oObjects.folderNameCompare:=$oPageObject
	
	$oPageObject:=New object:C1471("type"; "button"; "text"; "Cancel"; "top"; 240; "left"; 350; "width"; 100; "height"; 20; "action"; "cancel"; \
		"focusable"; True:C214; "shortcutKey"; "[Esc]"; "events"; New collection:C1472("onClick"))
	$oObjects.btnCancel:=$oPageObject
	
	$oPageObject:=New object:C1471("type"; "button"; "text"; "Start"; "top"; 240; "left"; 465; "width"; 100; "height"; 20; "method"; Current method name:C684; \
		"focusable"; True:C214; "shortcutKey"; "[Esc]"; "events"; New collection:C1472("onClick"); "defaultButton"; True:C214)
	$oObjects.btnOk:=$oPageObject
	
	$oFormLayout.pages.push(New object:C1471("objects"; $oObjects))
	
	// +++++++++++++++++++++++++++++++++++++++ end create form layout ++++++++++++++++++++++++++++++++
	// ++++++++++++++++++++++++++++++++++++++ populate FORM object +++++++++++++++++++++++++++++++++++
	$oFormObject:=New object:C1471
	$oFormObject.tMethodName:=""
	$oFormObject.iGenericName:=1
	$oFormObject.iAutoCompare:=0
	$oFormObject.iAutoPaste:=0
	$oFormObject.iCodeToPasteboard:=1
	$oFormObject.tFormName:=$oFormLayout.tMyFormName
	$oFormObject.tFolderNameCompare:="Compare4DForms"
	
	// +++++++++++++++++++++++++++++++++++ end populate FORM object +++++++++++++++++++++++++++++++++++
	// +++++++++++++++++++++++++++++++++++++++ Display Form +++++++++++++++++++++++++++++++++++++++++++
	
	$iWindowRef:=Open form window:C675($oFormLayout; Movable form dialog box:K39:8; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40($oFormLayout; $oFormObject)
	
Else 
	If (Count parameters:C259=0)
		// form event handling starts here
		If (FORM Event:C1606.objectName=Null:C1517)
			// -> this is the form method
			Case of 
				: (Form:C1466.tFormName="InputParameters")  // In case you have more than 1 form
					Case of 
						: (FORM Event:C1606.code=On Load:K2:1)
							
						: (FORM Event:C1606.code=On Outside Call:K2:11)
							
						: (FORM Event:C1606.code=On Menu Selected:K2:14)
							
					End case 
					
				Else 
					UT_Alert(New object:C1471("tMessage"; "Un-supported Form Name"))
					
			End case 
		Else 
			// below are all the object methods
			
			Case of 
				: (Form:C1466.tFormName="InputParameters")  // In case you have more than 1 form
					Case of 
						: (FORM Event:C1606.objectName="btnOk")
							Case of 
								: (FORM Event:C1606.code=On Clicked:K2:4)
									$bContinue:=True:C214
									$bCodePasted:=False:C215
									$bCompareCodePasted:=False:C215
									
									$tDocument:=Select folder:C670("Select a form folder"; Package open:K24:8)
									If (Ok=0)
										UT_Alert(New object:C1471("tMessage"; "Done, user cancelled form selection"))
										$bContinue:=False:C215
										
									Else 
										If (Test path name:C476($tDocument+"form.4DForm")#Is a document:K24:1)
											UT_Alert(New object:C1471("tMessage"; "The selected folder doesn't contain a 4D form"))
											$bContinue:=False:C215
											
										Else 
											If (Form:C1466.tMethodName#"")
												If (Not:C34(Is compiled mode:C492))
													ARRAY TEXT:C222($atMethodNames; 0)
													METHOD GET NAMES:C1166($atMethodNames; *)
													
													If (Find in array:C230($atMethodNames; Form:C1466.tMethodName)<=0)
														UT_Alert(New object:C1471("tMessage"; "The given method name '"+Form:C1466.tMethodName+"' does not exist"))
														$bContinue:=False:C215
													End if 
													
												Else 
													If (Form:C1466.iAutoPaste=1)
														UT_Alert(New object:C1471("tMessage"; "You cannot paste code into a compiled database"))
														$bContinue:=False:C215
														
													End if 
												End if 
												
											Else 
												If (Form:C1466.iGenericName=0)
													UT_Alert(New object:C1471("tMessage"; "You need to provide a method name when 'Use current method name' is not checked"))
													$bContinue:=False:C215
												End if 
												If (Form:C1466.iAutoPaste=1)
													UT_Alert(New object:C1471("tMessage"; "You need to provide the method name in which you want to paste the generated code"))
													$bContinue:=False:C215
												End if 
											End if 
											
										End if 
										If ($bContinue)  // Generate the code
											$tResultText:=""  // this will hold the 4D code for the creation of the selected form
											
											If (Form:C1466.iGenericName=1)
												$tMethodName:="Current Method Name"
											Else 
												$tMethodName:=Form:C1466.tMethodName
											End if 
											
											$colPathElements:=Split string:C1554($tDocument; Folder separator:K24:12; sk ignore empty strings:K86:1)
											$tFormName:=$colPathElements[$colPathElements.length-1]  // this will be an extra attribute in your form layout
											$tFormPath:=$tDocument+"form.4DForm"
											$tMethodMarkerStart:="// ** Begin generated code for form "+$tFormName
											$tMethodMarkerEnd:="// ** End generated code for form "+$tFormName
											$tJSONText:=Document to text:C1236($tFormPath; "UTF-8")
											$oFormObjectOrig:=JSON Parse:C1218($tJSONText)
											
											ARRAY OBJECT:C1221($aoFormObjects; 0)
											ARRAY TEXT:C222($atFormObjectsAttribNames; 0)
											
											ARRAY TEXT:C222($atPropertyNames; 0)
											ARRAY LONGINT:C221($aiPropertyTypes; 0)
											
											OB GET PROPERTY NAMES:C1232($oFormObjectOrig; $atPropertyNames; $aiPropertyTypes)
											If (Size of array:C274($atPropertyNames)>0)
												$tResultText:=$tResultText+$tMethodMarkerStart+Char:C90(Carriage return:K15:38)
												$tResultText:=$tResultText+"If(True)"+Char:C90(Carriage return:K15:38)
												$tResultText:=$tResultText+"var $colColumns; $colEntryOrder : Collection"+Char:C90(Carriage return:K15:38)
												$tResultText:=$tResultText+"var $oFormObject; $oFormSubObject; $oPageObject; $oObjects; $oColumns; $oColumnObj; $oObjectTemp : Object"+Char:C90(Carriage return:K15:38)+Char:C90(Carriage return:K15:38)
												$tResultText:=$tResultText+"//+++++++++++++++++++++++++++"+Char:C90(Carriage return:K15:38)
												$tResultText:=$tResultText+"//Processing main form object"+Char:C90(Carriage return:K15:38)
												$tResultText:=$tResultText+"//+++++++++++++++++++++++++++"+Char:C90(Carriage return:K15:38)
												$tResultText:=$tResultText+"$oFormObject:=$oParam.oFormLayout"+Char:C90(Carriage return:K15:38)
												
												For ($iCntrAttr; 1; Size of array:C274($atPropertyNames))
													$tAttributeName:=$atPropertyNames{$iCntrAttr}
													Case of 
														: ($aiPropertyTypes{$iCntrAttr}=Is object:K8:27)
															$tResultText:=$tResultText+"$oFormObject."+$tAttributeName+":= New object()"+Char:C90(Carriage return:K15:38)
															
															APPEND TO ARRAY:C911($atFormObjectsAttribNames; $tAttributeName)
															APPEND TO ARRAY:C911($aoFormObjects; $oFormObjectOrig[$tAttributeName])
															
														: ($aiPropertyTypes{$iCntrAttr}=Is collection:K8:32)
															Case of 
																: ($aiPropertyTypes{$iCntrAttr}=Is null:K8:31)
																	TRACE:C157
																	
																: ($tAttributeName="pages")
																	$tResultText:=$tResultText+"$oFormObject."+$tAttributeName+":= New collection()"+Char:C90(Carriage return:K15:38)
																	
																: ($tAttributeName="events")
																	$tEventList:=""
																	For each ($tElement; $oFormObjectOrig.events)
																		If ($tEventList="")
																			$tEventList:=$tEventList+Char:C90(Double quote:K15:41)+$tElement+Char:C90(Double quote:K15:41)
																		Else 
																			$tEventList:=$tEventList+";"+Char:C90(Double quote:K15:41)+$tElement+Char:C90(Double quote:K15:41)
																		End if 
																	End for each 
																	
																	$tResultText:=$tResultText+"$oFormObject."+$tAttributeName+":= New collection("+$tEventList+")"+Char:C90(Carriage return:K15:38)
																	
																Else 
																	TRACE:C157  // if any other collections besides form events and form pages show up here
																	
															End case 
															
														: ($aiPropertyTypes{$iCntrAttr}=Is real:K8:4)
															$tResultText:=$tResultText+"$oFormObject."+$tAttributeName+":="+String:C10($oFormObjectOrig[$tAttributeName])+Char:C90(Carriage return:K15:38)
															
														: ($aiPropertyTypes{$iCntrAttr}=Is boolean:K8:9)
															$tResultText:=$tResultText+"$oFormObject."+$tAttributeName+":="+String:C10($oFormObjectOrig[$tAttributeName])+Char:C90(Carriage return:K15:38)
															
														: ($aiPropertyTypes{$iCntrAttr}=Is text:K8:3)
															If (Position:C15(Char:C90(Carriage return:K15:38); $oFormObjectOrig[$tAttributeName])>0)
																$oFormObjectOrig[$tAttributeName]:=Replace string:C233($oFormObjectOrig[$tAttributeName]; Char:C90(Carriage return:K15:38); "\\r")
															End if 
															If (Position:C15(Char:C90(Double quote:K15:41); $oFormObjectOrig[$tAttributeName])>0)
																$oFormObjectOrig[$tAttributeName]:=Replace string:C233($oFormObjectOrig[$tAttributeName]; Char:C90(Double quote:K15:41); "\\\"")
															End if 
															If ($tAttributeName="method")
																If ($tMethodName#"")
																	$tResultText:=$tResultText+"$oFormObject."+$tAttributeName+":="+$tMethodName+Char:C90(Carriage return:K15:38)
																Else 
																	$tResultText:=$tResultText+"$oFormObject."+$tAttributeName+":="+Char:C90(Double quote:K15:41)+$oFormObjectOrig[$tAttributeName]+Char:C90(Double quote:K15:41)+Char:C90(Carriage return:K15:38)
																End if 
															Else 
																$tResultText:=$tResultText+"$oFormObject."+$tAttributeName+":="+Char:C90(Double quote:K15:41)+$oFormObjectOrig[$tAttributeName]+Char:C90(Double quote:K15:41)+Char:C90(Carriage return:K15:38)
															End if 
															
														Else 
															TRACE:C157
															
													End case 
												End for 
												
												$tResultText:=$tResultText+Char:C90(Carriage return:K15:38)
												
												If (Size of array:C274($atFormObjectsAttribNames)>0)
													For ($iCntrObj; 1; Size of array:C274($atFormObjectsAttribNames))
														$tAttributeName:=$atFormObjectsAttribNames{$iCntrObj}
														$oObjectTemp:=$aoFormObjects{$iCntrObj}
														
														ARRAY TEXT:C222($atPropertyNames; 0)
														ARRAY LONGINT:C221($aiPropertyTypes; 0)
														OB GET PROPERTY NAMES:C1232($oObjectTemp; $atPropertyNames; $aiPropertyTypes)
														
														If (Size of array:C274($atPropertyNames)>0)
															$tResultText:=$tResultText+"$oFormSubObject:=New Object"+Char:C90(Carriage return:K15:38)
															
															For ($iCntrAttr; 1; Size of array:C274($atPropertyNames))
																$tAttributeName2:=$atPropertyNames{$iCntrAttr}
																Case of 
																	: ($aiPropertyTypes{$iCntrAttr}=Is null:K8:31)
																		TRACE:C157
																		
																	: ($aiPropertyTypes{$iCntrAttr}=Is object:K8:27)  // still to be improved for views
																		Case of 
																			: ($tAttributeName="Editor")
																				If ($tAttributeName2="groups")
																					$oObjectTemp2:=$aoFormObjects{$iCntrObj}.groups
																					ARRAY TEXT:C222($atPropertyNamesGroups; 0)
																					ARRAY LONGINT:C221($aiPropertyTypesGroups; 0)
																					OB GET PROPERTY NAMES:C1232($oObjectTemp2; $atPropertyNamesGroups; $aiPropertyTypesGroups)
																					
																					If (Size of array:C274($atPropertyNamesGroups)>0)
																						$tResultText:=$tResultText+"$oFormSubObjectGroups:=New Object"+Char:C90(Carriage return:K15:38)
																						
																						For ($iCntrGroup; 1; Size of array:C274($atPropertyNamesGroups))
																							
																							$tEventList:=""
																							For each ($tElement; $oObjectTemp2[$atPropertyNamesGroups{$iCntrGroup}])
																								If ($tEventList="")
																									$tEventList:=$tEventList+Char:C90(Double quote:K15:41)+$tElement+Char:C90(Double quote:K15:41)
																								Else 
																									$tEventList:=$tEventList+";"+Char:C90(Double quote:K15:41)+$tElement+Char:C90(Double quote:K15:41)
																								End if 
																							End for each 
																							$tResultText:=$tResultText+"$oFormSubObjectGroups."+$atPropertyNamesGroups{$iCntrGroup}+":= New collection("+$tEventList+")"+Char:C90(Carriage return:K15:38)
																							
																						End for 
																						
																						$tResultText:=$tResultText+"$oFormSubObject."+$tAttributeName2+":=$oFormSubObjectGroups"+Char:C90(Carriage return:K15:38)
																						
																					End if 
																					
																				Else 
																					// don't do anything - we don't need it for now (=views)
																					
																				End if 
																				
																			Else 
																				TRACE:C157
																				
																		End case 
																		
																	: ($aiPropertyTypes{$iCntrAttr}=Is collection:K8:32)
																		TRACE:C157
																		
																	: ($aiPropertyTypes{$iCntrAttr}=Is real:K8:4)
																		$tResultText:=$tResultText+"$oFormSubObject."+$tAttributeName2+":="+String:C10($oObjectTemp[$tAttributeName2])+Char:C90(Carriage return:K15:38)
																		
																	: ($aiPropertyTypes{$iCntrAttr}=Is boolean:K8:9)
																		$tResultText:=$tResultText+"$oFormSubObject."+$tAttributeName2+":="+String:C10($oObjectTemp[$tAttributeName2])+Char:C90(Carriage return:K15:38)
																		
																	: ($aiPropertyTypes{$iCntrAttr}=Is text:K8:3)
																		If (Position:C15(Char:C90(Carriage return:K15:38); $oObjectTemp[$tAttributeName2])>0)
																			$oObjectTemp[$tAttributeName2]:=Replace string:C233($oObjectTemp[$tAttributeName2]; Char:C90(Carriage return:K15:38); "\\r")
																		End if 
																		If (Position:C15(Char:C90(Double quote:K15:41); $oObjectTemp[$tAttributeName2])>0)
																			$oObjectTemp[$tAttributeName2]:=Replace string:C233($oObjectTemp[$tAttributeName2]; Char:C90(Double quote:K15:41); "\\\"")
																		End if 
																		If ($tAttributeName2="method")
																			If ($tMethodName#"")
																				$tResultText:=$tResultText+"$oFormSubObject."+$tAttributeName2+":="+$tMethodName+Char:C90(Carriage return:K15:38)
																			Else 
																				$tResultText:=$tResultText+"$oFormSubObject."+$tAttributeName2+":="+Char:C90(Double quote:K15:41)+$oObjectTemp[$tAttributeName2]+Char:C90(Double quote:K15:41)+Char:C90(Carriage return:K15:38)
																			End if 
																		Else 
																			$tResultText:=$tResultText+"$oFormSubObject."+$tAttributeName2+":="+Char:C90(Double quote:K15:41)+$oObjectTemp[$tAttributeName2]+Char:C90(Double quote:K15:41)+Char:C90(Carriage return:K15:38)
																		End if 
																		
																	Else 
																		TRACE:C157
																		
																End case 
															End for 
															
															$tResultText:=$tResultText+"$oFormObject."+$tAttributeName+":=$oFormSubObject"+Char:C90(Carriage return:K15:38)+Char:C90(Carriage return:K15:38)
															
														End if 
														
													End for 
												End if 
												
												$tResultText:=$tResultText+"//+++++++++++++++++++++++++++"+Char:C90(Carriage return:K15:38)
												$tResultText:=$tResultText+"//Processing form pages"+Char:C90(Carriage return:K15:38)
												$tResultText:=$tResultText+"//+++++++++++++++++++++++++++"+Char:C90(Carriage return:K15:38)
												
												$iCntrPages:=0
												
												ARRAY OBJECT:C1221($aoFormObjects; 0)
												ARRAY TEXT:C222($atFormObjectsAttribNames; 0)
												
												$colPages:=$oFormObjectOrig.pages
												
												For each ($oPage; $colPages)
													If ($oPage=Null:C1517)
														$iCntrPages:=$iCntrPages+1
														$tResultText:=$tResultText+"//+++++++++++++++++++++++++++"+Char:C90(Carriage return:K15:38)
														$tResultText:=$tResultText+"//Processing form page "+String:C10($iCntrPages-1)+Char:C90(Carriage return:K15:38)
														$tResultText:=$tResultText+"//+++++++++++++++++++++++++++"+Char:C90(Carriage return:K15:38)
														$tResultText:=$tResultText+"$oFormObject.pages.push(null)"+Char:C90(Carriage return:K15:38)
														
													Else 
														$iCntrPages:=$iCntrPages+1
														$tResultText:=$tResultText+"//+++++++++++++++++++++++++++"+Char:C90(Carriage return:K15:38)
														$tResultText:=$tResultText+"//Processing form page "+String:C10($iCntrPages-1)+Char:C90(Carriage return:K15:38)
														$tResultText:=$tResultText+"//+++++++++++++++++++++++++++"+Char:C90(Carriage return:K15:38)
														
														$tResultText:=$tResultText+"$oObjects:=New object"+Char:C90(Carriage return:K15:38)
														
														ARRAY TEXT:C222($atPropertyNames; 0)
														ARRAY LONGINT:C221($aiPropertyTypes; 0)
														OB GET PROPERTY NAMES:C1232($oPage.objects; $atPropertyNames; $aiPropertyTypes)
														
														For ($iCntrObj; 1; Size of array:C274($atPropertyNames))
															$tAttributeName:=$atPropertyNames{$iCntrObj}
															$oObjectTemp:=$oPage.objects[$tAttributeName]
															$tResultText:=$tResultText+"$oPageObject:=New object"+Char:C90(Carriage return:K15:38)
															
															If ($aiPropertyTypes{$iCntrObj}=Is object:K8:27)  // these are form objects, so only objects to process
																
																ARRAY TEXT:C222($atPageObjectPropertyNames; 0)
																ARRAY LONGINT:C221($aiPageObjectPropertyTypes; 0)
																OB GET PROPERTY NAMES:C1232($oObjectTemp; $atPageObjectPropertyNames; $aiPageObjectPropertyTypes)
																
																For ($iCntrAttr; 1; Size of array:C274($atPageObjectPropertyNames))
																	$tAttributeName2:=$atPageObjectPropertyNames{$iCntrAttr}
																	
																	Case of 
																		: ($aiPageObjectPropertyTypes{$iCntrAttr}=Is null:K8:31)
																			TRACE:C157
																			
																		: ($aiPageObjectPropertyTypes{$iCntrAttr}=Is real:K8:4)
																			$tResultText:=$tResultText+"$oPageObject."+$tAttributeName2+":="+String:C10($oObjectTemp[$tAttributeName2])+Char:C90(Carriage return:K15:38)
																			
																		: ($aiPageObjectPropertyTypes{$iCntrAttr}=Is boolean:K8:9)
																			$tResultText:=$tResultText+"$oPageObject."+$tAttributeName2+":="+String:C10($oObjectTemp[$tAttributeName2])+Char:C90(Carriage return:K15:38)
																			
																		: ($aiPageObjectPropertyTypes{$iCntrAttr}=Is text:K8:3)
																			If (Position:C15(Char:C90(Carriage return:K15:38); $oObjectTemp[$tAttributeName2])>0)
																				$oObjectTemp[$tAttributeName2]:=Replace string:C233($oObjectTemp[$tAttributeName2]; Char:C90(Carriage return:K15:38); "\\r")
																			End if 
																			If (Position:C15(Char:C90(Double quote:K15:41); $oObjectTemp[$tAttributeName2])>0)
																				$oObjectTemp[$tAttributeName2]:=Replace string:C233($oObjectTemp[$tAttributeName2]; Char:C90(Double quote:K15:41); "\\\"")
																			End if 
																			If ($tAttributeName2="method")
																				If ($tMethodName#"")
																					$tResultText:=$tResultText+"$oPageObject."+$tAttributeName2+":="+$tMethodName+Char:C90(Carriage return:K15:38)
																				Else 
																					$tResultText:=$tResultText+"$oPageObject."+$tAttributeName2+":="+Char:C90(Double quote:K15:41)+$oObjectTemp[$tAttributeName2]+Char:C90(Double quote:K15:41)+Char:C90(Carriage return:K15:38)
																				End if 
																			Else 
																				$tResultText:=$tResultText+"$oPageObject."+$tAttributeName2+":="+Char:C90(Double quote:K15:41)+$oObjectTemp[$tAttributeName2]+Char:C90(Double quote:K15:41)+Char:C90(Carriage return:K15:38)
																				
																			End if 
																			
																		: ($aiPageObjectPropertyTypes{$iCntrAttr}=Is object:K8:27)
																			
																			Case of 
																				: ($tAttributeName2="tooltip") | ($tAttributeName2="numberFormat") | ($tAttributeName2="entryFilter") | ($tAttributeName2="textFormat") | ($tAttributeName2="choiceList")
																					$oObjectTemp2:=$oObjectTemp[$tAttributeName2]
																					ARRAY TEXT:C222($atObjectTemp2PropertyNames; 0)
																					ARRAY LONGINT:C221($atObjectTemp2PropertyTypes; 0)
																					OB GET PROPERTY NAMES:C1232($oObjectTemp2; $atObjectTemp2PropertyNames; $atObjectTemp2PropertyTypes)
																					
																					$tResultText:=$tResultText+"$oPageObject."+$tAttributeName2+":=New object("+Char:C90(Double quote:K15:41)+$atObjectTemp2PropertyNames{1}+Char:C90(Double quote:K15:41)+";"+Char:C90(Double quote:K15:41)+$oObjectTemp2[$atObjectTemp2PropertyNames{1}]+Char:C90(Double quote:K15:41)+")"+Char:C90(Carriage return:K15:38)
																					
																				Else 
																					TRACE:C157
																					
																			End case 
																			
																		: ($aiPageObjectPropertyTypes{$iCntrAttr}=Is collection:K8:32)
																			If (($oObjectTemp.type="listbox") & ($tAttributeName2="columns"))
																				$tResultText:=$tResultText+"$oPageObject."+$tAttributeName2+":=New collection"+Char:C90(Carriage return:K15:38)
																				
																				$tResultText:=$tResultText+"//+++++++++++++++++++++++++++"+Char:C90(Carriage return:K15:38)
																				$tResultText:=$tResultText+"//Start list box columns"+Char:C90(Carriage return:K15:38)
																				$tResultText:=$tResultText+"//+++++++++++++++++++++++++++"+Char:C90(Carriage return:K15:38)
																				
																				$colColumns:=$oObjectTemp.columns
																				$tResultText:=$tResultText+"$colColumns:=New collection"+Char:C90(Carriage return:K15:38)
																				
																				For each ($oColumn; $colColumns)
																					
																					ARRAY TEXT:C222($atColumnPropertyNames; 0)
																					ARRAY LONGINT:C221($aiColumnPropertyTypes; 0)
																					OB GET PROPERTY NAMES:C1232($oColumn; $atColumnPropertyNames; $aiColumnPropertyTypes)
																					
																					$tResultText:=$tResultText+"$oColumnObj:=New Object"+Char:C90(Carriage return:K15:38)
																					
																					For ($iCntrColumnAttr; 1; Size of array:C274($atColumnPropertyNames))
																						$tColumnAttributeName:=$atColumnPropertyNames{$iCntrColumnAttr}
																						
																						Case of 
																							: ($aiColumnPropertyTypes{$iCntrColumnAttr}=Is null:K8:31)
																								TRACE:C157
																								
																							: ($aiColumnPropertyTypes{$iCntrColumnAttr}=Is real:K8:4)
																								$tResultText:=$tResultText+"$oColumnObj."+$tColumnAttributeName+":="+String:C10($oColumn[$tColumnAttributeName])+Char:C90(Carriage return:K15:38)
																								
																							: ($aiColumnPropertyTypes{$iCntrColumnAttr}=Is boolean:K8:9)
																								$tResultText:=$tResultText+"$oColumnObj."+$tColumnAttributeName+":="+String:C10($oColumn[$tColumnAttributeName])+Char:C90(Carriage return:K15:38)
																								
																							: ($aiColumnPropertyTypes{$iCntrColumnAttr}=Is text:K8:3)
																								$tResultText:=$tResultText+"$oColumnObj."+$tColumnAttributeName+":="+Char:C90(Double quote:K15:41)+$oColumn[$tColumnAttributeName]+Char:C90(Double quote:K15:41)+Char:C90(Carriage return:K15:38)
																								
																							: ($aiColumnPropertyTypes{$iCntrColumnAttr}=Is object:K8:27)
																								
																								$oObjectTemp:=New object:C1471
																								$oObjectTemp:=$oColumn[$tColumnAttributeName]
																								
																								$tResultText:=$tResultText+"$oObjectTemp:=New Object"+Char:C90(Carriage return:K15:38)
																								
																								ARRAY TEXT:C222($atColumnObjectPropertyNames; 0)
																								ARRAY LONGINT:C221($aiColumnObjectPropertyTypes; 0)
																								OB GET PROPERTY NAMES:C1232($oObjectTemp; $atColumnObjectPropertyNames; $aiColumnObjectPropertyTypes)
																								
																								For ($iCntrColumnObjAttr; 1; Size of array:C274($atColumnObjectPropertyNames))
																									$tAttributeName3:=$atColumnObjectPropertyNames{$iCntrColumnObjAttr}
																									
																									Case of 
																										: ($aiColumnObjectPropertyTypes{$iCntrColumnObjAttr}=Is real:K8:4)
																											$tResultText:=$tResultText+"$oObjectTemp."+$tAttributeName3+":="+String:C10($oObjectTemp[$tAttributeName3])+Char:C90(Carriage return:K15:38)
																											
																										: ($aiColumnObjectPropertyTypes{$iCntrColumnObjAttr}=Is boolean:K8:9)
																											$tResultText:=$tResultText+"$oObjectTemp."+$tAttributeName3+":="+String:C10($oObjectTemp[$tAttributeName3])+Char:C90(Carriage return:K15:38)
																											
																										: ($aiColumnObjectPropertyTypes{$iCntrColumnObjAttr}=Is text:K8:3)
																											If (Position:C15(Char:C90(Carriage return:K15:38); $oObjectTemp[$tAttributeName3])>0)
																												$oObjectTemp[$tAttributeName3]:=Replace string:C233($oObjectTemp[$tAttributeName3]; Char:C90(Carriage return:K15:38); "\\r")
																											End if 
																											If (Position:C15(Char:C90(Double quote:K15:41); $oObjectTemp[$tAttributeName3])>0)
																												$oObjectTemp[$tAttributeName3]:=Replace string:C233($oObjectTemp[$tAttributeName3]; Char:C90(Double quote:K15:41); "\\\"")
																											End if 
																											If ($tAttributeName3="method")
																												If ($tMethodName#"")
																													$tResultText:=$tResultText+"$oObjectTemp."+$tAttributeName3+":="+$tMethodName+Char:C90(Carriage return:K15:38)
																												Else 
																													$tResultText:=$tResultText+"$oObjectTemp."+$tAttributeName3+":="+Char:C90(Double quote:K15:41)+$oObjectTemp[$tAttributeName3]+Char:C90(Double quote:K15:41)+Char:C90(Carriage return:K15:38)
																												End if 
																											Else 
																												$tResultText:=$tResultText+"$oObjectTemp."+$tAttributeName3+":="+Char:C90(Double quote:K15:41)+$oObjectTemp[$tAttributeName3]+Char:C90(Double quote:K15:41)+Char:C90(Carriage return:K15:38)
																											End if 
																											
																										: ($aiColumnObjectPropertyTypes{$iCntrColumnObjAttr}=Is object:K8:27)
																											TRACE:C157
																											
																										: ($aiColumnObjectPropertyTypes{$iCntrColumnObjAttr}=Is collection:K8:32)
																											TRACE:C157
																											
																									End case 
																								End for 
																								
																								$tResultText:=$tResultText+"$oColumnObj."+$tColumnAttributeName+":=$oObjectTemp"+Char:C90(Carriage return:K15:38)
																								
																							: ($aiColumnPropertyTypes{$iCntrColumnAttr}=Is collection:K8:32)
																								$tEventList:=""
																								For each ($tElement; $oColumn[$tColumnAttributeName])
																									If ($tEventList="")
																										$tEventList:=$tEventList+Char:C90(Double quote:K15:41)+$tElement+Char:C90(Double quote:K15:41)
																									Else 
																										$tEventList:=$tEventList+";"+Char:C90(Double quote:K15:41)+$tElement+Char:C90(Double quote:K15:41)
																									End if 
																								End for each 
																								
																								$tResultText:=$tResultText+"$oColumnObj."+$tColumnAttributeName+":= New collection("+$tEventList+")"+Char:C90(Carriage return:K15:38)
																								
																							Else 
																								TRACE:C157
																								
																						End case 
																						
																					End for 
																					
																					$tResultText:=$tResultText+"$colColumns.push($oColumnObj)"+Char:C90(Carriage return:K15:38)
																					
																				End for each 
																				
																				$tResultText:=$tResultText+"$oPageObject.columns:=$colColumns"+Char:C90(Carriage return:K15:38)
																				
																				$tResultText:=$tResultText+"//+++++++++++++++++++++++++++"+Char:C90(Carriage return:K15:38)
																				$tResultText:=$tResultText+"//End list box columns"+Char:C90(Carriage return:K15:38)
																				$tResultText:=$tResultText+"//+++++++++++++++++++++++++++"+Char:C90(Carriage return:K15:38)
																				
																			Else 
																				$tEventList:=""
																				For each ($tElement; $oObjectTemp[$tAttributeName2])
																					If ($tEventList="")
																						$tEventList:=$tEventList+Char:C90(Double quote:K15:41)+$tElement+Char:C90(Double quote:K15:41)
																					Else 
																						$tEventList:=$tEventList+";"+Char:C90(Double quote:K15:41)+$tElement+Char:C90(Double quote:K15:41)
																					End if 
																				End for each 
																				
																				$tResultText:=$tResultText+"$oPageObject."+$tAttributeName2+":= New collection("+$tEventList+")"+Char:C90(Carriage return:K15:38)
																				
																			End if 
																			
																		Else 
																			TRACE:C157
																			
																	End case 
																End for 
																
																$tResultText:=$tResultText+"$oObjects."+$tAttributeName+":= $oPageObject"+Char:C90(Carriage return:K15:38)+Char:C90(Carriage return:K15:38)
															Else 
																TRACE:C157  // nothing else but type Object possible 
																
															End if 
														End for 
														
														// process entry order if any
														If ($oPage.entryOrder#Null:C1517)
															$tEventList:=""
															For each ($tElement; $oPage.entryOrder)
																If ($tEventList="")
																	$tEventList:=$tEventList+Char:C90(Double quote:K15:41)+$tElement+Char:C90(Double quote:K15:41)
																Else 
																	$tEventList:=$tEventList+";"+Char:C90(Double quote:K15:41)+$tElement+Char:C90(Double quote:K15:41)
																End if 
															End for each 
															
															$tResultText:=$tResultText+"$colEntryOrder:=New Collection("+$tEventList+")"+Char:C90(Carriage return:K15:38)
															$tResultText:=$tResultText+"$oFormObject.pages.push(New object("+Char:C90(Double quote:K15:41)+"objects"+Char:C90(Double quote:K15:41)+";$oObjects;"+Char:C90(Double quote:K15:41)+"entryOrder"+Char:C90(Double quote:K15:41)+";$colEntryOrder))"+Char:C90(Carriage return:K15:38)
															
														Else 
															$tResultText:=$tResultText+"$oFormObject.pages.push(New object("+Char:C90(Double quote:K15:41)+"objects"+Char:C90(Double quote:K15:41)+";$oObjects))"+Char:C90(Carriage return:K15:38)
															
														End if 
														
													End if 
												End for each 
												
												$tResultText:=$tResultText+"$oFormObject.tMyFormName:="+Char:C90(Double quote:K15:41)+$tFormName+Char:C90(Double quote:K15:41)+Char:C90(Carriage return:K15:38)
												$tResultText:=$tResultText+"End if"+Char:C90(Carriage return:K15:38)
												$tResultText:=$tResultText+$tMethodMarkerEnd
												
												If (Form:C1466.iCodeToPasteboard=1)
													SET TEXT TO PASTEBOARD:C523($tResultText)
												End if 
												
											End if 
										End if 
									End if   // end of code generation
									
									If ($bContinue)
										If (Form:C1466.iAutoPaste=1)  // copy code into method
											UT_Confirm(New object:C1471("tMessage"; "Are you sure you want to paste the generated code in the method: '"+Form:C1466.tMethodName+"' ?"))
											If (OK=0)
												$bContinue:=False:C215
												
											Else 
												UT_Confirm(New object:C1471("tMessage"; "Is the method: '"+Form:C1466.tMethodName+"' closed?"))
												If (OK=0)
													$bContinue:=False:C215
												End if 
												If (Not:C34($bContinue))
													UT_Alert(New object:C1471("tMessage"; "Done, pasting the generated code was interupted by the user"))
													
												Else 
													$tMethodPath:=METHOD Get path:C1164(Path project method:K72:1; Form:C1466.tMethodName)
													METHOD GET CODE:C1190($tMethodPath; $tMethodText; *)
													$iStartPosition:=Position:C15($tMethodMarkerStart; $tMethodText)
													If ($iStartPosition<=0)
														UT_Alert(New object:C1471("tMessage"; "Cannot paste code, no start code marker found!!!"))
														$bContinue:=False:C215
													Else 
														$iEndPosition:=Position:C15($tMethodMarkerEnd; $tMethodText)
														If ($iEndPosition<=0)
															UT_Alert(New object:C1471("tMessage"; "Cannot paste code, no end code marker found!!!"))
															$bContinue:=False:C215
														Else 
															$tMethodFirstPart:=Substring:C12($tMethodText; 1; $iStartPosition-1)
															$tMethodLastPart:=Substring:C12($tMethodText; $iEndPosition+Length:C16($tMethodMarkerEnd))
															$tMethodText:=$tMethodFirstPart+$tResultText+$tMethodLastPart
															METHOD SET CODE:C1194($tMethodPath; $tMethodText; *)
															
															$bCodePasted:=True:C214
															
															METHOD OPEN PATH:C1213(Form:C1466.tMethodName; 1900; *)
															
														End if 
													End if 
												End if 
											End if 
										End if 
									End if 
									
									If ($bContinue)
										If (Form:C1466.iAutoCompare=1)  // copy code into method "UT_CompareJSONFormCode" and run the method
											UT_Confirm(New object:C1471("tMessage"; "Is the method: 'UT_CompareJSONFormCode' closed?"))
											If (Ok=0)
												UT_Alert(New object:C1471("tMessage"; "Done, compare generated code interupted by the user"))
												
											Else 
												$tDesktopPath:=System folder:C487(Desktop:K41:16)
												If (Test path name:C476($tDesktopPath+Form:C1466.tFolderNameCompare)=Is a folder:K24:2)
													DELETE FOLDER:C693($tDesktopPath+Form:C1466.tFolderNameCompare; Delete with contents:K24:24)
												End if 
												
												$tGeneratedFile:=$tDesktopPath+Form:C1466.tFolderNameCompare+Folder separator:K24:12+"GeneratedCode.txt"
												
												CREATE FOLDER:C475($tDesktopPath+Form:C1466.tFolderNameCompare)
												TEXT TO DOCUMENT:C1237($tGeneratedFile; $tResultText; "UTF-8")
												COPY DOCUMENT:C541($tFormPath; $tDesktopPath+Form:C1466.tFolderNameCompare+Folder separator:K24:12+$tFormName+".4DForm")
												
												$tMethodMarkerStart2:="// ** Begin code marker"
												$tMethodMarkerEnd2:="// ** End code marker"
												
												$tResultText:=Replace string:C233($tResultText; $tMethodMarkerStart; $tMethodMarkerStart2)
												$tResultText:=Replace string:C233($tResultText; $tMethodMarkerEnd; $tMethodMarkerEnd2)
												
												$tMethodPath:=METHOD Get path:C1164(Path project method:K72:1; "UT_CompareJSONFormCode")
												METHOD GET CODE:C1190($tMethodPath; $tMethodText; *)
												
												$iStartPosition:=Position:C15($tMethodMarkerStart2; $tMethodText)
												$iEndPosition:=Position:C15($tMethodMarkerEnd2; $tMethodText)
												
												If ($iStartPosition>0) & ($iEndPosition>0)
													$tMethodFirstPart:=Substring:C12($tMethodText; 1; $iStartPosition-1)
													$tMethodLastPart:=Substring:C12($tMethodText; $iEndPosition+Length:C16($tMethodMarkerEnd2))
													$tMethodText:=$tMethodFirstPart+$tResultText+$tMethodLastPart
													METHOD SET CODE:C1194($tMethodPath; $tMethodText; *)
													
													
													$oObjectTemp:=New object:C1471
													$oObjectTemp.desktopFolder:=Form:C1466.tFolderNameCompare
													UT_CompareJSONformCode($oObjectTemp)
													
													$bCompareCodePasted:=True:C214
													
												Else 
													UT_Alert(New object:C1471("tMessage"; "Can not run compare, code marker(s) is/are missing"))
													
												End if 
											End if 
										End if 
									End if 
									
									If ($bContinue)
										$tMessage:="Done!!!"+Char:C90(Carriage return:K15:38)
										If (Form:C1466.iCodeToPasteboard=1)
											$tMessage:=$tMessage+"- 4D code for form "+$tFormName+" copied to Pasteboard"+Char:C90(Carriage return:K15:38)
										End if 
										
										Case of 
											: ($bCompareCodePasted) & ($bCodePasted)
												$tMessage:=$tMessage+"- Generated coded was pasted in method "+Form:C1466.tMethodName+" at code marker "+$tMethodMarkerStart+Char:C90(Carriage return:K15:38)
												$tMessage:=$tMessage+"- Generated coded was pasted in method UT_CompareJSONFormCode at code marker "+$tMethodMarkerStart2+Char:C90(Carriage return:K15:38)
												$tMessage:=$tMessage+"- You can use the compare function if you have BBEdit"
												$tMessage:=$tMessage+"- To finalize compare, open terminal and paste command from Pasteboard"
												
											: ($bCodePasted)
												$tMessage:=$tMessage+"- Generated coded was pasted in method "+Form:C1466.tMethodName+" at code marker "+$tMethodMarkerStart+Char:C90(Carriage return:K15:38)
												
											: ($bCompareCodePasted)
												$tMessage:=$tMessage+"- Generated coded was pasted in method UT_CompareJSONFormCode at code marker "+$tMethodMarkerStart2+Char:C90(Carriage return:K15:38)
												$tMessage:=$tMessage+"- You can use the compare function if you have BBEdit"
												$tMessage:=$tMessage+"- To finalize compare, open terminal and paste command from Pasteboard"
												
										End case 
										
										UT_Alert(New object:C1471("tMessage"; $tMessage; "iWidth"; 650; "iHeight"; 210))
										
									End if 
									
									CANCEL:C270
									
							End case 
					End case 
					
				Else 
					UT_Alert(New object:C1471("tMessage"; "Un-supported Form Name"))
					
			End case 
		End if 
		
	Else 
		// start of all the sub-routines - method has been called from within 
		// parameters + return values in $oParam
		
		$oParam:=$1
		If ($oParam.tSubroutine#Null:C1517)
			Case of 
					
				Else 
					UT_Alert(New object:C1471("tMessage"; "Un-supported sub-routine"))
					
			End case 
		End if 
	End if 
End if 
