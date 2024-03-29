#INCLUDE "TOTVS.CH"

Static CRETB1 := SPACE(15)
//Static _aDadosF3 		:= {}
//Static _aDadosFil 	:= {}

User Function FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna)
/*
+------------------+------------------------------------------------------------+
!Modulo            ! Diversos                                                   !
+------------------+------------------------------------------------------------+
!Nome              ! FiltroF3                                                   !
+------------------+------------------------------------------------------------+
!Descricao         ! Fun��o usada para criar uma Consulta Padr�o  com SQL       !
!			       !                                                            !
!			       !                                                            !
+------------------+------------------------------------------------------------+
!Autor             ! Rodrigo Lacerda P Araujo                                   !
+------------------+------------------------------------------------------------+
!Data de Criacao   ! 03/01/2013                                                 !
+------------------+-----------+------------------------------------------------+
!Campo             ! Tipo	   ! Obrigatorio                                    !
+------------------+-----------+------------------------------------------------+
!cTitulo           ! Caracter  !                                                !
!cQuery            ! Caracter  ! X                                              !
!nTamCpo           ! Numerico  !                                                !
!cAlias            ! Caracter  ! X                                              !
!cCodigo           ! Caracter  !                                                !
!cCpoChave         ! Caracter  ! X                                              !
!cTitCampo         ! Caracter  ! X                                              !
!cMascara          ! Caracter  !                                                !
!cRetCpo           ! Caracter  ! X                                              !
!nColuna           ! Numerico  !                                                !
+------------------+-----------+------------------------------------------------+
!Parametros:                                                                  !
!==========		                                                        !
!          																			   !
!cTitulo = Titulo da janela da consulta                                         !
!cQuery  = A consulta SQL que vem do parametro cQuery n�o pode retornar um outro!
!nome para o campo pesquisado, pois a rotina valida o nome do campo real        !
!          																			   !
!Exemplo Incorreto                                                              !
!cQuery := "SELECT A1_NOME 'NOME', A1_CGC 'CGC' FROM SA1010 WHERE D_E_L_E_T_='' !
!          																			   !
!Exemplo Certo                                                                  !
!cQuery := "SELECT A1_NOME, A1_CGC FROM SA1010 WHERE D_E_L_E_T_=''              !
!          																			   !
!Deve-se manter o nome do campo apenas.                                         !
!          																			   !
!nTamCpo   = Tamanho do campo de pesquisar,se n�o informado assume 30 caracteres!
!cAlias    = Alias da tabela, ex: SA1                                           !
!cCodigo   = Conteudo do campo que chama o filtro                               !
!cCpoChave = Nome do campo que ser� utilizado para pesquisa, ex: A1_CODIGO      !
!cTitCampo = Titulo do label do campo                                           !
!cMascara  = Mascara do campo, ex: "@!"                                         !
!cRetCpo   = Campo que receber� o retorno do filtro                             !
!nColuna   = Coluna que ser� retornada na pesquisa, padr�o coluna 1             !
+--------------------------------------------------------------------------------
*/
Local nLista
Local cCampos 		:= ""
Local bCampo		:= {}
Local nCont			:= 0
Local bTitulos		:= {}
Local cTabela
Local cCSSGet		:= "QLineEdit{ border: 1px solid gray;border-radius: 3px;background-color: #ffffff;selection-background-color: #3366cc;selection-color: #ffffff;padding-left:1px;}"
Local cCSSButton 	:= "QPushButton{background-repeat: none; margin: 2px;background-color: #ffffff;border-style: outset;border-width: 2px;border: 1px solid #C0C0C0;border-radius: 5px;border-color: #C0C0C0;font: bold 12px Arial;padding: 6px;QPushButton:pressed {background-color: #ffffff;border-style: inset;}"
Local cCSSButF3		:= "QPushButton {background-color: #ffffff;margin: 2px;border-style: outset;border-width: 2px;border: 1px solid #C0C0C0;border-radius: 3px; border-color: #C0C0C0;font: Normal 10px Arial;padding: 3px;} QPushButton:pressed {background-color: #e6e6f9;border-style: inset;}"

Local cEstiloPes	:= "QLineEdit{ border: 1px solid gray;border-radius: 5px;background-color: #ffffff;selection-background-color: #ffffff;"
Local cEstiloPes	+= "background-image:url(rpo:localiza.png); "
Local cEstiloPes	+= "background-repeat: no-repeat;"
Local cEstiloPes	+= "background-attachment: fixed;"
Local cEstiloPes	+= "padding-left:25px; "
Local cEstiloPes	+= "}"
Local _nPos			:= 0

Private _oLista	:= nil
Private _oDlg 	:= nil
Private _oCodigo
Private _cCodigo
Private aCampos 	:= {}
//Private _aDadosF3 	:= {}
//Private _aDadosFil 	:= {}
Private _nOrd		:= 1
Private _cFilTmp 	:= ""//BuildExpr(cAlias)
Private _lTop		:= .T.
Private _nCol		:= 1
Private _nColBsc	:= 1
Private _nColuna
//ClassDataArr
Default cTitulo 	:= ""
Default cCodigo 	:= ""
Default nTamCpo 	:= 30
Default nColuna 	:= 1
Default cTitCampo	:= RetTitle(cCpoChave)
Default cMascara	:= PesqPict('"'+cAlias+'"',cCpoChave)

_nColuna	:= nColuna

If Empty(cAlias) .OR. Empty(cCpoChave) .OR. Empty(cRetCpo) .OR. Empty(cQuery)
	MsgStop("Os parametro cQuery, cCpoChave, cRetCpo e cAlias s�o obrigat�rios!","Erro")
	Return
Endif

//_cCodigo := Space(nTamCpo)
//_cCodigo := cCodigo
If Len(_aDadosF3) = 0
cTabela:= CriaTrab(Nil,.F.)

If Select(cTabela) <> 0
	(cTabela)->(dbCloseArea())
EndIf

DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cTabela, .F., .T.)

(cTabela)->(DbGoTop())
If (cTabela)->(Eof())
	MsgStop("N�o h� registros para serem exibidos!","Aten��o")
	Return
Endif

Do While (cTabela)->(!Eof())
	/*Cria o array conforme a quantidade de campos existentes na consulta SQL*/
	cCampos	:= ""
	aCampos 	:= {}
	For nX := 1 TO FCount()
		bCampo := {|nX| Field(nX) }
		//If EVAL(bCampo,nX) <> "B1_RECNO"
			If ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "M" .OR. ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "U"
				if ValType((cTabela)->&(EVAL(bCampo,nX)) )=="C"
					cCampos += "'" + strTRan(AllTrim((cTabela)->&(EVAL(bCampo,nX))),"'"," ")+ "',"
				ElseIf ValType((cTabela)->&(EVAL(bCampo,nX)) )=="D"
					cCampos +=  DTOC((cTabela)->&(EVAL(bCampo,nX))) + ","
				Else
					cCampos +=  (cTabela)->&(EVAL(bCampo,nX)) + ","
				Endif
				aadd(aCampos,{EVAL(bCampo,nX),Alltrim(RetTitle(EVAL(bCampo,nX))),"LEFT",TamSX3(EVAL(bCampo,nX))[1]*2})// 30 TamSX3(EVAL(bCampo,nX))[1]*2
			Endif
		//Else   
		//	cCampos +=  cValToChar((cTabela)->&(EVAL(bCampo,nX))) + ","
		//	aadd(aCampos,{EVAL(bCampo,nX),"Recno","LEFT",15})// 30 TamSX3(EVAL(bCampo,nX))[1]*2
		//EndIf
	Next
	If !Empty(cCampos)
		cCampos 	:= Substr(cCampos,1,len(cCampos)-1)
		aAdd( _aDadosF3,&("{"+cCampos+"}"))
	Endif
	
	(cTabela)->(DbSkip())
Enddo

DbCloseArea(cTabela)
_aDadosFil := AClone(_aDadosF3)
EndIf

If Len(_aDadosF3) == 0
	MsgInfo("N�o h� dados para exibir!","Aviso")
	Return
Endif

nLista := aScan(_aDadosF3, {|x| alltrim(x[1]) == alltrim(_cCodigo)})

iif(nLista = 0,nLista := 1,nLista)

Define MsDialog _oDlg Title "Consulta Padr�o" + IIF(!Empty(cTitulo)," - " + cTitulo,"") From 0,0 To 280, 500 Of oMainWnd Pixel STYLE DS_MODALFRAME
_cTitCod := "Pesquisar por("+Alltrim(cTitCampo)+"):"
_cCodigo := Space(100)//Space(TamSX3(aCampos[_nCol][1])[1]) //Len(_cCodigo)
_oCodigo := TGet():New( 003, 005,{|u| if(PCount()>0,_cCodigo:=u,_cCodigo)},_oDlg,205, 010,cMascara,{|| /*Processa({|| FiltroF3P(M->_cCodigo)},"Aguarde...")*/ },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",_cCodigo,,,,,,, _cTitCod,1 )
//oCodigo:= TGet():New( 003, 005,{|u| if(PCount()>0,_cCodigo:=u,_cCodigo)},_oDlg,205, 010,cMascara,{|| /*Processa({|| FiltroF3P(M->_cCodigo)},"Aguarde...")*/ },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",_cCodigo,,,,,,,cTitCampo + ": ",1 )
_oCodigo:cPlaceHold := "Pesquisar por("+Alltrim(cTitCampo)+"):"
_oCodigo:SetCss(cEstiloPes)//cCSSGet)
oButton1 := TButton():New(010, 212," &Pesquisar ",_oDlg,{|| Processa({|| FiltroF3P(M->_cCodigo) },"Aguarde...") },037,013,,,.F.,.T.,.F.,,.F.,,,.F. )
oButton1:SetCss(cCSSButton)
oButton1:bWhen 	:= { || Len(_aDadosF3) > 0 }
_oLista:= TCBrowse():New(26,05,245,090,,,,_oDlg,,,,,{|| _oLista:Refresh()}	,,,,,,,.F.,/*cTabela*/	,.T.,,.F.,,,.f.)
//		  TCBrowse():New(37,03,330,117,,,,_oDlg,,,,,						,,,,,,,.F.,cAliasSe5	,.T.,,.F.)
nCont := 1
//Para ficar din�mico a cria��o das colunas, eu uso macro substitui��o "&"
For nX := 1 to len(aCampos)
//	If aCampos[nX,1] <> "B1_RECNO"
		cColuna := &('_oLista:AddColumn(TCColumn():New("'+aCampos[nX,2]+'", {|| _aDadosF3[_oLista:nAt,'+StrZero(nCont,2)+']},PesqPict("'+cAlias+'","'+aCampos[nX,1]+'"),,,"'+aCampos[nX,3]+'", '+StrZero(aCampos[nX,4],3)+',.F.,.F.,,{|| .F. },,.F., ) )')
		nCont++
//	EndIf	
Next
_oLista:SetArray(_aDadosF3)
_oLista:bWhen 		 := { || Len(_aDadosF3) > 0 }
_oLista:bLDblClick   := { || FiltroF3R(_oLista:nAt, _aDadosF3, cRetCpo)  }
_oLista:bHeaderClick := {|o, _nColBsc | _nOrd := OrderF3(_nOrd,@_nColBsc,_aDadosF3,_oLista,_oCodigo) }// Alert(_nCol)
_oLista:bSeekChange  := {|| }  //Indica o bloco de c�digo que ser� executado quando mudar de linha.
_oLista:nScrollType  := 1  
_oLista:lAdjustColSize:= .T.
_oLista:Refresh()

If !Empty(CRETB1)
	_nPos := AScan(_aDadosF3,{|x|  Upper(Alltrim(CRETB1)) $ Upper(AllTrim(x[1])) }) 
	If _nPos > 0 
		_oLista:GoPosition(_nPos)
		_oLista:Setfocus()
		_oLista:Refresh()
	EndIf	
EndIf

oButton2 := TButton():New(122, 005," OK "		,_oDlg,{|| Processa({|| FiltroF3R(_oLista:nAt, _aDadosF3, cRetCpo) },"Aguarde...") },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
oButton2:SetCss(cCSSButton)
oButton2:bWhen 		 := { || Len(_aDadosF3) > 0 }
oButton3 := TButton():New(122, 047," Cancelar "	,_oDlg,{|| _oDlg:End() },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
oButton3:SetCss(cCSSButton)
oButton4 := TButton():New(122, 089," Filtrar "	,_oDlg,{|| _cFilTmp := BuildExpr(cAlias,,@_cFilTmp,_lTop),FilTemp(_cFilTmp,cQuery,cTabela) },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
oButton4:SetCss(cCSSButton)

Activate MSDialog _oDlg Centered
Return(bRet)

Static Function FilTemp(_cFilTmp,cQuery,cTabela)
Local _cRet := ""
Local _cNewQuery := Alltrim(Substr(cQuery,1,at("ORDER",cQuery)-1))
Local _cOrder    := Alltrim(Substr(cQuery,at("ORDER",cQuery)-1,len(cQuery)))
_cNewQuery := _cNewQuery+ " AND ( "+_cFilTmp+" ) "+_cOrder
If !Empty(_cFilTmp)
	If Select(cTabela) > 0
		dbSelectArea(cTabela)
		dbCloseArea()
	Endif
	
	//DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cTabela, .F., .T.)
	MsAguarde({|| DbUseArea(.T.,"TOPCONN", TCGENQRY(,,_cNewQuery),cTabela, .F., .T.)},"Selecionando Registros...")
	
	If !Empty(_cFilTmp)
		_aDadosF3 := {}
		
		Do While (cTabela)->(!Eof())
			/*Cria o array conforme a quantidade de campos existentes na consulta SQL*/
			cCampos	:= ""
			aCampos 	:= {}
			For nX := 1 TO FCount()
				bCampo := {|nX| Field(nX) }
				//If EVAL(bCampo,nX) <> "B1_RECNO"
					If ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "M" .OR. ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "U"
						if ValType((cTabela)->&(EVAL(bCampo,nX)) )=="C"
							cCampos += "'" + strTRan(AllTrim((cTabela)->&(EVAL(bCampo,nX))),"'"," ")+ "',"
						ElseIf ValType((cTabela)->&(EVAL(bCampo,nX)) )=="D"
							cCampos +=  DTOC((cTabela)->&(EVAL(bCampo,nX))) + ","
						Else
							cCampos +=  (cTabela)->&(EVAL(bCampo,nX)) + ","
						Endif
						
					Endif
				//Else
				//	cCampos +=  cValToChar((cTabela)->&(EVAL(bCampo,nX))) + ","
				//	aadd(aCampos,{EVAL(bCampo,nX),"Recno","LEFT",15})// 30 TamSX3(EVAL(bCampo,nX))[1]*2
				//EndIf
			Next
			
			If !Empty(cCampos)
				cCampos 	:= Substr(cCampos,1,len(cCampos)-1)
				aAdd( _aDadosF3,&("{"+cCampos+"}"))
			Endif
			
			(cTabela)->(DbSkip())
		Enddo
		
		DbCloseArea(cTabela)
		
		_oLista:SetArray(_aDadosF3)
		_oLista:Refresh()
	EndIf
Else
	_aDadosF3	 := AClone(_aDadosFil)
	_oLista:SetArray(_aDadosF3)
	_oLista:Refresh()
EndIF
Return

Static Function OrderF3(_nOrd,_nCol,_aDadosF3,_oLista,_oCodigo)
Local _nColOrd := 0
If _nCol > 0
	If _nOrd == 1
		_nOrd := 2
		ASORT(_aDadosF3, , , { | x,y | x[_nCol]<y[_nCol] } )
	Else
		_nOrd := 1
		ASORT(_aDadosF3, , , { | x,y | x[_nCol]>y[_nCol] } )
	EndIf
	_oLista:SetArray(_aDadosF3)
	_oLista:Refresh()
	_oCodigo:cCaption 	:= "Pesquisar por("+_oLista:ACOLUMNS[_nCol]:CHEADING+"): " //_oLista:ACOLUMNS[_nCol]:CHEADING
	_oCodigo:cPlaceHold := "Pesquisar por("+_oLista:ACOLUMNS[_nCol]:CHEADING+"): "
	//_cCodigo := Space(TamSX3(aCampos[_nCol][1])[1])
	_oCodigo:Refresh()
	_nColBsc := _nCol
EndIf
Return(_nOrd)

Static Function FiltroF3P(cBusca)
Local x := _oLista:nAt+1 //0 _nOrd
Local nPos := 0//AScan(_aDadosF3,{|x|  Upper(Alltrim(cBusca)) $ Upper(AllTrim(x[_nColuna])) }) //_aDados[1]
Local nLop := 0
If Len(Alltrim(cBusca)) >= 3
	If nPos > 0 .and. _oLista:nAt <> nPos
		_oLista:GoPosition(nPos)
		_oLista:Setfocus()
	Else
		If !Empty(cBusca)
			If x > len(_aDadosF3)
				x:= 1
			EndIf
			For i:= x to len(_aDadosF3)
				//Aqui busco o texto exato, mas pode utilizar a fun��o AT() para pegar parte do texto
				If UPPER(Alltrim(cBusca))  $ UPPER(Alltrim(_aDadosF3[i,_nColBsc]))
					//Se encontrar me posiciono no grid e saio do "For"
					_oLista:GoPosition(i)
					_oLista:Setfocus()
					exit
				ElseIf i == len(_aDadosF3)
					i := 1
					nLop += 1
					If nLop > 1
						_oLista:GoPosition(1)
						_oLista:Setfocus()
						Aviso("Aten��o","Registro n�o encontrado. Verifique os criterios de busca!",{"Fechar"})
						exit
					EndIf
				Endif
			Next
		Endif
	EndIf
Else
	Aviso("Aten��o","Informe pelo menos 3 caracteres, para busca!",{"Fechar"})
EndIf
Return

Static Function FiltroF3R(nLinha,aDados,cRetCpo)
cCodigo := aDados[nLinha,1]//aDados[nLinha,_nColuna]
//&(cRetCpo) := cCodigo //Uso desta forma para campos como tGet por exemplo.
//aCpoRet[1] := cCodigo //N�o esquecer de alimentar essa vari�vel quando for f3 pois ela e o retorno
CRETB1 := cCodigo
bRet := .T.
_oDlg:End()
Return

User Function SB1F3()//U_SB1F3()
Local cTitulo		:= "Produtos"
Local cQuery		:= "" 							//obrigatorio
Local cAlias		:= "SB1"						//obrigatorio
Local cCpoChave		:= "B1_COD" 					//obrigatorio
Local cTitCampo		:= RetTitle(cCpoChave)			//obrigatorio
Local cMascara		:= PesqPict(cAlias,cCpoChave)	//obrigatorio
Local nTamCpo		:= TamSx3(cCpoChave)[1]
Local cRetCpo		:= ReadVar()//"M->(C1_PRODUTO)"			//obrigatorio
Local nColuna		:= 1
Local cCodigo		:= Alltrim(&(ReadVar())) //M->&(C1_PRODUTO)				//pego o conteudo e levo para minha consulta padr�o
Private bRet 		:= .F.
Private cFil		:= U_FilXBSB1(2)

CRETB1 := &(ReadVar())
//Monto minha consulta, neste caso quero retornar apenas uma coluna, mas poderia inserir outros campos para compor outras colunas no grid, lembrando que n�o posso utilizar um alias para o nome do campo, deixar o nome real.
//Posso fazer qualquer tipo de consulta, usando INNER, GROUPY BY, UNION's etc..., desde que mantenha o nome dos campos no SELECT.
cQuery := " SELECT DISTINCT B1_COD,B1_DESC,B1_GRUPO " //,R_E_C_N_O_ AS B1_RECNO
cQuery += " FROM "+RetSQLName("SB1") + " AS SB1 " //WITH (NOLOCK)
cQuery += " WHERE B1_FILIAL  = '" + xFilial("SB1") + "' "
cQuery += " AND SB1.D_E_L_E_T_= ' ' "
If SB1->(FieldPos("B1_MSBLQL")) > 0
	cQuery += " AND B1_MSBLQL <> '1' OR B1_COD = '"+ALLTRIM(GetMV("MV_M110PRE"))+"' "
EndIf
If !Empty(cFil)
	cQuery += cFil
EndIf
cQuery += " ORDER BY B1_COD "

bRet := U_FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna)
DbSelectArea(cAlias)

Return(.T.)

User Function SB1F3RET()//U_SB1F3RET()
RETURN(CRETB1)
