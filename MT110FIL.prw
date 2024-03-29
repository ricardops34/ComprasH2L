#INCLUDE "TOTVS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT110FIL  �Autor  �Ricardo P Sotomayor � Data �  10/31/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � Filtrar Solicita�oes do usuario e grupo(C1_UNIDREQ)        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT110FIL()
Local cFiltro := ''
Local _aAprov := U_BJCOMP01()//Verifica se o usuario atual � aprovador de sc
Local _lAprov := _aAprov[1]
Local _cUnida := _aAprov[2]
Local _lCompr := U_BJCOMP02()//Verifica se o usuario atual � comprador
Local cPerg   := "MT110FIL"

Public _aDadosF3 	:= {}
Public _aDadosFil 	:= {}

AjustSx1(cPerg)

If GETMV("MV_USAM110") == "S"
	If GETMV("MV_FLMT110") == "S"
		If GETMV("MV_APROVSC")
			If RetCodUsr() <> "000000"
				
				Pergunte(cPerg,.T.)
				
				If _lAprov
					If !Empty(_cUnida)
						cFiltro += " C1_UNIDREQ == '"+_cUnida+"' "
					EndIf
				Else
					cFiltro += " C1_USER == '"+RetCodUsr()+"' "
				EndIf
				If !_lCompr   //PswAdmin(,,RetCodUsr())
					Set Key VK_F12 To // Desabilita F12 de cancelamento em lote de solicita�oes de compras
				EndIF
				
				
				If mv_par01 == 1
					cFiltro += IIf(!Empty(cFiltro),' .And. ','')+'C1_COTACAO == Space(Len(C1_COTACAO)) .And. C1_APROV $ " ,L"'
				ElseIf mv_par01 == 2
					cFiltro += IIf(!Empty(cFiltro),' .And. ','')+'C1_QUJE == C1_QUANT'
				EndIf
			EndIf
		EndIf
	EndIF
EndIf
Return (cFiltro)

Static Function AjustSx1(cPerg)

PutSx1( cPerg, "01","Lista Solicita�oes?","" ,"","mv_ch1","N" , 01,0,0,"C","",""   	,"","","mv_par01","Em Aberto","","","","Finalizadas","","","Todas"		,"","","","","","","","",{},{},{})

Return
