#INCLUDE "TOTVS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT110LOK  �Autor  �Ricardo P Sotomayor � Data �  02/06/17   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o de preenchimento de Observa��o para Preproduto   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT110LOK()
Local _lRet   := PARAMIXB[1]
Local _aItens := PARAMIXB[2] //adA110Data
Local nCProd  := aScan(aHeader,{|x| Trim(x[2])=="C1_PRODUTO"})
Local nOBs    := aScan(aHeader,{|x| Trim(x[2])=="C1_OBS"})
Local _cPreProd	:= GetMV("MV_M110PRE")
Local lDeleted

If _lRet .And. ValType(aCols[n,Len(aCols[n])]) == "L"
	lDeleted := aCols[n,Len(aCols[n])]      // VerIfica se esta Deletado
EndIf

If _lRet .And. ( !lDeleted )
	If nOBs>0
		If AllTrim(aCols[n][nCProd]) == Alltrim(_cPreProd)
			If Empty(Trim(aCols[n][nOBs]))
				Aviso("Aten��o - MT110LOK","� Obrigat�rio Informar a descri��o do Pre-Produto no campo Observa��es!",{"Voltar"})
				_lRet:= .F.
			EndIf
		EndIf
	EndIF
EndIF

Return(_lRet)
