#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#Define CRLF CHR(13)+CHR(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³COMXH2L   ºAutor  ³Ricardo P Sotomayor º Data ³  01/20/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcoes de apoio e validação modulo de compras.            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ H2L                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function COMXH2L(_Ret,_cTipo) //U_COMXH2L("1")
Default _Ret
Default _cTipo := ""

If _cTipo == '1' //Bloqueia troca de Unidade de Requisição
	Return BUNIREQ()
ElseIf _cTipo == '2' //Consulta historico de movimentação de Solicitação de Compras
	Return HISTSC1(_Ret)
EndIf

Return

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ0¿
//³Retorna Array com Itens do Historico³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ0Ù
*/

Static Function HISTSC1(_aStr,_cTipo)
Local aTrab := {}
Local aTrab1:= {}
Local _cEOL := 'Ð'//Quebra de Linha Memo
Local cStr	:= ""
//Legenda,Situação,Responsavel,Data,Motivo,Status
If ValType(_aStr) == "C" //Type("_cAnexo") = "C"
	aTrab:=	Str2Array(_aStr,_cEOL)
	For x := 1 To Len(aTrab)
		AaDd(aTrab1,Str2Array(aTrab[x],"|"))
	Next
ElseIf ValType(_aStr) == "A" //Type("_cAnexo") = "C"
	aTrab:= _aStr
EndIF

If _cTipo == '1'
	Return( aTrab1 )
ElseIf _cTipo == '2'
	For x:= 1 To Len(aTrab1)
		cStr += aTrab1[x][1]+"|"+aTrab1[x][2]+"|"+aTrab1[x][3]+"|"+aTrab1[x][4]+"|"+aTrab1[x][5]+"|"+aTrab1[x][6]+_cEOL
		//Legenda,
	Next
	Return( cStr )
EndIF
Return

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorno Itens de Historico formatados para gravação³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

User Function MNTHIST(cAtual,cAdd,cLeg)
Local cRet 	:= ""
Local cDatah:=Dtoc(Date())+" "+Time()
Local cEOL  := 'Ð'//Quebra de Linha Memo
Local cStatus := ""
Local aTrab := Str2Array(cAtual,cEOL)
Local cSeq 	:= Soma1(StrZero(Len(aTrab),3))

If cLeg == "B"
	cStatus := "SC Bloqueada"
ElseIf cLeg == "R"
	cStatus := "SC Rejeitada"
ElseIf cLeg == "C"
	cStatus := "SC Cancelada"
ElseIf cLeg == "A"
	cStatus := "SC Aprovada"
ElseIf cLeg == "D"
	cStatus := "SC Devolvida"
ElseIf cLeg == "I"  //Inclução
	cStatus := "SC Incluida"
ElseIf cLeg == "U"  //Alteração
	cStatus := "SC Alterada"
ElseIf cLeg == "P"  //Inclução
	cStatus := "SC C/Pre Produto"
ElseIf cLeg == "E"  //Inclução
	cStatus := "SC Excluida"
EndIF

cRet := cAtual  //+"|"
cRet += cLeg +"|"
cRet += cStatus+"|"
cRet += cUserName+"|"
cRet += cDatah+"|"
cRet += cAdd+"|"
cRet += cSeq+cEOL
//SC1->C1_HISTMOV+"R|Rejeitada|"+cUserName+"|"+Dtoc(Date())+" "+Time()+"|"+cJustifica+cEOL //
Return(cRet)


/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Í,Šä,Šä¿
//³Busca Unidade do Requisitante³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Í,Šä,ŠäÙ
*/

Static Function BUNIREQ()
Local _aArea	:= GetArea()
Local _AreaSY1	:= SY1->(GetArea())
Local _lRet 	:= .T.
Local _aAprov 	:= U_BJCOMP01()//Verifica se o usuario atual é aprovador de sc!
Local _lAprov 	:= _aAprov[1]
Local _cUniRqA	:= _aAprov[2]
Local _cUniRqI	:= &(ReadVar())

If Alltrim(_cUniRqA) <>  Alltrim(_cUniRqI)
	DbSelectArea("SY1")
	DbSetOrder(3)
	DbGoTop()
	If DbSeek(xFilial("SY1")+RetCodUsr())
		_lRet := .T.
	Else
		Aviso("Atenção","Usuário não autorizado a troca de Unidade de Requisição.",{"Fechar"})
		_lRet := .F.
		&(ReadVar()) := _cUniRqA
	EndIF
EndIf
RestArea( _aArea )
RestArea( _AreaSY1	)
Return(_lRet)

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se é aprovador de solicitação de Compras³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
User Function BJCOMP01()
Local lRet := .T.
Local cRet := ""
Local aRet := {lRet,cRet}
Local _aArea	:= GetArea()
Local _aAreaSAI	:= SAI->(GetArea())
Local _aGrupo	:= {}

If GETMV("MV_APROVSC")
	DbSelectArea("SAI")
	If SAI->(FieldPos("AI_APROVSC")) > 0
		DbSelectArea("SAI")
		DbSetOrder(2)
		DbGoTop()
		If DbSeek(xFilial("SAI")+RetCodUsr())
			If SAI->AI_APROVSC == "S"
				lRet := .T.
			Else
				lRet := .F.
			EndIf
			If SAI->(FieldPos("AI_UNIDREQ")) > 0
				cRet := SAI->AI_UNIDREQ
			EndIf
		Else
			lRet := .F.
		EndIf
		If !lRet
			_aGrupo := FWSFUsrGrps(RetCodUsr())//UsrRetGrp ( cUserName , RetCodUsr() )
			If Len(_aGrupo) > 0
				For x:= 1 To Len(_aGrupo)
					DbSelectArea("SAI")
					DbSetOrder(1)
					If DbGoTop(xFilial("SAI")+_aGrupo[x])
						lRet := .T.
						If SAI->(FieldPos("AI_UNIDREQ")) > 0
							If Empty(cRet)
								cRet := SAI->AI_UNIDREQ
							Else
								Exit
							EndIf
						EndIf
					EndIf
				Next
			EndIf
		EndIf
	EndIf
	aRet := {lRet,cRet}
EndIf
RestArea( _aArea )
RestArea( _aAreaSAI	)
Return(aRet)

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se usuario atual é Comprador  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/User Function BJCOMP02()//
//Static Function Comprador()
Local _aArea	:= GetArea()
Local _aAreaSY1	:= SY1->(GetArea())
Local _lRet := .F.
DbSelectArea("SY1")
DbSetOrder(3)
DbGoTop()
If DbSeek(xFilial("SY1")+RetCodUsr())
	_lRet := .T.
EndIF
RestArea( _aArea )
RestArea( _aAreaSY1	)
Return(_lRet)

User Function CONSC1(cCampo)
Local oNumSc,oSolic,oData,oSitua
Local oDlgHist,oSButton1
Local oBitmap1,oBitmap2,oBitmap3,oBitmap4
Local cNumSc := ""
Local cSolic := ""
Local dData  := CtoD("")
Local cSitua := Iif(SC1->C1_APROV=='B',"Bloqueada",Iif(SC1->C1_APROV=='R',"Rejeitada",Iif(SC1->C1_APROV=='L',"Liberada","")))
Local cAlias	:= Iif(SUBSTR(cCampo,1,1)<>"S","S"+SUBSTR(cCampo,1,2),SUBSTR(cCampo,1,3))
Local _aCpoMem 	:= HS_CfgSx3(cCampo)
Local _cMemo	:= StrTran(&(cAlias+"->"+cCampo),CHR(13)+CHR(10),CHR(13)+CHR(10) )
Private oLaran := LoadBitmap( GetResources(), "BR_LARANJA")
Private oVerde := LoadBitmap( GetResources(), "BR_VERDE")
Private oCinza := LoadBitmap( GetResources(), "BR_CINZA")
Private oVerm  := LoadBitmap( GetResources(), "BR_VERMELHO")
Private oAzul  := LoadBitMap( GetResources(), "BR_AZUL")
Private aList  := {}
Private _nopc  := 0
Private oList
Private nTime  := 5000
Private cHist  := ""
Private _nCol  := 2
Private _nOrd  := 1
Private aLstG  := {}
DEFINE MSDIALOG oDlgHist TITLE "Histórico" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME//STYLE( WS_VISIBLE, WS_POPUP )

@ 006, 004 SAY oSay1 PROMPT "Solicitação:" SIZE 031, 007 OF oDlgHist COLORS 0, 16777215 PIXEL
@ 005, 037 MSGET oNumSc VAR SC1->C1_NUM SIZE 038, 010 OF oDlgHist COLORS 0, 16777215 WHEN .F. PIXEL

@ 006, 077 SAY oSay2 PROMPT "Solicitante:" SIZE 030, 007 OF oDlgHist COLORS 0, 16777215 PIXEL
@ 005, 109 MSGET oSolic VAR UsrFullName(SC1->C1_USER) SIZE 069, 010 OF oDlgHist COLORS 0, 16777215 WHEN .F. PIXEL

@ 006, 180 SAY oSay3 PROMPT "Data:" SIZE 014, 007 OF oDlgHist COLORS 0, 16777215 PIXEL
@ 005, 196 MSGET oData VAR SC1->C1_EMISSAO SIZE 049, 010 OF oDlgHist COLORS 0, 16777215 WHEN .F. PIXEL

@ 020, 004 SAY oSay4 PROMPT "Situação:" SIZE 025, 007 OF oDlgHist COLORS 0, 16777215 PIXEL
@ 018, 037 MSGET oSitua VAR cSitua SIZE 073, 010 OF oDlgHist COLORS 0, 16777215 WHEN .F. PIXEL

//cList := "01|02|03|04|05"+"CHR(13)+CHR(10)"
aList := HISTSC1(_cMemo,"1")

//Status,Situação,Responsavel,Data,Justificativa,Sequencia,Legenda
If Len(aList) == 0
	aList := {}
	AaDd(aList,{"C","Sem Movimento","","","","001","C"})
ElseIf Len(aList) >= 1
	If Len(aList[1]) < 6
		aList := {}
		AaDd(aList,{"C","Sem Movimento","","","","001","C"})
	EndIf
EndIF

AEval( aList, {|x| AaDd(x,x[1])})
AEval( aList, {|x| x[7] := Iif(x[1] == "A",oVerde,Iif(x[1] == "R",oLaran,Iif(x[1] $ "BUIP",oCinza,Iif(x[1] == "C",oVerm ,Iif(x[1] == "D",oAzul ,x[7])))))})
aLstG:= AClone(aList)

oList := TcBrowse():New( 032, 005, 239, 103,,,,oDlgHist,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)
oList:AddColumn(TCColumn():New(" "			,{|| aList[oList:nAt,07] },"",,,"LEFT" ,010,.T.,.F.,,,,,))
oList:AddColumn(TCColumn():New("Seq"		,{|| aList[oList:nAt,06] },"",,,"LEFT" ,015,.F.,.F.,,,,,))
oList:AddColumn(TCColumn():New("Situação"	,{|| aList[oList:nAt,02] },"",,,"LEFT" ,080,.F.,.F.,,,,,))
oList:AddColumn(TCColumn():New("Responsável",{|| aList[oList:nAt,03] },"",,,"LEFT" ,080,.F.,.F.,,,,,))
oList:AddColumn(TCColumn():New("Data"		,{|| aList[oList:nAt,04] },"",,,"LEFT" ,020,.F.,.F.,,,,,))
oList:SetArray(aList)
//oList:nFreeze:= 1
// Evento de clique no cabeçalho da browse
oList:bHeaderClick := {|o,_nCol| _nOrd := ListOrdem(_nOrd,_nCol,aList,oList) }// Alert(_nCol)
// Evento de duplo click na celula
oList:bLDblClick := {|| SC1HIST(aList[oList:nAt],)} //Aviso("",cQuery,,,,,,.T.,5000)
oList:nScrollType := 1
//Legenda,Situação,Responsavel,Data,Historico
oBtn1 := TBtnBmp2():New(270, 015,80,26,"BR_VERDE"	,,,,{|| FilList("A",aList,aLstG,oList)},oDlgHist,,,.T. )
oBtn1:cCaption := "Aprovação"

oBtn2 := TBtnBmp2():New(270, 095,80,26,"BR_LARANJA"	,,,,{|| FilList("R",aList,aLstG,oList)},oDlgHist,,,.T. )
oBtn2:cCaption := "Rejeição"

oBtn3 := TBtnBmp2():New(270, 175,80,26,"BR_CINZA"	,,,,{|| FilList("BUI",aList,aLstG,oList)},oDlgHist,,,.T. )
oBtn3:cCaption := "Bloqueado"

oBtn4 := TBtnBmp2():New(270, 255,80,26,"BR_AZUL"	,,,,{|| FilList("D",aList,aLstG,oList)},oDlgHist,,,.T. )
oBtn4:cCaption := "Devolvido"

oBtn4 := TBtnBmp2():New(270, 335,80,26,"BR_BRANCO"	,,,,{|| FilList("",aList,aLstG,oList)},oDlgHist,,,.T. )
oBtn4:cCaption := "Todos"

DEFINE SBUTTON oSButton1 FROM 138, 218 TYPE 01 OF oDlgHist Action(oDlgHist:end()) ENABLE
//oTimer:= TTimer():New(nTime,{|| oDlgHist:End() },oDlgHist)
//oTimer:Activate()
ACTIVATE MSDIALOG oDlgHist CENTERED

Return

Static Function FilList(cTipo,aList,aLstG,oList)
If !Empty(cTipo)
	aList := {}
	
	For x:= 1 To Len(aLstG)
		If aLstG[x][1] $ cTipo
			AaDd(aList,aLstG[x])
		EndIF
	Next
	
	If Len(aList) == 0
		AaDd(aList,{"C","Sem Movimento(Filtro)","","","","001","C"})
	EndIf
	
Else
	aList := AClone(aLstG)
EndIf
AEval( aList, { | x | x[7] := Iif(x[1] == "A",oVerde,Iif(x[1] == "R",oLaran,Iif(x[1] $ "BUIP",oCinza,Iif(x[1] == "C",oVerm ,Iif(x[1] == "D",oAzul ,x[1])))))})
oList:SetArray(aList)
oList:Refresh()
Return

Static Function ListOrdem(_nOrd,_nCol,aList,oList)
Local _nColOrd := 0
If _nCol > 1
	If _nCol == 2
		_nColOrd := 06
	ElseIf _nCol == 3
		_nColOrd := 02
	ElseIf _nCol == 4
		_nColOrd := 03
	ElseIf _nCol == 5
		_nColOrd := 04
	EndIf
	If _nOrd == 1
		_nOrd := 2
		ASORT(aList, , , { | x,y | x[_nColOrd]<y[_nColOrd] } )
	Else
		_nOrd := 1
		ASORT(aList, , , { | x,y | x[_nColOrd]>y[_nColOrd] } )
	EndIf
	oList:SetArray(aList)
	oList:Refresh()
EndIf
Return(_nOrd)

Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para tema "Flat"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If "MP8" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return Int(nTam)

Static Function Str2Array(cString, cDelim)
Local aPieces := {}
Local nProc


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona um delimitador ao final da string - pos while       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cString += if( len(cString)==0, "", cDelim )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ - Procura a posicao do delimitador                           ³
//³ - Adiciona a matriz o elemento delimitado                    ³
//³ - Elimina da string o elemento acima                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
do while ! empty( cString )
	
	If ! ( nProc := at( cDelim, cString ) ) == 0
		If !Empty(substr( cString, 1, nProc - 1 ))
			aadd( aPieces, substr( cString, 1, nProc - 1 ) )
		EndIf
		cString := substr( cString, nProc + len( cDelim ) )
	EndIf
	
enddo

Return aPieces

Static Function SC1HIST(aCpo)////Status,Situação,Responsavel,Data,Justificativa,Sequencia,Legenda
Local oDlgJust,oConfir
Local nOpc	:= 0
Local cSitua := Iif(SC1->C1_APROV=='B',"Bloqueada",Iif(SC1->C1_APROV=='R',"Rejeitada",Iif(SC1->C1_APROV=='L',"Liberada","")))
Local dData  := Ctod(Substr(aCpo[4],1,at( " ",aCpo[4])-1)) //at( cDelim, cString ) )
//Local cJust := ""

DEFINE MSDIALOG oDlgJust TITLE "Histórico" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME

@ 006, 004 SAY oSay1 PROMPT "Solicitação:" SIZE 031, 007 OF oDlgJust COLORS 0, 16777215 PIXEL
cSolic := SC1->C1_NUM+" - "+aCpo[6]
@ 005, 037 MSGET oNumSc VAR cSolic SIZE 038, 010 OF oDlgJust COLORS 0, 16777215 WHEN .F. PIXEL

@ 006, 077 SAY oSay2 PROMPT "Solicitante:" SIZE 030, 007 OF oDlgJust COLORS 0, 16777215 PIXEL
@ 005, 109 MSGET oSolic VAR UsrFullName(SC1->C1_USER) SIZE 069, 010 OF oDlgJust COLORS 0, 16777215 WHEN .F. PIXEL

@ 006, 180 SAY oSay3 PROMPT "Data:" SIZE 014, 007 OF oDlgJust COLORS 0, 16777215 PIXEL
@ 005, 196 MSGET oData VAR dData SIZE 049, 010 OF oDlgJust COLORS 0, 16777215 WHEN .F. PIXEL

@ 020, 004 SAY oSay4 PROMPT "Situação:" SIZE 025, 007 OF oDlgJust COLORS 0, 16777215 PIXEL
@ 018, 037 MSGET oSitua VAR aCpo[2] SIZE 038, 010 OF oDlgJust COLORS 0, 16777215 WHEN .F. PIXEL

@ 020, 077 SAY oSay2 PROMPT "Reponsável:" SIZE 030, 007 OF oDlgJust COLORS 0, 16777215 PIXEL
@ 018, 109 MSGET oResp VAR aCpo[3] SIZE 069, 010 OF oDlgJust COLORS 0, 16777215 WHEN .F. PIXEL

@ 032, 005 GET oMultiGe VAR aCpo[5] OF oDlgJust MULTILINE SIZE 239, 103 COLORS 0, 16777215 READONLY HSCROLL  PIXEL

@ 135, 210 BUTTON oButton1 PROMPT "Fechar" SIZE 037, 012 OF oDlgJust Action(nOpc := 1,oDlgJust:end()) PIXEL

oTimer:= TTimer():New(5000,{|| oDlgJust:End() },oDlgJust)
oTimer:Activate()
ACTIVATE MSDIALOG oDlgJust CENTERED

Return()

User Function SC1NOTF(cTipo,cMensagem,cDest,cModelo)
Local cArqui   := Dtos(date())+StrTran(Time(),":","")
Local cEmailTo := ""//UsrRetMail(SC1->C1_USER)+Iif(!Empty(cDest),";"+cDest,"")
Local cEmailCc := "ricardops34@hotmail.com;ricardo@bjsft.com.br;ricardopataysotomayor@gmail.com"
Local cEmailBcc:= "" //"luvian@h2l.com.br;marcelovinholi@h2l.com.br" 
Local cTitulo  := " - "+SC1->C1_NUM
Local _cBody   := ""
Local cAnexo   := ""
Local _cBody   := ""
Local cFrom	   := UsrRetMail(RetCodUsr())

Default cTipo 	:= ""
Default cMensagem:= ""
Default cDest 	:= ""                       
Default cModelo := "modelo.html"

cEmailTo := UsrRetMail(SC1->C1_USER)+Iif(Empty(cDest),"",";"+cDest) //cDest

If cValToChar(cTipo) == "1"  // 1 - Aprovado ; 2 - Rejeitado ; 3 - Bloqueado
	cTitulo  := "Solicitação Aprovada"+cTitulo
ElseIf cValToChar(cTipo) == "2"
	cTitulo  := "Solicitação Bloqueada"+cTitulo
ElseIf cValToChar(cTipo) == "3"
	cTitulo  := "Solicitação Devolvida"+cTitulo
EndIF
If Empty(cFrom)
	cFrom  := AllTrim(GetMV("MV_RELAUSR"))
EndIf

_cBody   := MntBody(cTitulo,cMensagem,cModelo)

If !Empty(_cBody)
	IF ExistBlock("EnvEmail")
		If Empty(cEmailTo)// .Or. !("@"&cEmailTo)
			cEmailTo:= cFrom
		EndIf
		EnvioOk := U_EnvEmail(cFrom,cEmailTo,cEmailCc,cEmailBcc,cTitulo,_cBody,cAnexo,"mata110",.T.,.F.)
	Else
		MAKEDIR(GetSrvProfString("Startpath","")+"\compras\")
		MAKEDIR(GetSrvProfString("Startpath","")+"\compras\mata110\")
		MAKEDIR(GetSrvProfString("Startpath","")+"\compras\mata110\email\")
		MemoWrite(GetSrvProfString("Startpath","")+"\compras\mata110\email\"+SC1->C1_NUM+cArqui+".htm",_cBody)//LST1->DOC
	EndIF
EndIf

Return

Static Function MntBody(cTit,cAviso,cModelo)
Local cMsg := ""
Local cModelo := cMsg := MemoRead(  GetSrvProfString("Startpath","") + '\modelo\'+cModelo)
Local cTabela := MontaItens()
Default cTit := ""
Default cAviso := ""

cMsg := cModelo
If !Empty(cTit)
	cMsg := str_replace("<%TITULO%>",cTit,cMsg)
EndIf

If !Empty(cTabela)
	cMsg := str_replace("<%TABELA%>",cTabela,cMsg)
EndIf
If !Empty(cAviso)
	cMsg := str_replace("<%MENSAGEM%>",cAviso,cMsg)
EndIf

Return(cMsg)

Static Function MontaItens()
Local cRet	 := ""
Local cSolic := SC1->C1_NUM
Local aArea  := GetArea()
Local aArSc1 := SC1->(GetArea())
Local nIten  := 0  
Local cDesc	 := ""  
Local cStyle := ""
Local cStyle1:= " class='tr1' " //"style='background-color: #ffffff;'"
Local cStyle2:= " class='tr2' " //"style='background-color: #eeeeee;'"
Local nTipo  := 1
DbSelectArea("SC1")
DbSetOrder(1)
DbGoTop()
If DbSeek(xFilial("SC1")+cSolic)
	While !Eof() .And. cSolic == SC1->C1_NUM
		If nTipo == 1
			nTipo := 2
			cStyle:= cStyle1
		Else
			cStyle:= cStyle2
			nTipo := 1
		EndIF
		cDesc := Alltrim(SC1->C1_OBS)
		If Empty(cDesc)  
			cDesc:=  SC1->(Alltrim(C1_PRODUTO)+" - "+Alltrim(C1_DESCRI))
		EndIf	
		nIten +=1
		cRet +="<tr "+cStyle+" >"+CRLF
		cRet +="	<td align='left' >"+StrZero(nIten,2)+"</td>"+CRLF
		cRet +="	<td align='left' >"+cDesc+"</td>"+CRLF
		cRet +="	<td align='right' >"+Transform(SC1->C1_QUANT,PesqPict("SC1","C1_QUANT")) +"</td>"+CRLF
		cRet +="</tr>"+CRLF
		SC1->(DbSkip())
	End
EndIf
RestArea(aArSc1)
RestArea(aArea)
Return(cRet)


Static Function str_replace(_cSearch,_cReplace,_cSubject)
Local cRet := ""
Default _cSearch := ""
Default _cReplace:= ""
Default _cSubject:= ""
If !Empty(_cSubject).and.!Empty(_cSearch).and.!Empty(_cSubject)
	cRet :=	StrTran( _cSubject, _cSearch, _cReplace)//StrTran( < cString >, < cSearch >, [ cReplace ], [ nStart ], [ nCount ] )
Else
	cRet := _cSubject
EndIf
Return(cRet)