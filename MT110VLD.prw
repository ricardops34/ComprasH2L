#INCLUDE "TOTVS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT110VLD  �Autor  �Ricardo P Sotomayor � Data �  11/07/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � Mensagem de Confirma��o de Altera��o Copia                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT110VLD()
Local lRet := .T.
Local _nOpc:= Paramixb[1] //3- Inclus�o, 4- Altera��o, 8- Copia, 6- Exclus�o.
Local _aResp:= IIf(!lcopia ,{"Alterar","Cancelar"},{"Copiar","Cancelar"})
Local _aAprov := U_BJCOMP01()//Verifica se o usuario atual � aprovador de sc
Local _lAprov := _aAprov[1]
Local _cUnida := _aAprov[2]
Local _cNumSC 	:= SC1->C1_NUM
Local aAReaSc1	:= SC1->(GetArea())
Local _lCompr := U_BJCOMP02()//Comprador()
If GetMV("MV_USAM110")== "S"
	If _nOpc == 4 .Or. _nOpc == 8
		If _lCompr .Or. SC1->C1_USER == RetCodUsr() .Or. SC1->C1_UNIDREQ == _cUnida
			If Aviso("Aten��o - MT110VLD","Deseja "+IIf(!lcopia ,"Alterar","Copiar")+" a Solicita��o?",_aResp)== 2
				lRet := .F.
			EndIf          
		Else	
			Aviso("Aten��o - MT110VLD","A SC so poder ser Alterada pelo usuario ou area responsavel pela inclus�o",{"Voltar"})
			lRet := .F.
		EndIf
	ElseIf _nOpc == 6
		If !_lCompr//!_lAprov
			If !Empty(SC1->C1_UNIDREQ)
				If SC1->C1_UNIDREQ <> _cUnida
					Aviso("Aten��o - MT110VLD","A SC so poder ser Excluida pelo usuario ou area responsavel pela inclus�o",{"Voltar"})
					lRet := .F.
				EndIf
			ElseIf SC1->C1_USER <> RetCodUsr()
				Aviso("Aten��o - MT110VLD","A SC so poder ser Excluida pelo usuario ou area responsavel pela inclus�o",{"Voltar"})
				lRet := .F.
			EndIf
		EndIf
		If lRet
			DbSelectArea("SC1")
			DbSetOrder(1)
			DbGoTop()
			If DbSeek(xFilial("SC1")+_cNumSC)
				While SC1->(!Eof()) .And. SC1->(C1_FILIAL+C1_NUM)==xFilial("SC1")+_cNumSC
					
					If RecLock("SC1")
						SC1->C1_HISTMOV := U_MNTHIST(SC1->C1_HISTMOV,"Sc Excluida","E") //MNTHIST(cAtual,cAdd,cStatus)
						SC1->(MsUnlock())
					EndIF
					SC1->(DbSkip())
				End
			EndIF
		EndIf
		
	EndIf
EndIf
RestArea( aAReaSc1	)
Return(lRet)
