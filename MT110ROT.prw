#INCLUDE "TOTVS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT110ROT  �Autor  �Ricardo P. Sotomayor� Data �  11/01/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Filtrar Botoes da rotina, baseado no perfil do solicitante���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT110ROT()
Local _aRet		:= Paramixb
Local _aRotNew  := {}
Local _aAprov := U_BJCOMP01()//Verifica se o usuario atual � aprovador de sc!
Local _lAprov := _aAprov[1]
Local _lCompr := U_BJCOMP02()//Verifica se o usuario atual � Comprador

If !ExisteSX6("MV_FLMT110")
	CriarSX6("MV_FLMT110","C","Filtra Solicita�oes de Compra","N")
EndIf
If !ExisteSX6("MV_USAM110")
	CriarSX6("MV_USAM110","C","Usa Novo Nova Alcada de SC","N")
EndIf
If !ExisteSX6("MV_M110PRE")
	CriarSX6("MV_M110PRE","C","Codigo do Produto - usado como pre-produto","999999")
EndIf
If GETMV("MV_APROVSC") .And. GetMV("MV_USAM110")== "S"
	AtuSXB()
	For x:= 1 To Len(_aRet)
		If Alltrim("A110Aprov") == _aRet[x][2]
			If _lAprov
				AAdd( _aRotNew, { _aRet[x][1], _aRet[x][2], _aRet[x][3], _aRet[x][4], _aRet[x][5], _aRet[x][6] } )
			EndIF
		Else
			If Alltrim("A110Cancela") == _aRet[x][2]
				If RetCodUsr() == "000000" .Or. _lAprov .Or. _lCompr /*PswAdmin(,,RetCodUsr()) == 0*/
					AAdd( _aRotNew, { _aRet[x][1], _aRet[x][2], _aRet[x][3], _aRet[x][4], _aRet[x][5], _aRet[x][6] } )
				EndIf
			Else
				AAdd( _aRotNew, { _aRet[x][1], _aRet[x][2], _aRet[x][3], _aRet[x][4], _aRet[x][5], _aRet[x][6] } )
			EndIF
		EndIf
	Next

	If SC1->(FieldPos("C1_HISTMOV")) > 0	
		AAdd( _aRotNew,{ "Hist�rico"	,"U_CONSC1('C1_HISTMOV')" 		   , 0 , 2, 0, nil } )
	EndIf	
Else                                                                                          
	_aRotNew := aClone(_aRet)
EndIf
Return(_aRotNew)  

Static Function AtuSXB()
//  XB_ALIAS XB_TIPO XB_SEQ XB_COLUNA XB_DESCRI XB_DESCSPA XB_DESCENG XB_CONTEM XB_WCONTEM   
Local aSXB   := {}
Local aAjSXB := {}    
Local aEstrut:= {}
Local i      := 0
Local j      := 0
Local cTexto := ''
Local cAlias := ''
Local lSXB   := .F.
Local aArea	 := GetArea()
Local aAreaSX3 := SX3->(GetArea())

If (cPaisLoc == "BRA")
	aEstrut:= {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM","XB_WCONTEM"}
Else
	aEstrut:= {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM"}
EndIf
 
AaDd(aSXB,{"SB1F3 ","1","01","RE"	,"Produto SC1"	,"Produto SC1"	,"Produto SC1"	,"SB1"			,""})
AaDd(aSXB,{"SB1F3 ","2","01","01"	,""				,""				,""				,"U_SB1F3()"	,""})
AaDd(aSXB,{"SB1F3 ","5","01",""		,""				,""				,""				,"U_SB1F3RET()"	,""})

dbSelectArea("SXB")
dbSetOrder(1)
For i:= 1 To Len(aSXB)
	If !Empty(aSXB[i][1])
		If !MsSeek(Padr(aSXB[i,1], Len(SXB->XB_ALIAS))+aSXB[i,2]+aSXB[i,3]+aSXB[i,4])
			lSXB := .T.
			If !(aSXB[i,1]$cAlias)
				cAlias += aSXB[i,1]+"/"
			EndIf
			
			RecLock("SXB",.T.)
			
			For j:=1 To Len(aSXB[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSXB[i,j])
				EndIf
			Next j
			
			dbCommit()
			MsUnLock()
		EndIf
	EndIf
Next i

DbSelectArea( "SX3" )
DbSetOrder( 2 ) 
If DbSeek( "C1_PRODUTO" ) 
	If Alltrim(SX3->X3_F3) <> "SB1F3" 
		RecLock( "SX3", .F. )
		SX3->X3_F3 := "SB1F3" 
		MsUnLock()
	EndIf	
EndIf

RestArea(aArea)
RestArea(aAreaSX3)
Return