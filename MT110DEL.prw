#INCLUDE "TOTVS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT110DEL  �Autor  �Microsiga           � Data �  02/06/17   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT110DEL()
Local lRet := .T. 
Local _cNumSC 	:= SC1->C1_NUM
Local aAReaSc1	:= SC1->(GetArea())
Local _lCompr := U_BJCOMP02()//Comprador()
If GetMV("MV_USAM110")== "S" 
	If ValType(aCols[n,Len(aCols[n])]) == "L"
		lDeleted := aCols[n,Len(aCols[n])]      // VerIfica se esta Deletado
	EndIf
	If !lDeleted
		If !_lCompr 
			If SC1->C1_USER <> RetCodUsr() 
				If !Empty(SC1->C1_UNIDREQ)
					If SC1->C1_UNIDREQ <> _cUnida
						Aviso("Aten��o - MT110DEL","A Iten da SC so poder ser Excluida pelo usuario ou area responsavel pela inclus�o",{"Voltar"})
						lRet := .F.	
					EndIf
				EndIf	
			EndIf
		EndIf
	EndIf
EndIf	
Return(lRet)