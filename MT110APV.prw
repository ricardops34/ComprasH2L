#INCLUDE "TOTVS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT110APV  �Autor  �Ricardo P Sotomayor � Data �  10/31/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � Filtro de Aprovadores de Solicita��o                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT110APV
Local lRet 		:= .T.
Local _aAprov := U_BJCOMP01()//Verifica se o usuario atual � aprovador de sc      

Local _lAprov := _aAprov[1]
Local _cUnida := _aAprov[2]
Local _lCompr	:= .f.
Local _cNumSC 	:= SC1->C1_NUM
Local aAReaSc1	:= SC1->(GetArea())
Local _cPreProd	:= GetMV("MV_M110PRE")
If GetMV("MV_USAM110")== "S"
	If _lAProv
		_lCompr := U_BJCOMP02()//Comprador()
		If _lCompr .And. RetCodUsr() == SC1->C1_USER
			Aviso("Aten��o - MT110APV","N�o � permitido o comprador aprovar a propria solicita��o.",{"Voltar"})
			lRet := .F.
		EndIf
		If lRet
			DbSelectArea("SC1")
			DbSetOrder(1)
			DbGoTop()
			If DbSeek(xFilial("SC1")+_cNumSC) 
				While SC1->(!Eof()) .And. SC1->(C1_FILIAL+C1_NUM)==xFilial("SC1")+_cNumSC .And. lRet
                    If Alltrim(SC1->C1_PRODUTO) == Alltrim(_cPreProd)
						Aviso("Aten��o - MT110APV","N�o � possivel aprovar solicota��o com Pr� Produto.",{"Voltar"})
						lRet := .f.
	                EndIF
					SC1->(DbSkip())
				End
			EndIF	
		EndIf
	Else
		Aviso("Aten��o - MT110APV","Voc� n�o � aprovador de Solicita��o de Compras.",{"Voltar"})
		lRet := .F.
	EndIf
EndIf                            
RestArea(aAReaSc1)
Return(lRet)
