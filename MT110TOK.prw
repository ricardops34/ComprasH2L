#INCLUDE "TOTVS.CH"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO7     �Autor  �Ricardo P Sotomayor � Data �  02/06/17   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Valida��o de preenchimento de Observa��o para Preproduto  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT110TOK()
Local _lRet   := PARAMIXB[1]
Local _aItens := PARAMIXB[2] //adA110Data
Local nCProd  := aScan(aHeader,{|x| Trim(x[2])=="C1_PRODUTO"})
Local nOBs    := aScan(aHeader,{|x| Trim(x[2])=="C1_OBS"})
Local nPItem  := aScan(aHeader,{|x| Trim(x[2])=="C1_ITEM"})
Local _cPreProd	:= GetMV("MV_M110PRE")
Local lDeleted

For nX := 1 To Len(aCols)
	If _lRet .And. ValType(aCols[nX,Len(aCols[nX])]) == "L"
		lDeleted := aCols[nX,Len(aCols[nX])]      // VerIfica se esta Deletado
	EndIf
	
	If _lRet .And. ( !lDeleted )
		If nOBs>0
			If AllTrim(aCols[nX][nCProd]) == Alltrim(_cPreProd)
				If Empty(Trim(aCols[nX][nOBs]))
					Aviso("Aten��o - MT110LOK","� Obrigat�rio Informar a descri��o do Pre-Produto no campo Observa��es. Verifique o item: "+AllTrim(aCols[nX][nPItem])+"!",{"Voltar"})
					_lRet:= .F.
				EndIf
			EndIf
		EndIf
	EndIF
Next
Return(_lRet)