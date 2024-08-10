//%attributes = {}
// -------------------------------------------------------------------------------------------------
// Method name   : UT_JSONformTo4DCode
// Description.  : Converts a JSON 4D Form document into 4D Code to create to form in code
//
//               !!!!! ATTENTION - every trace you find is still an unresolved case !!!!!
//
// Parameters
//
// -------------------------------------------------------------------------------------------------
// All rights    : STC - Software, Training and Consultancy - Belgium
// -------------------------------------------------------------------------------------------------
// Created by    : Bruno Raeymaekers
// Date and time : 03/20/24, 9:18:33
// -------------------------------------------------------------------------------------------------
// ©2024 - STC bvba, All rights reserved.
// This software and source code is subject to copyright protection as literary work pursuant to the
// Belgian Copyright Laws and International Conventions. No part of this software may be reproduced
// or copied, in whole or in part, in any form or by any means. No part of this software may be used
// except under a valid licence agreement or without the prior written permission of STC bvba.
// Any infringement of the copyright in software and source code will be prosecuted to the full 
// extent permissible by law.
// -------------------------------------------------------------------------------------------------

var $colPages; $colColumns; $colPathElements : Collection
var $oFormObjectOrig; $oPage; $oColumn; $oObjectTemp; $oObjectTemp2 : Object
var $iCntrAttr; $iCntrObj; $iCntrPages; $iCntrGroup; $iCntrColumnAttr; $iCntrColumnObjAttr : Integer
var $tDesktopPath; $tDesktopFolder; $tGeneratedFile : Text
var $tDocument; $tJSONText; $tAttributeName; $tAttributeName2; $tAttributeName3 : Text
var $tColumnAttributeName; $tEventList; $tElement; $tResultText; $tMethodName; $tFormName; $tFormPath : Text
var $bSaveDocuments : Boolean

$tDocument:=Select folder:C670("Select a form folder"; Package open:K24:8)
If (ok=1)
	If (Test path name:C476($tDocument+"form.4DForm")#Is a document:K24:1)
		ALERT:C41("The selected folder doesn't contain a 4D form")
		
	Else 
		$bSaveDocuments:=True:C214
		$tResultText:=""  // this will hold the 4D code for the creation of the selected form
		$tDesktopFolder:="Compare4DForms"  // the 4D code for the form and the form itself will be saved in this folder on your desktop
		
		$tMethodName:="UT_Catalog_View"  // enter method name to change all 4D assigned method names to this one
		//$tMethodName:=""  // leave blank if you don't want to change to change the method name
		
		$colPathElements:=Split string:C1554($tDocument; Folder separator:K24:12; sk ignore empty strings:K86:1)
		$tFormName:=$colPathElements[$colPathElements.length-1]  // this will be an extra attribute in your form layout
		$tFormPath:=$tDocument+"form.4DForm"
		$tJSONText:=Document to text:C1236($tFormPath; "UTF-8")
		$oFormObjectOrig:=JSON Parse:C1218($tJSONText)
		
		ARRAY OBJECT:C1221($aoFormObjects; 0)
		ARRAY TEXT:C222($atFormObjectsAttribNames; 0)
		
		ARRAY TEXT:C222($atPropertyNames; 0)
		ARRAY LONGINT:C221($aiPropertyTypes; 0)
		
		OB GET PROPERTY NAMES:C1232($oFormObjectOrig; $atPropertyNames; $aiPropertyTypes)
		If (Size of array:C274($atPropertyNames)>0)
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
								$tResultText:=$tResultText+"$oFormObject."+$tAttributeName+":="+Char:C90(Double quote:K15:41)+$tMethodName+Char:C90(Double quote:K15:41)+Char:C90(Carriage return:K15:38)
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
											$tResultText:=$tResultText+"$oFormSubObject."+$tAttributeName2+":="+Char:C90(Double quote:K15:41)+$tMethodName+Char:C90(Double quote:K15:41)+Char:C90(Carriage return:K15:38)
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
												$tResultText:=$tResultText+"$oPageObject."+$tAttributeName2+":="+Char:C90(Double quote:K15:41)+$tMethodName+Char:C90(Double quote:K15:41)+Char:C90(Carriage return:K15:38)
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
																				$tResultText:=$tResultText+"$oObjectTemp."+$tAttributeName3+":="+Char:C90(Double quote:K15:41)+$tMethodName+Char:C90(Double quote:K15:41)+Char:C90(Carriage return:K15:38)
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
			
		End if 
	End if 
	
	SET TEXT TO PASTEBOARD:C523($tResultText)
	
	If ($bSaveDocuments)
		$tDesktopPath:=System folder:C487(Desktop:K41:16)
		If (Test path name:C476($tDesktopPath+$tDesktopFolder)=Is a folder:K24:2)
			DELETE FOLDER:C693($tDesktopPath+$tDesktopFolder; Delete with contents:K24:24)
		End if 
		
		$tGeneratedFile:=$tDesktopPath+$tDesktopFolder+Folder separator:K24:12+"GeneratedCode.txt"
		
		CREATE FOLDER:C475($tDesktopPath+$tDesktopFolder)
		TEXT TO DOCUMENT:C1237($tGeneratedFile; $tResultText; "UTF-8")
		COPY DOCUMENT:C541($tFormPath; $tDesktopPath+$tDesktopFolder+Folder separator:K24:12+$tFormName+".4DForm")
		
		ALERT:C41("Done, 4D code copied to Pasteboard and files saved in desktop folder")
		
	Else 
		ALERT:C41("Done, 4D code copied to Pasteboard")
		
	End if 
End if 
