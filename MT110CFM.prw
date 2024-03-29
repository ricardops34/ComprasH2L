#INCLUDE "TOTVS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT110CFM  �Autor  �Ricardo P Sotomayor � Data �  11/01/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � PE para grava��o de Observa��o e campos adicionais apos    ���
���          � Aprova��o,Rejei��o ou Bloqueio                             ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT110CFM()
Local _cNumSC := PARAMIXB[1] //N�mero da Solicita��o de Compras
Local _nOpca  := PARAMIXB[2] //Cont�m a op��o selecionada: 1 = Aprovar; 2 = Rejeitar; 3 = Bloquear
Local _aArea	:= GetArea()
Local _aAreaSC1	:= SC1->(GetArea())
Private cJustifica	:= "",oJustifica,_nOpc := 0
Private cEOL   := CHR(13)+CHR(10)
Private _lJust := .F.
Private _nItem := 0
If GetMV("MV_USAM110")== "S"
	If SC1->(FieldPos("C1_DATAAPR")) > 0 .And. SC1->(FieldPos("C1_HORAAPR")) > 0
		Begin Transaction
		DbSelectArea("SC1")
		DbSetOrder(1)
		DbGoTop()
		If DbSeek(xFilial("SC1")+_cNumSC)
			While SC1->(!Eof()) .And. SC1->(C1_FILIAL+C1_NUM)==xFilial("SC1")+_cNumSC
				_nItem += 1
				If RecLock("SC1")
					SC1->C1_DATAAPR := Date()
					SC1->C1_HORAAPR := Substr(Time(),1,5)
					If SC1->(FieldPos("C1_HISTMOV")) > 0
						If _nOpca == 1  //1 = Aprovar //Legenda,Situa��o,Responsavel,Data,Motivo SC1->C1_APROV=='B'
							cJustifica := "Solicita��o de Compras Aprovada" +cEOL
							cJustifica += "Att, "+UsrFullName(RetCodUsr())+cEOL							
							
							SC1->C1_HISTMOV := U_MNTHIST(SC1->C1_HISTMOV,cJustifica,"A") //MNTHIST(cAtual,cAdd,cStatus)
							If _nItem == 1
								U_SC1NOTF("1",cJustifica,,'mata110.html')//cTipo,cMesagem,cDest)
							EndIf	
						ElseIf _nOpca == 2  //2 = Bloquear/Rejeitar
							If _nItem == 1
								cJustifica := "" //Iif(!Empty(SC1->C1_HISTMOV),SC1->C1_HISTMOV,cJustifica)
								cTitulo	:= "Rejei��o"
								While Empty(cJustifica)
									cJustifica := SC1JUST(cJustifica,cTitulo)
									If Empty(cJustifica)
										Aviso("Aten��o - MT110CFM","� Obrigat�rio Informar a Justificativa da Rejei��o!",{"Voltar"})
									EndIF
									_lJust := .t.
								End
								If !Empty(cJustifica) .And. _lJust
									cJustifica := strTRan(AllTrim(cJustifica),"|"," ")
								EndIf                                          
								U_SC1NOTF("2",cJustifica,,'mata110.html')//cTipo,cMesagem,cDest)
							EndIf
							//Legenda,Situa��o,Responsavel,Data,Motivo
							SC1->C1_HISTMOV := U_MNTHIST(SC1->C1_HISTMOV,cJustifica,"R") //MNTHIST(cAtual,cAdd,cStatus)
						ElseIf _nOpca == 3  //3 = Bloquear   //SC1->C1_APROV
							If _nItem == 1
								While Empty(cJustifica)
									cJustifica := "SC Devolvida para analise de l�der."+cEOL
									cTitulo	:= "Devolu��o"
									cJustifica := SC1JUST(cJustifica,cTitulo)
									If Empty(cJustifica)
										Aviso("Aten��o - MT110CFM","� Obrigat�rio Informar a Justificativa da Devolu��o!",{"Voltar"})
									EndIF
								End	
								U_SC1NOTF("3",cJustifica,,'mata110.html')//cTipo,cMesagem,cDest)
							EndIf	
							SC1->C1_HISTMOV := U_MNTHIST(SC1->C1_HISTMOV,cJustifica,"D") //MNTHIST(cAtual,cAdd,cStatus)
						EndIF
					EndIf
					SC1->(MsUnlock())
				EndIf
				SC1->(DbSkip())
			End
		EndIf
		End Transaction
	EndIf
EndIF
RestArea( _aArea )
RestArea( _aAreaSC1	)
Return Nil

Static Function SC1JUST(cJust,cTitulo)
Local oDlgJust,oConfir
Local nOpc	:= 0
Local cSitua := Iif(SC1->C1_APROV=='B',"Bloqueada",Iif(SC1->C1_APROV=='R',"Rejeitada",Iif(SC1->C1_APROV=='L',"Liberada","")))

//Local cJust := ""

DEFINE MSDIALOG oDlgJust TITLE "Justificativa - "+cTitulo FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL

@ 006, 004 SAY oSay1 PROMPT "Solicita��o:" SIZE 031, 007 OF oDlgJust COLORS 0, 16777215 PIXEL
@ 005, 037 MSGET oNumSc VAR SC1->C1_NUM SIZE 038, 010 OF oDlgJust COLORS 0, 16777215 WHEN .F. PIXEL

@ 006, 077 SAY oSay2 PROMPT "Solicitante:" SIZE 030, 007 OF oDlgJust COLORS 0, 16777215 PIXEL
@ 005, 109 MSGET oSolic VAR UsrFullName(SC1->C1_USER) SIZE 069, 010 OF oDlgJust COLORS 0, 16777215 WHEN .F. PIXEL

@ 006, 180 SAY oSay3 PROMPT "Data:" SIZE 014, 007 OF oDlgJust COLORS 0, 16777215 PIXEL
@ 005, 196 MSGET oData VAR SC1->C1_EMISSAO SIZE 049, 010 OF oDlgJust COLORS 0, 16777215 WHEN .F. PIXEL

@ 020, 004 SAY oSay4 PROMPT "Situa��o:" SIZE 025, 007 OF oDlgJust COLORS 0, 16777215 PIXEL
@ 018, 037 MSGET oSitua VAR cSitua SIZE 073, 010 OF oDlgJust COLORS 0, 16777215 WHEN .F. PIXEL

@ 032, 005 GET oMultiGe VAR cJust OF oDlgJust MULTILINE SIZE 239, 103 COLORS 0, 16777215 HSCROLL PIXEL

@ 135, 210 BUTTON oButton1 PROMPT "Confirma" SIZE 037, 012 OF oDlgJust Action(nOpc := 1,oDlgJust:end()) PIXEL
ACTIVATE MSDIALOG oDlgJust CENTERED

Return(cJust)