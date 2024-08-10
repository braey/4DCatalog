//%attributes = {}
// -------------------------------------------------------------------------------------------------
// Method name   : UT_CreateTableFromCatalog
// Description    
// 
//
// Parameters
//
// -------------------------------------------------------------------------------------------------
// All rights    : STC - Software, Training and Consultancy - Belgium
// -------------------------------------------------------------------------------------------------
// Created by    : Bruno Raeymaekers
// Date and time : 26/07/24, 9:42:40
// -------------------------------------------------------------------------------------------------
// ©2024 - STC bvba, All rights reserved.
// This software and source code is subject to copyright protection as literary work pursuant to the
// Belgian Copyright Laws and International Conventions. No part of this software may be reproduced
// or copied, in whole or in part, in any form or by any means. No part of this software may be used
// except under a valid licence agreement or without the prior written permission of STC bvba.
// Any infringement of the copyright in software and source code will be prosecuted to the full 
// extent permissible by law.
// -------------------------------------------------------------------------------------------------

var $oParam; $oReturn; $oCatalog; $oTable; $oField; $oIndex; $oRelation : Object
var $colTables; $colRelations; $colIndexes; $colFields; $colTemp1; $colTemp2 : Collection
var $iLeft; $iTop; $iRight; $iBottom; $iProgress; $iAttributes; $iPosition; $iIndexRef : Integer
var $iCntr; $iCntrTables; $iCntrRelations; $iCntrIndexes; $iCntrAttributes; $iAttributes : Integer
var $tDocument; $tXMLText; $tXMLRef; $tXMLElementRef; $tKind; $tName; $tValue; $tChildName; $tChildValue : Text
var $tTableName; $tFieldName; $tIndexName; $tIndexType; $tPKName; $tXMLElementFieldRef; $tXMLElementFieldExtraRef : Text
var $tFieldExtraName; $tFieldExtraValue; $tXMLElementIndexField; $tXMLElementIndexTableName; $tXMLElementRefRelation : Text
var $tXMLElementRefRelationField; $tXMLElementRefRelationTable; $tPrimaryKey; $tSQL; $tSQLField; $tTableAlias : Text
var $bStopProcessing; $bStopField; $bStopRelation; $bStopCompositeIndex; $bCompositeIndex : Boolean

If (Count parameters:C259=0)
	
	$oReturn:=New object:C1471
	UT_CreateTableFromCatalog(New object:C1471("tSubroutine"; "SelectCatalog"; "oReturn"; $oReturn))
	
	If ($oReturn.ok=1)
		$oCatalog:=New object:C1471
		UT_CreateTableFromCatalog(New object:C1471("tSubroutine"; "ProcessCatalogFile"; "document"; $oReturn.tDocument; "oCatalog"; $oCatalog; "oReturn"; $oReturn))
		If ($oReturn.ok#1)
			CANCEL:C270
			
		Else 
			ARRAY TEXT:C222($atTables; 0)
			ARRAY TEXT:C222($atTablesAlias; 0)
			
			CONFIRM:C162("Copy ALL tables in the selected catalog?"; "Yes"; "No")
			If (ok=1)
				For each ($oTable; $oCatalog.colTables)
					APPEND TO ARRAY:C911($atTables; $oTable.name)
					
				End for each 
				
				COPY ARRAY:C226($atTables; $atTablesAlias)
				
			Else 
				APPEND TO ARRAY:C911($atTables; "Metrics_Summary")
				APPEND TO ARRAY:C911($atTables; "Metrics_Detail")
				APPEND TO ARRAY:C911($atTables; "Metrics_Summary_Daily")
				APPEND TO ARRAY:C911($atTables; "Metrics_Detail_Daily")
				APPEND TO ARRAY:C911($atTables; "Table_Based_Lists")
				
				APPEND TO ARRAY:C911($atTablesAlias; "Statistics_Summary")
				APPEND TO ARRAY:C911($atTablesAlias; "Statistics_Detail")
				APPEND TO ARRAY:C911($atTablesAlias; "Statistics_Summary_Daily")
				APPEND TO ARRAY:C911($atTablesAlias; "Statistics_Detail_Daily")
				APPEND TO ARRAY:C911($atTablesAlias; "TableBasedLists")
				
			End if 
			
			$iIndexRef:=0  // Keep this out of the main loop
			
			For ($iCntr; 1; Size of array:C274($atTables))
				$tTableName:=$atTables{$iCntr}
				$tTableAlias:=$atTablesAlias{$iCntr}
				
				// create table
				
				$colTemp1:=$oCatalog.colTables.query("name = :1"; $tTableName)
				If ($colTemp1.length=1)
					$colTemp2:=$oCatalog.colFields.query("tableName = :1"; $tTableName)
					If ($colTemp2.length>0)
						
						$tSQL:=""
						
						For each ($oField; $colTemp2)
							$tSQLField:=""
							$tPrimaryKey:=""
							
							$oParam:=New object:C1471("tSubroutine"; "ProcessThisField"; "fieldName"; $oField.name; "processField"; True:C214)
							UT_CreateTableFromCatalog($oParam)
							If ($oParam.processField)
								
								$oParam:=New object:C1471("tSubroutine"; "RenameFields"; "oldName"; $oField.name; "newName"; $oField.name)
								UT_CreateTableFromCatalog($oParam)
								$oField.name:=$oParam.newName
								
								If ($tSQL="")
									$tSQLField:=Char:C90(Tab:K15:37)+$oField.name
								Else 
									$tSQLField:=","+Char:C90(Carriage return:K15:38)+Char:C90(Tab:K15:37)+$oField.name
								End if 
								
								Case of 
									: ($oField.type=1)
										$tSQLField:=$tSQLField+" Boolean"
									: ($oField.type=3)
										$tSQLField:=$tSQLField+" Smallint"
									: ($oField.type=4)
										$tSQLField:=$tSQLField+" Int"
									: ($oField.type=5)
										$tSQLField:=$tSQLField+" Int64"
									: ($oField.type=6)
										$tSQLField:=$tSQLField+" Real"
									: ($oField.type=8)
										$tSQLField:=$tSQLField+" Timestamp"
									: ($oField.type=9)
										$tSQLField:=$tSQLField+" Duration"
									: ($oField.type=10)
										$tSQLField:=$tSQLField+" Varchar"
									: ($oField.type=12)
										$tSQLField:=$tSQLField+" Picture"
									: ($oField.type=13)
										$tSQLField:=$tSQLField+" UUID"
									: ($oField.type=14)
										$tSQLField:=$tSQLField+" Text"
									: ($oField.type=18)
										$tSQLField:=$tSQLField+" Blob"
									: ($oField.type=21)
										$tSQLField:=$tSQLField+" Blob"
									Else 
										$tSQLField:=$tSQLField+" Varchar"
								End case 
								
								If ($oField.mandatory)
									$tSQLField:=$tSQLField+" NOT NULL"
								End if 
								
								If ($oField.unique)
									If (Position:C15("NOT NULL"; $tSQLField)<=0)
										$tSQLField:=$tSQLField+" NOT NULL UNIQUE"
									Else 
										$tSQLField:=$tSQLField+" UNIQUE"
									End if 
								End if 
								
								If ($oField.primaryKey)
									$tSQLField:=$tSQLField+" PRIMARY KEY"
								End if 
								
								If ($oField.UUID)
									If ($oField.type#13)
										//$tSQLField:=$tSQLField+" UUID"
										$tSQLField:=Replace string:C233($tSQLField; "Varchar"; "UUID")
									End if 
									If ($oField.autoGenerate)
										$tSQLField:=$tSQLField+" AUTO_GENERATE"
									End if 
									
								Else 
									If ($oField.autoSequence)
										$tSQLField:=$tSQLField+" AUTO_INCREMENT"
										
									End if 
								End if 
								
								$tSQL:=$tSQL+$tSQLField
								
							End if 
						End for each 
						
						$tSQL:="CREATE TABLE IF NOT EXISTS "+$tTableAlias+" ("+Char:C90(Carriage return:K15:38)+$tSQL
						$tSQL:=$tSQL+Char:C90(Carriage return:K15:38)+");"
						
						SET TEXT TO PASTEBOARD:C523($tSQL)
						
						Begin SQL
							EXECUTE IMMEDIATE :$tSQL
						End SQL
						
						// create single fields indexes
						$colTemp1:=$oCatalog.colIndexes.query("tableName = :1 AND isCompositeIndex = :2"; $tTableName; False:C215)
						If ($colTemp1.length>0)
							For each ($oIndex; $colTemp1)
								$tSQL:=""
								
								$oParam:=New object:C1471("tSubroutine"; "ProcessThisField"; "fieldName"; $oIndex.fieldName; "processField"; True:C214)
								UT_CreateTableFromCatalog($oParam)
								If ($oParam.processField)
									$iIndexRef:=$iIndexRef+1
									$tIndexName:="IX_"+String:C10($iIndexRef)+"_"+Substring:C12($oIndex.fieldName; 1; 23)
									
									$oParam:=New object:C1471("tSubroutine"; "RenameFields"; "oldName"; $oIndex.fieldName; "newName"; $oIndex.fieldName)
									UT_CreateTableFromCatalog($oParam)
									$oIndex.fieldName:=$oParam.newName
									
									$tSQL:="Create Index "+$tIndexName+" ON "+$tTableAlias+" ("+$oIndex.fieldName+")"
									
									Begin SQL
										EXECUTE IMMEDIATE :$tSQL
									End SQL
									
								End if 
							End for each 
						End if 
						
						// create composite indexes
						
						$colTemp1:=$oCatalog.colIndexes.query("tableName = :1 AND isCompositeIndex = :2"; $tTableName; True:C214)
						If ($colTemp1.length>0)
							$colTemp2:=$colTemp1.distinct("indexName")
							
							For each ($tIndexName; $colTemp2)
								$tSQL:=""
								$tSQLField:=""
								$colTemp1:=$oCatalog.colIndexes.query("tableName = :1 AND isCompositeIndex = :2 AND indexName = :3"; $tTableName; True:C214; $tIndexName)
								
								For each ($oIndex; $colTemp1)
									$oParam:=New object:C1471("tSubroutine"; "ProcessThisField"; "fieldName"; $oIndex.fieldName; "processField"; True:C214)
									UT_CreateTableFromCatalog($oParam)
									If ($oParam.processField)
										
										$oParam:=New object:C1471("tSubroutine"; "RenameFields"; "oldName"; $oIndex.fieldName; "newName"; $oIndex.fieldName)
										UT_CreateTableFromCatalog($oParam)
										$oIndex.fieldName:=$oParam.newName
										
										If ($tSQLField="")
											$tSQLField:=$oIndex.fieldName
										Else 
											$tSQLField:=$tSQLField+", "+$oIndex.fieldName
										End if 
									End if 
									
								End for each 
								
								If ($tSQLField#"")
									$tSQL:="Create Index "+$tIndexName+" ON "+$tTableAlias+" ("+$tSQLField+")"
								End if 
								
								Begin SQL
									EXECUTE IMMEDIATE :$tSQL
								End SQL
								
							End for each 
							
						End if 
					End if 
				End if 
				
			End for 
		End if 
	End if 
	
	ALERT:C41("Done")
	
Else 
	$oParam:=$1
	
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
			
			For ($iCntrAttributes; 1; $iAttributes)
				DOM GET XML ATTRIBUTE BY INDEX:C729($tXMLRef; $iCntrAttributes; $atAttribName{$iCntrAttributes}; $atAttribVal{$iCntrAttributes})
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
							
							For ($iCntrAttributes; 1; $iAttributes)
								DOM GET XML ATTRIBUTE BY INDEX:C729($tXMLElementRef; $iCntrAttributes; $atAttribTableName{$iCntrAttributes}; $atAttribTableVal{$iCntrAttributes})
							End for 
							
							$iPosition:=Find in array:C230($atAttribTableName; "name")
							$oTable.name:=$atAttribTableVal{$iPosition}
							$iPosition:=Find in array:C230($atAttribTableName; "id")
							$oTable.id:=Num:C11($atAttribTableVal{$iPosition})
							$oTable.primaryKey:=""
							$oTable.visible:=True:C214
							$oTable.triggerLoad:=False:C215
							$oTable.triggerInsert:=False:C215
							$oTable.triggerUpdate:=False:C215
							$oTable.triggerDelete:=False:C215
							
							$tXMLElementFieldRef:=DOM Get first child XML element:C723($tXMLElementRef; $tChildName; $tChildValue)
							If (Ok=1)
								
								Case of 
									: ($tChildName="field")
										$oTable.colFields:=New collection:C1472
										
										UT_CreateTableFromCatalog(New object:C1471("tSubroutine"; "ProcessField"; "node"; $tXMLElementFieldRef; "collection"; $oTable.colFields; "collectionAllFields"; $colFields; "tableName"; $oTable.name; "tableID"; $oTable.id))
										
										$bStopField:=False:C215
										Repeat 
											$tXMLElementFieldRef:=DOM Get next sibling XML element:C724($tXMLElementFieldRef; $tChildName; $tChildValue)
											If (Ok=0)
												$bStopField:=True:C214
												
											Else 
												Case of 
													: ($tChildName="field")
														UT_CreateTableFromCatalog(New object:C1471("tSubroutine"; "ProcessField"; "node"; $tXMLElementFieldRef; "collection"; $oTable.colFields; "collectionAllFields"; $colFields; "tableName"; $oTable.name; "tableID"; $oTable.id))
														
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
														
														For ($iCntrAttributes; 1; $iAttributes)
															DOM GET XML ATTRIBUTE BY INDEX:C729($tXMLElementFieldRef; $iCntrAttributes; $atAttribName{$iCntrAttributes}; $atAttribValue{$iCntrAttributes})
														End for 
														
														$iPosition:=Find in array:C230($atAttribName; "visible")
														If ($iPosition>0)
															If ($atAttribValue{$iPosition}="True")
																$oTable.visible:=True:C214
															Else 
																$oTable.visible:=False:C215
															End if 
														End if 
														
														$iPosition:=Find in array:C230($atAttribName; "trigger_insert")
														If ($iPosition>0)
															If ($atAttribValue{$iPosition}="True")
																$oTable.triggerInsert:=True:C214
															Else 
																$oTable.triggerInsert:=False:C215
															End if 
														End if 
														
														$iPosition:=Find in array:C230($atAttribName; "trigger_delete")
														If ($iPosition>0)
															If ($atAttribValue{$iPosition}="True")
																$oTable.triggerDelete:=True:C214
															Else 
																$oTable.triggerDelete:=False:C215
															End if 
														End if 
														
														$iPosition:=Find in array:C230($atAttribName; "trigger_update")
														If ($iPosition>0)
															If ($atAttribValue{$iPosition}="True")
																$oTable.triggerUpdate:=True:C214
															Else 
																$oTable.triggerUpdate:=False:C215
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
							UT_CreateTableFromCatalog(New object:C1471("tSubroutine"; "ProcessRelation"; "node"; $tXMLElementRef; "collection"; $colRelations))
							
							$iCntrRelations:=$iCntrRelations+1
							
							// +++++++++++++++++++++++++++++++++++++ end processing relations +++++++++++++++++++++++++++++++++++++
							// +++++++++++++++++++++++++++++++++++++ begin processing indexes +++++++++++++++++++++++++++++++++++++
						: ($tName="index")
							$bCompositeIndex:=False:C215
							
							$iAttributes:=DOM Count XML attributes:C727($tXMLElementRef)
							ARRAY TEXT:C222($atAttribIndexName; $iAttributes)
							ARRAY TEXT:C222($atAttribIndexValue; $iAttributes)
							
							For ($iCntrAttributes; 1; $iAttributes)
								DOM GET XML ATTRIBUTE BY INDEX:C729($tXMLElementRef; $iCntrAttributes; $atAttribIndexName{$iCntrAttributes}; $atAttribIndexValue{$iCntrAttributes})
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
								UT_CreateTableFromCatalog(New object:C1471("tSubroutine"; "ProcessIndex"; "node"; $tXMLElementIndexField; "collection"; $colIndexes; "isCompositeIndex"; False:C215; "indexName"; $tIndexName; "indexType"; $tIndexType))
								
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
											UT_CreateTableFromCatalog(New object:C1471("tSubroutine"; "ProcessIndex"; "node"; $tXMLElementIndexField; "collection"; $colIndexes; "isCompositeIndex"; True:C214; "indexName"; $tIndexName; "indexType"; $tIndexType))
											
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
			
			For ($iCntrAttributes; 1; $iAttributes)
				DOM GET XML ATTRIBUTE BY INDEX:C729($oParam.node; $iCntrAttributes; $atAttribFieldName{$iCntrAttributes}; $atAttribFieldVal{$iCntrAttributes})
			End for 
			
			$oField.visible:=True:C214
			$oField.unique:=False:C215
			$oField.autoGenerate:=False:C215
			$oField.UUID:=False:C215
			$oField.mandatory:=False:C215
			$oField.enterable:=True:C214
			$oField.modifiable:=True:C214
			$oField.primaryKey:=False:C215
			$oField.indexed:=False:C215
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
				Else 
					$oField.unique:=False:C215
				End if 
			End if 
			
			$iPosition:=Find in array:C230($atAttribFieldName; "autogenerate")
			If ($iPosition>0)
				If ($atAttribFieldVal{$iPosition}="True")
					$oField.autoGenerate:=True:C214
				Else 
					$oField.autoGenerate:=False:C215
				End if 
			End if 
			
			$iPosition:=Find in array:C230($atAttribFieldName; "store_as_UUID")
			If ($iPosition>0)
				If ($atAttribFieldVal{$iPosition}="True")
					$oField.UUID:=True:C214
				Else 
					$oField.UUID:=False:C215
				End if 
			End if 
			
			$iPosition:=Find in array:C230($atAttribFieldName; "visible")
			If ($iPosition>0)
				If ($atAttribFieldVal{$iPosition}="True")
					$oField.visible:=True:C214
				Else 
					$oField.visible:=False:C215
				End if 
			End if 
			
			$iPosition:=Find in array:C230($atAttribFieldName; "limiting_length")
			If ($iPosition>0)
				$oField.limitingLength:=Num:C11($atAttribFieldVal{$iPosition})
			End if 
			
			$tXMLElementFieldExtraRef:=DOM Get first child XML element:C723($oParam.node; $tFieldExtraName; $tFieldExtraValue)
			If (Ok=1)
				If ($tFieldExtraName="field_extra")
					$iAttributes:=DOM Count XML attributes:C727($tXMLElementFieldExtraRef)
					ARRAY TEXT:C222($atAttribFieldExtraName; $iAttributes)
					ARRAY TEXT:C222($atAttribFieldExtraVal; $iAttributes)
					
					For ($iCntrAttributes; 1; $iAttributes)
						DOM GET XML ATTRIBUTE BY INDEX:C729($tXMLElementFieldExtraRef; $iCntrAttributes; $atAttribFieldExtraName{$iCntrAttributes}; $atAttribFieldExtraVal{$iCntrAttributes})
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
			
			For ($iCntrAttributes; 1; $iAttributes)
				DOM GET XML ATTRIBUTE BY INDEX:C729($oParam.node; $iCntrAttributes; $atAttribIndexFieldName{$iCntrAttributes}; $atAttribIndexFieldValue{$iCntrAttributes})
			End for 
			
			$iPosition:=Find in array:C230($atAttribIndexFieldName; "name")
			$oIndex.fieldName:=$atAttribIndexFieldValue{$iPosition}
			
			$tXMLElementIndexTableName:=DOM Get first child XML element:C723($oParam.node; $tName; $tValue)
			If ($tName="table_ref")
				
				$iAttributes:=DOM Count XML attributes:C727($tXMLElementIndexTableName)
				ARRAY TEXT:C222($atAttribIndexTableName; $iAttributes)
				ARRAY TEXT:C222($atAttribIndexTableValue; $iAttributes)
				
				For ($iCntrAttributes; 1; $iAttributes)
					DOM GET XML ATTRIBUTE BY INDEX:C729($tXMLElementIndexTableName; $iCntrAttributes; $atAttribIndexTableName{$iCntrAttributes}; $atAttribIndexTableValue{$iCntrAttributes})
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
			
			For ($iCntrAttributes; 1; $iAttributes)
				DOM GET XML ATTRIBUTE BY INDEX:C729($oParam.node; $iCntrAttributes; $atAttribRelationName{$iCntrAttributes}; $atAttribRelationValue{$iCntrAttributes})
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
			
			
		: ($oParam.tSubroutine="RenameFields")
			// SQL Reserved words for columns (incomplete list)
			ARRAY TEXT:C222($atReservedFieldNames; 0)
			APPEND TO ARRAY:C911($atReservedFieldNames; "COUNT")
			APPEND TO ARRAY:C911($atReservedFieldNames; "AND")
			APPEND TO ARRAY:C911($atReservedFieldNames; "ANY")
			APPEND TO ARRAY:C911($atReservedFieldNames; "ASC")
			APPEND TO ARRAY:C911($atReservedFieldNames; "AT")
			APPEND TO ARRAY:C911($atReservedFieldNames; "AVG")
			APPEND TO ARRAY:C911($atReservedFieldNames; "BEGIN")
			APPEND TO ARRAY:C911($atReservedFieldNames; "BIT")
			APPEND TO ARRAY:C911($atReservedFieldNames; "BLOB")
			APPEND TO ARRAY:C911($atReservedFieldNames; "BY")
			APPEND TO ARRAY:C911($atReservedFieldNames; "CASCADE")
			APPEND TO ARRAY:C911($atReservedFieldNames; "CASE")
			APPEND TO ARRAY:C911($atReservedFieldNames; "CHAR")
			APPEND TO ARRAY:C911($atReservedFieldNames; "CURRENT")
			APPEND TO ARRAY:C911($atReservedFieldNames; "DATE")
			APPEND TO ARRAY:C911($atReservedFieldNames; "DEC")
			APPEND TO ARRAY:C911($atReservedFieldNames; "DESC")
			APPEND TO ARRAY:C911($atReservedFieldNames; "DESCRIPTOR")
			APPEND TO ARRAY:C911($atReservedFieldNames; "DURATION")
			APPEND TO ARRAY:C911($atReservedFieldNames; "EXCEPTION")
			APPEND TO ARRAY:C911($atReservedFieldNames; "EXISTS")
			APPEND TO ARRAY:C911($atReservedFieldNames; "FLOAT")
			APPEND TO ARRAY:C911($atReservedFieldNames; "GROUP")
			APPEND TO ARRAY:C911($atReservedFieldNames; "INT")
			APPEND TO ARRAY:C911($atReservedFieldNames; "INTEGER")
			APPEND TO ARRAY:C911($atReservedFieldNames; "KEY")
			APPEND TO ARRAY:C911($atReservedFieldNames; "LENGTH")
			APPEND TO ARRAY:C911($atReservedFieldNames; "LOG")
			APPEND TO ARRAY:C911($atReservedFieldNames; "MAX")
			APPEND TO ARRAY:C911($atReservedFieldNames; "MIN")
			APPEND TO ARRAY:C911($atReservedFieldNames; "MODE")
			APPEND TO ARRAY:C911($atReservedFieldNames; "NATURAL")
			APPEND TO ARRAY:C911($atReservedFieldNames; "OBJECT")
			APPEND TO ARRAY:C911($atReservedFieldNames; "ORDER")
			APPEND TO ARRAY:C911($atReservedFieldNames; "OVERLAPS")
			APPEND TO ARRAY:C911($atReservedFieldNames; "PICTURE")
			APPEND TO ARRAY:C911($atReservedFieldNames; "POSITION")
			APPEND TO ARRAY:C911($atReservedFieldNames; "SMALLINT")
			APPEND TO ARRAY:C911($atReservedFieldNames; "SUM")
			APPEND TO ARRAY:C911($atReservedFieldNames; "SYSDATE")
			APPEND TO ARRAY:C911($atReservedFieldNames; "TIME")
			APPEND TO ARRAY:C911($atReservedFieldNames; "TIMESTAMP")
			APPEND TO ARRAY:C911($atReservedFieldNames; "UUID")
			APPEND TO ARRAY:C911($atReservedFieldNames; "VARCHAR")
			APPEND TO ARRAY:C911($atReservedFieldNames; "YEAR")
			
			ARRAY TEXT:C222($atReservedFieldNamesAlias; 0)
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "AMOUNT")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "AND_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "ANY_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "ASC_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "AT_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "AVG_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "BEGIN_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "BIT_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "BLOB_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "BY_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "CASCADE_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "CASE_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "CHAR_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "CURRENT_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "DATE_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "DEC_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "DESC_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "DESCRIPTOR_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "DURATION_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "EXCEPTION_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "EXISTS_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "FLOAT_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "GROUP_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "INT_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "INTEGER_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "KEY_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "LENGTH_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "LOG_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "MAX_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "MIN_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "MODE_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "NATURAL_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "OBJECT_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "ORDER_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "OVERLAPS_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "PICTURE_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "POSITION_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "SMALLINT_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "SUM_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "SYSDATE_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "TIME_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "TIMESTAMP_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "UUID_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "VARCHAR_Fld")
			APPEND TO ARRAY:C911($atReservedFieldNamesAlias; "YEAR_Fld")
			
			$iPosition:=Find in array:C230($atReservedFieldNames; $oParam.oldName)
			If ($iPosition>0)
				$oParam.newName:=$atReservedFieldNamesAlias{$iPosition}
				
			Else 
				$iPosition:=Position:C15($oParam.oldName; " ")
				If ($iPosition>0)
					$oParam.newName:=Replace string:C233($oParam.oldName; " "; "_")
					
				Else 
					// Rename these fields
					ARRAY TEXT:C222($atFields; 0)
					APPEND TO ARRAY:C911($atFields; "METDET_ID")
					APPEND TO ARRAY:C911($atFields; "METSUM_ID")
					APPEND TO ARRAY:C911($atFields; "METDETDAY_ID")
					APPEND TO ARRAY:C911($atFields; "METSUMDAY_ID")
					APPEND TO ARRAY:C911($atFields; "MET_Type")
					APPEND TO ARRAY:C911($atFields; "INVT_ID")
					APPEND TO ARRAY:C911($atFields; "ITEM_Number")
					APPEND TO ARRAY:C911($atFields; "Metrics_Detail_Daily")
					APPEND TO ARRAY:C911($atFields; "Parent_ID")
					APPEND TO ARRAY:C911($atFields; "Invt_Qty_OHB")
					APPEND TO ARRAY:C911($atFields; "Invt_Qty_OH")
					APPEND TO ARRAY:C911($atFields; "Invt_Qty_GAS")
					APPEND TO ARRAY:C911($atFields; "Invt_Qty_OnOrder")
					APPEND TO ARRAY:C911($atFields; "Invt_Qty_Net")
					APPEND TO ARRAY:C911($atFields; "QA_QM_Classification")
					APPEND TO ARRAY:C911($atFields; "Date Received")
					
					ARRAY TEXT:C222($atFieldsAlias; 0)
					APPEND TO ARRAY:C911($atFieldsAlias; "STATDET_ID")
					APPEND TO ARRAY:C911($atFieldsAlias; "STATSUM_ID")
					APPEND TO ARRAY:C911($atFieldsAlias; "STATDETDAY_ID")
					APPEND TO ARRAY:C911($atFieldsAlias; "STATSUMDAY_ID")
					APPEND TO ARRAY:C911($atFieldsAlias; "Type")
					APPEND TO ARRAY:C911($atFieldsAlias; "Product_ID")
					APPEND TO ARRAY:C911($atFieldsAlias; "Product_Number")
					APPEND TO ARRAY:C911($atFieldsAlias; "Statistics_Detail_Daily")
					APPEND TO ARRAY:C911($atFieldsAlias; "Origin_ID")
					APPEND TO ARRAY:C911($atFieldsAlias; "Product_Qty_OHB")
					APPEND TO ARRAY:C911($atFieldsAlias; "Product_Qty_OH")
					APPEND TO ARRAY:C911($atFieldsAlias; "Product_Qty_GAS")
					APPEND TO ARRAY:C911($atFieldsAlias; "Product_Qty_OnOrder")
					APPEND TO ARRAY:C911($atFieldsAlias; "Product_Qty_Net")
					APPEND TO ARRAY:C911($atFieldsAlias; "QA_InHouse_Classification")
					APPEND TO ARRAY:C911($atFieldsAlias; "Date_Received")
					
					$iPosition:=Find in array:C230($atFields; $oParam.oldName)
					If ($iPosition>0)
						$oParam.newName:=$atFieldsAlias{$iPosition}
					Else 
						$oParam.newName:=$oParam.oldName
					End if 
				End if 
			End if 
			
			
		: ($oParam.tSubroutine="ProcessThisField")  // skip these fields
			// Fields NOT to process
			ARRAY TEXT:C222($atFieldsNotToProcess; 0)
			APPEND TO ARRAY:C911($atFieldsNotToProcess; "Combo_ID")
			APPEND TO ARRAY:C911($atFieldsNotToProcess; "Dealer")
			APPEND TO ARRAY:C911($atFieldsNotToProcess; "Company_ID")
			APPEND TO ARRAY:C911($atFieldsNotToProcess; "IS_AAP")
			APPEND TO ARRAY:C911($atFieldsNotToProcess; "IS_JAX")
			APPEND TO ARRAY:C911($atFieldsNotToProcess; "Invt_ID_AsString")
			APPEND TO ARRAY:C911($atFieldsNotToProcess; "Ordered_Dealer")
			APPEND TO ARRAY:C911($atFieldsNotToProcess; "Unused_Field25")
			APPEND TO ARRAY:C911($atFieldsNotToProcess; "Unused_Field27")
			APPEND TO ARRAY:C911($atFieldsNotToProcess; "Unused_Field30")
			APPEND TO ARRAY:C911($atFieldsNotToProcess; "Unused_Field31")
			APPEND TO ARRAY:C911($atFieldsNotToProcess; "Unused_Field32")
			APPEND TO ARRAY:C911($atFieldsNotToProcess; "Unused_Field36")
			
			If (Find in array:C230($atFieldsNotToProcess; $oParam.fieldName)>0)
				$oParam.processField:=False:C215
			End if 
			
	End case 
End if 