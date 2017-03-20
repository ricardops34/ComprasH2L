#INCLUDE "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FILXBSB1  ºAutor  ³Ricardo P Sotomayor º Data ³  12/27/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Filtar SXB para listar somente produtos autorizados ao     º±±
±±º          ³ Solicitante                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Não trata Grupo de usuarios                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FilXBSB1(nTipo) //@#U_FilXBSB1(1)
Local cFil := "" //"@#"
Local _aAprov := U_BJCOMP01()//Verifica se o usuario atual é aprovador de sc
Local _lAprov := _aAprov[1]
Local _cUnida := _aAprov[2]
Local _lCompr := U_BJCOMP02()//Verifica se o usuario atual é comprador
Local aArea	  := GetArea()
Local aAreaSAI:= SAI->(GetArea())
Local aAreaSB1:= SB1->(GetArea())
Local _aGrupo := FWSFUsrGrps(RetCodUsr())//UsrRetGrp ( cUserName , RetCodUsr() )
Local cFilIncC:= ""
Local cFilIncG:= ""
Local cFilExcC:= ""
Local cFilExcG:= ""
Local cSinal  := ""
Default nTipo = 0
//AI_GRUPO//AI_PRODUTO
//AI_DOMINIO//AI_GRUPCOM

If !ExisteSX6("MV_USAM110")
	CriarSX6("MV_USAM110","C","Usa Novo Nova Alcada de SC","N")
EndIf
If GETMV("MV_USAM110") == "S"
	If nTipo == 1//SAI 
		cFil += "@#"
		If SB1->(FieldPos("B1_MSBLQL")) > 0
			cFil += " ( B1_MSBLQL <> '1') "
		EndIf
		DbSelectArea("SAI")
		DbSetOrder(2)
		DbGotop()
		If DbSeek(xFilial("SAI")+RetCodUsr())//Usuario
			While !Eof() .And. xFilial("SAI")+RetCodUsr() == SAI->(AI_FILIAL+AI_USER)
				If SAI->AI_DOMINIO = 'I'
					IF ALLTRIM(SAI->AI_GRUPO) <> '*'
						If !Empty(cFilIncG)
							cFilIncG += " .Or. "
						EndIf
						cFilIncG += "B1_GRUPO = '"+ALLTRIM(SAI->AI_GRUPO)+"' "
					ElseIf ALLTRIM(SAI->AI_PRODUTO) <> '*'
						If !Empty(cFilIncC)
							cFilIncC += " .Or. "
						EndIf
						cFilIncC += "B1_COD = '"+ALLTRIM(SAI->AI_PRODUTO)+"'"
					EndIf
				Elseif SAI->AI_DOMINIO = 'E'
					IF ALLTRIM(SAI->AI_GRUPO) <> '*'
						If !Empty(cFilExcG)
							cFilExcG += " .AND. "
						EndIf
						cFilExcG += "B1_GRUPO <> '"+ALLTRIM(SAI->AI_GRUPO)+"'"
					ElseIf ALLTRIM(SAI->AI_PRODUTO) <> '*'
						If !Empty(cFilExcC)
							cFilExcC += " .AND. "
						EndIf
						cFilExcC += "B1_COD <> '"+ALLTRIM(SAI->AI_PRODUTO)+"'"
					EndIf
				EndIf
				SAI->(DbSkip())
			End
		EndIf
		
		If !EmpTy(cFilIncC) .OR. !EmpTy(cFilIncG)
			cFil += " .And. ( ( "
			If !EmpTy(cFilIncC)
				cFil += cFilIncC + " ) "
			EndIf
			If !EmpTy(cFilIncG)
				If !EmpTy(cFilIncC)
					cFil += " .OR. ( "
				EndIF
				cFil += cFilIncG + " ) "
			EndIf
			cFil += ") "
		EndIf
		
		If !EmpTy(cFilExcC) .OR. !EmpTy(cFilExcG)
			If !EmpTy(cFilExcC)
				cFil += " .And. ( ( "
				cFil += cFilExcC + " ) "
			EndIF
			If !EmpTy(cFilExcG)
				If !EmpTy(cFilExcC)
					cFil += " .And. ( "
				EndIF
				cFil += cFilExcG + " ) "
			EndIF
			cFil += ") "
		EndIf           
		cFil += "@#"
	ElseIf nTipo == 2 //SQL
		DbSelectArea("SAI")
		DbSetOrder(2)
		DbGotop()
		If DbSeek(xFilial("SAI")+RetCodUsr())//Usuario
			While !Eof() .And. xFilial("SAI")+RetCodUsr() == SAI->(AI_FILIAL+AI_USER)
				If SAI->AI_DOMINIO = 'I'
					IF ALLTRIM(SAI->AI_GRUPO) <> '*'
						If !Empty(cFilIncG)
							cFilIncG += " Or "
						EndIf
						cFilIncG += "B1_GRUPO = '"+ALLTRIM(SAI->AI_GRUPO)+"' "
					ElseIf ALLTRIM(SAI->AI_PRODUTO) <> '*'
						If !Empty(cFilIncC)
							cFilIncC += " Or "
						EndIf
						cFilIncC += "B1_COD = '"+ALLTRIM(SAI->AI_PRODUTO)+"'"
					EndIf
				Elseif SAI->AI_DOMINIO = 'E'
					IF ALLTRIM(SAI->AI_GRUPO) <> '*'
						If !Empty(cFilExcG)
							cFilExcG += " AND "
						EndIf
						cFilExcG += "B1_GRUPO <> '"+ALLTRIM(SAI->AI_GRUPO)+"'"
					ElseIf ALLTRIM(SAI->AI_PRODUTO) <> '*'
						If !Empty(cFilExcC)
							cFilExcC += " AND "
						EndIf
						cFilExcC += "B1_COD <> '"+ALLTRIM(SAI->AI_PRODUTO)+"'"
					EndIf
				EndIf
				SAI->(DbSkip())
			End
		EndIf
		
		If !EmpTy(cFilIncC) .OR. !EmpTy(cFilIncG)
			cFil += " And ( ( "
			If !EmpTy(cFilIncC)
				cFil += cFilIncC + " ) "
			EndIf
			If !EmpTy(cFilIncG)
				If !EmpTy(cFilIncC)
					cFil += " OR ( "
				EndIF
				cFil += cFilIncG + " ) "
			EndIf
			cFil += ") "
		EndIf
		
		If !EmpTy(cFilExcC) .OR. !EmpTy(cFilExcG)
			If !EmpTy(cFilExcC)
				cFil += " And ( ( "
				cFil += cFilExcC + " ) "
			EndIF
			If !EmpTy(cFilExcG)
				If !EmpTy(cFilExcC)
					cFil += " And ( "
				EndIF
				cFil += cFilExcG + " ) "
			EndIF
			cFil += ") "
		EndIf
	EndIf
EndIf
RestArea(aAreaSB1)
RestArea(aAreaSAI)
RestArea(aArea)
Return(cFil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValXBSB1  ºAutor  ³Ricardo P Sotomayor º Data ³  12/27/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida produto digitado, para verificar se esta atendendo  º±±
±±º          ³ regras de permissão do solicitante                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ValXBSB1(cCod) //U_ValXBSB1(cCod)
Local lRet := .T.
Local aArea	  := GetArea()
Local aAreaSAI:= SAI->(GetArea())
Local aAreaSB1:= SB1->(GetArea())
Local cGrupo  := ""
Local cFilIncC:= ""
Local cFilIncG:= ""
Local cFilExcC:= ""
Local cFilExcG:= ""

Default cCod := &(ReadVar())
cGrupo := Posicione("SB1",1,xFilial("SB1")+cCod,'B1_GRUPO')

If SB1->(FieldPos("B1_MSBLQL")) > 0
	If Posicione("SB1",1,xFilial("SB1")+cCod,'B1_GRUPO') == '1'
		MSGSTOP( "Produto bloqueado. Verifique.", "Atenção - ValXBSB1" )
		lRet := .F.
	EndIf
EndIf

If GETMV("MV_USAM110") == "S"
	If lRet
		DbSelectArea("SAI")
		DbSetOrder(2)
		DbGotop()
		If DbSeek(xFilial("SAI")+RetCodUsr())//Usuario
			While !Eof() .And. xFilial("SAI")+RetCodUsr() == SAI->(AI_FILIAL+AI_USER)
				If SAI->AI_DOMINIO = 'I'
					IF ALLTRIM(SAI->AI_GRUPO) <> '*'
						cFilIncG += SAI->AI_GRUPO+"|"
					EndIf
					IF ALLTRIM(SAI->AI_PRODUTO) <> '*'
						cFilIncC += SAI->AI_PRODUTO+"|"
					EndIf
				ElseIf SAI->AI_DOMINIO = 'E'
					IF ALLTRIM(SAI->AI_GRUPO) <> '*'
						cFilExcG += SAI->AI_GRUPO+"|"
					EndIf
					IF ALLTRIM(SAI->AI_PRODUTO) <> '*'
						cFilExcC += SAI->AI_PRODUTO+"|"
					EndIf
				EndIf
				SAI->(DbSkip())
			End
		EndIf
		
		If cCod $(cFilIncC) .Or. cGrupo $(cFilIncG)
			lRet := .T.
		EndIf
		
		If cCod $(cFilExcC) .Or. cGrupo $(cFilExcG)
			MSGSTOP( "Produto não autorizado. Verifique.", "Atenção - ValXBSB1" )
			lRet := .F.
		EndIf
	EndIf
EndIF
RestArea(aAreaSB1)
RestArea(aAreaSAI)
RestArea(aArea)
Return(lRet)
